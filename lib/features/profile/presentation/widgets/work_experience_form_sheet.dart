import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/work_experience.dart';
import '../providers/profile_provider.dart';

/// Bottom sheet form for creating or editing a work experience entry.
///
/// Uses DraggableScrollableSheet with surfaceVariant background.
/// In edit mode, pre-populates fields from the existing entity.
/// Calls repository directly (no usecase per Exception Rule).
void showWorkExperienceFormSheet(
  BuildContext context,
  WidgetRef ref, {
  WorkExperience? existing,
  required String userId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WorkExperienceFormSheet(
      existing: existing,
      userId: userId,
    ),
  );
}

class _WorkExperienceFormSheet extends ConsumerStatefulWidget {
  const _WorkExperienceFormSheet({
    this.existing,
    required this.userId,
  });

  final WorkExperience? existing;
  final String userId;

  @override
  ConsumerState<_WorkExperienceFormSheet> createState() =>
      _WorkExperienceFormSheetState();
}

class _WorkExperienceFormSheetState
    extends ConsumerState<_WorkExperienceFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyController;
  late final TextEditingController _roleController;
  late final TextEditingController _descriptionController;

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isCurrent = false;
  bool _isSaving = false;
  String? _fromDateError;
  String? _toDateError;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.existing?.company ?? '');
    _roleController =
        TextEditingController(text: widget.existing?.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.existing?.description ?? '');
    _fromDate = widget.existing?.fromDate;
    _toDate = widget.existing?.toDate;
    _isCurrent = widget.existing?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _isEditMode
                        ? 'Chỉnh sửa kinh nghiệm'
                        : 'Thêm kinh nghiệm',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Company
                TextFormField(
                  controller: _companyController,
                  decoration: _inputDecoration('Tên công ty'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) => Validators.required(v, 'Tên công ty'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Role
                TextFormField(
                  controller: _roleController,
                  decoration: _inputDecoration('Vị trí'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) => Validators.required(v, 'Vị trí'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // From date
                _buildDateField(
                  label: 'Ngày bắt đầu',
                  value: _fromDate,
                  error: _fromDateError,
                  onTap: () => _pickDate(isFrom: true),
                ),
                const SizedBox(height: 16),

                // Is current toggle
                Row(
                  children: [
                    Switch(
                      value: _isCurrent,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isCurrent = val;
                          if (val) {
                            _toDate = null;
                            _toDateError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.currentlyWorking,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // To date (disabled if isCurrent)
                if (!_isCurrent)
                  _buildDateField(
                    label: 'Ngày kết thúc',
                    value: _toDate,
                    error: _toDateError,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                if (!_isCurrent) const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Mô tả'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: Validators.bio,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor: AppColors.primary.withAlpha(128),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.cardBorderRadius),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text(
                            AppStrings.saveChanges,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                  ),
                ),

                // Delete button (edit mode only)
                if (_isEditMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSaving ? null : _confirmDelete,
                      child: Text(
                        AppStrings.delete,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required String? error,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: _inputDecoration(label).copyWith(
              errorText: error,
            ),
            child: Text(
              value != null
                  ? DateFormat('dd/MM/yyyy').format(value)
                  : 'Chọn ngày',
              style: AppTextStyles.body.copyWith(
                color: value != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        _fromDateError = null;
      } else {
        _toDate = picked;
        _toDateError = null;
      }
    });
  }

  Future<void> _handleSave() async {
    // Validate form fields
    final formValid = _formKey.currentState!.validate();

    // Validate from_date
    final fromDateError = Validators.fromDate(_fromDate);
    setState(() => _fromDateError = fromDateError);

    // Cross-field: to_date >= from_date
    if (_toDate != null && _fromDate != null && _toDate!.isBefore(_fromDate!)) {
      setState(() => _toDateError = AppStrings.toDateError);
    }

    if (!formValid || _fromDateError != null || _toDateError != null) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      final entity = WorkExperience(
        id: widget.existing?.id ?? '',
        userId: widget.userId,
        company: _companyController.text.trim(),
        role: _roleController.text.trim(),
        fromDate: _fromDate!,
        toDate: _isCurrent ? null : _toDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isCurrent: _isCurrent,
      );

      final result = _isEditMode
          ? await repo.updateWorkExperience(entity)
          : await repo.addWorkExperience(entity);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          ref.invalidate(workExperiencesProvider);
          if (mounted) Navigator.pop(context);
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
        ),
        child: AlertDialog(
          title: const Text(AppStrings.confirmDelete, style: AppTextStyles.title),
          content: const Text(
            AppStrings.confirmDeleteMessage,
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performDelete();
              },
              child: Text(
                AppStrings.delete,
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDelete() async {
    setState(() => _isSaving = true);
    try {
      final result = await ref
          .read(profileRepositoryProvider)
          .deleteWorkExperience(widget.existing!.id);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          ref.invalidate(workExperiencesProvider);
          if (mounted) Navigator.pop(context);
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
