import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/chat_store.dart';

class NursePatientChatScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const NursePatientChatScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<NursePatientChatScreen> createState() => _NursePatientChatScreenState();
}

class _NursePatientChatScreenState extends State<NursePatientChatScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChatStore.instance.seedIfEmpty(widget.patientId);
    ChatStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ChatStore.instance.removeListener(_refresh);
    _ctrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _send() {
    ChatStore.instance.send(
      patientId: widget.patientId,
      sender: ChatSender.nurse,
      text: _ctrl.text,
    );
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ChatStore.instance.thread(widget.patientId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.patientName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Nurse ↔ Patient",
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                final mine = m.sender == ChatSender.nurse;

                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: mine ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: mine ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -6)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: "Type a message…",
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _send,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
