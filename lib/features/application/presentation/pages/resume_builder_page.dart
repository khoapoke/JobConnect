import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/resume_content.dart';
import '../providers/application_provider.dart';

class ResumeBuilderPage extends ConsumerStatefulWidget {
  const ResumeBuilderPage({super.key, this.initialResume});

  final Resume? initialResume;

  @override
  ConsumerState<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends ConsumerState<ResumeBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _professionalTitleController = TextEditingController();
  final _headlineController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _workExperiencesController = TextEditingController();
  final _educationsController = TextEditingController();
  final _certificatesController = TextEditingController();

  List<int>? _previewBytes;
  bool _didPrefill = false;

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _professionalTitleController.dispose();
    _headlineController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _workExperiencesController.dispose();
    _educationsController.dispose();
    _certificatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final workExperiencesAsync = ref.watch(workExperiencesProvider);
    final educationsAsync = ref.watch(educationsProvider);
    final certificatesAsync = ref.watch(certificatesProvider);
    final userSkillsAsync = ref.watch(userSkillsProvider);
    final actionState = ref.watch(resumeActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resumeBuilder),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) {
          final workExperiences = workExperiencesAsync.valueOrNull ?? [];
          final educations = educationsAsync.valueOrNull ?? [];
          final certificates = certificatesAsync.valueOrNull ?? [];
          final userSkills = userSkillsAsync.valueOrNull ?? [];

          if (!_didPrefill) {
            _didPrefill = true;
            final existingContent = widget.initialResume?.content;
            _titleController.text =
                widget.initialResume?.title ?? 'CV ${profile.fullName}';
            _fullNameController.text =
                existingContent?.fullName ?? profile.fullName;
            _professionalTitleController.text =
                existingContent?.professionalTitle ?? profile.headline ?? '';
            _headlineController.text =
                existingContent?.headline ?? profile.headline ?? '';
            _emailController.text = existingContent?.contactEmail ?? '';
            _locationController.text =
                existingContent?.location ?? profile.location ?? '';
            _summaryController.text =
                existingContent?.summary ?? profile.bio ?? '';
            _skillsController.text =
                existingContent?.skills.join('\n') ??
                userSkills.map((item) => item.skillName).join('\n');
            _workExperiencesController.text =
                existingContent?.workExperiences.join('\n') ??
                workExperiences
                    .map(
                      (item) =>
                          '${item.role} tại ${item.company} (${_dateRange(item.fromDate, item.toDate, item.isCurrent)})${item.description?.trim().isNotEmpty == true ? ' — ${item.description!.trim()}' : ''}',
                    )
                    .join('\n');
            _educationsController.text =
                existingContent?.educations.join('\n') ??
                educations
                    .map(
                      (item) =>
                          '${item.degree?.trim().isNotEmpty == true ? '${item.degree} · ' : ''}${item.major?.trim().isNotEmpty == true ? '${item.major} · ' : ''}${item.school} (${_dateRange(item.fromDate, item.toDate, false)})',
                    )
                    .join('\n');
            _certificatesController.text =
                existingContent?.certificates.join('\n') ??
                certificates
                    .map(
                      (item) =>
                          '${item.name}${item.issuer?.trim().isNotEmpty == true ? ' — ${item.issuer}' : ''}',
                    )
                    .join('\n');
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialResume == null
                            ? AppStrings.firstResumeDefault
                            : AppStrings.editResume,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.resumeTitle,
                        ),
                        validator: Validators.resumeTitle,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.fullNameLabel,
                        ),
                        validator: Validators.fullName,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _professionalTitleController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.professionalTitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _headlineController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.headlineLabel,
                        ),
                        validator: Validators.headline,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.contactEmail,
                        ),
                        validator: Validators.emailOptional,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.locationLabel,
                        ),
                        validator: Validators.location,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _summaryController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.summary,
                          hintText: AppStrings.summaryHint,
                        ),
                        maxLines: 5,
                        validator: Validators.summary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _multilineSection(
                  title: AppStrings.skills,
                  controller: _skillsController,
                ),
                const SizedBox(height: 16),
                _multilineSection(
                  title: AppStrings.workExperience,
                  controller: _workExperiencesController,
                ),
                const SizedBox(height: 16),
                _multilineSection(
                  title: AppStrings.education,
                  controller: _educationsController,
                ),
                const SizedBox(height: 16),
                _multilineSection(
                  title: AppStrings.certificate,
                  controller: _certificatesController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: actionState.isLoading ? null : _buildPreview,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text(AppStrings.resumePreview),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: actionState.isLoading ? null : _saveResume,
                        icon: actionState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text(AppStrings.saveResume),
                      ),
                    ),
                  ],
                ),
                if (_previewBytes != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 560,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: PdfPreview(
                        build: (_) async => Uint8List.fromList(_previewBytes!),
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _multilineSection({
    required String title,
    required TextEditingController controller,
  }) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.oneItemPerLine,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: controller, maxLines: 7),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  ResumeContent _buildContent() {
    List<String> parseLines(String raw) => raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return ResumeContent(
      fullName: _fullNameController.text.trim(),
      professionalTitle: _professionalTitleController.text.trim(),
      headline: _headlineController.text.trim(),
      contactEmail: _emailController.text.trim(),
      location: _locationController.text.trim(),
      summary: _summaryController.text.trim(),
      skills: parseLines(_skillsController.text),
      workExperiences: parseLines(_workExperiencesController.text),
      educations: parseLines(_educationsController.text),
      certificates: parseLines(_certificatesController.text),
    );
  }

  Future<void> _buildPreview() async {
    if (!_formKey.currentState!.validate()) return;
    final bytes = await ref
        .read(resumePdfServiceProvider)
        .buildPdf(
          title: _titleController.text.trim(),
          content: _buildContent(),
        );
    if (!mounted) return;
    setState(() => _previewBytes = bytes);
  }

  Future<void> _saveResume() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(resumeActionNotifierProvider.notifier);
    final result = widget.initialResume == null
        ? await notifier.createBuilderResume(
            userId: auth.userId,
            title: _titleController.text.trim(),
            content: _buildContent(),
          )
        : await notifier.updateBuilderResume(
            resumeId: widget.initialResume!.id,
            userId: auth.userId,
            title: _titleController.text.trim(),
            content: _buildContent(),
            currentFileUrl: widget.initialResume!.fileUrl ?? '',
          );

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialResume == null
                  ? AppStrings.resumeSaved
                  : AppStrings.resumeUpdated,
            ),
          ),
        );
        context.pop();
      },
    );
  }

  String _dateRange(DateTime fromDate, DateTime? toDate, bool isCurrent) {
    final from =
        '${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}';
    final to = isCurrent || toDate == null
        ? AppStrings.currently
        : '${toDate.month.toString().padLeft(2, '0')}/${toDate.year}';
    return '$from - $to';
  }
}
