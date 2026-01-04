import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/motion_controller.dart';
import 'controllers/permission_controller.dart';
import 'controllers/time_controller.dart';
import 'services/motion_service.dart';
import 'storage/local_storage.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalStorage();
  final timeController = Get.put(
    TimeAggregationController(localStorage: storage),
  );
  final motionService = MotionService();
  Get.put(PermissionController(motionService: motionService));
  final motionController = Get.put(
    MotionController(
      motionService: motionService,
      timeAggregationController: timeController,
    ),
  );

  // Start tracking immediately when permissions are already granted.
  PermissionController permissionController = Get.find();
  permissionController.refreshPermission().then((_) {
    if (permissionController.isGranted) {
      motionController.startTracking();
    }
  });

  runApp(const TimeLeakApp());
}

class TimeLeakApp extends StatelessWidget {
  const TimeLeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Time Leak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F3F0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF20201F),
          secondary: Color(0xFF3B3B39),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Color(0xFF20201F),
            letterSpacing: -1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Color(0xFF20201F),
            letterSpacing: -0.8,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3B3B39),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF4B4B4A),
            height: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20201F),
            foregroundColor: const Color(0xFFF4F3F0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF20201F),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
