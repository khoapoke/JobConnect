import 'package:supabase_flutter/supabase_flutter.dart';

class ReportDatasource {
  const ReportDatasource(this._supabase);

  final SupabaseClient _supabase;

  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    Map<String, dynamic>? targetSnapshot,
  }) async {
    await _supabase.from('reports').insert({
      'reporter_id': _supabase.auth.currentUser!.id,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'details': details,
      'target_snapshot': targetSnapshot,
      'status': 'pending',
    });
  }

  Future<bool> checkDuplicate({
    required String targetType,
    required String targetId,
  }) async {
    final res = await _supabase
        .from('reports')
        .select('id')
        .eq('reporter_id', _supabase.auth.currentUser!.id)
        .eq('target_type', targetType)
        .eq('target_id', targetId)
        .maybeSingle();
    return res != null;
  }
}
