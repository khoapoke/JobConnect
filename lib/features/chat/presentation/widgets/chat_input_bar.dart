import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _canSend) {
        setState(() => _canSend = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: GlassSurface(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadii.radiusLg),
          topRight: Radius.circular(AppRadii.radiusLg),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space3,
          AppSpacing.space4,
          AppSpacing.space4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                maxLength: 1000,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: TextStyle(
                  color: AppColors.inkFor(brightness),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.chatInputHint,
                  hintStyle: TextStyle(
                    color: AppColors.gray400For(brightness),
                    fontSize: 15,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceVariantFor(brightness),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.radiusLg),
                    borderSide: BorderSide(
                      color: AppColors.hairlineFor(brightness),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.radiusLg),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _SendButton(
                canSend: _canSend,
                onTap: _canSend ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.canSend, this.onTap});

  final bool canSend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedScale(
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: canSend ? 1.0 : 0.88,
      child: Container(
        decoration: BoxDecoration(
          color: canSend ? AppColors.accent : AppColors.surfaceVariantFor(brightness),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Icon(
                Icons.send_rounded,
                color: canSend
                    ? AppColors.onAccent
                    : AppColors.gray400For(brightness),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
