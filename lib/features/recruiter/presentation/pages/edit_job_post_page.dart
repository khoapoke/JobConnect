import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/job_post.dart';
import '../../domain/entities/update_job_post_input.dart';
import '../providers/job_categories_provider.dart';
import '../providers/job_post_provider.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/job_skill_picker_sheet.dart';

/// Page for editing an existing job post.
/// Loads existing data and allows modifications.
class EditJobPostPage extends ConsumerStatefulWidget {
  const EditJobPostPage({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<EditJobPostPage> createState() => _EditJobPostPageState();
}

class _EditJobPostPageState extends ConsumerState<EditJobPostPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  String? _selectedType;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime? _expiresAt;
  bool _isRemote = false;
  bool _isSalaryVisible = true;
  Map<String, String> _selectedSkills = {}; // id -> name

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadJobPostData();
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

  Future<void> _loadJobPostData() async {
    final detail = await ref.read(jobPostDetailProvider(widget.jobId).future);
    final jobPost = detail.jobPost;
    final location = detail.location;
    final skills = detail.skills;

    setState(() {
      _titleController.text = jobPost.title;
      _descriptionController.text = jobPost.description ?? '';
      _requirementsController.text = jobPost.requirements ?? '';
      _salaryMinController.text = jobPost.salaryMin.toString();
      _salaryMaxController.text = jobPost.salaryMax.toString();
      _selectedType = jobPost.type;
      _selectedCategoryId = jobPost.categoryId;
      // Look up category name from provider
      final categories = ref.read(jobCategoriesProvider).valueOrNull ?? [];
      if (jobPost.categoryId != null) {
        final category = categories.where((c) => c.id == jobPost.categoryId).firstOrNull;
        _selectedCategoryName = category?.name;
      }
      _expiresAt = jobPost.expiresAt;
      _isSalaryVisible = jobPost.isSalaryVisible;

      _provinceController.text = location.province ?? '';
      _districtController.text = location.district ?? '';
      _addressController.text = location.address ?? '';
      _isRemote = location.isRemote;

      _selectedSkills = {
        for (final s in skills) s.skillId: s.skillName ?? '',
      };

      _isLoading = false;
    });
  }

  Future<void> _pickCategory() async {
    final categoryId = await showCategoryPickerSheet(
      context,
      selectedCategoryId: _selectedCategoryId,
    );
    if (categoryId != null && mounted) {
      // Find category name from provider
      final categories = ref.read(jobCategoriesProvider).valueOrNull ?? [];
      final category = categories.where((c) => c.id == categoryId).firstOrNull;
      
      setState(() {
        _selectedCategoryId = categoryId;
        _selectedCategoryName = category?.name;
      });
    }
  }

  Future<void> _pickSkills() async {
    final skills = await showJobSkillPickerSheet(
      context,
      alreadyPicked: _selectedSkills,
    );
    if (skills != null) {
      setState(() {
        _selectedSkills = skills;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobPostDetail = ref.watch(jobPostDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.editJobPost,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : jobPostDetail.when(
              data: (detail) => _buildForm(detail.jobPost),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${error.toString()}',
                      style: AppTextStyles.body.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildForm(JobPost jobPost) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề *',
              border: OutlineInputBorder(),
            ),
            validator: Validators.jobTitle,
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả *',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) => Validators.jobDescription(value, forPublish: false),
          ),
          const SizedBox(height: 16),

          // Requirements
          TextFormField(
            controller: _requirementsController,
            decoration: const InputDecoration(
              labelText: 'Yêu cầu *',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) => Validators.jobRequirements(value, forPublish: false),
          ),
          const SizedBox(height: 16),

          // Salary range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _salaryMinController,
                  decoration: const InputDecoration(
                    labelText: 'Lương tối thiểu (VNĐ) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.required(value, 'Lương tối thiểu'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _salaryMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Lương tối đa (VNĐ) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.required(value, 'Lương tối đa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Salary visibility
          SwitchListTile(
            title: Text(
              'Hiển thị mức lương',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            value: _isSalaryVisible,
            onChanged: (value) => setState(() => _isSalaryVisible = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          // Job type
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Loại công việc *',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'full_time', child: Text('Toàn thời gian')),
              DropdownMenuItem(value: 'part_time', child: Text('Bán thời gian')),
              DropdownMenuItem(value: 'contract', child: Text('Hợp đồng')),
              DropdownMenuItem(value: 'internship', child: Text('Thực tập')),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
            validator: (value) => Validators.required(value, 'Loại công việc'),
          ),
          const SizedBox(height: 16),

          // Category picker
          InkWell(
            onTap: _pickCategory,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: AppStrings.jobCategory,
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedCategoryName ?? '—',
                style: AppTextStyles.body.copyWith(
                  color: _selectedCategoryName != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location
          Text(
            'Địa điểm',
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _provinceController,
            decoration: const InputDecoration(
              labelText: 'Tỉnh/Thành phố *',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'Tỉnh/Thành phố'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _districtController,
            decoration: const InputDecoration(
              labelText: 'Quận/Huyện',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ cụ thể',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(
              'Làm việc từ xa',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            value: _isRemote,
            onChanged: (value) => setState(() => _isRemote = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          // Expires at
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Hạn nộp hồ sơ',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: _expiresAt != null
                  ? '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'
                  : '',
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _expiresAt = picked);
              }
            },
          ),
          const SizedBox(height: 16),

          // Required skills
          Text(
            AppStrings.requiredSkills,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
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
          const SizedBox(height: 32),

          // Action buttons
          if (_isSaving)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else ...[
            // Save button
            FilledButton(
              onPressed: () => _saveJobPost(jobPost),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                AppStrings.saveChanges,
                style: AppTextStyles.label,
              ),
            ),
            const SizedBox(height: 16),

            // Publish/Close/Discard buttons based on status
            if (jobPost.status == 'draft' || jobPost.status == 'rejected')
              FilledButton(
                onPressed: () => _publishJobPost(jobPost),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  jobPost.status == 'rejected' ? AppStrings.resubmit : AppStrings.publish,
                  style: AppTextStyles.label,
                ),
              ),
            if (jobPost.status == 'active')
              OutlinedButton(
                onPressed: () => _closeJobPost(jobPost),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  AppStrings.close,
                  style: AppTextStyles.label,
                ),
              ),
            if (jobPost.status == 'draft')
              TextButton(
                onPressed: () => _discardJobPost(jobPost),
                child: Text(
                  AppStrings.discard,
                  style: AppTextStyles.label.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveJobPost(JobPost jobPost) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final salaryMin = int.tryParse(_salaryMinController.text);
    final salaryMax = int.tryParse(_salaryMaxController.text);

    if (salaryMin == null || salaryMax == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lương không hợp lệ')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final salaryError = Validators.salaryRange(salaryMin, salaryMax);
    if (salaryError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(salaryError)),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final input = UpdateJobPostInput(
      jobId: widget.jobId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim(),
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      isSalaryVisible: _isSalaryVisible,
      type: _selectedType ?? 'full_time',
      categoryId: _selectedCategoryId,
      expiresAt: _expiresAt,
      province: _provinceController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      isRemote: _isRemote,
      skillIds: _selectedSkills.keys.toList(),
    );

    final result = await ref.read(jobPostNotifierProvider.notifier).update(input);

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.jobPostUpdated)),
        );
        ref.invalidate(myJobPostsProvider);
        ref.invalidate(jobPostDetailProvider(widget.jobId));
        context.pop();
      },
    );
  }

  Future<void> _publishJobPost(JobPost jobPost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.publishConfirmTitle),
        content: const Text(AppStrings.publishConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final result = await ref
        .read(jobPostNotifierProvider.notifier)
        .updateStatus(widget.jobId, 'active');

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.jobPostPublished)),
        );
        ref.invalidate(myJobPostsProvider);
        context.pop();
      },
    );
  }

  Future<void> _closeJobPost(JobPost jobPost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.closeConfirmTitle),
        content: const Text(AppStrings.closeConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final result = await ref
        .read(jobPostNotifierProvider.notifier)
        .updateStatus(widget.jobId, 'closed');

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.jobPostClosed)),
        );
        ref.invalidate(myJobPostsProvider);
        context.pop();
      },
    );
  }

  Future<void> _discardJobPost(JobPost jobPost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.discardConfirmTitle),
        content: const Text(AppStrings.discardConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final result = await ref
        .read(jobPostNotifierProvider.notifier)
        .updateStatus(widget.jobId, 'closed');

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.jobPostDiscarded)),
        );
        ref.invalidate(myJobPostsProvider);
        context.pop();
      },
    );
  }
}
