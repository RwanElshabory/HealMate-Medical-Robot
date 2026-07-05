import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'run_diagnosis_screen.dart';

class CaptureSkinScreen extends StatefulWidget {
  const CaptureSkinScreen({super.key});

  @override
  State<CaptureSkinScreen> createState() => _CaptureSkinScreenState();
}

class _CaptureSkinScreenState extends State<CaptureSkinScreen> {
  bool _captured = false;
  bool _capturing = false;
  String? _capturedAt;

  Future<void> _captureSkin() async {
    setState(() {
      _capturing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final now = TimeOfDay.now();

    if (!mounted) return;

    setState(() {
      _capturing = false;
      _captured = true;
      _capturedAt =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Skin image captured successfully")),
    );
  }

  void _goToDiagnosis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RunDiagnosisScreen(),
      ),
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: const Text(
          "Capture Skin",
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
              height: 240,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Container(
                      color: AppColors.inputBackground,
                      alignment: Alignment.center,
                      child: _capturing
                          ? const CircularProgressIndicator()
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _captured
                                ? Icons.check_circle_rounded
                                : Icons.camera_alt_outlined,
                            size: 38,
                            color: _captured
                                ? Colors.green
                                : AppColors.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _captured
                                ? "Skin image captured ✓"
                                : "Skin Camera Preview",
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_capturedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              "Captured at $_capturedAt",
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Skin Camera",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _capturing ? null : _captureSkin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _capturing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      "Capture",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _captured ? _goToDiagnosis : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.biotech_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      "Run Diagnosis",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Tip: Capture a clear close-up image of the rash area with good lighting.",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Current mode: local mock capture only. Real camera/robot image endpoint is still not connected from backend.",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}