import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String instructions;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final bool isCustom;

  @HiveField(6)
  final String? mood;

  @HiveField(7)
  final String? ownerName;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.instructions,
    required this.imageUrl,
    this.isCustom = false,
    this.mood,
    this.ownerName,
  });

  factory Recipe.fromMealApi(Map<String, dynamic> json) {
    return Recipe(
      title: json['strMeal'] ?? 'Unknown meal',
      category: json['strCategory'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? 'No instructions',
      imageUrl: json['strMealThumb'] ?? '',
      isCustom: false,
      mood: null,
    );
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? category,
    String? instructions,
    String? imageUrl,
    bool? isCustom,
    String? mood,
    String? ownerName,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      isCustom: isCustom ?? this.isCustom,
      mood: mood ?? this.mood,
      ownerName: ownerName ?? this.ownerName,
    );
  }

}