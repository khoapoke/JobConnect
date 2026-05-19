import 'dart:typed_data';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_update.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_datasource.dart';

/// Thin pass-through to datasource (same pattern as ProfileRepositoryImpl).
class CompanyRepositoryImpl implements CompanyRepository {
  const CompanyRepositoryImpl(this._datasource);

  final CompanyDatasource _datasource;

  @override
  Future<Either<Failure, Company?>> getCompanyByRecruiterId(
    String recruiterId,
  ) async {
    return _datasource.getCompanyByRecruiterId(recruiterId);
  }

  @override
  Future<Either<Failure, String>> createCompany(CompanyUpdate update) async {
    return _datasource.createCompany(update);
  }

  @override
  Future<Either<Failure, void>> updateCompany(
    String companyId,
    CompanyUpdate update,
  ) async {
    return _datasource.updateCompany(companyId, update);
  }

  @override
  Future<Either<Failure, String>> uploadLogo(
    String companyId,
    Uint8List bytes,
    String ext,
  ) async {
    return _datasource.uploadLogo(companyId, bytes, ext);
  }
}
