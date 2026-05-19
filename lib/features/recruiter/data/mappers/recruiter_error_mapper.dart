import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';

class RecruiterErrorMapper {
  const RecruiterErrorMapper._();

  static Failure fromPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DatabaseFailure(
          message: 'Bạn đã có hồ sơ công ty. '
              'Vui lòng làm mới trang.',
          code: e.code,
        ),
      '23503' => DatabaseFailure(
          message: 'Dữ liệu liên quan không tồn tại.',
          code: e.code,
        ),
      '42501' => DatabaseFailure(
          message: 'Bạn không có quyền thực hiện '
              'thao tác này.',
          code: e.code,
        ),
      _ => DatabaseFailure(
          message: AppStrings.errorGeneral,
          code: e.code,
        ),
    };
  }

  static Failure fromStorage(StorageException e) =>
      StorageFailure(message: e.message);

  static Failure fromUnknown(Object e, StackTrace st) =>
      NetworkFailure(
        message: AppStrings.errorGeneral,
        stackTrace: st,
      );
}
