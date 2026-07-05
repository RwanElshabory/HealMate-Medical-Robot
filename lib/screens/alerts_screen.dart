import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      _AlertItem(
        title: "High Fever Detected",
        detail: "Patient #203 — 38.9°C for 15 min.",
        type: AlertType.critical,
        time: "09:20",
      ),
      _AlertItem(
        title: "Low SpO₂",
        detail: "Patient #210 — 92%.",
        type: AlertType.warning,
        time: "08:45",
      ),
      _AlertItem(
        title: "Robot Task Completed",
        detail: "Vitals check finished for patient #201.",
        type: AlertType.info,
        time: "08:30",
      ),
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
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return _AlertCard(alert: alerts[index]);
        },
      ),
    );
  }
}

enum AlertType { critical, warning, info }

class _AlertItem {
  final String title;
  final String detail;
  final AlertType type;
  final String time;
  _AlertItem({
    required this.title,
    required this.detail,
    required this.type,
    required this.time,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  const _AlertCard({required this.alert});

  Color get _color {
    switch (alert.type) {
      case AlertType.critical:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_outlined,
              color: _color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            alert.time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
