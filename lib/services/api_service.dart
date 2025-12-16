import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class ApiService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1/search.php';

  Future<List<Recipe>> fetchRecipesByKeyword(String keyword) async {
    final uri = Uri.parse('$_baseUrl?s=$keyword');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load recipes');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;

    if (meals == null) {
      return [];
    }

    return meals.map((e) => Recipe.fromMealApi(e as Map<String, dynamic>)).toList();
  }
}


