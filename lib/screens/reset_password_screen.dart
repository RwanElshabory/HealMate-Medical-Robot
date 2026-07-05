import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'password_updated_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // ---------- PASSWORD RULES ----------
  bool get hasUpper => _newPassController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLower => _newPassController.text.contains(RegExp(r'[a-z]'));
  bool get hasNumber => _newPassController.text.contains(RegExp(r'[0-9]'));
  bool get hasSpecial =>
      _newPassController.text.contains(RegExp(r'[!@#\$%^&*]'));
  bool get longEnough => _newPassController.text.length >= 8;
  bool get noSpaces => !_newPassController.text.contains(" ");

  bool get _isPasswordValid =>
      longEnough &&
          hasUpper &&
          hasLower &&
          hasNumber &&
          hasSpecial &&
          noSpaces &&
          _newPassController.text == _confirmPassController.text;

  // Strength score (0..5)
  int get _strengthScore {
    int score = 0;
    if (longEnough) score++;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;
    return score;
  }

  String get _strengthLabel {
    final s = _strengthScore;
    if (_newPassController.text.isEmpty) return "—";
    if (s <= 2) return "Weak";
    if (s <= 4) return "Medium";
    return "Strong";
  }

  Color get _strengthColor {
    final s = _strengthScore;
    if (_newPassController.text.isEmpty) return AppColors.textLight;
    if (s <= 2) return Colors.redAccent;
    if (s <= 4) return Colors.orange;
    return Colors.green;
  }

  int get _filledBars {
    final s = _strengthScore;
    if (_newPassController.text.isEmpty) return 0;
    if (s <= 2) return 1;
    if (s <= 4) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch =
        _confirmPassController.text.isNotEmpty &&
            _newPassController.text == _confirmPassController.text;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: [
                  _IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: Column(
                  children: const [
                    Text(
                      "Create a new password",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your new password must be strong and secure.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== Password Card =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PasswordField(
                      title: "New Password",
                      controller: _newPassController,
                      obscure: _obscureNew,
                      onToggle: () {
                        setState(() => _obscureNew = !_obscureNew);
                      },
                      onChange: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    // ===== Strength Bar =====
                    _StrengthBar(
                      label: _strengthLabel,
                      color: _strengthColor,
                      filledBars: _filledBars,
                    ),

                    const SizedBox(height: 14),

                    _PasswordField(
                      title: "Confirm Password",
                      controller: _confirmPassController,
                      obscure: _obscureConfirm,
                      onToggle: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                      onChange: (_) => setState(() {}),
                      helper: passwordsMatch
                          ? null
                          : (_confirmPassController.text.isEmpty
                          ? null
                          : "Passwords do not match"),
                      helperIsError: _confirmPassController.text.isNotEmpty &&
                          !passwordsMatch,
                    ),

                    const SizedBox(height: 16),

                    _PasswordRequirementsGrid(
                      hasMinLength: longEnough,
                      hasUppercase: hasUpper,
                      hasLowercase: hasLower,
                      hasNumber: hasNumber,
                      hasSpecial: hasSpecial,
                      hasNoSpaces: noSpaces,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== Next Button (DISABLED truly) + Hint =====
              Opacity(
                opacity: _isPasswordValid ? 1 : 0.45,
                child: IgnorePointer(
                  ignoring: !_isPasswordValid, // ✅ يمنع الضغط فعليًا
                  child: GradientButton(
                    text: "Next",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PasswordUpdatedScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (!_isPasswordValid)
                Center(
                  child: Text(
                    "Please complete the requirements above to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight.withOpacity(0.9),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Widgets =================

class _PasswordField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final void Function(String)? onChange;
  final String? helper;
  final bool helperIsError;

  const _PasswordField({
    required this.title,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.onChange,
    this.helper,
    this.helperIsError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChange,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "••••••••",
            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
      if (helper != null) ...[
        const SizedBox(height: 6),
        Text(
          helper!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: helperIsError ? Colors.redAccent : AppColors.textLight,
          ),
        ),
      ],
    ]);
  }
}

class _StrengthBar extends StatelessWidget {
  final String label;
  final Color color;
  final int filledBars; // 0..3

  const _StrengthBar({
    required this.label,
    required this.color,
    required this.filledBars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBackground),
      ),
      child: Row(
        children: [
          const Text(
            "Strength",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List.generate(3, (i) {
                final active = i < filledBars;
                return Expanded(
                  child: Container(
                    height: 8,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: active ? color : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirementsGrid extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;
  final bool hasNoSpaces;

  const _PasswordRequirementsGrid({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
    required this.hasNoSpaces,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ("8+ characters", hasMinLength),
      ("Uppercase (A–Z)", hasUppercase),
      ("Lowercase (a–z)", hasLowercase),
      ("Number (0–9)", hasNumber),
      ("Special (!@#)", hasSpecial),
      ("No spaces", hasNoSpaces),
    ];

    return Center( // ✅ يخلي البوكس في النص
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320), // عرض ثابت شيك
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.inputBackground),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Password requirements",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: items
                    .map((e) => _RequirementChip(text: e.$1, ok: e.$2))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  final String text;
  final bool ok;

  const _RequirementChip({required this.text, required this.ok});

  @override
  Widget build(BuildContext context) {
    final chipColor =
    ok ? Colors.green.withOpacity(0.1) : AppColors.inputBackground;
    final iconColor = ok ? Colors.green : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
        ],
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
