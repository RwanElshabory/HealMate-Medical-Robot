import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/colors.dart';

class PatientTreatmentPlansScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String avatarPath;

  const PatientTreatmentPlansScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.avatarPath,
  });

  @override
  State<PatientTreatmentPlansScreen> createState() =>
      _PatientTreatmentPlansScreenState();
}

class _PatientTreatmentPlansScreenState extends State<PatientTreatmentPlansScreen> {
  late Box _box;
  late String _key;
  List<TreatmentPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _key = "plans_${widget.patientId}".toLowerCase();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox("plans_box");

    final raw = _box.get(_key, defaultValue: []) as List;
    _plans = raw.map((e) => TreatmentPlan.fromAny(e)).toList();

    // seed لأول مرة
    if (_plans.isEmpty) {
      _plans = [
        TreatmentPlan(
          title: "Metformin Plan",
          details: "Metformin 500mg — 2x daily after meals.\nFollow-up in 7 days.",
          status: PlanStatus.active,
          createdAt: DateTime.now(),
        ),
      ];
      await _save();
    }

    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    await _box.put(_key, _plans.map((e) => e.toMap()).toList());
  }

  void _addPlanSheet() {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    PlanStatus status = PlanStatus.active;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
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
              const SizedBox(height: 12),
              const Text(
                "New Treatment Plan",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _Field(hint: "Plan title", controller: titleCtrl),
              const SizedBox(height: 10),
              _Field(
                hint: "Plan details (meds, dosage, notes...)",
                controller: detailsCtrl,
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Status:",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<PlanStatus>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: PlanStatus.active, child: Text("Active")),
                      DropdownMenuItem(value: PlanStatus.pending, child: Text("Pending")),
                      DropdownMenuItem(value: PlanStatus.completed, child: Text("Completed")),
                    ],
                    onChanged: (v) => setState(() => status = v ?? PlanStatus.active),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final t = titleCtrl.text.trim();
                    final d = detailsCtrl.text.trim();
                    if (t.isEmpty || d.isEmpty) return;

                    setState(() {
                      _plans.insert(
                        0,
                        TreatmentPlan(
                          title: t,
                          details: d,
                          status: status,
                          createdAt: DateTime.now(),
                        ),
                      );
                    });
                    await _save();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    "Save Plan",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlanActions(TreatmentPlan p, int index) {
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
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text("Mark as Completed"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _plans[index] = p.copyWith(status: PlanStatus.completed));
                  await _save();
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Colors.orange),
                title: const Text("Mark as Pending"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _plans[index] = p.copyWith(status: PlanStatus.pending));
                  await _save();
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                title: const Text("Mark as Active"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _plans[index] = p.copyWith(status: PlanStatus.active));
                  await _save();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text("Delete plan"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _plans.removeAt(index));
                  await _save();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: const Text(
          "Treatment Plans",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addPlanSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          children: [
            _PatientHeader(
              name: widget.patientName,
              avatarPath: widget.avatarPath,
              subtitle: "Plans linked to this patient",
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final p = _plans[index];
                  return _PlanCard(
                    plan: p,
                    onTap: () => _openPlanActions(p, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== UI Widgets =====
class _PatientHeader extends StatelessWidget {
  final String name;
  final String avatarPath;
  final String subtitle;

  const _PatientHeader({
    required this.name,
    required this.avatarPath,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundImage: AssetImage(avatarPath)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Patient",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final TreatmentPlan plan;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(plan.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                badge,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.details,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Created: ${_date(plan.createdAt)}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statusBadge(PlanStatus s) {
    late Color c;
    late String t;
    switch (s) {
      case PlanStatus.active:
        c = Colors.green;
        t = "ACTIVE";
        break;
      case PlanStatus.pending:
        c = Colors.orange;
        t = "PENDING";
        break;
      case PlanStatus.completed:
        c = Colors.blueGrey;
        t = "COMPLETED";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: c,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _Field({
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ===== Model =====
enum PlanStatus { active, pending, completed }

class TreatmentPlan {
  final String title;
  final String details;
  final PlanStatus status;
  final DateTime createdAt;

  TreatmentPlan({
    required this.title,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  TreatmentPlan copyWith({PlanStatus? status}) => TreatmentPlan(
    title: title,
    details: details,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "details": details,
    "status": status.name,
    "createdAt": createdAt.toIso8601String(),
  };

  factory TreatmentPlan.fromMap(Map<String, dynamic> m) => TreatmentPlan(
    title: (m["title"] ?? "").toString(),
    details: (m["details"] ?? "").toString(),
    status: PlanStatus.values.firstWhere(
          (e) => e.name == (m["status"] ?? "active"),
      orElse: () => PlanStatus.active,
    ),
    createdAt: DateTime.tryParse((m["createdAt"] ?? "").toString()) ??
        DateTime.now(),
  );

  factory TreatmentPlan.fromAny(dynamic e) {
    if (e is Map) return TreatmentPlan.fromMap(Map<String, dynamic>.from(e));
    return TreatmentPlan(
      title: "Plan",
      details: "Details",
      status: PlanStatus.active,
      createdAt: DateTime.now(),
    );
  }
}

String _date(DateTime d) =>
    "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
