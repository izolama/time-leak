import 'package:get/get.dart';

import '../services/motion_service.dart';

class PermissionController extends GetxController {
  PermissionController({required this.motionService});

  final MotionService motionService;

  Rx<MotionPermission> permission = MotionPermission.unknown.obs;

  bool get isGranted => permission.value == MotionPermission.granted;

  @override
  void onInit() {
    super.onInit();
    refreshPermission();
  }

  Future<void> refreshPermission() async {
    permission.value = await motionService.checkPermission();
  }

  Future<void> requestPermission() async {
    permission.value = await motionService.requestPermission();
  }
}
