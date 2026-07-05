import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api/ai_api_service.dart';
import 'robot_treatment_plans_screen.dart';

class RunDiagnosisScreen extends StatefulWidget {
  const RunDiagnosisScreen({super.key});

  @override
  State<RunDiagnosisScreen> createState() => _RunDiagnosisScreenState();
}

class _RunDiagnosisScreenState extends State<RunDiagnosisScreen> {
  final AiApiService _aiApiService = AiApiService();

  bool _running = false;
  String _result = "Not run";
  double _confidence = 0.0;
  String? _error;

  Future<void> _run() async {
    try {
      setState(() {
        _running = true;
        _result = "Running...";
        _confidence = 0.0;
        _error = null;
      });

      final response = await _aiApiService.predictDisease(
        patientId: 1,
        age: 45,
        gender: "Male",
        symptoms: ["fever", "cough"],
      );

      final disease = (response["predictedDisease"] ?? "Unknown").toString();
      final confidenceValue = response["confidence"];

      double parsedConfidence = 0.0;
      if (confidenceValue is int) {
        parsedConfidence = confidenceValue.toDouble();
      } else if (confidenceValue is double) {
        parsedConfidence = confidenceValue;
      } else {
        parsedConfidence =
            double.tryParse(confidenceValue?.toString() ?? "0") ?? 0.0;
      }

      if (parsedConfidence > 1) {
        parsedConfidence = parsedConfidence / 100.0;
      }

      if (!mounted) return;

      setState(() {
        _running = false;
        _result = disease;
        _confidence = parsedConfidence.clamp(0.0, 1.0);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _running = false;
        _result = "Failed";
        _confidence = 0.0;
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Diagnosis failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowerResult = _result.toLowerCase();
    final isPositive = lowerResult.contains("positive") ||
        lowerResult.contains("chickenpox") ||
        lowerResult.contains("flu") ||
        lowerResult.contains("disease");

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
          "Run Diagnosis",
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
              padding: const EdgeInsets.all(14),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Skin Diagnosis",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.verified_rounded
                            : Icons.shield_outlined,
                        color: isPositive
                            ? Colors.redAccent
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Result: $_result",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(100 * _confidence).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _running ? null : _confidence,
                    backgroundColor: AppColors.inputBackground,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _running ? null : _run,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _running
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Run Diagnosis",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _result != "Not run" && _result != "Failed"
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RobotTreatmentPlansScreen(),
                    ),
                  );
                }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                ),
                label: const Text(
                  "Go to Treatment Plans",
                  style: TextStyle(
                    color: AppColors.primary,
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