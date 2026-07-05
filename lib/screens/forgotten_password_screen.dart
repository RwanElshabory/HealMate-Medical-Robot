import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';

import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'otp_verification_screen.dart';
import 'recover_via_email_screen.dart';

class ForgottenPasswordScreen extends StatefulWidget {
  const ForgottenPasswordScreen({super.key});

  @override
  State<ForgottenPasswordScreen> createState() => _ForgottenPasswordScreenState();
}

class _ForgottenPasswordScreenState extends State<ForgottenPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // Default: Egypt
  Country _selectedCountry = Country.parse("EG");

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _digitsOnly =>
      _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

  bool get _isValidPhone {
    final d = _digitsOnly;

    // مصر: 01xxxxxxxxx (11 رقم) أو 1xxxxxxxxx (10 أرقام بدون صفر)
    if (_selectedCountry.countryCode == "EG") {
      if (d.length == 11 && d.startsWith('01')) return true;
      if (d.length == 10 && d.startsWith('1')) return true;
      return false;
    }

    // باقي الدول: تحقق عام (7 إلى 14 رقم)
    return d.length >= 7 && d.length <= 14;
  }

  String _normalizedLocalPhone() {
    // مصر: لو كتب 1xxxxxxxxx نخليها 01xxxxxxxxx
    final d = _digitsOnly;
    if (_selectedCountry.countryCode == "EG") {
      if (d.length == 10 && d.startsWith('1')) return '0$d';
      return d;
    }
    return d;
  }

  String? get _errorText {
    if (_phoneController.text.isEmpty) return null;
    return _isValidPhone ? null : "Please enter a valid phone number.";
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
          _phoneController.clear();
        });
      },
    );
  }

  void _goNext() {
    if (!_isValidPhone) return;

    final normalized = _normalizedLocalPhone();
    final fullNumber = "+${_selectedCountry.phoneCode}$normalized";

    debugPrint("SEND OTP TO: $fullNumber"); // TODO: API call

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OtpVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canNext = _isValidPhone;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
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
                      "Forgot Password",
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

              // ===== Title + Subtitle =====
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Recover your account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your phone number and we’ll send you a verification code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== Phone Card =====
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
                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _phoneField(
                      onTapCountry: _openCountryPicker,
                      onChanged: (_) => setState(() {}),
                      isValid: _isValidPhone,
                    ),

                    if (_errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== Next Button (disabled truly) =====
              Opacity(
                opacity: canNext ? 1 : 0.45,
                child: IgnorePointer(
                  ignoring: !canNext,
                  child: GradientButton(
                    text: "Next",
                    onTap: _goNext,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (!canNext)
                Center(
                  child: Text(
                    "Enter a valid phone number to continue.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight.withOpacity(0.9),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ===== Recover via Email =====
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Want to recover using your email? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecoverViaEmailScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Recover via Email",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneField({
    required VoidCallback onTapCountry,
    required void Function(String) onChanged,
    required bool isValid,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _phoneController.text.isEmpty
              ? Colors.transparent
              : (isValid ? Colors.green : Colors.redAccent).withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Country picker trigger
          InkWell(
            onTap: onTapCountry,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "+${_selectedCountry.phoneCode}",
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 24,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          const SizedBox(width: 12),

          // Phone input
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
                LengthLimitingTextInputFormatter(14),
              ],
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _selectedCountry.countryCode == "EG"
                    ? "01X XXXX XXXX"
                    : "Phone number",
                hintStyle: TextStyle(
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ),

          if (_phoneController.text.isNotEmpty) ...[
            const SizedBox(width: 6),
            Icon(
              isValid ? Icons.check_circle : Icons.error_outline,
              size: 18,
              color: isValid ? Colors.green : Colors.redAccent,
            ),
          ],
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
