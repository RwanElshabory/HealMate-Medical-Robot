import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PatientVitalsScreen extends StatelessWidget {
  const PatientVitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _CheckItem("Temperature", "38.2°C", "Fever • Today 03:40 PM", Icons.thermostat_rounded),
      _CheckItem("Skin Scan", "Chickenpox", "Positive • Medium risk", Icons.camera_alt_outlined),
      _CheckItem("Temperature", "37.3°C", "Normal • Yesterday 09:10 PM", Icons.thermostat_rounded),
      _CheckItem("Skin Scan", "Mpox", "Negative • Low risk", Icons.camera_alt_outlined),
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
          "My Checkups",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CheckCard(item: items[i]),
      ),
    );
  }
}

class _CheckItem {
  final String title;
  final String value;
  final String note;
  final IconData icon;
  const _CheckItem(this.title, this.value, this.note, this.icon);
}

class _CheckCard extends StatelessWidget {
  final _CheckItem item;
  const _CheckCard({required this.item});

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.value,
            style: const TextStyle(

              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
