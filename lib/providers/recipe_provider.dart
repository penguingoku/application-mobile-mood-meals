import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class RecipeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  List<Recipe> _apiRecipes = [];
  List<Recipe> _favorites = [];
  String? _currentUserName;

  bool get isLoading => _isLoading;
  List<Recipe> get apiRecipes => _apiRecipes;
  List<Recipe> get favorites => _favorites;

  Future<void> setCurrentUser(String? userName) async {
    _currentUserName = userName;
    await loadFavorites();
  }

  Future<void> fetchRecipesForMood(String moodKeyword) async {
    _isLoading = true;
    notifyListeners();
    try {
      _apiRecipes = await _apiService.fetchRecipesByKeyword(moodKeyword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    if (_currentUserName == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    final allRecipes = HiveService.getAllRecipes();
    _favorites = allRecipes.where((r) => r.ownerName == _currentUserName).toList();
    notifyListeners();
  }

  Future<void> addFavorite(Recipe recipe) async {
    if (_currentUserName == null) {
      return;
    }

    final recipeWithOwner = recipe.copyWith(ownerName: _currentUserName);
    await HiveService.addRecipe(recipeWithOwner);
    await loadFavorites();
  }

  Future<void> updateFavorite(Recipe recipe) async {
    if (_currentUserName == null) {
      return;
    }

    if (recipe.key != null) {
      await HiveService.updateRecipe(recipe.key!, recipe);
    } else {
      if (_favorites.isNotEmpty) {
        final latestCustomRecipe = _favorites
            .where((r) => r.isCustom == true)
            .last;

        if (latestCustomRecipe.key != null) {
          final updatedWithKey = latestCustomRecipe.copyWith(
            title: recipe.title,
            category: recipe.category,
            instructions: recipe.instructions,
            imageUrl: recipe.imageUrl,
          );

          await HiveService.updateRecipe(latestCustomRecipe.key!, updatedWithKey);
        } else {
          await addFavorite(recipe);
        }
      } else {
        await addFavorite(recipe);
      }
    }

    await loadFavorites();
  }

  Future<void> deleteFavorite(Recipe recipe) async {
    if (recipe.key != null) {
      await HiveService.deleteRecipe(recipe.key!);
    } else {
      final allRecipes = HiveService.getAllRecipes();
      for (var r in allRecipes) {
        if (r.title == recipe.title && r.ownerName == _currentUserName) {
          if (r.key != null) {
            await HiveService.deleteRecipe(r.key!);
          }
          break;
        }
      }
    }

    await loadFavorites();
  }

  bool isRecipeInFavorites(Recipe recipe) {
    return _favorites.any((fav) =>
    fav.title == recipe.title &&
        fav.ownerName == recipe.ownerName
    );
  }
}