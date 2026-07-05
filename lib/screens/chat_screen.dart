import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:open_filex/open_filex.dart';

import '../constants/colors.dart';
import '../models/chat_message_model.dart';
import '../core/storage/secure_storage_service.dart';
import '../services/api/chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String avatarPath;
  final String subtitle;

  /// مهم جدًا للربط الحقيقي
  final int otherUserId;

  const ChatScreen({
    super.key,
    this.chatId = "default_chat",
    this.chatName = "Messages",
    this.avatarPath = "assets/images/patient_avatar.jpeg",
    this.subtitle = "Online",
    this.otherUserId = 0,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final ChatApiService _chatApiService = ChatApiService();

  late Box _box;
  late String _chatKey;

  List<HealChatMessage> _messages = [];
  bool _ready = false;
  bool _isSending = false;
  bool _isLoadingRemote = true;
  int _myUserId = 0;

  @override
  void initState() {
    super.initState();
    _chatKey = "chat_${widget.chatId}".replaceAll(" ", "_").toLowerCase();
    _initChat();
  }

  Future<void> _initChat() async {
    await _initHive();
    await _loadCurrentUserId();
    await _loadMessages();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen("chats_box")) {
      await Hive.initFlutter();
      _box = await Hive.openBox("chats_box");
    } else {
      _box = Hive.box("chats_box");
    }
  }

  Future<void> _loadCurrentUserId() async {
    final saved = await SecureStorageService.getUserId();
    _myUserId = int.tryParse(saved ?? '') ?? 0;
  }

  Future<void> _loadMessages() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingRemote = true;
          _ready = false;
        });
      }

      if (_myUserId > 0 && widget.otherUserId > 0) {
        final result = await _chatApiService.getHistory(_myUserId, widget.otherUserId);

        _messages = result.map((m) {
          return HealChatMessage(
            id: m.messageId,
            text: m.contentPath,
            isMe: m.senderId == _myUserId,
            createdAt: m.sentAt,
            seen: m.isRead || m.senderId == _myUserId,
          );
        }).toList();

        await _save();

        final unreadIds = result
            .where((m) => m.receiverId == _myUserId && !m.isRead)
            .map((m) => m.messageId)
            .toList();

        if (unreadIds.isNotEmpty) {
          await _chatApiService.markAsRead(unreadIds);
        }
      } else {
        final raw = (_box.get(_chatKey, defaultValue: []) as List);
        _messages = raw.map((e) => HealChatMessage.fromAny(e)).toList();

        if (_messages.isEmpty) {
          final now = DateTime.now();
          _messages = [
            HealChatMessage(
              text: "Hello doctor, I feel a bit dizzy today.",
              isMe: false,
              createdAt: now.subtract(const Duration(minutes: 18)),
            ),
            HealChatMessage(
              text: "Did the robot check your blood pressure?",
              isMe: true,
              createdAt: now.subtract(const Duration(minutes: 16)),
              seen: true,
            ),
            HealChatMessage(
              text: "Yes, it was slightly low.",
              isMe: false,
              createdAt: now.subtract(const Duration(minutes: 13)),
            ),
          ];
          await _save();
        }
      }
    } catch (_) {
      final raw = (_box.get(_chatKey, defaultValue: []) as List);
      _messages = raw.map((e) => HealChatMessage.fromAny(e)).toList();
    }

    _ready = true;
    _isLoadingRemote = false;

    if (mounted) setState(() {});
    _scrollToBottom(delayMs: 80);
  }

  Future<void> _save() async {
    await _box.put(_chatKey, _messages.map((e) => e.toMap()).toList());
  }

  void _scrollToBottom({int delayMs = 0}) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _time(DateTime dt) {
    final t = TimeOfDay.fromDateTime(dt);
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) return "Today";
    if (d == today.subtract(const Duration(days: 1))) return "Yesterday";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  Future<void> _sendText() async {
    final txt = _controller.text.trim();
    if (txt.isEmpty || _isSending) return;

    final tempMessage = HealChatMessage(
      text: txt,
      isMe: true,
      createdAt: DateTime.now(),
      seen: false,
    );

    setState(() {
      _isSending = true;
      _messages.add(tempMessage);
      _controller.clear();
    });

    _scrollToBottom(delayMs: 50);

    try {
      if (_myUserId > 0 && widget.otherUserId > 0) {
        final sent = await _chatApiService.sendMessage(
          senderId: _myUserId,
          receiverId: widget.otherUserId,
          message: txt,
        );

        final index = _messages.indexOf(tempMessage);
        if (index != -1) {
          _messages[index] = HealChatMessage(
            id: sent.messageId,
            text: sent.contentPath,
            isMe: true,
            createdAt: sent.sentAt,
            seen: true,
          );
        }
      }

      await _save();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<File> _copyToAppDir(File f, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File("${dir.path}/$name");
    return f.copy(dest.path);
  }

  Future<void> _openFile(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open this file on device.")),
      );
    }
  }

  Future<void> _attachImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source, imageQuality: 85);
    if (img == null) return;

    final copied = await _copyToAppDir(
      File(img.path),
      "img_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    setState(() {
      _messages.add(
        HealChatMessage(
          text: "Photo",
          isMe: true,
          createdAt: DateTime.now(),
          attachmentPath: copied.path,
          attachmentType: "image",
          seen: false,
        ),
      );
    });

    await _save();
    _scrollToBottom(delayMs: 60);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image attached locally only. Backend upload API is still missing."),
      ),
    );
  }

  Future<void> _attachFile() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'documents',
      extensions: <String>[
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt',
        'png',
        'jpg',
        'jpeg'
      ],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) return;

    final p = file.path;
    final safeName = file.name.replaceAll(" ", "_");

    final copied = await _copyToAppDir(
      File(p),
      "file_${DateTime.now().millisecondsSinceEpoch}_$safeName",
    );

    setState(() {
      _messages.add(
        HealChatMessage(
          text: file.name,
          isMe: true,
          createdAt: DateTime.now(),
          attachmentPath: copied.path,
          attachmentType: "file",
          seen: false,
        ),
      );
    });

    await _save();
    _scrollToBottom(delayMs: 60);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("File attached locally only. Backend upload API is still missing."),
      ),
    );
  }

  void _openAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Attach",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AttachAction(
                      icon: Icons.photo_outlined,
                      label: "Gallery",
                      onTap: () async {
                        Navigator.pop(context);
                        await _attachImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AttachAction(
                      icon: Icons.photo_camera_outlined,
                      label: "Camera",
                      onTap: () async {
                        Navigator.pop(context);
                        await _attachImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AttachAction(
                icon: Icons.insert_drive_file_outlined,
                label: "File (PDF, doc, ...)",
                onTap: () async {
                  Navigator.pop(context);
                  await _attachFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            _MenuItem(
              icon: Icons.search,
              title: "Search in chat",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Search (next step)")),
                );
              },
            ),
            _MenuItem(
              icon: Icons.notifications_off_outlined,
              title: "Mute",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Muted (UI)")),
                );
              },
            ),
            _MenuItem(
              icon: Icons.delete_outline,
              title: "Clear chat",
              danger: true,
              onTap: () async {
                Navigator.pop(context);
                setState(() => _messages.clear());
                await _save();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.inputBackground.withOpacity(0.6),
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                name: widget.chatName,
                subtitle: widget.subtitle,
                avatarPath: widget.avatarPath,
                onCall: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Call action (next step)")),
                  );
                },
                onMore: _openMoreMenu,
              ),
              Expanded(
                child: !_ready || _isLoadingRemote
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];

                    final showDaySeparator = index == 0 ||
                        !_isSameDay(_messages[index - 1].createdAt, m.createdAt);

                    return Column(
                      children: [
                        if (showDaySeparator)
                          _DaySeparator(text: _dayLabel(m.createdAt)),
                        _TextMessageRow(
                          isMe: m.isMe,
                          time: _time(m.createdAt),
                          seen: m.seen,
                          msg: m,
                          onOpenAttachment: (path) => _openFile(path),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _InputBar(
                controller: _controller,
                onAttach: _openAttachSheet,
                onSend: _sendText,
                isSending: _isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatarPath;
  final VoidCallback onCall;
  final VoidCallback onMore;

  const _Header({
    required this.name,
    required this.subtitle,
    required this.avatarPath,
    required this.onCall,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          CircleAvatar(radius: 20, backgroundImage: AssetImage(avatarPath)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIcon(icon: Icons.call, onTap: onCall),
          const SizedBox(width: 8),
          _HeaderIcon(icon: Icons.more_horiz, onTap: onMore),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  final String text;

  const _DaySeparator({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12.withOpacity(0.06)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TextMessageRow extends StatelessWidget {
  final bool isMe;
  final String time;
  final bool seen;
  final HealChatMessage msg;
  final void Function(String path) onOpenAttachment;

  const _TextMessageRow({
    required this.isMe,
    required this.time,
    required this.seen,
    required this.msg,
    required this.onOpenAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final cross = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.white : AppColors.inputBackground;

    return Align(
      alignment: align,
      child: Container(
        margin: EdgeInsets.fromLTRB(isMe ? 60 : 0, 6, isMe ? 0 : 60, 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: cross,
          children: [
            if (msg.attachmentPath != null && msg.attachmentType == "image")
              InkWell(
                onTap: () => onOpenAttachment(msg.attachmentPath!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(msg.attachmentPath!),
                    height: 160,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (msg.attachmentPath != null)
              InkWell(
                onTap: () => onOpenAttachment(msg.attachmentPath!),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 180,
                      child: Text(
                        msg.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Icon(
                    seen ? Icons.done_all : Icons.done,
                    size: 14,
                    color: seen ? Colors.green : AppColors.textLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final bool isSending;

  const _InputBar({
    required this.controller,
    required this.onAttach,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach,
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Write here...",
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: isSending ? null : onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSending
                  ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool danger;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = danger ? Colors.redAccent : AppColors.textDark;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c),
      title: Text(
        title,
        style: TextStyle(color: c, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class HealChatMessage {
  final int? id;
  final String text;
  final bool isMe;
  final DateTime createdAt;
  bool seen;
  String? attachmentPath;
  String? attachmentType;

  HealChatMessage({
    this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
    this.seen = false,
    this.attachmentPath,
    this.attachmentType,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "text": text,
    "isMe": isMe,
    "createdAt": createdAt.toIso8601String(),
    "seen": seen,
    "attachmentPath": attachmentPath,
    "attachmentType": attachmentType,
  };

  factory HealChatMessage.fromMap(Map<String, dynamic> m) => HealChatMessage(
    id: m["id"],
    text: (m["text"] ?? "").toString(),
    isMe: (m["isMe"] ?? false) as bool,
    createdAt: DateTime.tryParse((m["createdAt"] ?? "").toString()) ?? DateTime.now(),
    seen: (m["seen"] ?? false) as bool,
    attachmentPath: m["attachmentPath"],
    attachmentType: m["attachmentType"],
  );

  factory HealChatMessage.fromAny(dynamic e) {
    if (e is Map) return HealChatMessage.fromMap(Map<String, dynamic>.from(e));
    return HealChatMessage(text: "Message", isMe: false, createdAt: DateTime.now());
  }
}