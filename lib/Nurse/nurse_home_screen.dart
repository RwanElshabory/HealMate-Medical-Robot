import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'nurse_robot_assist_screen.dart';

// Shared screens
import '../screens/monitoring_dashboard_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/robot_control_screen.dart';

// Nurse screens (YOUR structure)
import 'nurse_patients_screen.dart';
import 'nurse_tasks_screen.dart';
import 'nurse_profile_screen.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  int _currentIndex = 0;

  void _openTab(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _NurseDashboardTab(
        onOpenPatients: () => _openTab(1),
        onOpenTasks: () => _openTab(2),
        onOpenProfile: () => _openTab(3),
      ),
      const NursePatientsScreen(),
      const NurseTasksScreen(),
      const NurseProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _NurseBottomNav(
        currentIndex: _currentIndex,
        onTap: _openTab,
      ),
    );
  }
}

/// ================= HOME (Dashboard) =================

class _NurseDashboardTab extends StatelessWidget {
  final VoidCallback onOpenPatients;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenProfile;

  const _NurseDashboardTab({
    required this.onOpenPatients,
    required this.onOpenTasks,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data (later connect to your services/models)
    const assignedPatientsCount = 12;
    const pendingTasksCount = 5;
    const activeAlertsCount = 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NurseHeader(
            onTapProfile: onOpenProfile,
            onTapAlerts: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
            },
          ),
          const SizedBox(height: 18),

          // ===== Overview =====
          Row(
            children: const [
              Expanded(child: _StatCard(number: "$assignedPatientsCount", label: "Assigned Patients")),
              SizedBox(width: 8),
              Expanded(child: _StatCard(number: "$pendingTasksCount", label: "Pending Tasks")),
              SizedBox(width: 8),
              Expanded(child: _StatCard(number: "$activeAlertsCount", label: "Active Alerts", highlight: true)),
            ],
          ),

          const SizedBox(height: 22),

          // ===== Nurse Role Quick Actions =====
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // Main nurse actions: Patients / Tasks (execution) + Vitals / Alerts (monitoring)
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: Icons.people_outline,
                  title: "Patients",
                  subtitle: "Chat • Notes",
                  onTap: onOpenPatients,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickTile(
                  icon: Icons.checklist_outlined,
                  title: "Tasks",
                  subtitle: "Today plan",
                  onTap: onOpenTasks,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: Icons.monitor_heart_outlined,
                  title: "Vitals",
                  subtitle: "Check readings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MonitoringDashboardScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickTile(
                  icon: Icons.notifications_none,
                  title: "Alerts",
                  subtitle: "Review & act",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Optional: nurse can assist robot operation (NOT treatment decisions)
          GradientButton(
            text: "Robot Assist",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NurseRobotAssistScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // ===== Assigned Patients Preview =====
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Assigned Patients",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenPatients,
                child: const Text(
                  "View all",
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const _AssignedPatientCard(
            name: "Ahmed Hassan",
            note: "Post-op • Room 203",
            status: "Stable",
            risk: "Low",
          ),
          const _AssignedPatientCard(
            name: "Mona Ali",
            note: "Diabetes • Room 210",
            status: "BP check every 4h",
            risk: "Medium",
          ),
          const _AssignedPatientCard(
            name: "Olivia Turner",
            note: "Chickenpox • Room 206",
            status: "Fever + rash",
            risk: "High",
          ),

          const SizedBox(height: 10),

          // Tip card to match nurse role
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: AppColors.inputBackground.withOpacity(0.7)),
            ),
            child: Row(
              children: const [
                Icon(Icons.sticky_note_2_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Tip: Open a patient → write Notes (patient can see) or start Chat.",
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NurseHeader extends StatelessWidget {
  final VoidCallback onTapAlerts;
  final VoidCallback onTapProfile;

  const _NurseHeader({
    required this.onTapAlerts,
    required this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTapProfile,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage("assets/images/nurse.jpg"),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good Morning", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              SizedBox(height: 2),
              Text(
                "Nurse Sara Ahmed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Monitoring • Notes • Tasks",
                style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onTapAlerts,
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final bool highlight;

  const _StatCard({required this.number, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: highlight ? Colors.red : AppColors.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: highlight ? Colors.red : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppColors.inputBackground.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _AssignedPatientCard extends StatelessWidget {
  final String name;
  final String note;
  final String status;
  final String risk;

  const _AssignedPatientCard({
    required this.name,
    required this.note,
    required this.status,
    required this.risk,
  });

  Color _riskColor(String r) {
    switch (r.toLowerCase()) {
      case "high":
        return const Color(0xFFE53935);
      case "medium":
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor(risk);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/patient_avatar.jpeg"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(note, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: rc.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Text(
              "$risk risk",
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: rc),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= BOTTOM NAV =================

class _NurseBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NurseBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.home_filled, index: 0, currentIndex: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.people_outline, index: 1, currentIndex: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.checklist_outlined, index: 2, currentIndex: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.person_outline, index: 3, currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.index, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Icon(icon, size: 24, color: isActive ? AppColors.primary : AppColors.textLight),
    );
  }
}
