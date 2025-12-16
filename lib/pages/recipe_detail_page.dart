import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailArgs {
  final Recipe recipe;

  RecipeDetailArgs({required this.recipe});
}

class RecipeDetailPage extends StatelessWidget {
  static const String routeName = '/recipe-detail';

  final RecipeDetailArgs args;

  const RecipeDetailPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final recipe = args.recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.read<RecipeProvider>().addFavorite(
                recipe.copyWith(isCustom: false),
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to favorites')),
            );
          }
        },
        icon: const Icon(Icons.favorite_border),
        label: const Text('Save to favorites'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(recipe.imageUrl),
              ),
            const SizedBox(height: 16),
            Text(
              recipe.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.category,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions,
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}


