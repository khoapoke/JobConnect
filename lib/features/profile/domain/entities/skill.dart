/// A skill from the lookup table, joined with its category name.
class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
}
