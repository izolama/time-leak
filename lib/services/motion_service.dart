import 'dart:async';
import 'dart:io';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

enum MotionPermission { unknown, granted, denied }

enum MotionState { still, moving }

class MotionService {
  MotionService()
    : _activityRecognition = ActivityRecognition(),
      _motionController = StreamController<MotionState>.broadcast();

  final ActivityRecognition _activityRecognition;
  final StreamController<MotionState> _motionController;
  StreamSubscription<ActivityEvent>? _subscription;

  Stream<MotionState> get motionStream => _motionController.stream;

  Future<MotionPermission> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      return _mapPermission(status);
    }
    // iOS requests happen implicitly via Core Motion, so treat as granted once available.
    return MotionPermission.granted;
  }

  Future<MotionPermission> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return _mapPermission(status);
    }
    return MotionPermission.granted;
  }

  Future<void> start() async {
    if (_subscription != null) return;
    final permission = await checkPermission();
    if (permission != MotionPermission.granted) return;
    _subscription = _activityRecognition
        .activityStream(runForegroundService: true)
        .listen((event) {
          final state = _toMotionState(event.type);
          _motionController.add(state);
        }, onError: (_) {});
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  MotionState _toMotionState(ActivityType type) {
    switch (type) {
      case ActivityType.WALKING:
      case ActivityType.ON_BICYCLE:
      case ActivityType.IN_VEHICLE:
      case ActivityType.RUNNING:
        return MotionState.moving;
      case ActivityType.STILL:
      case ActivityType.UNKNOWN:
      case ActivityType.TILTING:
      case ActivityType.ON_FOOT:
        return MotionState.still;
      case ActivityType.INVALID:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  MotionPermission _mapPermission(PermissionStatus status) {
    if (status.isGranted) {
      return MotionPermission.granted;
    }
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      return MotionPermission.denied;
    }
    return MotionPermission.unknown;
  }
}
