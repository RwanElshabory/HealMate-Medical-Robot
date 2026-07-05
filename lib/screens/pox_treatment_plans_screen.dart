import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PoxTreatmentPlansScreen extends StatefulWidget {
  const PoxTreatmentPlansScreen({super.key});

  @override
  State<PoxTreatmentPlansScreen> createState() => _PoxTreatmentPlansScreenState();
}

class _PoxTreatmentPlansScreenState extends State<PoxTreatmentPlansScreen> {
  String _filter = "All"; // All / Pending / Active / Completed

  // ✅ Robot drawer state (UI simulation)
  bool _drawerOpen = false;

  // ✅ Demo data (بدّليها بعدين بالـ API)
  final List<_PoxPlanModel> _plans = [
    _PoxPlanModel(
      patientName: "Sara Ibrahim",
      patientImage: "assets/images/patient_avatar.jpeg",
      room: "105",
      diagnosisType: PoxType.chickenpox,
      diagnosisResult: "Positive",
      confidence: 0.91,
      planTitle: "AI Suggested Plan",
      planDetails:
      "• Isolation & hydration\n"
          "• Paracetamol if fever\n"
          "• Itch relief + skin care\n"
          "• Doctor review required",
      status: "Pending",
      lastUpdated: "Today",
      source: "Robot AI",
      hasSkinImage: true,
    ),
    _PoxPlanModel(
      patientName: "Ahmed Nour",
      patientImage: "assets/images/patient_avatar.jpeg",
      room: "206",
      diagnosisType: PoxType.monkeypox,
      diagnosisResult: "Positive",
      confidence: 0.87,
      planTitle: "AI Suggested Plan",
      planDetails:
      "• Contact precautions\n"
          "• Symptom control + hydration\n"
          "• Consider antiviral per protocol\n"
          "• Doctor review required",
      status: "Pending",
      lastUpdated: "Today",
      source: "Robot AI",
      hasSkinImage: true,
    ),
    _PoxPlanModel(
      patientName: "Olivia Turner",
      patientImage: "assets/images/patient_avatar.jpeg",
      room: "203",
      diagnosisType: PoxType.unknown,
      diagnosisResult: "Positive",
      confidence: 0.62,
      planTitle: "AI Suggested Plan",
      planDetails:
      "• Treat as suspected case\n"
          "• Re-check skin images\n"
          "• Lab confirmation recommended\n"
          "• Doctor review required",
      status: "Pending",
      lastUpdated: "Today",
      source: "Robot AI",
      hasSkinImage: true,
    ),
  ];

  List<_PoxPlanModel> get _filteredPlans {
    final list = _filter == "All"
        ? _plans
        : _plans.where((p) => p.status == _filter).toList();
    return list;
  }

  // ================= Drawer Control (Auto) =================

  void _openDrawer() {
    if (_drawerOpen) return;
    setState(() => _drawerOpen = true);
    debugPrint("OPEN medicine drawer");
    // TODO: robotService.openDrawer();
  }

  void _closeDrawer() {
    if (!_drawerOpen) return;
    setState(() => _drawerOpen = false);
    debugPrint("CLOSE medicine drawer");
    // TODO: robotService.closeDrawer();
  }

  void _openDrawerThenAutoClose() {
    _openDrawer();
    Timer(const Duration(seconds: 30), () {
      // لو المستخدم خرج من الشاشة مايحصلش crash
      if (!mounted) return;
      _closeDrawer();
    });
  }

  // ================= Bottom Sheet =================

  void _openPlanSheet(_PoxPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.70,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(plan.patientImage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.patientName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Room ${plan.room} • ${plan.source}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(status: plan.status),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _DiagnosisRow(plan: plan),

                  const SizedBox(height: 12),

                  if (plan.hasSkinImage) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Skin image attached from robot camera",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    plan.planTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      plan.planDetails,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Last updated: ${plan.lastUpdated}",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textLight.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Doctor Review actions
                  if (plan.status == "Pending") ...[
                    const Text(
                      "Doctor Review",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() => plan.status = "Active");

                              // ✅ Auto open drawer then close in 30s
                              _openDrawerThenAutoClose();

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Approved • Drawer opened (auto close in 30s)"),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "Approve",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                    content: Text("Modify (placeholder)")),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.primary),
                            label: const Text(
                              "Modify",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => plan.status = "Completed");
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text("Declined (UI only)")),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE53935)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFFE53935)),
                        label: const Text(
                          "Decline",
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side:
                        const BorderSide(color: AppColors.primary, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = _filteredPlans;

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
          "Pox Diagnosis & Plans",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _DrawerChip(isOpen: _drawerOpen),
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Filters =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: "All",
                    isActive: _filter == "All",
                    onTap: () => setState(() => _filter = "All"),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: "Pending",
                    isActive: _filter == "Pending",
                    onTap: () => setState(() => _filter = "Pending"),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: "Active",
                    isActive: _filter == "Active",
                    onTap: () => setState(() => _filter = "Active"),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: "Completed",
                    isActive: _filter == "Completed",
                    onTap: () => setState(() => _filter = "Completed"),
                  ),
                ],
              ),
            ),
          ),

          // ===== List =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _PlanCard(
                  plan: plan,
                  onTap: () => _openPlanSheet(plan),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =================== UI ===================

class _DiagnosisRow extends StatelessWidget {
  final _PoxPlanModel plan;
  const _DiagnosisRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    final diagColor =
    plan.diagnosisResult == "Positive" ? Colors.deepPurple : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.biotech_outlined, color: diagColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${plan.diagnosisType.label} • ${plan.diagnosisResult} • ${(plan.confidence * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerChip extends StatelessWidget {
  final bool isOpen;
  const _DrawerChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final c = isOpen ? Colors.green : Colors.grey;
    final txt = isOpen ? "Drawer Open" : "Drawer Closed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBackground),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 16, color: c),
          const SizedBox(width: 6),
          Text(
            txt,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.inputBackground,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PoxPlanModel plan;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diagColor =
    plan.diagnosisResult == "Positive" ? Colors.deepPurple : Colors.grey;

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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(plan.patientImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.patientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Room ${plan.room}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${plan.diagnosisType.label} • ${(plan.confidence * 100).toStringAsFixed(0)}%",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: diagColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.planTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: plan.status),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    size: 26, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color c = status == "Active"
        ? Colors.green
        : status == "Pending"
        ? Colors.orange
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: c,
        ),
      ),
    );
  }
}

// =================== MODEL ===================

enum PoxType { chickenpox, monkeypox, smallpox, unknown }

extension PoxTypeLabel on PoxType {
  String get label {
    switch (this) {
      case PoxType.chickenpox:
        return "Chickenpox (Varicella)";
      case PoxType.monkeypox:
        return "Mpox (Monkeypox)";
      case PoxType.smallpox:
        return "Smallpox (Variola)";
      case PoxType.unknown:
        return "Uncertain";
    }
  }
}

class _PoxPlanModel {
  final String patientName;
  final String patientImage;
  final String room;

  final PoxType diagnosisType;
  final String diagnosisResult; // Positive / Negative
  final double confidence;

  final String planTitle;
  final String planDetails;

  String status; // Pending / Active / Completed
  final String lastUpdated;

  final String source; // Robot AI
  final bool hasSkinImage;

  _PoxPlanModel({
    required this.patientName,
    required this.patientImage,
    required this.room,
    required this.diagnosisType,
    required this.diagnosisResult,
    required this.confidence,
    required this.planTitle,
    required this.planDetails,
    required this.status,
    required this.lastUpdated,
    required this.source,
    required this.hasSkinImage,
  });
}
