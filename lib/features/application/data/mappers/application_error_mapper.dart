import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';

class ApplicationErrorMapper {
  const ApplicationErrorMapper._();

  static Failure fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DatabaseFailure(
        message: AppStrings.duplicateApplication,
        code: e.code,
      ),
      '23503' => DatabaseFailure(
        message: 'Dữ liệu liên quan không tồn tại.',
        code: e.code,
      ),
      '42501' => DatabaseFailure(
        message: 'Bạn không có quyền thực hiện thao tác này.',
        code: e.code,
      ),
      'P0001' => DatabaseFailure(message: e.message, code: e.code),
      _ => DatabaseFailure(
        message: e.message.isNotEmpty ? e.message : AppStrings.errorGeneral,
        code: e.code,
      ),
    };
  }

  static Failure fromStorage(StorageException e) =>
      StorageFailure(message: e.message);

  static Failure fromUnknown(Object error, StackTrace stackTrace) {
    return NetworkFailure(
      message: AppStrings.errorGeneral,
      stackTrace: stackTrace,
    );
  }
}
