import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class AddRecipePage extends StatefulWidget {
  static const String routeName = '/add-recipe';

  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _instructionsController = TextEditingController();
  String? _selectedMood;

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
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a mood for this recipe')),
      );
      return;
    }

    final recipe = Recipe(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      instructions: _instructionsController.text.trim(),
      isCustom: true,
      mood: _selectedMood,
    );

    await context.read<RecipeProvider>().addFavorite(recipe);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added to favorites')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
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
                  labelText: 'Category (e.g. Dessert, Vegetarian)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mood for this recipe',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Happy'),
                    value: 'Happy',
                    groupValue: _selectedMood,
                    onChanged: (value) {
                      setState(() => _selectedMood = value);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Sad'),
                    value: 'Sad',
                    groupValue: _selectedMood,
                    onChanged: (value) {
                      setState(() => _selectedMood = value);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Stressed'),
                    value: 'Stressed',
                    groupValue: _selectedMood,
                    onChanged: (value) {
                      setState(() => _selectedMood = value);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Excited'),
                    value: 'Excited',
                    groupValue: _selectedMood,
                    onChanged: (value) {
                      setState(() => _selectedMood = value);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Unsure'),
                    value: 'Unsure',
                    groupValue: _selectedMood,
                    onChanged: (value) {
                      setState(() => _selectedMood = value);
                    },
                  ),
                ],
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
                  if (value.trim().length < 10) {
                    return 'Instructions should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
    );
  }
}


