/// Plain data class for company write operations.
///
/// All fields nullable — updates can be partial.
/// Only non-null fields are sent to the API (null-skipping toJson).
class CompanyUpdate {
  const CompanyUpdate({
    this.name,
    this.description,
    this.website,
    this.size,
    this.province,
  });

  final String? name;
  final String? description;
  final String? website;
  final String? size;         // CompanySize.value string
  final String? province;     // VietnamProvinces.all entry

  CompanyUpdate copyWith({
    String? name,
    String? description,
    String? website,
    String? size,
    String? province,
  }) => CompanyUpdate(
    name: name ?? this.name,
    description: description ?? this.description,
    website: website ?? this.website,
    size: size ?? this.size,
    province: province ?? this.province,
  );

  /// Converts non-null fields to a JSON map for Supabase.
  /// Null fields are skipped — prevents overwriting existing DB values.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (website != null) map['website'] = website;
    if (size != null) map['size'] = size;
    if (province != null) map['province'] = province;
    return map;
  }
}
