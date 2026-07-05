import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/user_role.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Column(
            children: [
              const Spacer(),

              // ===== Title =====
              const Text(
                'Select your role',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you will use HealMate',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              _roleCard(
                context,
                title: 'Doctor',
                subtitle: 'Manage patients & monitor health',
                imagePath: 'assets/images/Doctor_role.png',
                role: UserRole.doctor,
              ),
              const SizedBox(height: 18),

              _roleCard(
                context,
                title: 'Patient',
                subtitle: 'Track your health & receive care',
                imagePath: 'assets/images/Patient_role.png',
                role: UserRole.patient,
              ),
              const SizedBox(height: 18),

              _roleCard(
                context,
                title: 'Nurse',
                subtitle: 'Assist doctors & patients',
                imagePath: 'assets/images/Nurse_role.png',
                role: UserRole.nurse,
              ),

              const Spacer(),

              // ===== Logo =====
              Image.asset("assets/images/logoo.png", height: 100),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String imagePath,
        required UserRole role,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/welcome',
          arguments: role,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.textLight.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
