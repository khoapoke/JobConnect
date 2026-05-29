import 'package:equatable/equatable.dart';

/// Value object representing a predefined salary range for filtering.
class SalaryRange {
  const SalaryRange({required this.label, required this.min, this.max});

  final String label;
  final int min;
  final int? max;
}

/// Predefined salary range tiers (VND/month).
const List<SalaryRange> kSalaryRanges = [
  SalaryRange(label: 'Dưới 7 triệu', min: 0, max: 7000000),
  SalaryRange(label: '7 - 15 triệu', min: 7000000, max: 15000000),
  SalaryRange(label: '15 - 25 triệu', min: 15000000, max: 25000000),
  SalaryRange(label: '25 - 35 triệu', min: 25000000, max: 35000000),
  SalaryRange(label: '35 - 50 triệu', min: 35000000, max: 50000000),
  SalaryRange(label: '50 - 70 triệu', min: 50000000, max: 70000000),
  SalaryRange(label: 'Trên 70 triệu', min: 70000000, max: null),
];

/// Labels for job post types (Vietnamese).
const Map<String, String> kJobTypeLabels = {
  'full_time': 'Toàn thời gian',
  'part_time': 'Bán thời gian',
  'contract': 'Hợp đồng',
  'internship': 'Thực tập',
  'remote': 'Từ xa',
  'hybrid': 'Hybrid',
};

/// Immutable filter state for job search queries.
class JobFilter extends Equatable {
  const JobFilter({
    this.categoryIds = const [],
    this.provinces = const [],
    this.jobTypes = const [],
    this.salaryRange,
    this.isRemote,
  });

  final List<String> categoryIds;
  final List<String> provinces;
  final List<String> jobTypes;
  final SalaryRange? salaryRange;
  final bool? isRemote;

  bool get hasFilters =>
      categoryIds.isNotEmpty ||
      provinces.isNotEmpty ||
      jobTypes.isNotEmpty ||
      salaryRange != null ||
      isRemote != null;

  JobFilter copyWith({
    List<String>? categoryIds,
    List<String>? provinces,
    List<String>? jobTypes,
    SalaryRange? salaryRange,
    bool? isRemote,
  }) {
    return JobFilter(
      categoryIds: categoryIds ?? this.categoryIds,
      provinces: provinces ?? this.provinces,
      jobTypes: jobTypes ?? this.jobTypes,
      salaryRange: salaryRange ?? this.salaryRange,
      isRemote: isRemote ?? this.isRemote,
    );
  }

  JobFilter clear() => const JobFilter();

  @override
  List<Object?> get props => [
        categoryIds,
        provinces,
        jobTypes,
        salaryRange,
        isRemote,
      ];
}
