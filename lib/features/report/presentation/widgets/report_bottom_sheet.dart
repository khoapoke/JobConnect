import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/report_provider.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetSnapshot,
  });

  final String targetType;
  final String targetId;
  final Map<String, dynamic>? targetSnapshot;

  static Future<void> show({
    required BuildContext context,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? targetSnapshot,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReportBottomSheet(
        targetType: targetType,
        targetId: targetId,
        targetSnapshot: targetSnapshot,
      ),
    );
  }

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  String? _selectedReason;
  final _detailsController = TextEditingController();

  final _reasons = const [
    'Nội dung lừa đảo / scam',
    'Thông tin sai lệch',
    'Nội dung không phù hợp',
    'Spam',
    'Khác',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    final success = await ref.read(reportNotifierProvider.notifier).submit(
          targetType: widget.targetType,
          targetId: widget.targetId,
          reason: _selectedReason!,
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
          targetSnapshot: widget.targetSnapshot,
        );
    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi báo cáo. Cảm ơn bạn!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportNotifierProvider);
    final isLoading = state.isLoading;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Báo cáo vi phạm',
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Chọn lý do báo cáo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _reasons.length,
                  itemBuilder: (context, index) {
                    final reason = _reasons[index];
                    final isSelected = _selectedReason == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ChoiceChip(
                        label: Text(reason),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedReason = reason),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedReason == 'Khác')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết...',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    state.error.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _selectedReason == null || isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi báo cáo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
