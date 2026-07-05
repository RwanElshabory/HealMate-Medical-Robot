import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NurseTasksScreen extends StatefulWidget {
  const NurseTasksScreen({super.key});

  @override
  State<NurseTasksScreen> createState() => _NurseTasksScreenState();
}

class _NurseTasksScreenState extends State<NurseTasksScreen> {
  final List<_Task> _tasks = [
    _Task("Check vitals", "Room 203 • Ahmed Hassan"),
    _Task("Write patient note", "Room 206 • Olivia Turner"),
    _Task("Assist robot checkup", "Room 210 • Mona Ali", done: true),
    _Task("Prepare meds delivery", "06:00 PM • Mona Ali"),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.background;
    final remaining = _tasks.where((t) => !t.done).length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Today’s Tasks",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$remaining tasks remaining",
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return _TaskCard(
                    task: task,
                    onChanged: () => setState(() => task.done = !task.done),
                    onDelete: () => setState(() => _tasks.removeAt(index)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addTask() {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
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
                const Text("Add Task",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: "Task title",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subCtrl,
                  decoration: InputDecoration(
                    hintText: "Room / Patient / Time (optional)",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final t = titleCtrl.text.trim();
                      if (t.isEmpty) return;
                      setState(() => _tasks.insert(0, _Task(t, subCtrl.text.trim())));
                      Navigator.pop(context);
                    },
                    child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Task {
  final String title;
  final String subtitle;
  bool done;

  _Task(this.title, this.subtitle, {this.done = false});
}

class _TaskCard extends StatelessWidget {
  final _Task task;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _TaskCard({required this.task, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDone = task.done;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isDone ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(
            color: isDone ? const Color(0xFF2E7D32).withOpacity(0.25) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onChanged,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDone ? AppColors.primary : AppColors.textLight.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.85)),
            ),
          ],
        ),
      ),
    );
  }
}
