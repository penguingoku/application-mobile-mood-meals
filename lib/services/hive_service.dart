import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';

class HiveService {
  static late Box<Recipe> recipesBox;
  static late Box<UserProfile> usersBox;

  static Future<void> init() async {
    recipesBox = await Hive.openBox<Recipe>('recipes');
    usersBox = await Hive.openBox<UserProfile>('users');
  }

  static Future<int> addRecipe(Recipe recipe) async {
    final key = await recipesBox.add(recipe);
    return key;
  }

  static List<Recipe> getAllRecipes() {
    return recipesBox.values.toList();
  }

  static Future<void> updateRecipe(int key, Recipe recipe) async {
    if (!recipesBox.containsKey(key)) {
      return;
    }

    final before = recipesBox.get(key);
    if (before == null) {
      return;
    }

    await recipesBox.put(key, recipe);
  }

  static Future<void> deleteRecipe(int key) async {
    await recipesBox.delete(key);
  }

  static void debugAllRecipes() {
  }

  static Future<void> addUser(UserProfile user) async {
    await usersBox.put(user.name.toLowerCase(), user);
  }

  static UserProfile? getUser(String username) {
    return usersBox.get(username.toLowerCase());
  }
}