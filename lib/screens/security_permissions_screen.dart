import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SecurityPermissionsScreen extends StatefulWidget {
  const SecurityPermissionsScreen({super.key});

  @override
  State<SecurityPermissionsScreen> createState() =>
      _SecurityPermissionsScreenState();
}

class _SecurityPermissionsScreenState extends State<SecurityPermissionsScreen> {
  bool _twoFactorEnabled = true;
  bool _nurseCameraControl = true;
  bool _robotOnlyInsideHospital = true;

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
          "Security & Permissions",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _switchTile(
            title: "Two-factor Authentication",
            subtitle: "Require code when logging in on new devices",
            value: _twoFactorEnabled,
            onChanged: (v) => setState(() => _twoFactorEnabled = v),
          ),
          _switchTile(
            title: "Nurse Robot Camera Control",
            subtitle: "Allow nurses to start camera sessions with patients",
            value: _nurseCameraControl,
            onChanged: (v) => setState(() => _nurseCameraControl = v),
          ),
          _switchTile(
            title: "Robot restricted to hospital network",
            subtitle: "Prevent robot control from outside secure network",
            value: _robotOnlyInsideHospital,
            onChanged: (v) => setState(() => _robotOnlyInsideHospital = v),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
