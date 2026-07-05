import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/select_role_screen.dart';

class NurseProfileScreen extends StatelessWidget {
  const NurseProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
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
            "You will need to login again to access your dashboard.",
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
                      (route) => false,
                );
              },
              child: const Text("Logout",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
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
                  radius: 28,
                  backgroundImage: AssetImage("assets/images/nurse_avatar.jpeg"),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nurse Sara Ahmed",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text("ICU & Remote Monitoring",
                          style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text("On Duty",
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const _SectionTitle("Account"),
          _Item(
            icon: Icons.person_outline,
            title: "Edit Profile",
            subtitle: "Update name, photo",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit Profile (TODO)")));
            },
          ),
          _Item(
            icon: Icons.lock_outline,
            title: "Security",
            subtitle: "Change password",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Change Password (TODO)")));
            },
          ),

          const SizedBox(height: 14),
          const _SectionTitle("Support"),
          _Item(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "FAQs, contact, report issue",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Help & Support (TODO)")));
            },
          ),

          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showLogoutDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 13.5, color: Colors.red, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textDark),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Item({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
          ],
          border: Border.all(color: AppColors.inputBackground.withOpacity(0.65)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textLight)),
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
