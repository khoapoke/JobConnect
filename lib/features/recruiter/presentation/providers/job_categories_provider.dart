import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/domain/entities/job_category.dart';

part 'job_categories_provider.g.dart';

/// Lookup provider for all job categories.
/// Used by CategoryPickerSheet and CreateJobPostPage.
@riverpod
Future<List<JobCategory>> jobCategories(Ref ref) async {
  final data = await Supabase.instance.client
      .from('job_categories')
      .select('id, name')
      .order('name');

  return (data as List<dynamic>)
      .map((e) {
        final row = e as Map<String, dynamic>;
        return JobCategory(
          id: row['id'] as String,
          name: row['name'] as String,
        );
      })
      .toList();
}
