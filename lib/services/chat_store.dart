import 'package:flutter/foundation.dart';

enum ChatSender { nurse, patient }

class ChatMessage {
  final String id;
  final String patientId; // conversation key
  final ChatSender sender;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.patientId,
    required this.sender,
    required this.text,
    required this.time,
  });
}

class ChatStore extends ChangeNotifier {
  ChatStore._();
  static final ChatStore instance = ChatStore._();

  final Map<String, List<ChatMessage>> _threads = {};

  List<ChatMessage> thread(String patientId) {
    return (_threads[patientId] ?? <ChatMessage>[]).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  void send({
    required String patientId,
    required ChatSender sender,
    required String text,
  }) {
    final t = text.trim();
    if (t.isEmpty) return;

    final msg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      patientId: patientId,
      sender: sender,
      text: t,
      time: DateTime.now(),
    );

    _threads.putIfAbsent(patientId, () => <ChatMessage>[]);
    _threads[patientId]!.add(msg);
    notifyListeners();
  }

  void seedIfEmpty(String patientId) {
    _threads.putIfAbsent(patientId, () => <ChatMessage>[]);
    if (_threads[patientId]!.isNotEmpty) return;
    _threads[patientId]!.addAll([
      ChatMessage(
        id: "seed1",
        patientId: patientId,
        sender: ChatSender.nurse,
        text: "Hi 👋 I’m your nurse. I’ll follow up with your daily checkups.",
        time: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        id: "seed2",
        patientId: patientId,
        sender: ChatSender.patient,
        text: "Thanks. I have a mild fever today.",
        time: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ]);
    notifyListeners();
  }
}
