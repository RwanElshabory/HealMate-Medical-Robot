import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/notes_store.dart';

class NursePatientNotesScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const NursePatientNotesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<NursePatientNotesScreen> createState() => _NursePatientNotesScreenState();
}

class _NursePatientNotesScreenState extends State<NursePatientNotesScreen> {
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

  void _addNoteSheet() {
    final ctrl = TextEditingController();
    bool visible = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Add Note • ${widget.patientName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ctrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write clinical note / instructions…",
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Visible to patient",
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                          ),
                        ),
                        Switch(
                          value: visible,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setLocal(() => visible = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final t = ctrl.text.trim();
                          if (t.isEmpty) return;

                          NotesStore.instance.addNote(
                            patientId: widget.patientId,
                            authorName: "Nurse Sara Ahmed",
                            text: t,
                            visibleToPatient: visible,
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Note added")),
                          );
                        },
                        child: const Text(
                          "Add Note",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, "0");
    final m = d.minute.toString().padLeft(2, "0");
    return "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}  $h:$m";
  }

  @override
  Widget build(BuildContext context) {
    final notes = NotesStore.instance.notesFor(widget.patientId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Patient Notes",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _addNoteSheet,
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addNoteSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.sticky_note_2_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "${notes.length} notes",
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (notes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("No notes yet", style: TextStyle(color: AppColors.textLight)),
              ),
            ),

          ...notes.map((n) {
            final badgeColor = n.visibleToPatient ? const Color(0xFF2E7D32) : const Color(0xFF607D8B);
            final badgeText = n.visibleToPatient ? "Visible" : "Private";

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                        child: Text(
                          badgeText,
                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fmt(n.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    n.text,
                    style: const TextStyle(color: AppColors.textDark, height: 1.35, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => NotesStore.instance.toggleVisibility(n.id),
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                        label: const Text(
                          "Toggle visibility",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => NotesStore.instance.deleteNote(n.id),
                        icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.85)),
                      ),
                    ],
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
