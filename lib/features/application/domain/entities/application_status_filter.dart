enum ApplicationStatusFilter {
  all,
  pending,
  reviewing,
  interview,
  rejected,
  withdrawn,
}

extension ApplicationStatusFilterX on ApplicationStatusFilter {
  String? get value => switch (this) {
    ApplicationStatusFilter.all => null,
    ApplicationStatusFilter.pending => 'pending',
    ApplicationStatusFilter.reviewing => 'reviewing',
    ApplicationStatusFilter.interview => 'interview',
    ApplicationStatusFilter.rejected => 'rejected',
    ApplicationStatusFilter.withdrawn => 'withdrawn',
  };
}
