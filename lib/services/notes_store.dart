import 'package:flutter/foundation.dart';

class PatientNote {
  final String id;
  final String patientId;
  final String authorName; // e.g. Nurse Sara
  final String text;
  final DateTime createdAt;
  bool visibleToPatient;

  PatientNote({
    required this.id,
    required this.patientId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    required this.visibleToPatient,
  });
}

class NotesStore extends ChangeNotifier {
  NotesStore._();
  static final NotesStore instance = NotesStore._();

  final List<PatientNote> _notes = [];

  List<PatientNote> notesFor(String patientId) {
    return _notes.where((n) => n.patientId == patientId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<PatientNote> visibleNotesForPatient(String patientId) {
    return notesFor(patientId).where((n) => n.visibleToPatient).toList();
  }

  void addNote({
    required String patientId,
    required String authorName,
    required String text,
    required bool visibleToPatient,
  }) {
    final n = PatientNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      patientId: patientId,
      authorName: authorName,
      text: text,
      createdAt: DateTime.now(),
      visibleToPatient: visibleToPatient,
    );
    _notes.insert(0, n);
    notifyListeners();
  }

  void toggleVisibility(String noteId) {
    final i = _notes.indexWhere((n) => n.id == noteId);
    if (i == -1) return;
    _notes[i].visibleToPatient = !_notes[i].visibleToPatient;
    notifyListeners();
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
  }
}
