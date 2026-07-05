import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PatientAlertsScreen extends StatelessWidget {
  const PatientAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = const [
      ("Fever detected", "Temperature 38.2°C • Please rest and hydrate", true),
      ("Diagnosis ready", "Skin scan result: Chickenpox (Positive)", true),
      ("Medication delivery", "Paracetamol scheduled at 06:00 PM", false),
      ("Treatment plan updated", "Doctor approved your new plan", false),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: const Text(
          "Alerts",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final a = alerts[i];
          final isCritical = a.$3;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.notifications_none,
                  color: isCritical ? const Color(0xFFE53935) : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.$1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
        },
      ),
    );
  }
}
