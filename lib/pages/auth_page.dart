import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import 'mood_selection_page.dart';

class AuthPage extends StatefulWidget {
  static const String routeName = '/auth';

  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _registerFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();

  late TabController _tabController;

  final _regNameController = TextEditingController();
  final _regAgeController = TextEditingController();
  final _regWeightController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();

  final _loginNameController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regNameController.dispose();
    _regAgeController.dispose();
    _regWeightController.dispose();
    _regEmailController.dispose();
    _loginNameController.dispose();
    _regPasswordController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final user = UserProfile(
      name: _regNameController.text.trim(),
      age: int.parse(_regAgeController.text.trim()),
      weight: double.parse(_regWeightController.text.trim()),
      password: _regPasswordController.text.trim(),
      email: _regEmailController.text.trim().isEmpty
          ? null
          : _regEmailController.text.trim(),
    );

    final success = await context.read<AuthProvider>().register(user);

    if (success) {
      await context.read<RecipeProvider>().setCurrentUser(user.name);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        MoodSelectionPage.routeName,
        arguments: const MoodSelectionArgs(showWelcomeSnackbar: true),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User already exists. Please choose a different name.'),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _loginNameController.text.trim(),
      _loginPasswordController.text.trim(),
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid name or password. Please register first.'),
        ),
      );
      return;
    }

    await context.read<RecipeProvider>().setCurrentUser(auth.currentUser!.name);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      MoodSelectionPage.routeName,
      arguments: const MoodSelectionArgs(showWelcomeSnackbar: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade700,
                  Colors.orange.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Opacity(
            opacity: 0.15,
            child: IgnorePointer(
              child: Image.network(
                'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.restaurant_menu,
                        color: Colors.white, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'MoodMeals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Eat what matches your mood',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: colorScheme.primary,
                        tabs: const [
                          Tab(text: 'Register'),
                          Tab(text: 'Login'),
                        ],
                      ),
                      SizedBox(
                        height: 380,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRegisterForm(context),
                            _buildLoginForm(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _regNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _regPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                if (value.trim().length < 4) {
                  return 'Password must be at least 4 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _regAgeController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(value.trim());
                if (age == null || age <= 0) {
                  return 'Enter a valid positive age';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _regWeightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Weight is required';
                }
                final weight = double.tryParse(value.trim());
                if (weight == null || weight <= 0) {
                  return 'Enter a valid positive weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _regEmailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleRegister,
              icon: const Icon(Icons.person_add),
              label: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _loginNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleLogin,
              icon: const Icon(Icons.login),
              label: const Text('Log in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}