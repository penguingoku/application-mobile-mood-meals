import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'edit_recipe_page.dart';

class FavoritesPage extends StatelessWidget {
  static const String routeName = '/favorites';

  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final favorites = recipeProvider.favorites;

    print('=== FAVORITES PAGE ===');
    print('Nombre de favoris: ${favorites.length}');
    for (var fav in favorites) {
      print('- ${fav.title} | owner: ${fav.ownerName} | isCustom: ${fav.isCustom}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              recipeProvider.loadFavorites();
            },
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(
        child: Text(
          'No favorite recipes yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final recipe = favorites[index];
          final bool canEdit = recipe.isCustom;

          return ListTile(
            leading: recipe.imageUrl.isNotEmpty
                ? Image.network(
              recipe.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.restaurant, size: 50),
            title: Text(recipe.title),
            subtitle: Text(recipe.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        EditRecipePage.routeName,
                        arguments: EditRecipeArgs(recipe: recipe),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, recipe),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<RecipeProvider>().deleteFavorite(recipe);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted')),
        );
      }
    }
  }
}