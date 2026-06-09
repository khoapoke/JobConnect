import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'admin_dashboard_provider.dart';

part 'admin_users_provider.g.dart';

@riverpod
class AdminUserFilter extends _$AdminUserFilter {
  @override
  String build() => 'all'; // all | seeker | recruiter | banned

  void setFilter(String value) => state = value;
}

@riverpod
class AdminUserSearch extends _$AdminUserSearch {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

@riverpod
Future<List<Map<String, dynamic>>> adminUsers(Ref ref) async {
  final filter = ref.watch(adminUserFilterProvider);
  final search = ref.watch(adminUserSearchProvider);

  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getUsers(
    role: filter == 'all' || filter == 'banned' ? null : filter,
    search: search.isEmpty ? null : search,
    bannedOnly: filter == 'banned',
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (users) => users,
  );
}
