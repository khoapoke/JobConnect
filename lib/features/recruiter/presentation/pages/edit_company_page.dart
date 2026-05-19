import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/company_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/province_picker_sheet.dart';
import '../../domain/entities/company_update.dart';
import '../../domain/usecases/upload_logo_usecase.dart';
import '../providers/company_provider.dart';
import '../widgets/logo_picker.dart';

/// Edit/create company form (push route at `/recruiter/company/edit`).
///
/// ConsumerStatefulWidget with TextEditingControllers.
/// Reads currentCompanyProvider ONCE in initState for initial values.
/// _isCreating flag: company == null means CREATE, else UPDATE.
class EditCompanyPage extends ConsumerStatefulWidget {
  const EditCompanyPage({super.key});

  @override
  ConsumerState<EditCompanyPage> createState() => _EditCompanyPageState();
}

class _EditCompanyPageState extends ConsumerState<EditCompanyPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late final TextEditingController _provinceController;

  CompanySize? _selectedSize;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  String? _currentLogoPath;
  String? _existingCompanyId;
  bool _isCreating = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Read ONCE on mount — NOT ref.watch()
    final companyAsync = ref.read(currentCompanyProvider);
    final company = companyAsync.valueOrNull;

    _isCreating = company == null;
    _existingCompanyId = company?.id;
    _currentLogoPath = company?.logoUrl;

    _nameController = TextEditingController(text: company?.name ?? '');
    _descriptionController =
        TextEditingController(text: company?.description ?? '');
    _websiteController = TextEditingController(text: company?.website ?? '');
    _provinceController = TextEditingController(text: company?.province ?? '');

    if (company?.size != null) {
      _selectedSize = CompanySize.fromValue(company!.size);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCreating ? AppStrings.createCompany : AppStrings.editCompany,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Logo picker
              LogoPicker(
                currentLogoPath: _currentLogoPath,
                localImage: _pickedImageBytes,
                onImagePicked: (bytes, ext) {
                  setState(() {
                    _pickedImageBytes = bytes;
                    _pickedImageExt = ext;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 2. Company name (required)
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(AppStrings.companyName),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: (v) =>
                    Validators.text(v, AppStrings.companyName),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // 3. Description (optional, multiline)
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(AppStrings.companyDescription),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: (v) =>
                    Validators.longText(v, AppStrings.companyDescription),
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),

              // 4. Website (optional)
              TextFormField(
                controller: _websiteController,
                decoration: _inputDecoration(AppStrings.companyWebsite),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                validator: Validators.url,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // 5. Size dropdown (optional)
              DropdownButtonFormField<CompanySize>(
                initialValue: _selectedSize,
                decoration: _inputDecoration(AppStrings.companySize),
                hint: Text(
                  AppStrings.companySize,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                items: CompanySize.values.map((size) {
                  return DropdownMenuItem<CompanySize>(
                    value: size,
                    child: Text(
                      size.displayLabel,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSize = value);
                },
                dropdownColor: AppColors.surface,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // 6. Province (read-only with onTap → ProvincePickerSheet)
              TextFormField(
                controller: _provinceController,
                readOnly: true,
                decoration: _inputDecoration(AppStrings.companyProvince)
                    .copyWith(
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                onTap: () async {
                  final result = await showProvincePickerSheet(
                    context,
                    selectedProvince: _provinceController.text.isNotEmpty
                        ? _provinceController.text
                        : null,
                  );
                  if (result != null) {
                    setState(() {
                      _provinceController.text = result;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

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
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 32),
            ],
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(companyRepositoryProvider);

      // Build CompanyUpdate from controllers
      final update = CompanyUpdate(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        size: _selectedSize?.value,
        province: _provinceController.text.trim().isNotEmpty
            ? _provinceController.text.trim()
            : null,
      );

      if (_isCreating) {
        // ─── CREATE flow ───────────────────────────────────────
        final createResult = await repository.createCompany(update);

        final String? companyId = createResult.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
              // 23505 self-heal: invalidate provider to refresh
              if (failure.code == '23505') {
                ref.invalidate(currentCompanyProvider);
              }
            }
            return null;
          },
          (id) => id,
        );
        if (companyId == null) return;

        // Upload logo if picked — MUST await
        if (_pickedImageBytes != null && _pickedImageExt != null) {
          final uploadUseCase = UploadLogoUseCase(repository);
          final uploadResult = await uploadUseCase.call(
            companyId,
            _pickedImageBytes!,
            _pickedImageExt!,
          );
          uploadResult.fold<void>(
            (failure) {
              // Logo upload failure during CREATE → SnackBar only, company saved
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                );
              }
            },
            (_) {}, // success — no action needed
          );
        }

        ref.invalidate(currentCompanyProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.companyCreated)),
          );
          context.pop();
        }
      } else {
        // ─── EDIT flow ─────────────────────────────────────────
        final updateResult = await repository.updateCompany(
          _existingCompanyId!,
          update,
        );

        final bool updateFailed = updateResult.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
            return true;
          },
          (_) => false,
        );
        if (updateFailed) return;

        // Upload logo if changed — MUST await
        if (_pickedImageBytes != null && _pickedImageExt != null) {
          final uploadUseCase = UploadLogoUseCase(repository);
          final uploadResult = await uploadUseCase.call(
            _existingCompanyId!,
            _pickedImageBytes!,
            _pickedImageExt!,
          );
          uploadResult.fold<void>(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                );
              }
            },
            (_) {}, // success — no action needed
          );
        }

        ref.invalidate(currentCompanyProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.companyUpdated)),
          );
          context.pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
