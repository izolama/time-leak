import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/time_controller.dart';
import '../meaning/meaning_service.dart';
import '../meaning/meaning_model.dart';

class MeaningScreen extends StatelessWidget {
  const MeaningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeController = Get.find<TimeAggregationController>();
    final meaningService = MeaningService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: const Color(0xFF20201F),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FutureBuilder<int>(
            future: meaningService.loadMonthlySeconds(),
            builder: (context, snapshot) {
              final monthlySeconds = snapshot.data ?? 0;
              final equivalents = meaningService.buildMeaning(monthlySeconds);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THIS TIME COULD HOLD',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 0.5,
                      color: const Color(0xFF3B3B39),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'In the past month,\nyour time spent moving equals roughly:',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF20201F),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF20201F),
                      ),
                    )
                  else if (equivalents.isEmpty)
                    Text(
                      'Not enough movement yet to compare. We will keep watching quietly.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B6B69),
                      ),
                    )
                  else
                    ...equivalents
                        .map((item) => _MeaningRow(display: item))
                        .toList(),
                  const Spacer(),
                  _TotalsFootnote(
                    dailySeconds: timeController.todaySeconds.value,
                    weeklySeconds: timeController.weekSeconds.value,
                    monthlySeconds: monthlySeconds,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No judgement. Just perspective.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B6B69),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MeaningRow extends StatelessWidget {
  const _MeaningRow({required this.display});

  final MeaningDisplay display;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ${display.emoji}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${display.approxUnits} ${display.label}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF20201F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsFootnote extends StatelessWidget {
  const _TotalsFootnote({
    required this.dailySeconds,
    required this.weeklySeconds,
    required this.monthlySeconds,
  });

  final int dailySeconds;
  final int weeklySeconds;
  final int monthlySeconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today: ${_formatHoursMinutes(dailySeconds)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6B69)),
        ),
        Text(
          'This week: ${_formatHoursMinutes(weeklySeconds)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6B69)),
        ),
        Text(
          'Past month: ${_formatHoursMinutes(monthlySeconds)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6B69)),
        ),
      ],
    );
  }

  String _formatHoursMinutes(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0 && minutes == 0) return '0m';
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
