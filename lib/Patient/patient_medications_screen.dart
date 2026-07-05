import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PatientMedicationsScreen extends StatelessWidget {
  const PatientMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data (later from backend / treatment plan)
    final meds = const <_MedItem>[
      _MedItem("Paracetamol 500mg", "06:00 PM", DeliveryStatus.pending),
      _MedItem("Antihistamine", "09:00 PM", DeliveryStatus.delivered),
      _MedItem("Calamine lotion", "10:00 AM", DeliveryStatus.missed),
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
          "Medication Delivery",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: meds.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _MedCard(item: meds[i]),
      ),
    );
  }
}

enum DeliveryStatus { pending, delivered, missed }

class _MedItem {
  final String name;
  final String time;
  final DeliveryStatus status;
  const _MedItem(this.name, this.time, this.status);
}

class _MedCard extends StatelessWidget {
  final _MedItem item;
  const _MedCard({required this.item});

  String _statusText(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.delivered:
        return "Delivered";
      case DeliveryStatus.missed:
        return "Missed";
      case DeliveryStatus.pending:
      default:
        return "Pending";
    }
  }

  Color _statusColor(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.missed:
        return const Color(0xFFE53935);
      case DeliveryStatus.pending:
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.delivered:
        return Icons.check_circle_rounded;
      case DeliveryStatus.missed:
        return Icons.cancel_rounded;
      case DeliveryStatus.pending:
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(item.status);

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
          ),
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
            child: const Icon(Icons.medication_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Scheduled: ${item.time}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(item.status), size: 16, color: c),
                const SizedBox(width: 6),
                Text(
                  _statusText(item.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
