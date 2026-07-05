import 'dart:async';
import 'package:flutter/foundation.dart';

class RobotService {
  RobotService._();
  static final RobotService instance = RobotService._();

  bool drawerOpen = false;

  Future<void> openDrawer() async {
    drawerOpen = true;
    debugPrint("ROBOT: OPEN drawer");
  }

  Future<void> closeDrawer() async {
    drawerOpen = false;
    debugPrint("ROBOT: CLOSE drawer");
  }

  /// لما الدكتور يعمل Approve -> افتح الدرج واقفله بعد 30 ثانية
  Future<void> dispenseMedicineAutoClose({int seconds = 30}) async {
    await openDrawer();
    Timer(Duration(seconds: seconds), () async {
      await closeDrawer();
    });
  }
}
