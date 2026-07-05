import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../models/user_role.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final UserRole role;
  const WelcomeScreen({super.key, required this.role});

  String _titleForRole() {
    switch (role) {
      case UserRole.doctor:
        return 'Welcome, Doctor';
      case UserRole.nurse:
        return 'Welcome, Nurse';
      case UserRole.patient:
        return 'Welcome to HealMate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ===== Title =====
              Text(
                _titleForRole(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign in or create an account to continue",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ===== Logo Center =====
              Center(
                child: Image.asset(
                  "assets/images/logoo.png",
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              // ===== Buttons =====
              GradientButton(
                text: "Create Account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateAccountScreen(role: role),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(role: role),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Already have an account",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
