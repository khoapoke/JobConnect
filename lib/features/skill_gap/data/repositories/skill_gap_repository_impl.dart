import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/skill_gap_advice.dart';
import '../../domain/repositories/skill_gap_repository.dart';
import '../datasources/skill_gap_datasource.dart';

part 'skill_gap_repository_impl.g.dart';

class SkillGapRepositoryImpl implements SkillGapRepository {
  const SkillGapRepositoryImpl(this._datasource);

  final SkillGapDatasource _datasource;

  @override
  Future<Either<Failure, SkillGapAdvice>> getSkillGapAdvice(String jobId) {
    return _datasource.getSkillGapAdvice(jobId);
  }
}

@riverpod
SkillGapRepository skillGapRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return SkillGapRepositoryImpl(SkillGapDatasourceImpl(supabase));
}
