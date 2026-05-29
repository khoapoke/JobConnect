/// Employment type for Job Posts.
///
/// Per ADR-0001: `job_posts.type` is employment category ONLY.
/// Remote work is tracked via `job_locations.is_remote`, not here.
/// The DB CHECK constraint allows 'remote'/'hybrid' but this enum
/// never writes them.
enum JobPostType {
  fullTime('full_time', 'Toàn thời gian'),
  partTime('part_time', 'Bán thời gian'),
  contract('contract', 'Hợp đồng'),
  internship('internship', 'Thực tập');

  const JobPostType(this.value, this.displayLabel);

  final String value;
  final String displayLabel;

  static JobPostType? fromValue(String? value) {
    if (value == null) return null;
    return values.where((t) => t.value == value).firstOrNull;
  }

  static JobPostType? fromDisplayLabel(String? label) {
    if (label == null) return null;
    return values.where((t) => t.displayLabel == label).firstOrNull;
  }
}
