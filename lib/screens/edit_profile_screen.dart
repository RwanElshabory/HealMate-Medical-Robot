import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: "Dr. Farida Mahmoud");
  final _specialtyController =
  TextEditingController(text: "Internal Medicine & Robotics");
  final _hospitalController =
  TextEditingController(text: "HealMate Smart Hospital");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Basic Info",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            _textField("Full Name", _nameController),
            _textField("Specialty", _specialtyController),
            _textField("Hospital / Clinic", _hospitalController),

            const SizedBox(height: 24),
            const Text(
              "Contact",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _textField("Email", TextEditingController(text: "doctor@healmate.ai")),
            _textField("Phone", TextEditingController(text: "+20 100 000 0000")),

            const SizedBox(height: 30),
            GradientButton(
              text: "Save Changes",
              onTap: () {
                // هنا هتحطي منطق الحفظ بعدين
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile updated successfully"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
