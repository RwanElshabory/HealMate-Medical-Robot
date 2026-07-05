import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'select_role_screen.dart';

class PatientAccountScreen extends StatefulWidget {
  const PatientAccountScreen({super.key});

  @override
  State<PatientAccountScreen> createState() => _PatientAccountScreenState();
}

class _PatientAccountScreenState extends State<PatientAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Mock editable fields (replace later with your real user model)
  final _nameCtrl = TextEditingController(text: "Patient Name");
  final _phoneCtrl = TextEditingController(text: "+20 1X XXX XXXX");
  final _emailCtrl = TextEditingController(text: "patient@mail.com");
  final _dobCtrl = TextEditingController(text: "2000-01-01");

  final _emgNameCtrl = TextEditingController(text: "Emergency Contact");
  final _emgPhoneCtrl = TextEditingController(text: "+20 1X XXX XXXX");

  bool _notifyEnabled = true;
  String _language = "EN"; // EN / AR

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _emgNameCtrl.dispose();
    _emgPhoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    // TODO: Save to API / local storage
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            "Log out?",
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          content: const Text(
            "You will be signed out from your account.",
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);

                // TODO: clear token/session here

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
                      (route) => false,
                );
              },
              child: const Text(
                "Log out",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  // ====== UI Helpers (match screenshot style) ======

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _pillField({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
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
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage("assets/images/patient_avatar.jpeg"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameCtrl.text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Manage your personal info & preferences",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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

  Widget _prefsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          _toggleRow(
            icon: Icons.notifications_none,
            title: "Notifications",
            value: _notifyEnabled,
            onChanged: (v) => setState(() => _notifyEnabled = v),
          ),
          const Divider(height: 18),
          _dropdownRow(
            icon: Icons.language_outlined,
            title: "Language",
            value: _language,
            items: const ["EN", "AR"],
            onChanged: (v) => setState(() => _language = v ?? "EN"),
          ),
          const Divider(height: 18),
          _actionRow(
            icon: Icons.logout,
            title: "Log out",
            danger: true,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dropdownRow({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFE53935) : AppColors.textDark;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: danger ? const Color(0xFFE53935) : AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  // ====== Screen ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Account",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              "Save",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _headerCard(),

              _sectionTitle("Personal Information"),
              _pillField(
                icon: Icons.person_outline,
                controller: _nameCtrl,
                hint: "Patient Name",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
              ),
              _pillField(
                icon: Icons.phone_outlined,
                controller: _phoneCtrl,
                hint: "+20 1X XXX XXXX",
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 7) ? "Enter a valid phone" : null,
              ),
              _pillField(
                icon: Icons.mail_outline,
                controller: _emailCtrl,
                hint: "patient@mail.com",
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains("@")) ? "Enter a valid email" : null,
              ),
              _pillField(
                icon: Icons.cake_outlined,
                controller: _dobCtrl,
                hint: "2000-01-01",
              ),

              _sectionTitle("Emergency Contact"),
              _pillField(
                icon: Icons.person_pin_outlined,
                controller: _emgNameCtrl,
                hint: "Emergency Contact",
              ),
              _pillField(
                icon: Icons.local_phone_outlined,
                controller: _emgPhoneCtrl,
                hint: "+20 1X XXX XXXX",
                keyboardType: TextInputType.phone,
              ),

              _sectionTitle("Preferences"),
              _prefsCard(),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
