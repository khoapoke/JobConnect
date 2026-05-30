import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/application_provider.dart';

class ScheduleInterviewPage extends ConsumerStatefulWidget {
  const ScheduleInterviewPage({
    super.key,
    required this.applicationId,
    required this.jobId,
  });

  final String applicationId;
  final String jobId;

  @override
  ConsumerState<ScheduleInterviewPage> createState() =>
      _ScheduleInterviewPageState();
}

class _ScheduleInterviewPageState extends ConsumerState<ScheduleInterviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(applicationActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scheduleInterview),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppStrings.scheduledAt,
                hintText: _scheduledAt == null
                    ? AppStrings.pickDateTime
                    : DateFormat('dd/MM/yyyy · HH:mm').format(_scheduledAt!),
                suffixIcon: const Icon(Icons.schedule_outlined),
              ),
              validator: (_) => Validators.scheduledAt(_scheduledAt),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: AppStrings.interviewLocation,
              ),
              validator: (value) => Validators.text(
                value,
                AppStrings.interviewLocation,
                min: 2,
                max: 120,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: AppStrings.interviewNote,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: actionState.isLoading ? null : _save,
              child: const Text(AppStrings.scheduleInterview),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .scheduleInterview(
          applicationId: widget.applicationId,
          scheduledAt: _scheduledAt!,
          location: _locationController.text.trim(),
          note: _noteController.text.trim(),
          jobId: widget.jobId,
        );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.interviewScheduled)),
        );
        context.pop();
      },
    );
  }
}
