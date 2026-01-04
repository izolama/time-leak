import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/formatters.dart';
import 'worth_it_controller.dart';
import 'worth_it_models.dart';

class WorthItCalculatorScreen extends StatefulWidget {
  const WorthItCalculatorScreen({super.key});

  @override
  State<WorthItCalculatorScreen> createState() =>
      _WorthItCalculatorScreenState();
}

class _WorthItCalculatorScreenState extends State<WorthItCalculatorScreen> {
  late final WorthItController controller;

  late final TextEditingController incomeController;
  late final TextEditingController workHoursController;
  late final TextEditingController workDaysController;
  late final TextEditingController commuteMinutesController;
  late final TextEditingController commuteDaysController;
  late final TextEditingController breakMinutesController;

  @override
  void initState() {
    super.initState();
    controller =
        Get.isRegistered<WorthItController>()
            ? Get.find<WorthItController>()
            : Get.put(WorthItController());

    incomeController = TextEditingController(
      text: _zeroAsEmpty(controller.monthlyIncome),
    );
    workHoursController = TextEditingController(
      text: controller.workHoursPerDay.value.toString(),
    );
    workDaysController = TextEditingController(
      text: controller.workDaysPerWeek.value.toString(),
    );
    commuteMinutesController = TextEditingController(
      text:
          controller.commuteMinutesPerDay.value == 0
              ? ''
              : controller.commuteMinutesPerDay.value.toString(),
    );
    commuteDaysController = TextEditingController(
      text: controller.commuteDaysPerWeek.value.toString(),
    );
    breakMinutesController = TextEditingController(
      text:
          controller.breakMinutesPerDay.value == 0
              ? ''
              : controller.breakMinutesPerDay.value.toString(),
    );

    incomeController.addListener(_onIncomeChanged);
    workHoursController.addListener(_onWorkHoursChanged);
    workDaysController.addListener(_onWorkDaysChanged);
    commuteMinutesController.addListener(_onCommuteMinutesChanged);
    commuteDaysController.addListener(_onCommuteDaysChanged);
    breakMinutesController.addListener(_onBreakMinutesChanged);
  }

  @override
  void dispose() {
    incomeController.dispose();
    workHoursController.dispose();
    workDaysController.dispose();
    commuteMinutesController.dispose();
    commuteDaysController.dispose();
    breakMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worth It'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF20201F),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Obx(() {
            final hasData = controller.isValid;
            final outputs = hasData ? controller.computeOutputs() : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A simple time and pay calculation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4B4B4A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputCard(context),
                const SizedBox(height: 20),
                if (hasData && outputs != null) _buildResults(context, outputs),
                const SizedBox(height: 16),
                Text(
                  'Estimates are based on your inputs and recent moving time. No location data is used.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7A7A78),
                    height: 1.4,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final noteStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B6B69));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inputs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _InputField(
            label: 'Monthly Income',
            controller: incomeController,
            keyboardType: TextInputType.number,
            placeholder: 'e.g. 7000000',
          ),
          _InputField(
            label: 'Work Hours / Day',
            controller: workHoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            placeholder: 'e.g. 8',
          ),
          _InputField(
            label: 'Work Days / Week',
            controller: workDaysController,
            keyboardType: TextInputType.number,
            placeholder: 'e.g. 5',
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Use commute from Time Leak',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Switch(
                value: controller.useTimeLeakCommute.value,
                activeColor: const Color(0xFF20201F),
                onChanged: (enabled) {
                  controller.toggleUseTimeLeakCommute(enabled);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (controller.useTimeLeakCommute.value)
            _CommuteFromTimeLeak(controller: controller, noteStyle: noteStyle),
          if (!controller.useTimeLeakCommute.value) ...[
            _InputField(
              label: 'Commute Minutes / Day',
              controller: commuteMinutesController,
              keyboardType: TextInputType.number,
              placeholder: 'e.g. 60',
            ),
            if (!controller.commuteDataAvailable.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Not enough recent movement to estimate commute. Enter it manually.',
                  style: noteStyle,
                ),
              ),
          ],
          _InputField(
            label: 'Commute Days / Week',
            controller: commuteDaysController,
            keyboardType: TextInputType.number,
            placeholder: controller.workDaysPerWeek.value.toString(),
          ),
          _InputField(
            label: 'Break Minutes / Day (optional)',
            controller: breakMinutesController,
            keyboardType: TextInputType.number,
            placeholder: '0',
          ),
          if (!controller.isValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Enter realistic values to see the calculation.',
                style: noteStyle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, WorthItOutputs outputs) {
    final commuteMinutesPerWorkHour = outputs.commuteMinutesPerWorkHour;
    return Column(
      children: [
        _ResultCard(
          title: 'Commute impact',
          body:
              'Each work hour includes ~${commuteMinutesPerWorkHour} min of commute.',
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Effective hourly rate',
          body:
              'Work-only rate: ${controller.formatCurrency(outputs.hourlyWorkRate.round())} / hour\n'
              'Effective rate: ${controller.formatCurrency(outputs.effectiveHourlyRate.round())} / hour (includes commute)',
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Monthly time committed',
          body:
              'Work: ${formatHoursOneDecimal(outputs.workHoursPerMonth)}\nCommute: ${formatHoursOneDecimal(outputs.commuteHoursPerMonth)}\nTotal: ${formatHoursOneDecimal(outputs.timeCommittedPerMonth)}',
        ),
      ],
    );
  }

  void _onIncomeChanged() {
    final cleaned = incomeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned != incomeController.text) {
      incomeController.value = incomeController.value.copyWith(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    controller.monthlyIncome.value = int.tryParse(cleaned) ?? 0;
  }

  void _onWorkHoursChanged() {
    controller.workHoursPerDay.value =
        double.tryParse(workHoursController.text) ?? 0;
  }

  void _onWorkDaysChanged() {
    controller.workDaysPerWeek.value =
        int.tryParse(workDaysController.text) ?? 0;
  }

  void _onCommuteMinutesChanged() {
    controller.commuteMinutesPerDay.value =
        int.tryParse(commuteMinutesController.text) ?? 0;
  }

  void _onCommuteDaysChanged() {
    controller.commuteDaysPerWeek.value =
        int.tryParse(commuteDaysController.text) ?? 0;
  }

  void _onBreakMinutesChanged() {
    controller.breakMinutesPerDay.value =
        int.tryParse(breakMinutesController.text) ?? 0;
  }

  String _zeroAsEmpty(RxInt value) {
    return value.value == 0 ? '' : value.value.toString();
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.placeholder,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: const Color(0xFFF7F7F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommuteFromTimeLeak extends StatelessWidget {
  const _CommuteFromTimeLeak({
    required this.controller,
    required this.noteStyle,
  });

  final WorthItController controller;
  final TextStyle? noteStyle;

  @override
  Widget build(BuildContext context) {
    if (controller.commuteDataLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 4, color: Color(0xFF20201F)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commute Minutes / Day',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.derivedCommuteMinutes.value} minutes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('Based on the last 7 days.', style: noteStyle),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
