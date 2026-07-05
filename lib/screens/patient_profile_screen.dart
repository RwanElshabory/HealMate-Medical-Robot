import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'chat_screen.dart';
import 'robot_control_screen.dart';
import 'robot_treatment_plans_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final int patientId;
  final String patientName;
  final String patientAvatar;
  final String patientSubtitle;
  final String specialty;
  final String room;
  final int age;
  final String status;

  const PatientProfileScreen({
    super.key,
    this.patientId = 1,
    this.patientName = "Olivia Turner",
    this.patientAvatar = "assets/images/patient_avatar.jpeg",
    this.patientSubtitle = "Room 206 • Patient",
    this.specialty = "Dermato-Endocrinology",
    this.room = "206",
    this.age = 34,
    this.status = "Stable",
  });

  @override
  Widget build(BuildContext context) {
    final chatId = "patient_$patientId";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 16),

              _TopPatientCard(
                patientId: patientId,
                patientName: patientName,
                patientAvatar: patientAvatar,
                specialty: specialty,
                room: room,
                age: age,
                status: status,
              ),

              const SizedBox(height: 20),

              const _SectionTitle("Care Team"),
              const SizedBox(height: 10),

              _CareTeamSection(
                patientId: patientId,
                chatId: chatId,
                patientName: patientName,
                patientAvatar: patientAvatar,
                patientSubtitle: patientSubtitle,
              ),

              const SizedBox(height: 20),

              const _SectionTitle("Quick Actions"),
              const SizedBox(height: 12),

              _QuickActionsRow(
                patientId: patientId,
                chatId: chatId,
                patientName: patientName,
                patientAvatar: patientAvatar,
                patientSubtitle: patientSubtitle,
              ),

              const SizedBox(height: 24),

              const _SectionTitle("Today’s Vitals"),
              const SizedBox(height: 12),
              const _VitalsGrid(),

              const SizedBox(height: 24),

              const _SectionTitle("Recent Logs"),
              const SizedBox(height: 12),
              const _LogsList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        const Expanded(
          child: Text(
            "Patient Profile",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _TopPatientCard extends StatelessWidget {
  final int patientId;
  final String patientName;
  final String patientAvatar;
  final String specialty;
  final String room;
  final int age;
  final String status;

  const _TopPatientCard({
    required this.patientId,
    required this.patientName,
    required this.patientAvatar,
    required this.specialty,
    required this.room,
    required this.age,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status.toLowerCase() == "stable"
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(patientAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.badge_outlined,
                      text: "ID: PT-$patientId",
                    ),
                    _InfoChip(
                      icon: Icons.cake_outlined,
                      text: "Age: $age",
                    ),
                    _InfoChip(
                      icon: Icons.meeting_room_outlined,
                      text: "Room $room",
                    ),
                    _InfoChip(
                      icon: Icons.circle,
                      text: status,
                      iconColor: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareTeamSection extends StatelessWidget {
  final int patientId;
  final String chatId;
  final String patientName;
  final String patientAvatar;
  final String patientSubtitle;

  const _CareTeamSection({
    required this.patientId,
    required this.chatId,
    required this.patientName,
    required this.patientAvatar,
    required this.patientSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _CareTeamRow(
      role: "Assigned Nurse",
      name: "Nurse Sara Ahmed",
      avatarAsset: "assets/images/nurse.jpg",
      color: const Color(0xFF00C89A),
      onMessage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              chatName: patientName,
              avatarPath: patientAvatar,
              subtitle: patientSubtitle,
              otherUserId: patientId,
            ),
          ),
        );
      },
    );
  }
}

class _CareTeamRow extends StatelessWidget {
  final String role;
  final String name;
  final String avatarAsset;
  final Color color;
  final VoidCallback onMessage;

  const _CareTeamRow({
    required this.role,
    required this.name,
    required this.avatarAsset,
    required this.color,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(avatarAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onMessage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppColors.inputBackground,
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              "Message",
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final int patientId;
  final String chatId;
  final String patientName;
  final String patientAvatar;
  final String patientSubtitle;

  const _QuickActionsRow({
    required this.patientId,
    required this.chatId,
    required this.patientName,
    required this.patientAvatar,
    required this.patientSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final half = (w - 20 * 2 - 10) / 2;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: half,
          child: GradientButton(
            text: "Chat with patient",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: chatId,
                    chatName: patientName,
                    avatarPath: patientAvatar,
                    subtitle: patientSubtitle,
                    otherUserId: patientId,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: half,
          child: GradientButton(
            text: "Robot Control",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RobotControlScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: "Treatment Plans",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RobotTreatmentPlansScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  const _VitalsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _VitalItem(
        label: "Temperature",
        value: "37.2°C",
        icon: Icons.thermostat_outlined,
      ),
      _VitalItem(
        label: "Heart Rate",
        value: "82 bpm",
        icon: Icons.favorite_border,
      ),
      _VitalItem(
        label: "SpO₂",
        value: "97%",
        icon: Icons.water_drop_outlined,
      ),
      _VitalItem(
        label: "Blood Pressure",
        value: "118 / 76",
        icon: Icons.monitor_heart_outlined,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 90,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _VitalItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _VitalItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
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

class _LogsList extends StatelessWidget {
  const _LogsList();

  @override
  Widget build(BuildContext context) {
    final logs = [
      "Robot recorded vitals – temperature stable.",
      "Skin image captured for chickenpox screening.",
      "AI suggested a treatment plan (pending doctor review).",
      "Doctor can approve/modify/decline and dispense medicine via drawer.",
    ];

    return Column(
      children: logs.map((text) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.timeline_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}