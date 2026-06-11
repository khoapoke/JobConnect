import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../providers/auth_deps.dart';
import '../providers/register_state.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selectedRole = ref.read(registerRoleProvider);
    if (!_formKey.currentState!.validate() || selectedRole == null) return;

    ref.read(registerIsLoadingProvider.notifier).setLoading(true);

    final res = await ref.read(registerUseCaseProvider).call(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: selectedRole,
          fullName: _nameController.text.trim(),
        );

    ref.read(registerIsLoadingProvider.notifier).setLoading(false);

    res.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registerIsLoadingProvider);
    final selectedRole = ref.watch(registerRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(AppStrings.register, style: AppTextStyles.display),
              const SizedBox(height: 6),
              Text(
                'Tạo tài khoản để bắt đầu với JobConnect',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: 'Họ và tên',
                controller: _nameController,
                validator: Validators.fullName,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Mật khẩu',
                controller: _passwordController,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Xác nhận mật khẩu',
                controller: _confirmController,
                obscureText: true,
                validator: (val) => Validators.confirmPassword(val, _passwordController.text),
              ),
              const SizedBox(height: 24),
              const Text('Bạn là:', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Người kiếm việc',
                      icon: Icons.person_search,
                      isSelected: selectedRole == UserRole.seeker,
                      onTap: () => ref.read(registerRoleProvider.notifier).setRole(UserRole.seeker),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'Nhà tuyển dụng',
                      icon: Icons.business,
                      isSelected: selectedRole == UserRole.recruiter,
                      onTap: () => ref.read(registerRoleProvider.notifier).setRole(UserRole.recruiter),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              PremiumButton(
                label: AppStrings.register,
                isLoading: isLoading,
                onPressed: selectedRole == null || isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
