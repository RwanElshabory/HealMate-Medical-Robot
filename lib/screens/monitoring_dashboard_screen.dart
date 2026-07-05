import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../core/storage/secure_storage_service.dart';
import '../services/api/robot_api_service.dart';

class MonitoringDashboardScreen extends StatefulWidget {
  const MonitoringDashboardScreen({super.key});

  @override
  State<MonitoringDashboardScreen> createState() =>
      _MonitoringDashboardScreenState();
}

class _MonitoringDashboardScreenState extends State<MonitoringDashboardScreen> {
  final RobotApiService _robotApiService = RobotApiService();

  bool _loading = false;
  double _tempValue = 38.2;
  String? _lastUpdated;
  int _doctorId = 0;
  int? _patientId = 2;

  final List<Map<String, String>> _history = [
    {"time": "09:10", "temp": "37.6 °C"},
    {"time": "10:05", "temp": "38.0 °C"},
    {"time": "10:40", "temp": "38.2 °C"},
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
    _setInitialTime();
  }

  Future<void> _loadDoctorId() async {
    final saved = await SecureStorageService.getUserId();
    setState(() {
      _doctorId = int.tryParse(saved ?? '') ?? 0;
    });
  }

  void _setInitialTime() {
    final now = TimeOfDay.now();
    _lastUpdated =
    "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _refreshMonitoring() async {
    if (_doctorId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor ID not found. Please login first.")),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      await _robotApiService.sendCommand(
        doctorId: _doctorId,
        patientId: _patientId,
        command: "READ_TEMPERATURE",
      );

      await Future.delayed(const Duration(seconds: 1));

      final now = TimeOfDay.now();
      final updatedTemp = 38.1;

      setState(() {
        _tempValue = updatedTemp;
        _lastUpdated =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        _history.insert(0, {
          "time": _lastUpdated!,
          "temp": "${updatedTemp.toStringAsFixed(1)} °C",
        });

        if (_history.length > 5) {
          _history.removeLast();
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Monitoring refreshed")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to refresh monitoring: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFever = _tempValue >= 38.0;

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
          "Monitoring",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: ListView(
          children: [
            _TemperatureCard(
              value: "${_tempValue.toStringAsFixed(1)} °C",
              status: isFever ? "Fever" : "Normal",
              statusColor: isFever ? Colors.redAccent : Colors.green,
              lastUpdated: _lastUpdated ?? "—",
            ),
            const SizedBox(height: 12),
            _TempHistoryCard(history: _history),
            const SizedBox(height: 14),
            const _AlertSummaryTempOnly(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _refreshMonitoring,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "Refresh Monitoring",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  final String value;
  final String status;
  final Color statusColor;
  final String lastUpdated;

  const _TemperatureCard({
    required this.value,
    required this.status,
    required this.statusColor,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.thermostat_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Temperature",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Last updated: $lastUpdated",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TempHistoryCard extends StatelessWidget {
  final List<Map<String, String>> history;

  const _TempHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Readings",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in history) ...[
            Row(
              children: [
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      item["time"] ?? "--",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item["temp"] ?? "--",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AlertSummaryTempOnly extends StatelessWidget {
  const _AlertSummaryTempOnly();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "AI Summary (Temperature Only):\n\n"
            "• Monitoring is focused on body temperature.\n"
            "• If temperature ≥ 38.0°C, it will be flagged as Fever.\n"
            "• No other vitals are tracked in this version.\n"
            "• Real vitals history API is still missing from backend.",
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textDark,
          height: 1.4,
        ),
      ),
    );
  }
}