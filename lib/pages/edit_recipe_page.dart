import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class EditRecipeArgs {
  final Recipe recipe;

  EditRecipeArgs({required this.recipe});
}

class EditRecipePage extends StatefulWidget {
  static const String routeName = '/edit-recipe';

  final EditRecipeArgs args;

  const EditRecipePage({super.key, required this.args});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final recipe = widget.args.recipe;
    _titleController = TextEditingController(text: recipe.title);
    _categoryController = TextEditingController(text: recipe.category);
    _imageUrlController = TextEditingController(text: recipe.imageUrl);
    _instructionsController = TextEditingController(text: recipe.instructions);

    print('=== EDIT PAGE INIT ===');
    print('Recipe key: ${recipe.key}');
    print('Recipe title: ${recipe.title}');
    print('Recipe owner: ${recipe.ownerName}');
    print('Recipe isCustom: ${recipe.isCustom}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    print('=== EDIT RECIPE SAVE START ===');
    print('Original recipe:');
    print('- Key: ${widget.args.recipe.key}');
    print('- Title: "${widget.args.recipe.title}"');
    print('- Owner: "${widget.args.recipe.ownerName}"');
    print('- isCustom: ${widget.args.recipe.isCustom}');

    final updated = widget.args.recipe.copyWith(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    print('Updated recipe:');
    print('- Key: ${updated.key}');
    print('- Title: "${updated.title}"');
    print('- Owner: "${updated.ownerName}"');
    print('- isCustom: ${updated.isCustom}');
    print('=== EDIT RECIPE SAVE END ===');

    try {
      await context.read<RecipeProvider>().updateFavorite(updated);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('ERROR updating recipe: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  if(value == _titleController.text){
                    return 'Category and title should not be the same' ;

                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Instructions are required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}