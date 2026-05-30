import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/providers/application_provider.dart';

class ResumePreviewPage extends ConsumerWidget {
  const ResumePreviewPage({
    super.key,
    required this.resumePath,
    this.title = AppStrings.resumePreview,
  });

  final String resumePath;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytesAsync = ref.watch(resumeBytesProvider(resumePath));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: bytesAsync.when(
        data: (bytes) => PdfPreview(
          build: (_) async => Uint8List.fromList(bytes),
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
