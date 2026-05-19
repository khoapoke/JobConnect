import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/company.dart';
import '../entities/company_update.dart';

abstract class CompanyRepository {
  /// Fetch the Recruiter's company. Returns null if not created yet.
  Future<Either<Failure, Company?>> getCompanyByRecruiterId(
    String recruiterId);

  /// Create a new company. Returns the generated company ID.
  Future<Either<Failure, String>> createCompany(CompanyUpdate update);

  /// Update an existing company's text fields.
  Future<Either<Failure, void>> updateCompany(
    String companyId, CompanyUpdate update);

  /// Upload logo to Storage and update companies.logo_url.
  /// Flow: delete existing → upload new → UPDATE logo_url.
  Future<Either<Failure, String>> uploadLogo(
    String companyId, Uint8List bytes, String ext);
}
