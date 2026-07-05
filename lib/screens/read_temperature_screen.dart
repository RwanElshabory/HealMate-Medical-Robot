import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../core/storage/secure_storage_service.dart';
import '../services/api/robot_api_service.dart';

class ReadTemperatureScreen extends StatefulWidget {
  const ReadTemperatureScreen({super.key});

  @override
  State<ReadTemperatureScreen> createState() => _ReadTemperatureScreenState();
}

class _ReadTemperatureScreenState extends State<ReadTemperatureScreen> {
  final RobotApiService _robotApiService = RobotApiService();

  bool _loading = false;
  double? _temp;
  int _doctorId = 0;
  int? _patientId = 2;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final saved = await SecureStorageService.getUserId();
    setState(() {
      _doctorId = int.tryParse(saved ?? '') ?? 0;
    });
  }

  Future<void> _readTemp() async {
    if (_doctorId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor ID not found. Please login first.")),
      );
      return;
    }

    setState(() {
      _loading = true;
      _temp = null;
    });

    try {
      await _robotApiService.sendCommand(
        doctorId: _doctorId,
        patientId: _patientId,
        command: "READ_TEMPERATURE",
      );

      await Future.delayed(const Duration(seconds: 1));

      final now = TimeOfDay.now();
      setState(() {
        _loading = false;
        _temp = 38.2;
        _lastUpdated =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Temperature read completed")),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to read temperature: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFever = (_temp ?? 0) >= 38.0;

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
          "Read Temperature",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.thermostat_rounded,
                      color: AppColors.primary,
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
                            fontSize: 13,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _temp == null ? "--" : "${_temp!.toStringAsFixed(1)} °C",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (_lastUpdated != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Last updated: $_lastUpdated",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_temp != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      isFever ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: isFever ? Colors.redAccent : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isFever ? "Patient has fever" : "Temperature is within normal range",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isFever ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _readTemp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Read Now",
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