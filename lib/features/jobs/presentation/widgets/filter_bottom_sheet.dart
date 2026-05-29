import 'package:flutter/material.dart';

import '../../../../core/constants/vietnam_provinces.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../recruiter/presentation/providers/job_categories_provider.dart';
import '../../domain/entities/job_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for filtering job search results.
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
  });

  final JobFilter initialFilter;

  @override
  ConsumerState<FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late List<String> _selectedCategoryIds;
  late List<String> _selectedProvinces;
  late List<String> _selectedJobTypes;
  SalaryRange? _selectedSalaryRange;
  late bool _isRemote;
  bool _remoteToggled = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List.from(widget.initialFilter.categoryIds);
    _selectedProvinces = List.from(widget.initialFilter.provinces);
    _selectedJobTypes = List.from(widget.initialFilter.jobTypes);
    _selectedSalaryRange = widget.initialFilter.salaryRange;
    _isRemote = widget.initialFilter.isRemote ?? false;
    _remoteToggled = widget.initialFilter.isRemote != null;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Xóa tất cả',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          // Filter content (scrollable via outer DraggableScrollableSheet)
          // Category (multi-select)
          _sectionTitle('Ngành nghề'),
          categoriesAsync.when(
            data: (categories) => _MultiSelectChips(
              options: categories
                  .map((c) => _Option(label: c.name, value: c.id))
                  .toList(),
              selectedValues: _selectedCategoryIds,
              onToggle: _toggleCategory,
            ),
            loading: () => const _LoadingChips(count: 5),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Location / Province (multi-select)
          _sectionTitle('Tỉnh / Thành phố'),
          _MultiSelectChips(
            options: VietnamProvinces.all
                .map((p) => _Option(label: p, value: p))
                .toList(),
            selectedValues: _selectedProvinces,
            onToggle: _toggleProvince,
          ),
          const SizedBox(height: 16),

          // Job Type (multi-select)
          _sectionTitle('Loại hình'),
          _MultiSelectChips(
            options: kJobTypeLabels.entries
                .map((e) => _Option(label: e.value, value: e.key))
                .toList(),
            selectedValues: _selectedJobTypes,
            onToggle: _toggleJobType,
          ),
          const SizedBox(height: 16),

          // Salary Range (single-select)
          _sectionTitle('Mức lương'),
          _SingleSelectChips(
            options: kSalaryRanges
                .map((r) => _Option(label: r.label, value: r.label))
                .toList(),
            selectedValue: _selectedSalaryRange?.label,
            onTap: _toggleSalaryRange,
          ),
          const SizedBox(height: 16),

          // Remote toggle
          _sectionTitle('Làm việc từ xa'),
          SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isRemote ? 'Chỉ tìm việc từ xa' : 'Tất cả địa điểm',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    value: _isRemote,
                    onChanged: (value) {
                      setState(() {
                        _isRemote = value;
                        _remoteToggled = true;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Áp dụng bộ lọc',
                style: AppTextStyles.title.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.title.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleProvince(String province) {
    setState(() {
      if (_selectedProvinces.contains(province)) {
        _selectedProvinces.remove(province);
      } else {
        _selectedProvinces.add(province);
      }
    });
  }

  void _toggleJobType(String type) {
    setState(() {
      if (_selectedJobTypes.contains(type)) {
        _selectedJobTypes.remove(type);
      } else {
        _selectedJobTypes.add(type);
      }
    });
  }

  void _toggleSalaryRange(String label) {
    setState(() {
      if (_selectedSalaryRange?.label == label) {
        _selectedSalaryRange = null;
      } else {
        _selectedSalaryRange = kSalaryRanges.firstWhere(
          (r) => r.label == label,
        );
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedProvinces.clear();
      _selectedJobTypes.clear();
      _selectedSalaryRange = null;
      _isRemote = false;
      _remoteToggled = false;
    });
  }

  void _applyFilters() {
    final filter = JobFilter(
      categoryIds: List.unmodifiable(_selectedCategoryIds),
      provinces: List.unmodifiable(_selectedProvinces),
      jobTypes: List.unmodifiable(_selectedJobTypes),
      salaryRange: _selectedSalaryRange,
      isRemote: _remoteToggled ? _isRemote : null,
    );
    Navigator.pop(context, filter);
  }
}

class _Option {
  const _Option({required this.label, required this.value});
  final String label;
  final String value;
}

class _MultiSelectChips extends StatelessWidget {
  const _MultiSelectChips({
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final List<_Option> options;
  final List<String> selectedValues;
  final void Function(String value) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selectedValues.contains(option.value);
          return FilterChip(
            label: Text(
              option.label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onToggle(option.value),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          );
        }).toList(),
      );
    }
}

class _SingleSelectChips extends StatelessWidget {
  const _SingleSelectChips({
    required this.options,
    required this.selectedValue,
    required this.onTap,
  });

  final List<_Option> options;
  final String? selectedValue;
  final void Function(String value) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return FilterChip(
          label: Text(
            option.label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onTap(option.value),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        );
      }).toList(),
    );
  }
}

class _LoadingChips extends StatelessWidget {
  const _LoadingChips({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        count,
        (_) => Container(
          height: 32,
          width: 60 + (count * 7) % 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
        ),
      ),
    );
  }
}
