import 'dart:async';

import 'package:get/get.dart';

import '../services/motion_service.dart';
import 'time_controller.dart';

class MotionController extends GetxController {
  MotionController({
    required this.motionService,
    required this.timeAggregationController,
  });

  final MotionService motionService;
  final TimeAggregationController timeAggregationController;

  RxBool isTrackingEnabled = false.obs;
  Rx<MotionState> currentState = MotionState.still.obs;

  static const int _minSegmentSeconds = 600;
  StreamSubscription<MotionState>? _motionSubscription;
  Timer? _tickTimer;
  DateTime? _stateChangedAt;
  int _segmentRecordedSeconds = 0;
  bool _isMoving = false;

  Future<void> startTracking() async {
    if (isTrackingEnabled.value) return;
    await motionService.start();
    _motionSubscription = motionService.motionStream.listen(_handleMotionState);
    isTrackingEnabled.value = true;
    _tickTimer ??= Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  Future<void> pauseTracking() async {
    if (!isTrackingEnabled.value) return;
    _tick();
    await _motionSubscription?.cancel();
    _motionSubscription = null;
    await motionService.stop();
    _resetSegment();
    isTrackingEnabled.value = false;
  }

  void _handleMotionState(MotionState state) {
    final now = DateTime.now();
    currentState.value = state;

    if (_stateChangedAt == null) {
      _stateChangedAt = now;
      _isMoving = state == MotionState.moving;
      return;
    }

    if (_isMoving && state == MotionState.still) {
      _recordSegment(now);
      _isMoving = false;
      _stateChangedAt = now;
      _segmentRecordedSeconds = 0;
      return;
    }

    if (!_isMoving && state == MotionState.moving) {
      _isMoving = true;
      _stateChangedAt = now;
      _segmentRecordedSeconds = 0;
    }
  }

  void _tick() {
    if (!_isMoving || _stateChangedAt == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(_stateChangedAt!).inSeconds;
    if (elapsed < _minSegmentSeconds) return;

    final unrecorded = elapsed - _segmentRecordedSeconds;
    if (unrecorded > 0) {
      _segmentRecordedSeconds += unrecorded;
      timeAggregationController.addMovingSeconds(unrecorded);
    }
  }

  void _recordSegment(DateTime now) {
    final elapsed = now.difference(_stateChangedAt!).inSeconds;
    if (elapsed < _minSegmentSeconds) return;
    final unrecorded = elapsed - _segmentRecordedSeconds;
    if (unrecorded > 0) {
      timeAggregationController.addMovingSeconds(unrecorded);
    }
  }

  void _resetSegment() {
    _stateChangedAt = null;
    _segmentRecordedSeconds = 0;
    _isMoving = false;
    currentState.value = MotionState.still;
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  @override
  void onClose() {
    _tickTimer?.cancel();
    _motionSubscription?.cancel();
    super.onClose();
  }
}
