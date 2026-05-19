import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_update.dart';
import '../mappers/recruiter_error_mapper.dart';
import '../models/company_model.dart';

/// Supabase calls for company operations.
abstract class CompanyDatasource {
  Future<Either<Failure, Company?>> getCompanyByRecruiterId(
    String recruiterId);
  Future<Either<Failure, String>> createCompany(CompanyUpdate update);
  Future<Either<Failure, void>> updateCompany(
    String companyId, CompanyUpdate update);
  Future<Either<Failure, String>> uploadLogo(
    String companyId, Uint8List bytes, String ext);
}

class CompanyDatasourceImpl implements CompanyDatasource {
  const CompanyDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, Company?>> getCompanyByRecruiterId(
    String recruiterId,
  ) async {
    try {
      final response = await _supabase
          .from('companies')
          .select()
          .eq('recruiter_id', recruiterId)
          .maybeSingle();

      if (response == null) return const Right(null);

      final company = CompanyModel.fromJson(response).toEntity();
      return Right(company);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, String>> createCompany(CompanyUpdate update) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final result = await _supabase
          .from('companies')
          .insert({
            'recruiter_id': userId,
            ...update.toJson(),
          })
          .select('id')
          .single();

      return Right(result['id'] as String);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompany(
    String companyId,
    CompanyUpdate update,
  ) async {
    try {
      // PostgREST silent UPDATE rule: chain .select() and check if empty.
      // Empty = 0 rows affected = likely RLS block.
      final result = await _supabase
          .from('companies')
          .update(update.toJson())
          .eq('id', companyId)
          .select();

      if (result.isEmpty) {
        return const Left(DatabaseFailure(
          message: 'Không thể cập nhật hồ sơ công ty. '
              'Vui lòng thử lại.',
        ));
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLogo(
    String companyId,
    Uint8List bytes,
    String ext,
  ) async {
    try {
      // Use userId for storage path — same pattern as avatar upload.
      // RLS: auth.uid()::text = (storage.foldername(name))[2]
      // Path: logos/{userId}/logo.{ext}
      final userId = _supabase.auth.currentUser!.id;
      final storagePath = 'logos/$userId/logo.$ext';

      // 1. Delete existing logo files
      final existingFiles = await _supabase.storage
          .from('public-assets')
          .list(path: 'logos/$userId');
      if (existingFiles.isNotEmpty) {
        await _supabase.storage.from('public-assets').remove(
              existingFiles
                  .map((f) => 'logos/$userId/${f.name}')
                  .toList(),
            );
      }

      // 2. Upload new logo
      await _supabase.storage.from('public-assets').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      // 3. Update logo_url in companies table
      final updateResult = await _supabase
          .from('companies')
          .update({'logo_url': storagePath})
          .eq('id', companyId)
          .select();

      if (updateResult.isEmpty) {
        return const Left(DatabaseFailure(
          message: 'Không thể cập nhật logo. Vui lòng thử lại.',
        ));
      }

      return Right(storagePath);
    } on StorageException catch (e) {
      return Left(RecruiterErrorMapper.fromStorage(e));
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }
}
