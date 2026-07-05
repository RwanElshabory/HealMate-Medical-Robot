import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/notes_store.dart';

class PatientNotesScreen extends StatefulWidget {
  final String patientId;

  const PatientNotesScreen({super.key, required this.patientId});

  @override
  State<PatientNotesScreen> createState() => _PatientNotesScreenState();
}

class _PatientNotesScreenState extends State<PatientNotesScreen> {
  @override
  void initState() {
    super.initState();
    NotesStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    NotesStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, "0");
    final m = d.minute.toString().padLeft(2, "0");
    return "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}  $h:$m";
  }

  @override
  Widget build(BuildContext context) {
    final notes = NotesStore.instance.visibleNotesForPatient(widget.patientId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Nurse Notes",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        children: [
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text("No notes available yet", style: TextStyle(color: AppColors.textLight)),
              ),
            ),
          ...notes.map((n) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text(_fmt(n.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 10),
                  Text(
                    n.text,
                    style: const TextStyle(color: AppColors.textDark, height: 1.35, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
