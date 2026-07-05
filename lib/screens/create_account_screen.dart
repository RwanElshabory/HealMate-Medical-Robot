import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'doctor_home_screen.dart';
import 'login_screen.dart';
import '../services/biometric_service.dart';
import '../models/user_role.dart';
import '../services/api/auth_api_service.dart';
import '../Nurse/nurse_home_screen.dart';
import '../Patient/patient_home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserRole? role;

  const CreateAccountScreen({super.key, this.role});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthApiService _authApiService = AuthApiService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _password = '';
  bool _isLoading = false;
  bool _acceptedPrivacy = true;
  bool _obscurePassword = true;

  bool get _hasMinLength => _password.length >= 8 && _password.length <= 12;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _password.contains(RegExp(r'[!@#\$%^&*]'));
  bool get _hasNoSpaces => !_password.contains(' ');

  bool get _isPasswordValid =>
      _hasMinLength &&
          _hasUppercase &&
          _hasLowercase &&
          _hasNumber &&
          _hasSpecial &&
          _hasNoSpaces;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapRoleToApi(UserRole? role) {
    switch (role) {
      case UserRole.nurse:
        return "nurse";
      case UserRole.patient:
        return "patient";
      case UserRole.doctor:
      default:
        return "doctor";
    }
  }

  void _goHomeByRole(UserRole role) {
    Widget target;

    if (role == UserRole.nurse) {
      target = const NurseHomeScreen();
    } else if (role == UserRole.patient) {
      target = const PatientHomeScreen();
    } else {
      target = const DoctorHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  Future<void> _onRegisterPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final selectedRole = widget.role ?? UserRole.doctor;
    final apiRole = _mapRoleToApi(selectedRole);

    if (email.isEmpty) {
      _showSnackBar("Please enter your email");
      return;
    }

    if (password.isEmpty) {
      _showSnackBar("Please enter your password");
      return;
    }

    if (!_isPasswordValid) {
      _showSnackBar("Please complete all password requirements first.");
      return;
    }

    if (!_acceptedPrivacy) {
      _showSnackBar("Please accept the privacy policy first.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _authApiService.register(
        email: email,
        password: password,
        role: apiRole,
      );

      if (!mounted) return;

      _showSnackBar("Account created successfully. Please login.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(role: selectedRole),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Register failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = widget.role ?? UserRole.doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  "Let’s set up your new HealMate ${_mapRoleToApi(selectedRole)} account",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Full Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _fullNameController,
                      hint: "Dr. Farida Mahmoud",
                      keyboardType: TextInputType.name,
                    ),

                    const Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _emailController,
                      hint: "example@example.com",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),

                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _mobileController,
                      hint: "0123456789",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),

                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _passwordField(),

                    if (_password.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _PasswordRequirementsCard(
                        hasMinLength: _hasMinLength,
                        hasUppercase: _hasUppercase,
                        hasLowercase: _hasLowercase,
                        hasNumber: _hasNumber,
                        hasSpecial: _hasSpecial,
                        hasNoSpaces: _hasNoSpaces,
                      ),
                    ],

                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _acceptedPrivacy,
                            onChanged: (v) {
                              setState(() {
                                _acceptedPrivacy = v ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "I agree with the Privacy Policy and allow HealMate to securely store my medical data.",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
                  : Opacity(
                opacity: _isPasswordValid ? 1 : 0.55,
                child: GradientButton(
                  text: "Sign up",
                  onTap: _onRegisterPressed,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    "Enable login with Fingerprint",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final success = await BiometricService.authenticate();

                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fingerprint enabled successfully"),
                        ),
                      );
                      _goHomeByRole(selectedRole);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Biometric authentication failed"),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "or sign up with",
                    style: TextStyle(
                      color: AppColors.textLight.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialCircle("assets/images/apple.png"),
                  _socialCircle("assets/images/facebook.png"),
                  _socialCircle("assets/images/google.png"),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an Account? ",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: _passwordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: _obscurePassword,
        onChanged: (value) {
          setState(() => _password = value);
        },
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.textLight,
            size: 20,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          hintText: "••••••••",
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool isPass = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPass,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
            prefixIcon,
            color: AppColors.textLight,
            size: 20,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static Widget _socialCircle(String icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        icon,
        width: 26,
        height: 26,
      ),
    );
  }
}

class _PasswordRequirementsCard extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;
  final bool hasNoSpaces;

  const _PasswordRequirementsCard({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
    required this.hasNoSpaces,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBackground,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password requirements",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          _requirementRow("8–12 characters", hasMinLength),
          _requirementRow("One uppercase letter (A–Z)", hasUppercase),
          _requirementRow("One lowercase letter (a–z)", hasLowercase),
          _requirementRow("One number (0–9)", hasNumber),
          _requirementRow("One special (!@#\$%^&*)", hasSpecial),
          _requirementRow("No spaces", hasNoSpaces),
        ],
      ),
    );
  }

  Widget _requirementRow(String text, bool ok) {
    final color = ok ? Colors.green : Colors.redAccent.shade200;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}