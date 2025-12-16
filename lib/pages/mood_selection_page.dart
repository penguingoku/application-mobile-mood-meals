import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'recipe_list_page.dart';
import 'favorites_page.dart';
import 'add_recipe_page.dart';
import 'auth_page.dart';

class MoodSelectionArgs {
  final bool showWelcomeSnackbar;

  const MoodSelectionArgs({this.showWelcomeSnackbar = false});
}

class MoodSelectionPage extends StatefulWidget {
  static const String routeName = '/';

  const MoodSelectionPage({super.key});

  @override
  State<MoodSelectionPage> createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  bool _welcomeShown = false;

  String _keywordForMood(String mood) {
    switch (mood) {
      case 'Happy':
        return 'cake';
      case 'Sad':
        return 'soup';
      case 'Stressed':
        return 'salad';
      case 'Excited':
        return 'meat';
      case 'Unsure':
        return 'pasta';
      default:
        return 'pasta';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (!_welcomeShown && auth.isLoggedIn) {
      _welcomeShown = true;
      final name = auth.currentUser?.name ?? 'friend';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome $name! What is your mood today?'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moods = [
      (
        'Happy',
        Icons.emoji_emotions,
        Colors.amber
      ),
      (
        'Sad',
        Icons.sentiment_dissatisfied,
        Colors.lightBlue
      ),
      (
        'Stressed',
        Icons.sentiment_neutral,
        Colors.orange
      ),
      (
        'Excited',
        Icons.celebration,
        Colors.purple
      ),
      (
        'Unsure',
        Icons.help_outline,
        Colors.grey
      ),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodMeals'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add recipe',
            onPressed: () {
              Navigator.pushNamed(context, AddRecipePage.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, FavoritesPage.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AuthPage.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.7),
                  colorScheme.secondaryContainer.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Opacity(
            opacity: 0.12,
            child: IgnorePointer(
              child: Image.network(
                'https://www.themealdb.com/images/media/meals/58oia61564916529.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: moods.map((entry) {
                      return _MoodButton(
                        label: entry.$1,
                        icon: entry.$2,
                        color: entry.$3,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RecipeListPage.routeName,
                            arguments: RecipeListArgs(
                              mood: entry.$1,
                              keyword: _keywordForMood(entry.$1),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MoodButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MoodButton> createState() => _MoodButtonState();
}

class _MoodButtonState extends State<_MoodButton> {
  bool _isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) {
        setState(() {
          _isLongPressed = true;
        });
      },
      onLongPressEnd: (_) {
        setState(() {
          _isLongPressed = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isLongPressed ? 1.2 : 1.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 40, color: widget.color),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
