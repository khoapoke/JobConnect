import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../repositories/company_repository.dart';

/// Uploads a company logo with the delete-then-upload flow.
///
/// Returns the relative storage path on success
/// (e.g. `logos/{companyId}/logo.jpg`).
/// Same pattern as UploadAvatarUseCase.
class UploadLogoUseCase {
  const UploadLogoUseCase(this._repository);

  final CompanyRepository _repository;

  Future<Either<Failure, String>> call(
    String companyId, Uint8List bytes, String ext,
  ) async {
    return _repository.uploadLogo(companyId, bytes, ext);
  }
}
