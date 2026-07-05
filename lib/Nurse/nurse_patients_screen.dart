import 'package:flutter/material.dart';
import '../constants/colors.dart';

import 'nurse_patient_notes_screen.dart';
import 'nurse_patient_chat_screen.dart';

// لو لسه بتستخدميه مؤقتًا:
import '../screens/patient_profile_screen.dart';

class NursePatientsScreen extends StatelessWidget {
  const NursePatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = const [
      ("PT-1042", "Olivia Turner", "Room 206", "Chickenpox", "High"),
      ("PT-1091", "Ahmed Hassan", "Room 203", "Post-op", "Low"),
      ("PT-1150", "Mona Ali", "Room 210", "Diabetes", "Medium"),
    ];

    Color riskColor(String r) {
      switch (r.toLowerCase()) {
        case "high":
          return const Color(0xFFE53935);
        case "medium":
          return const Color(0xFFFF9800);
        default:
          return const Color(0xFF2E7D32);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Patients",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        itemCount: patients.length,
        itemBuilder: (_, i) {
          final p = patients[i];
          final patientId = p.$1;
          final patientName = p.$2;
          final room = p.$3;
          final condition = p.$4;
          final risk = p.$5;

          final rc = riskColor(risk);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
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
            ),
            child: Column(
              children: [
                Row(
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
                            patientName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "$room • $condition",
                            style: const TextStyle(
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
                        color: rc.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "$risk risk",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: rc,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniBtn(
                        icon: Icons.person_outline,
                        text: "Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniBtn(
                        icon: Icons.chat_bubble_outline,
                        text: "Chat",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NursePatientChatScreen(
                                patientId: patientId,
                                patientName: patientName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniBtn(
                        icon: Icons.sticky_note_2_outlined,
                        text: "Notes",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NursePatientNotesScreen(
                                patientId: patientId,
                                patientName: patientName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MiniBtn({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
