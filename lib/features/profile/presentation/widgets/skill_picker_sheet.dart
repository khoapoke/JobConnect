import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/user_skill.dart';
import '../providers/profile_provider.dart';

/// Bottom sheet for adding new skills to the user's profile.
///
/// Flow per plan Section 8:
/// 1. Search TextField at top filters availableSkillsProvider
/// 2. Skills grouped by categoryName, sorted alphabetically
/// 3. Already-added skills filtered out
/// 4. Tap a skill → inline ChoiceChips appear for level selection
/// 5. Tap level → calls repository.addUserSkill → stays open for more
void showSkillPickerSheet(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SkillPickerSheet(userId: userId),
  );
}

class _SkillPickerSheet extends ConsumerStatefulWidget {
  const _SkillPickerSheet({required this.userId});

  final String userId;

  @override
  ConsumerState<_SkillPickerSheet> createState() => _SkillPickerSheetState();
}

class _SkillPickerSheetState extends ConsumerState<_SkillPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSkillId;
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableAsync = ref.watch(availableSkillsProvider);
    final userSkillsAsync = ref.watch(userSkillsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar + title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
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
                  Text(
                    AppStrings.skills,
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchSkill,
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
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
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Skills list
            Expanded(
              child: availableAsync.when(
                data: (allSkills) => userSkillsAsync.when(
                  data: (userSkills) => _buildSkillList(
                    allSkills,
                    userSkills,
                    scrollController,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      AppStrings.errorGeneral,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, __) => Center(
                  child: Text(
                    AppStrings.errorGeneral,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillList(
    List<Skill> allSkills,
    List<UserSkill> userSkills,
    ScrollController scrollController,
  ) {
    final userSkillIds = userSkills.map((s) => s.skillId).toSet();

    // Filter out already-added skills and apply search
    final filteredSkills = allSkills.where((s) {
      if (userSkillIds.contains(s.id)) return false;
      if (_searchQuery.isNotEmpty) {
        return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Group by category
    final grouped = <String, List<Skill>>{};
    for (final skill in filteredSkills) {
      grouped.putIfAbsent(skill.categoryName, () => []).add(skill);
    }

    // Sort categories alphabetically
    final sortedCategories = grouped.keys.toList()..sort();

    if (sortedCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppStrings.noData,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final skills = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              category,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...skills.map((skill) => _buildSkillItem(skill)),
          ],
        );
      },
    );
  }

  Widget _buildSkillItem(Skill skill) {
    final isSelected = _selectedSkillId == skill.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedSkillId = isSelected ? null : skill.id;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(20)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              skill.name,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Level selection (appears when skill is selected)
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 8),
            child: Row(
              children: ['beginner', 'intermediate', 'advanced']
                  .map(
                    (level) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          UserSkill.levelLabelFor(level),
                          style: AppTextStyles.label,
                        ),
                        selected: false,
                        onSelected: _isAdding
                            ? null
                            : (_) => _addSkill(skill.id, level),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withAlpha(30),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _addSkill(String skillId, String level) async {
    setState(() => _isAdding = true);
    try {
      final result = await ref
          .read(profileRepositoryProvider)
          .addUserSkill(widget.userId, skillId, level);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          ref.invalidate(userSkillsProvider);
          setState(() => _selectedSkillId = null);
        },
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}

/// Shows a small bottom sheet to edit the level of an existing user skill.
void showEditSkillLevelSheet(
  BuildContext context,
  WidgetRef _, {
  required UserSkill skill,
  required String userId,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceVariant,
    builder: (sheetContext) => Consumer(
      builder: (consumerCtx, ref, __) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${skill.skillName} — ${AppStrings.selectLevel}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['beginner', 'intermediate', 'advanced']
                    .map(
                      (level) => ChoiceChip(
                        label: Text(
                          UserSkill.levelLabelFor(level),
                          style: AppTextStyles.label,
                        ),
                        selected: skill.level == level,
                        onSelected: (selected) async {
                          if (!selected) return;
                          final result = await ref
                              .read(profileRepositoryProvider)
                              .updateUserSkillLevel(
                                  userId, skill.skillId, level);
                          result.fold(
                            (failure) {
                              if (sheetContext.mounted) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(content: Text(failure.message)),
                                );
                              }
                            },
                            (_) {
                              ref.invalidate(userSkillsProvider);
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                          );
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withAlpha(30),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

