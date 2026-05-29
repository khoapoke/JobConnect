import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/job_category.dart';
import '../providers/job_categories_provider.dart';

/// Bottom sheet for picking a single job category.
///
/// Flow:
/// 1. Fetches all categories via jobCategoriesProvider
/// 2. Shows them in a scrollable list
/// 3. Highlights currently selected category
/// 4. Tap → returns the selected category ID
Future<String?> showCategoryPickerSheet(
  BuildContext context, {
  String? selectedCategoryId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryPickerSheet(
      selectedCategoryId: selectedCategoryId,
    ),
  );
}

class _CategoryPickerSheet extends ConsumerStatefulWidget {
  const _CategoryPickerSheet({this.selectedCategoryId});

  final String? selectedCategoryId;

  @override
  ConsumerState<_CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<_CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Material(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    AppStrings.selectCategory,
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
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Category list
            Expanded(
              child: categoriesAsync.when(
                data: (categories) => _buildCategoryList(
                  categories,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List<JobCategory> categories,
    ScrollController scrollController,
  ) {
    final filtered = _searchQuery.isEmpty
        ? categories
        : categories
            .where((c) =>
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
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
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        final isSelected = category.id == widget.selectedCategoryId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context, category.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      category.name,
                      style: AppTextStyles.body.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
