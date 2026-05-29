import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/profile/domain/entities/skill.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';

/// Bottom sheet for picking skills for a Job Post.
///
/// Unlike T-12's SkillPickerSheet (which writes to user_skills),
/// this picker just returns selected skill IDs and names — no database writes.
///
/// Flow:
/// 1. Fetches all skills from skills table (joined with category name)
/// 2. Filters out already-picked skill IDs
/// 3. Groups by category, sorted alphabetically
/// 4. Tap a skill → adds to selection, stays open for more
/// 5. Close button → returns map of {id: name}
Future<Map<String, String>?> showJobSkillPickerSheet(
  BuildContext context, {
  required Map<String, String> alreadyPicked,
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JobSkillPickerSheet(
      alreadyPicked: alreadyPicked,
    ),
  );
}

class _JobSkillPickerSheet extends ConsumerStatefulWidget {
  const _JobSkillPickerSheet({required this.alreadyPicked});

  final Map<String, String> alreadyPicked;

  @override
  ConsumerState<_JobSkillPickerSheet> createState() =>
      _JobSkillPickerSheetState();
}

class _JobSkillPickerSheetState extends ConsumerState<_JobSkillPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  final Map<String, String> _selectedNames = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _toggleSkill(Skill skill) {
    setState(() {
      if (_selectedIds.contains(skill.id)) {
        _selectedIds.remove(skill.id);
        _selectedNames.remove(skill.id);
      } else {
        _selectedIds.add(skill.id);
        _selectedNames[skill.id] = skill.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(availableSkillsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Material(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          children: [
            // Handle bar + title + done button
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.selectSkill,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final result = _selectedIds.isEmpty
                              ? null
                              : {
                                  for (final id in _selectedIds)
                                    id: _selectedNames[id]!,
                                };
                          Navigator.pop(context, result);
                        },
                        child: Text(
                          '${AppStrings.saveChanges} (${_selectedIds.length})',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Skills list
            Expanded(
              child: skillsAsync.when(
                data: (skills) => _buildSkillList(skills, scrollController),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillList(
    List<Skill> allSkills,
    ScrollController scrollController,
  ) {
    final alreadyPickedIds = widget.alreadyPicked.keys.toSet();

    // Filter out already-picked skills (from the form) and apply search
    final filteredSkills = allSkills.where((s) {
      if (alreadyPickedIds.contains(s.id) && !_selectedIds.contains(s.id)) {
        return false;
      }
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
    final isSelected = _selectedIds.contains(skill.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _toggleSkill(skill),
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
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
