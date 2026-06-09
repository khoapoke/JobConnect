class AdminStats {
  const AdminStats({
    required this.totalSeekers,
    required this.totalRecruiters,
    required this.totalActivePosts,
    required this.totalApplications,
    required this.applicationsPerDay,
    required this.postsByCategory,
  });

  final int totalSeekers;
  final int totalRecruiters;
  final int totalActivePosts;
  final int totalApplications;
  final List<DayCount> applicationsPerDay;
  final List<CategoryCount> postsByCategory;
}

class DayCount {
  const DayCount({required this.date, required this.count});
  final DateTime date;
  final int count;
}

class CategoryCount {
  const CategoryCount({required this.category, required this.count});
  final String category;
  final int count;
}
