import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/motion_controller.dart';
import '../controllers/permission_controller.dart';
import '../controllers/time_controller.dart';
import '../meaning/meaning_screen.dart';
import '../features/worth_it/worth_it_screen.dart';
import '../services/motion_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionController = Get.find<PermissionController>();
    final motionController = Get.find<MotionController>();
    final timeController = Get.find<TimeAggregationController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TIME LEAK', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 32),
              _buildTimeSection(
                context: context,
                label: 'Today',
                valueBuilder:
                    () => formatDuration(timeController.todaySeconds.value),
                subtitle: 'spent moving',
              ),
              const SizedBox(height: 28),
              _buildTimeSection(
                context: context,
                label: 'This Week',
                valueBuilder:
                    () => formatDuration(timeController.weekSeconds.value),
              ),
              const SizedBox(height: 32),
              _PermissionBlock(
                permissionController: permissionController,
                motionController: motionController,
              ),
              const SizedBox(height: 32),
              const Divider(thickness: 1, color: Color(0x3320201F)),
              const SizedBox(height: 16),
              Text(
                'We calculate time spent moving.\nWe don’t track your location.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.to(() => const MeaningScreen()),
                child: const Text('See what this time means'),
              ),
              TextButton(
                onPressed: () => Get.to(() => const WorthItCalculatorScreen()),
                child: const Text('Worth It calculator'),
              ),
              const Spacer(),
              Obx(() {
                final isPaused = !motionController.isTrackingEnabled.value;
                final state = motionController.currentState.value;
                return Text(
                  isPaused ? 'Tracking is paused.' : _stateDescription(state),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A7A78),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection({
    required BuildContext context,
    required String label,
    required String Function() valueBuilder,
    String? subtitle,
  }) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF3B3B39)),
          ),
          const SizedBox(height: 8),
          Text(
            valueBuilder(),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A7A78)),
            ),
          ],
        ],
      );
    });
  }

  String _stateDescription(MotionState state) {
    switch (state) {
      case MotionState.moving:
        return 'Measuring time spent moving.';
      case MotionState.still:
        return 'You are still. We keep watching quietly.';
    }
  }
}

class _PermissionBlock extends StatelessWidget {
  const _PermissionBlock({
    required this.permissionController,
    required this.motionController,
  });

  final PermissionController permissionController;
  final MotionController motionController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = permissionController.permission.value;
      final granted = permissionController.isGranted;

      if (!granted) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Leak calculates how much time you spend moving.\nWe don’t track your location.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await permissionController.requestPermission();
                if (permissionController.isGranted) {
                  await motionController.startTracking();
                }
              },
              child: const Text('Allow Motion Access'),
            ),
            if (status == MotionPermission.denied)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Motion access is needed to calculate moving time.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A7A78),
                  ),
                ),
              ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motion access is on. We only log time, not location.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (motionController.isTrackingEnabled.value) {
                await motionController.pauseTracking();
              } else {
                await motionController.startTracking();
              }
            },
            child: const Text('Pause Tracking'),
          ),
        ],
      );
    });
  }
}

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0 && minutes == 0) {
    return '0m';
  }

  if (hours == 0) {
    return '${minutes}m';
  }

  if (minutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${minutes}m';
}
