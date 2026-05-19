/// Company headcount brackets.
///
/// Stored as [value] in `companies.size` (DB).
/// Displayed as [displayLabel] in UI.
enum CompanySize {
  tiny('1-10', '1–10 nhân viên'),
  small('11-50', '11–50 nhân viên'),
  medium('51-200', '51–200 nhân viên'),
  large('201-500', '201–500 nhân viên'),
  enterprise('501-1000', '501–1000 nhân viên'),
  corporation('1000+', 'Trên 1000 nhân viên');

  const CompanySize(this.value, this.displayLabel);
  final String value;        // stored in DB
  final String displayLabel; // shown in UI

  static CompanySize? fromValue(String? value) =>
      CompanySize.values.where((e) => e.value == value).firstOrNull;
}
