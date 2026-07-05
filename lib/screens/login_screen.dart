import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../models/user_role.dart';
import '../services/biometric_service.dart';
import '../services/api/auth_api_service.dart';
import '../core/storage/secure_storage_service.dart';

// screens
import 'forgotten_password_screen.dart';
import 'create_account_screen.dart';
import 'doctor_home_screen.dart';
import '../Nurse/nurse_home_screen.dart';
import '../Patient/patient_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole? role;

  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController(text: "");

  final AuthApiService _authApiService = AuthApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  UserRole _mapRoleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'nurse':
        return UserRole.nurse;
      case 'patient':
        return UserRole.patient;
      case 'doctor':
      default:
        return UserRole.doctor;
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

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Please enter your email");
      return;
    }

    if (password.isEmpty) {
      _showSnackBar("Please enter your password");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final result = await _authApiService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final userRole = _mapRoleFromString(result.role);

      _goHomeByRole(userRole);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Login failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final success = await BiometricService.authenticate();

    if (!mounted) return;

    if (!success) {
      _showSnackBar("Biometric authentication failed");
      return;
    }

    final savedRole = await SecureStorageService.getRole();

    if (!mounted) return;

    if (savedRole == null || savedRole.isEmpty) {
      _showSnackBar("No saved session found. Please login first.");
      return;
    }

    final userRole = _mapRoleFromString(savedRole);
    _goHomeByRole(userRole);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    "Login Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  "Welcome back, please sign in to continue",
                  style: TextStyle(
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
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email or Mobile Number",
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
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _passwordController,
                      hint: "••••••••",
                      isPass: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock_outline,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) {
                                  setState(() {
                                    _rememberMe = v ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Keep me logged in",
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgottenPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
                  : GradientButton(
                text: "Login",
                onTap: _onLoginPressed,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithBiometrics,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.9),
                      width: 1.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    "Login with Fingerprint",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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

              _socialButton("assets/images/google.png", "Continue With Google"),
              const SizedBox(height: 12),
              _socialButton("assets/images/apple.png", "Continue With Apple"),
              const SizedBox(height: 12),
              _socialButton("assets/images/facebook.png", "Continue With Facebook"),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
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
                          builder: (_) => CreateAccountScreen(role: widget.role),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign up",
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

  Widget _inputField({
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
        obscureText: isPass ? _obscurePassword : false,
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
          suffixIcon: isPass
              ? IconButton(
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
          )
              : null,
          filled: true,
          fillColor: AppColors.inputBackground,
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
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

  Widget _socialButton(String icon, String text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withOpacity(0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Image.asset(icon, width: 22, height: 22),
          const SizedBox(width: 18),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}