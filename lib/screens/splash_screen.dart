import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ✅ عدّلي الرقم ده بس لو لسه باين على اليمين/الشمال
  // سالب = يروح شمال ، موجب = يروح يمين
  static const double _logoXFix = -10; // جرّبي -8 أو -12 حسب جهازك

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF80CFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // placeholder (هنعوضها في builder)
              ],
            ),
            builder: (context, _) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ هنا التوسيط الحقيقي + تصحيح الإزاحة
                      Transform.translate(
                        offset: const Offset(_logoXFix, 0),
                        child: Image.asset(
                          'assets/images/logoo.png', // خليها اسم الصورة اللي عندك
                          height: 320,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
