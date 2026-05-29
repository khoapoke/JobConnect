import 'package:flutter/material.dart';

import '../../core/constants/vietnam_provinces.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Bottom sheet for picking a Vietnamese province.
///
/// Features:
/// - Search TextField at top (case-insensitive contains matching)
/// - ListView of matching provinces from VietnamProvinces.all
/// - Highlights currently selected province
/// - Reused by: T-13 (Company), T-14 (Job Location), T-16 (Search filter)
class ProvincePickerSheet extends StatefulWidget {
  const ProvincePickerSheet({
    super.key,
    this.selectedProvince,
  });

  /// Currently selected province to highlight.
  final String? selectedProvince;

  @override
  State<ProvincePickerSheet> createState() => _ProvincePickerSheetState();
}

class _ProvincePickerSheetState extends State<ProvincePickerSheet> {
  final _searchController = TextEditingController();
  List<String> _filteredProvinces = VietnamProvinces.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProvinces = VietnamProvinces.all;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredProvinces = VietnamProvinces.all
            .where((p) => p.toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.surfaceVariant,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Column(
            children: [
              const SizedBox(height: 8),
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
                'Chọn tỉnh / thành phố',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
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
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredProvinces.length,
                  itemBuilder: (context, index) {
                    final province = _filteredProvinces[index];
                    final isSelected = province == widget.selectedProvince;
                    return ListTile(
                      title: Text(
                        province,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, province),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows the province picker bottom sheet and returns the selected province.
Future<String?> showProvincePickerSheet(
  BuildContext context, {
  String? selectedProvince,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProvincePickerSheet(selectedProvince: selectedProvince),
  );
}
