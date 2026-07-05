import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../core/storage/secure_storage_service.dart';
import '../services/api/robot_api_service.dart';
import 'capture_skin_screen.dart';
import 'run_diagnosis_screen.dart';
import 'read_temperature_screen.dart';
import 'robot_treatment_plans_screen.dart';

enum SkinDiagnosis { none, chickenpoxPositive, chickenpoxNegative }

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  final RobotApiService _robotApiService = RobotApiService();

  bool _drawerOpen = false;
  double? _temperature;
  DateTime? _tempTime;
  String? _skinImageAsset;
  SkinDiagnosis _diagnosis = SkinDiagnosis.none;
  String? _suggestedPlan;
  bool _isGeneratingPlan = false;
  bool _isDiagnosing = false;

  bool _isSendingCommand = false;
  int _doctorId = 0;
  int? _patientId = 2;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final saved = await SecureStorageService.getUserId();
    final parsed = int.tryParse(saved ?? '');
    setState(() {
      _doctorId = parsed ?? 0;
    });
  }

  Future<void> _sendRobotCommand(
      String command, {
        String? parameters,
        String? successMessage,
      }) async {
    if (_isSendingCommand) return;

    if (_doctorId == 0) {
      _showSnack("Doctor ID not found. Please login first.");
      return;
    }

    try {
      setState(() => _isSendingCommand = true);

      await _robotApiService.sendCommand(
        doctorId: _doctorId,
        patientId: _patientId,
        command: command,
        parameters: parameters,
      );

      if (!mounted) return;
      if (successMessage != null) {
        _showSnack(successMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack("Robot command failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  Future<void> _openDrawer() async {
    await _sendRobotCommand(
      "OPEN_DRAWER",
      successMessage: "Medicine drawer opened",
    );

    if (!mounted) return;
    setState(() => _drawerOpen = true);
  }

  Future<void> _closeDrawer() async {
    await _sendRobotCommand(
      "CLOSE_DRAWER",
      successMessage: "Medicine drawer closed",
    );

    if (!mounted) return;
    setState(() => _drawerOpen = false);
  }

  void _readTemperature() {
    final now = DateTime.now();
    final mock = 38.2;
    setState(() {
      _temperature = mock;
      _tempTime = now;
    });
  }

  void _captureSkinImage() {
    setState(() {
      _skinImageAsset = "assets/images/skin_sample.jpg";
      _diagnosis = SkinDiagnosis.none;
      _suggestedPlan = null;
    });
  }

  Future<void> _runDiagnosis() async {
    if (_skinImageAsset == null) {
      _showSnack("Capture a skin image first");
      return;
    }

    setState(() => _isDiagnosing = true);

    await Future.delayed(const Duration(milliseconds: 900));

    setState(() {
      _diagnosis = SkinDiagnosis.chickenpoxPositive;
      _suggestedPlan = null;
      _isDiagnosing = false;
    });
  }

  Future<void> _generateTreatmentPlan() async {
    if (_diagnosis == SkinDiagnosis.none) {
      _showSnack("Run diagnosis first");
      return;
    }

    setState(() => _isGeneratingPlan = true);

    await Future.delayed(const Duration(milliseconds: 900));

    setState(() {
      _suggestedPlan =
      "Suggested Plan (AI):\n• Isolation & hydration\n• Antipyretic (paracetamol) if fever\n• Skin care + itch relief\n• Doctor review required";
      _isGeneratingPlan = false;
    });
  }

  Future<void> _startAutoCheckup() async {
    await _sendRobotCommand(
      "AUTO_CHECKUP",
      successMessage: "Auto checkup started",
    );

    _readTemperature();
    _captureSkinImage();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _formatTime(DateTime? t) {
    if (t == null) return "—";
    final hh = t.hour.toString().padLeft(2, "0");
    final mm = t.minute.toString().padLeft(2, "0");
    return "$hh:$mm";
  }

  Color _diagnosisColor() {
    switch (_diagnosis) {
      case SkinDiagnosis.chickenpoxPositive:
        return Colors.redAccent;
      case SkinDiagnosis.chickenpoxNegative:
        return Colors.green;
      case SkinDiagnosis.none:
      default:
        return AppColors.textLight;
    }
  }

  String _diagnosisText() {
    switch (_diagnosis) {
      case SkinDiagnosis.chickenpoxPositive:
        return "Chickenpox: Positive";
      case SkinDiagnosis.chickenpoxNegative:
        return "Chickenpox: Negative";
      case SkinDiagnosis.none:
      default:
        return "Diagnosis: Not run";
    }
  }

  @override
  Widget build(BuildContext context) {
    final temp = _temperature;
    final tempText = temp == null ? "—" : "${temp.toStringAsFixed(1)} °C";
    final fever = temp != null && temp >= 38.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Robot Control",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  _isSendingCommand
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const _StatusChip(
                    text: "Online",
                    icon: Icons.wifi_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                height: 210,
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
                        child: _skinImageAsset == null
                            ? Text(
                          "Robot Navigation Preview",
                          style: TextStyle(
                            color: AppColors.textLight.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                            : Image.asset(
                          _skinImageAsset!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              "Add a sample image at:\n$_skinImageAsset",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textLight.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Navigation Camera",
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

              const SizedBox(height: 16),

              const Text(
                "Robot Status",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: const [
                  Expanded(
                    child: _InfoTile(
                      title: "Robot",
                      value: "RX-01",
                      icon: Icons.smart_toy_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      title: "Battery",
                      value: "78%",
                      icon: Icons.battery_6_bar_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: _InfoTile(
                      title: "Connection",
                      value: "Online",
                      icon: Icons.wifi_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      title: "Location",
                      value: "Room 203",
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                "Movement Controls",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DpadButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        label: "Forward",
                        onTap: () => _sendRobotCommand(
                          "MOVE_FORWARD",
                          parameters: '{"speed":2}',
                          successMessage: "Moving forward",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DpadButton(
                            icon: Icons.keyboard_arrow_left_rounded,
                            label: "Left",
                            onTap: () => _sendRobotCommand(
                              "MOVE_LEFT",
                              parameters: '{"speed":2}',
                              successMessage: "Moving left",
                            ),
                          ),
                          const SizedBox(width: 10),
                          _DpadCenterButton(
                            icon: Icons.stop_rounded,
                            label: "Stop",
                            onTap: () => _sendRobotCommand(
                              "STOP",
                              successMessage: "Robot stopped",
                            ),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.keyboard_arrow_right_rounded,
                            label: "Right",
                            onTap: () => _sendRobotCommand(
                              "MOVE_RIGHT",
                              parameters: '{"speed":2}',
                              successMessage: "Moving right",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DpadButton(
                            icon: Icons.rotate_left_rounded,
                            label: "Rotate L",
                            onTap: () => _sendRobotCommand(
                              "ROTATE_LEFT",
                              parameters: '{"speed":1}',
                              successMessage: "Rotating left",
                            ),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            label: "Backward",
                            onTap: () => _sendRobotCommand(
                              "MOVE_BACKWARD",
                              parameters: '{"speed":2}',
                              successMessage: "Moving backward",
                            ),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.rotate_right_rounded,
                            label: "Rotate R",
                            onTap: () => _sendRobotCommand(
                              "ROTATE_RIGHT",
                              parameters: '{"speed":1}',
                              successMessage: "Rotating right",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Robot Actions",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionCard(
                    icon: Icons.thermostat_rounded,
                    title: "Read Temperature",
                    onTap: () {
                      _readTemperature();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReadTemperatureScreen(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.camera_alt_outlined,
                    title: "Capture Skin",
                    onTap: () {
                      _captureSkinImage();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaptureSkinScreen(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.biotech_outlined,
                    title: "Run Diagnosis",
                    onTap: () async {
                      await _runDiagnosis();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RunDiagnosisScreen(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.assignment_outlined,
                    title: "Treatment Plan",
                    onTap: () async {
                      await _generateTreatmentPlan();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RobotTreatmentPlansScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

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
                  border: Border.all(
                    color: _diagnosis == SkinDiagnosis.none
                        ? Colors.transparent
                        : _diagnosisColor().withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _diagnosis == SkinDiagnosis.none
                            ? AppColors.inputBackground
                            : _diagnosisColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: _diagnosis == SkinDiagnosis.none
                            ? AppColors.primary
                            : _diagnosisColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Skin Diagnosis",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _diagnosisText(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _diagnosis == SkinDiagnosis.none
                                  ? AppColors.textDark
                                  : _diagnosisColor(),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _skinImageAsset == null
                                ? "No image captured yet"
                                : "Image captured ✓",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (_suggestedPlan != null)
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
                        "Suggested Treatment Plan (AI)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _suggestedPlan!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _OutlinePillButton(
                              text: "Send to Doctor",
                              icon: Icons.send_outlined,
                              onTap: () => _showSnack("Plan sent to doctor"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _OutlinePillButton(
                              text: "Edit",
                              icon: Icons.edit_outlined,
                              onTap: () => _showSnack("Edit plan"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              const Text(
                "Medicine Drawer",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _BetterActionButton(
                      title: "Open Drawer",
                      subtitle: "Medicine",
                      icon: Icons.inventory_2_outlined,
                      enabled: !_drawerOpen,
                      onTap: _openDrawer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BetterActionButton(
                      title: "Close Drawer",
                      subtitle: "Medicine",
                      icon: Icons.lock_outline_rounded,
                      enabled: _drawerOpen,
                      onTap: _closeDrawer,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _isSendingCommand
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                text: "Start Auto Checkup",
                onTap: _startAutoCheckup,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _StatusChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBackground),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
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

class _OutlinePillButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlinePillButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.35),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DpadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DpadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inputBackground),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DpadCenterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DpadCenterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textLight.withOpacity(0.8),
            )
          ],
        ),
      ),
    );
  }
}

class _BetterActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _BetterActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.inputBackground),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textLight.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}