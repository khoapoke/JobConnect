import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/job_post_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/province_picker_sheet.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../providers/company_provider.dart';
import '../providers/job_categories_provider.dart';
import '../providers/job_post_provider.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/expires_at_picker.dart';
import '../widgets/job_skill_picker_sheet.dart';

/// Create Job Post form (push route at `/recruiter/posts/new`).
///
/// ConsumerStatefulWidget with TextEditingControllers.
/// Reads currentCompanyProvider ONCE in initState for company ID.
/// Always saves as draft (status='draft').
class CreateJobPostPage extends ConsumerStatefulWidget {
  const CreateJobPostPage({super.key});

  @override
  ConsumerState<CreateJobPostPage> createState() =>
      _CreateJobPostPageState();
}

class _CreateJobPostPageState extends ConsumerState<CreateJobPostPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _requirementsController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _addressController;

  JobPostType _selectedType = JobPostType.fullTime;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime? _expiresAt;
  bool _isRemote = false;
  bool _isSalaryVisible = true;
  final Map<String, String> _selectedSkills = {}; // id -> name
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController()
      ..addListener(_markChanged);
    _descriptionController = TextEditingController()
      ..addListener(_markChanged);
    _requirementsController = TextEditingController()
      ..addListener(_markChanged);
    _salaryMinController = TextEditingController()
      ..addListener(_markChanged);
    _salaryMaxController = TextEditingController()
      ..addListener(_markChanged);
    _provinceController = TextEditingController()
      ..addListener(_markChanged);
    _districtController = TextEditingController()
      ..addListener(_markChanged);
    _addressController = TextEditingController()
      ..addListener(_markChanged);

    _expiresAt = DateTime.now().add(const Duration(days: 30));
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(currentCompanyProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.createJobPost,
            style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _hasChanges ? _confirmLeave : () => context.pop(),
          ),
        ),
        body: companyAsync.when(
          data: (company) {
            if (company == null) {
              return const Center(
                child: Text('Company not found. Please create a company first.'),
              );
            }
            return _buildForm();
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error: ${error.toString()}',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Job title
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(AppStrings.jobTitle).copyWith(
                    counterText:
                        '${_titleController.text.length}/100',
                  ),
                  maxLength: 100,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: Validators.jobTitle,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 2. Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(AppStrings.jobDescription)
                      .copyWith(
                    hintText: AppStrings.jobDescriptionHint,
                    counterText:
                        '${_descriptionController.text.length}/5000',
                  ),
                  maxLength: 5000,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) =>
                      Validators.jobDescription(v, forPublish: false),
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),

                // 3. Requirements
                TextFormField(
                  controller: _requirementsController,
                  decoration: _inputDecoration(AppStrings.jobRequirements)
                      .copyWith(
                    hintText: AppStrings.jobRequirementsHint,
                    counterText:
                        '${_requirementsController.text.length}/3000',
                  ),
                  maxLength: 3000,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: (v) =>
                      Validators.jobRequirements(v, forPublish: false),
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),

                // 4. Employment type (SegmentedButton)
                _sectionLabel(AppStrings.jobType),
                const SizedBox(height: 8),
                SegmentedButton<JobPostType>(
                  segments: JobPostType.values.map((type) {
                    return ButtonSegment<JobPostType>(
                      value: type,
                      label: Text(type.displayLabel),
                    );
                  }).toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _selectedType = selected.first;
                      _hasChanges = true;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    selectedBackgroundColor: AppColors.primary.withAlpha(30),
                    foregroundColor: AppColors.textPrimary,
                    selectedForegroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Category picker
                _buildCategoryRow(),
                const SizedBox(height: 16),

                // 6. Salary
                _sectionLabel(AppStrings.salaryRange),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMinController,
                        decoration: _inputDecoration(AppStrings.salaryFrom)
                            .copyWith(
                          suffixText: AppStrings.salaryMillionPerMonth,
                        ),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMaxController,
                        decoration: _inputDecoration(AppStrings.salaryTo)
                            .copyWith(
                          suffixText: AppStrings.salaryMillionPerMonth,
                        ),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Salary visibility switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.showSalary,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isSalaryVisible,
                      onChanged: (val) {
                        setState(() {
                          _isSalaryVisible = val;
                          _hasChanges = true;
                        });
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Location subform
                _sectionLabel(AppStrings.jobLocation),
                const SizedBox(height: 8),

                // Remote switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.remoteWork,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isRemote,
                      onChanged: (val) {
                        setState(() {
                          _isRemote = val;
                          _hasChanges = true;
                        });
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Province picker
                TextFormField(
                  controller: _provinceController,
                  readOnly: true,
                  decoration: _inputDecoration(AppStrings.province).copyWith(
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  validator: Validators.province,
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
                const SizedBox(height: 12),

                // District
                TextFormField(
                  controller: _districtController,
                  decoration: _inputDecoration(AppStrings.district),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration(AppStrings.address).copyWith(
                    hintText: AppStrings.addressHint,
                  ),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // 8. Required skills
                _sectionLabel(AppStrings.requiredSkills),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedSkills.entries.map((entry) {
                      return Chip(
                        label: Text(
                          entry.value,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withAlpha(20),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedSkills.remove(entry.key);
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                    if (_selectedSkills.length < 15)
                      ActionChip(
                        label: Text(
                          '+ ${AppStrings.addSkill}',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onPressed: _pickSkills,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_selectedSkills.length}${AppStrings.skillCount}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 9. Expires at
                _buildExpiresAtRow(),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor:
                          AppColors.primary.withAlpha(128),
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
                            AppStrings.saveDraft,
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
        );
    }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
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

  Widget _buildCategoryRow() {
    return InkWell(
      onTap: _pickCategory,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.jobCategory,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCategoryName ?? '—',
                    style: AppTextStyles.body.copyWith(
                      color: _selectedCategoryName != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiresAtRow() {
    return InkWell(
      onTap: _pickExpiresAt,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.expiresAt,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _expiresAt != null
                        ? formatExpiresAt(_expiresAt!)
                        : '—',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCategory() async {
    final result = await showCategoryPickerSheet(
      context,
      selectedCategoryId: _selectedCategoryId,
    );
    if (result != null) {
      final categories = ref.read(jobCategoriesProvider).valueOrNull;
      final category = categories?.where((c) => c.id == result).firstOrNull;
      if (category != null && mounted) {
        setState(() {
          _selectedCategoryId = result;
          _selectedCategoryName = category.name;
          _hasChanges = true;
        });
      }
    }
  }

  Future<void> _pickExpiresAt() async {
    final result = await showExpiresAtPicker(
      context,
      initialDate: _expiresAt,
    );
    if (result != null) {
      setState(() {
        _expiresAt = result;
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickSkills() async {
    final result = await showJobSkillPickerSheet(
      context,
      alreadyPicked: _selectedSkills,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedSkills.addAll(result);
        _hasChanges = true;
      });
    }
  }

  Future<void> _confirmLeave() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: AlertDialog(
          title: Text(
            AppStrings.unsavedChangesTitle,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            AppStrings.unsavedChangesMessage,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                AppStrings.stay,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                AppStrings.leave,
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
        ),
      ),
    );
    if (result == true && mounted) {
      context.pop();
    }
  }

  Future<void> _handleSave() async {
    // Validate salary as integer fields
    final salaryMin = int.tryParse(_salaryMinController.text.trim());
    final salaryMax = int.tryParse(_salaryMaxController.text.trim());

    // Convert millions to raw VND
    final salaryMinRaw = salaryMin != null ? salaryMin * 1000000 : null;
    final salaryMaxRaw = salaryMax != null ? salaryMax * 1000000 : null;

    final salaryError = Validators.salaryRange(salaryMinRaw, salaryMaxRaw);
    if (salaryError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(salaryError)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final company = ref.read(currentCompanyProvider).valueOrNull;
      if (company == null) return;

      final input = CreateJobPostInput(
        companyId: company.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim(),
        salaryMin: salaryMinRaw!,
        salaryMax: salaryMaxRaw!,
        isSalaryVisible: _isSalaryVisible,
        type: _selectedType.value,
        categoryId: _selectedCategoryId,
        expiresAt: _expiresAt,
        province: _provinceController.text.trim(),
        district: _districtController.text.trim().isNotEmpty
            ? _districtController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        isRemote: _isRemote,
        skillIds: _selectedSkills.keys.toList(),
      );

      final result = await ref.read(jobPostNotifierProvider.notifier).create(input);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (jobId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.draftSaved)),
            );
            context.pop();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
