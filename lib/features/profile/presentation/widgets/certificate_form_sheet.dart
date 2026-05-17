import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/certificate.dart';
import '../providers/profile_provider.dart';

/// Bottom sheet form for creating or editing a certificate entry.
///
/// Uses DraggableScrollableSheet with surfaceVariant background.
/// In edit mode, pre-populates fields from the existing entity.
/// Calls repository directly (no usecase per Exception Rule).
void showCertificateFormSheet(
  BuildContext context,
  WidgetRef ref, {
  Certificate? existing,
  required String userId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CertificateFormSheet(
      existing: existing,
      userId: userId,
    ),
  );
}

class _CertificateFormSheet extends ConsumerStatefulWidget {
  const _CertificateFormSheet({
    this.existing,
    required this.userId,
  });

  final Certificate? existing;
  final String userId;

  @override
  ConsumerState<_CertificateFormSheet> createState() =>
      _CertificateFormSheetState();
}

class _CertificateFormSheetState
    extends ConsumerState<_CertificateFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _issuerController;
  late final TextEditingController _credentialUrlController;

  DateTime? _issuedAt;
  bool _isSaving = false;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    _issuerController =
        TextEditingController(text: widget.existing?.issuer ?? '');
    _credentialUrlController =
        TextEditingController(text: widget.existing?.credentialUrl ?? '');
    _issuedAt = widget.existing?.issuedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                    _isEditMode ? 'Chỉnh sửa chứng chỉ' : 'Thêm chứng chỉ',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Tên chứng chỉ'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) => Validators.required(v, 'Tên chứng chỉ'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Issuer (optional)
                TextFormField(
                  controller: _issuerController,
                  decoration: _inputDecoration('Tổ chức cấp'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Issued at (optional date)
                _buildDateField(
                  label: 'Ngày cấp',
                  value: _issuedAt,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),

                // Credential URL (optional)
                TextFormField(
                  controller: _credentialUrlController,
                  decoration: _inputDecoration('URL xác thực'),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: Validators.url,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'Chọn ngày',
          style: AppTextStyles.body.copyWith(
            color:
                value != null ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedAt ?? DateTime.now(),
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
    setState(() => _issuedAt = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      final entity = Certificate(
        id: widget.existing?.id ?? '',
        userId: widget.userId,
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim().isNotEmpty
            ? _issuerController.text.trim()
            : null,
        issuedAt: _issuedAt,
        credentialUrl: _credentialUrlController.text.trim().isNotEmpty
            ? _credentialUrlController.text.trim()
            : null,
      );

      final result = _isEditMode
          ? await repo.updateCertificate(entity)
          : await repo.addCertificate(entity);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          ref.invalidate(certificatesProvider);
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
          .deleteCertificate(widget.existing!.id);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          ref.invalidate(certificatesProvider);
          if (mounted) Navigator.pop(context);
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
