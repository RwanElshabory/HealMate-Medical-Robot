import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'otp_verification_screen.dart';

class RecoverViaEmailScreen extends StatelessWidget {
  const RecoverViaEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "Forgotten Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Center(
                child: Text(
                  "Provide the email address linked with your account to\n"
                      "reset your password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textLight.withOpacity(0.9),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Please Enter your registered Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              _emailField(),

              const SizedBox(height: 25),

              GradientButton(
                text: "Request Password Reset Link",
                onTap: () {
                  // TODO: send reset link
                },
              ),

              const SizedBox(height: 15),

              GradientButton(
                text: "Next",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OtpVerificationScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "faridamahmoud@gmail.com",
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
