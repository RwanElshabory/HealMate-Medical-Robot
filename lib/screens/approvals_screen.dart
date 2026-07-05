import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final approvals = [
      ApprovalItem(
        patientId: "PT-310",
        patientName: "Sara Ibrahim",
        room: "105",
        action: "Approve AI Treatment Plan",
        reason: "Skin image diagnosis: Chickenpox (Positive)",
        priority: ApprovalPriority.critical,
        time: "2 min ago",
        type: ApprovalType.treatmentPlan,
      ),
      ApprovalItem(
        patientId: "PT-311",
        patientName: "Youssef Ali",
        room: "210",
        action: "Dispense Paracetamol 500mg",
        reason: "Temperature: 38.4°C (Fever)",
        priority: ApprovalPriority.high,
        time: "8 min ago",
        type: ApprovalType.dispenseMedication,
      ),
      ApprovalItem(
        patientId: "PT-312",
        patientName: "Olivia Turner",
        room: "203",
        action: "Open Medicine Drawer",
        reason: "Deliver scheduled dose",
        priority: ApprovalPriority.medium,
        time: "15 min ago",
        type: ApprovalType.drawerControl,
      ),
      ApprovalItem(
        patientId: "PT-313",
        patientName: "Mariam Hassan",
        room: "118",
        action: "Approve Skin Diagnosis Report",
        reason: "Skin image captured by robot camera",
        priority: ApprovalPriority.low,
        time: "28 min ago",
        type: ApprovalType.diagnosisReport,
      ),
    ];

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
          "Robot Approvals",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        itemCount: approvals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _ApprovalCard(item: approvals[index]);
        },
      ),
    );
  }
}

/// =================== MODEL ===================

enum ApprovalPriority { critical, high, medium, low }
enum ApprovalType { treatmentPlan, dispenseMedication, drawerControl, diagnosisReport }

class ApprovalItem {
  final String patientId;
  final String patientName;
  final String room;
  final String action;
  final String reason;
  final ApprovalPriority priority;
  final String time;
  final ApprovalType type;

  ApprovalItem({
    required this.patientId,
    required this.patientName,
    required this.room,
    required this.action,
    required this.reason,
    required this.priority,
    required this.time,
    required this.type,
  });
}

/// =================== CARD ===================

class _ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  const _ApprovalCard({required this.item});

  Color _priorityColor(ApprovalPriority p) {
    switch (p) {
      case ApprovalPriority.critical:
        return const Color(0xFFE53935);
      case ApprovalPriority.high:
        return const Color(0xFFFF8F00);
      case ApprovalPriority.medium:
        return const Color(0xFF1E88E5);
      case ApprovalPriority.low:
        return const Color(0xFF43A047);
    }
  }

  String _priorityText(ApprovalPriority p) {
    switch (p) {
      case ApprovalPriority.critical:
        return "CRITICAL";
      case ApprovalPriority.high:
        return "HIGH";
      case ApprovalPriority.medium:
        return "MEDIUM";
      case ApprovalPriority.low:
        return "LOW";
    }
  }

  IconData _typeIcon(ApprovalType t) {
    switch (t) {
      case ApprovalType.treatmentPlan:
        return Icons.assignment_outlined;
      case ApprovalType.dispenseMedication:
        return Icons.medication_outlined;
      case ApprovalType.drawerControl:
        return Icons.inventory_2_outlined;
      case ApprovalType.diagnosisReport:
        return Icons.health_and_safety_outlined;
    }
  }

  void _openModifySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
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
                "Modify Suggestion",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _MiniInfoRow(
                icon: Icons.person_outline,
                title: "Patient",
                value: "${item.patientName} • Room ${item.room}",
              ),
              const SizedBox(height: 8),
              _MiniInfoRow(
                icon: _typeIcon(item.type),
                title: "Request",
                value: item.action,
              ),
              const SizedBox(height: 8),
              _MiniInfoRow(
                icon: Icons.info_outline,
                title: "Reason",
                value: item.reason,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type your adjustment notes here...",
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Modified (UI only)")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _priorityColor(item.priority);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.inputBackground.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_typeIcon(item.type), color: pColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Room ${item.room} • ${item.patientId}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Badge(text: _priorityText(item.priority), color: pColor),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground.withOpacity(0.65),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _MiniInfoRow(
                  icon: _typeIcon(item.type),
                  title: "Request",
                  value: item.action,
                ),
                const SizedBox(height: 8),
                _MiniInfoRow(
                  icon: Icons.info_outline,
                  title: "Reason",
                  value: item.reason,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: "Approve",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Approved (UI only)")),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openModifySheet(context),
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
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
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
            ],
          ),
        ],
      ),
    );
  }
}

/// =================== SMALL UI HELPERS ===================

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MiniInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 78,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
