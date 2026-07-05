import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'patient_vitals_screen.dart';
import 'patient_medications_screen.dart';
import 'patient_plan_screen.dart';
import 'patient_alerts_screen.dart';
import 'patient_chat_screen.dart';
import '../screens/patient_profile_screen.dart';
import '../screens/patient_account_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _PatientDashboardTab(),
      const _PatientHealthTab(),
      const PatientChatScreen(),
      const PatientAccountScreen(), // ✅ بدل PatientProfileScreen
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: _PatientBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

/// ================= Dashboard Tab =================

class _PatientDashboardTab extends StatelessWidget {
  const _PatientDashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PatientHeader(),
          const SizedBox(height: 18),

          // ✅ Updated cards (Robot-based) + overflow-safe
          const _PatientTodayCards(),
          const SizedBox(height: 22),

          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: "My Checkups",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientVitalsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: "Medications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientMedicationsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GradientButton(
            text: "My Treatment Plan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientPlanScreen()),
              );
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _OutlineQuickButton(
                  icon: Icons.notifications_none,
                  text: "Alerts",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientAlertsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OutlineQuickButton(
                  icon: Icons.chat_bubble_outline,
                  text: "Chat",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientChatScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Today Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          const _InfoCard(
            title: "Next Robot Checkup",
            subtitle: "Temperature + Skin Scan • 08:00 PM",
            icon: Icons.smart_toy_outlined,
          ),
          const _InfoCard(
            title: "Next Medication Delivery",
            subtitle: "Paracetamol • 06:00 PM",
            icon: Icons.medication_outlined,
          ),
          const _InfoCard(
            title: "Doctor Review Status",
            subtitle: "Treatment plan pending approval",
            icon: Icons.verified_outlined,
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage("assets/images/patient_avatar.jpeg"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning",
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              SizedBox(height: 2),
              Text(
                "Patient Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientAlertsScreen()),
            );
          },
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
      ],
    );
  }
}

/// ✅ Updated Today Cards (overflow-safe + more professional)
class _PatientTodayCards extends StatelessWidget {
  const _PatientTodayCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.thermostat_rounded,
            title: "Temperature",
            value: "38.2°C",
            subtitle: "Fever",
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.camera_alt_outlined,
            title: "Skin Status",
            value: "Chickenpox",
            subtitle: "Positive • Medium risk",
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.assignment_outlined,
            title: "Treatment",
            value: "In progress",
            subtitle: "Doctor approved",
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _MiniStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Taller to avoid overflow
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ Value: never overflow
          SizedBox(
            height: 26,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ✅ Subtitle: single line ellipsis
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineQuickButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _OutlineQuickButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withOpacity(0.8), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
        ),
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
        ],
      ),
    );
  }
}

/// ================= Health Tab (Simple hub) =================
class _PatientHealthTab extends StatelessWidget {
  const _PatientHealthTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Checkups",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _HubTile(
            icon: Icons.thermostat_rounded,
            title: "Temperature Readings",
            subtitle: "Robot temperature checks & history",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientVitalsScreen()),
            ),
          ),
          _HubTile(
            icon: Icons.camera_alt_outlined,
            title: "Skin Scans",
            subtitle: "Captured images & diagnosis results",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientVitalsScreen()),
            ),
          ),
          _HubTile(
            icon: Icons.assignment_outlined,
            title: "Treatment Plan",
            subtitle: "Doctor-approved plan & instructions",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientPlanScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubTile({
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

/// ================= Bottom Nav =================

class _PatientBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PatientBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_filled,
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.assignment_outlined,
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
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

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? AppColors.primary : AppColors.textLight,
      ),
    );
  }
}
