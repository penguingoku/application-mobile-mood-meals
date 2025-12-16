import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';
import 'edit_recipe_page.dart';

class RecipeListArgs {
  final String mood;
  final String keyword;

  RecipeListArgs({required this.mood, required this.keyword});
}

class RecipeListPage extends StatefulWidget {
  static const String routeName = '/recipes';

  final RecipeListArgs args;

  const RecipeListPage({super.key, required this.args});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RecipeProvider>().fetchRecipesForMood(widget.args.keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.args.mood} recipes'),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Recipe> apiRecipes = provider.apiRecipes;
          final List<Recipe> customForMood = provider.favorites
              .where((r) => r.isCustom &&
              (r.mood ?? '').toLowerCase() == widget.args.mood.toLowerCase())
              .toList();

          final List<Recipe> recipes = [...customForMood, ...apiRecipes];

          if (recipes.isEmpty) {
            return const Center(
              child: Text('No recipes found for this mood.'),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              final bool canEdit = recipe.isCustom;
              final bool isInFavorites = provider.isRecipeInFavorites(recipe);

              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RecipeDetailPage.routeName,
                    arguments: RecipeDetailArgs(recipe: recipe),
                  );
                },
                trailing: canEdit && isInFavorites
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Modifier',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          EditRecipePage.routeName,
                          arguments: EditRecipeArgs(recipe: recipe),
                        ).then((value) {
                          if (value == true) {
                            setState(() {});
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Supprimer',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer la recette'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette recette ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await provider.deleteFavorite(recipe);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recette supprimée'),
                              ),
                            );
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ],
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}