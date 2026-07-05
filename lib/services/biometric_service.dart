import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isSupported) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Use your fingerprint to login',
        // ✅ بدون options عشان يشتغل مع أي version
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Biometric unknown error: $e');
      return false;
    }
  }
}
