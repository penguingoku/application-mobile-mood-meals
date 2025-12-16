import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/recipe_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/auth_page.dart';
import 'pages/mood_selection_page.dart';
import 'pages/recipe_list_page.dart';
import 'pages/recipe_detail_page.dart';
import 'pages/favorites_page.dart';
import 'pages/add_recipe_page.dart';
import 'pages/edit_recipe_page.dart';
import 'models/recipe.dart';
import 'models/user_profile.dart';
import 'services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== APP STARTING ===');

  await Hive.initFlutter();

  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await HiveService.init();

  runApp(const MoodMealsApp());
}

class MoodMealsApp extends StatelessWidget {
  const MoodMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecipeProvider>(
          create: (_) => RecipeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MoodMeals',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.orange,
          brightness: Brightness.light,
        ),
        initialRoute: AuthPage.routeName,
        routes: {
          AuthPage.routeName: (_) => const AuthPage(),
          MoodSelectionPage.routeName: (_) => const MoodSelectionPage(),
          FavoritesPage.routeName: (_) => const FavoritesPage(),
          AddRecipePage.routeName: (_) => const AddRecipePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == RecipeListPage.routeName) {
            final args = settings.arguments as RecipeListArgs;
            return MaterialPageRoute(
              builder: (_) => RecipeListPage(args: args),
            );
          }
          if (settings.name == RecipeDetailPage.routeName) {
            final args = settings.arguments as RecipeDetailArgs;
            return MaterialPageRoute(
              builder: (_) => RecipeDetailPage(args: args),
            );
          }
          if (settings.name == EditRecipePage.routeName) {
            final args = settings.arguments as EditRecipeArgs;
            return MaterialPageRoute(
              builder: (_) => EditRecipePage(args: args),
            );
          }
          return null;
        },
      ),
    );
  }
}