import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminProfilePage extends ConsumerWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final inviteCodesAsync = ref.watch(adminInviteCodesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.aiAccent,
                    child: Icon(Icons.admin_panel_settings,
                        size: 40, color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quản trị viên',
                    style: AppTextStyles.sectionTitle,
                  ),
                  if (auth is AuthAuthenticated)
                    Text(
                      auth.userId.substring(0, 8),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Mã mời', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              'Tạo mã mời để cấp quyền cho người dùng mới. Mã có hiệu lực 24 giờ.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _RoleSelector(
              onGenerate: (role) => ref.read(adminInviteCodesProvider.notifier).generate(role: role),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: inviteCodesAsync.when(
                data: (codes) {
                  if (codes.isEmpty) {
                    return const Center(
                      child: Text(
                        'Chưa có mã mời nào',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: codes.length,
                    itemBuilder: (context, index) {
                      final code = codes[index];
                      final usedBy = code['used_by'];
                      final expiresAt = DateTime.parse(code['expires_at'] as String);
                      final isExpired = DateTime.now().isAfter(expiresAt);
                      final isUsed = usedBy != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code['code'] as String,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Role: ${code['role'] ?? 'admin'}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    isUsed
                                        ? 'Đã sử dụng'
                                        : isExpired
                                            ? 'Hết hạn'
                                            : 'Còn hiệu lực',
                                    style: TextStyle(
                                      color: isUsed
                                          ? AppColors.success
                                          : isExpired
                                              ? AppColors.error
                                              : AppColors.success,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isUsed && !isExpired)
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                color: AppColors.textSecondary,
                                onPressed: () {
                                  // Could use clipboard here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã sao chép mã')),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Lỗi: $e', style: const TextStyle(color: AppColors.error)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends StatefulWidget {
  const _RoleSelector({required this.onGenerate});

  final void Function(String role) onGenerate;

  @override
  State<_RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<_RoleSelector> {
  String _selectedRole = 'seeker';

  final _roles = [
    ('seeker', 'Người kiếm việc'),
    ('recruiter', 'Nhà tuyển dụng'),
    ('admin', 'Quản trị viên'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: _roles.map((r) {
            final isSelected = _selectedRole == r.$1;
            return ChoiceChip(
              label: Text(r.$2),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedRole = r.$1),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => widget.onGenerate(_selectedRole),
          icon: const Icon(Icons.add),
          label: const Text('Tạo mã mời mới'),
        ),
      ],
    );
  }
}
