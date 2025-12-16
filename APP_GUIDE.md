## MoodMeals – Project Guide

### 1. Concept

**MoodMeals** suggests recipes based on the user’s current mood and allows saving favorites locally.

- User registers or logs in with basic personal info.
- Chooses a mood (Happy, Sad, Stressed, Excited, Unsure).
- App calls TheMealDB API with a keyword mapped to that mood.
- Shows a list of recipes; user can open details and save as favorite.
- User can also add their own recipes, linked to a specific mood, and manage them (edit/delete) via SQLite.

---

### 2. Pages (Screens)

1. **AuthPage (`lib/pages/auth_page.dart`)**
   - Facebook-inspired login/register UI inside a centered card with food background.
   - Register tab: name, password, age, weight, optional email (with validation).
   - Login tab: name + password.
   - On register:
     - Creates a `UserProfile` and calls `AuthProvider.register(user)`.
     - Also calls `RecipeProvider.setCurrentUser(user.name)` so favorites are scoped to that user.
   - On login:
     - Calls `AuthProvider.login(name, password)`; shows an error Snackbar if credentials are wrong.
     - When successful, also calls `RecipeProvider.setCurrentUser(currentUser.name)`.

2. **MoodSelectionPage (`lib/pages/mood_selection_page.dart`)**
   - Greets user with a Snackbar: “Welcome \<name\>! What is your mood today?”.
   - Colorful grid of 5 mood buttons:
     - Happy, Sad, Stressed, Excited, Unsure.
   - Long-press on a mood makes the card grow using `AnimatedScale`.
   - Tap a mood → navigates to `RecipeListPage` with:
     - `mood` (string for UI)
     - `keyword` for API (Happy → "cake", Sad → "soup", Stressed → "salad", Excited → "meat", Unsure → "pasta").
   - AppBar actions:
     - Add Recipe → `AddRecipePage`
     - Favorites → `FavoritesPage`
     - Logout → clears `AuthProvider` and returns to `AuthPage`.

3. **RecipeListPage (`lib/pages/recipe_list_page.dart`)**
   - Uses `RecipeProvider.fetchRecipesForMood(keyword)` to call TheMealDB.
   - Combines:
     - API recipes for the selected mood keyword, and
     - Custom recipes from SQLite whose `mood` matches the current mood.
   - Displays a vertical list of `RecipeCard` widgets.
   - Tap a card → `RecipeDetailPage`.

4. **RecipeDetailPage (`lib/pages/recipe_detail_page.dart`)**
   - Shows:
     - Recipe image
     - Title
     - Category
     - Instructions (scrollable text).
   - Floating button “Save to favorites”:
     - Calls `RecipeProvider.addFavorite()` to store in SQLite (or in-memory on web).

5. **FavoritesPage (`lib/pages/favorites_page.dart`)**
   - Lists all recipes saved locally for the **currently logged-in user only**.
   - Each item:
     - Shows `RecipeCard`.
     - Has Edit and Delete icons:
       - Edit → `EditRecipePage`.
       - Delete → removes from SQLite and shows Snackbar.
   - Floating action button → `AddRecipePage` to add a new custom recipe quickly.

6. **AddRecipePage (`lib/pages/add_recipe_page.dart`)**
   - Form with validation:
     - Title (required).
     - Mood selection using radio buttons (Happy, Sad, Stressed, Excited, Unsure).
     - Image URL (optional).
     - Instructions (required, min 10 chars).
   - On save:
     - Builds a `Recipe` with `isCustom = true` and `mood` set from radios.
     - Saves to favorites via `RecipeProvider.addFavorite()`.
     - Shows Snackbar and returns to previous screen.

7. **EditRecipePage (`lib/pages/edit_recipe_page.dart`)**
   - Same fields as Add but pre-filled from the selected favorite.
   - Saves updates with `RecipeProvider.updateFavorite()`.

---

### 3. Architecture & Folders

- `lib/models/`
  - `recipe.dart` – Recipe model used for both API and SQLite.
    - Fields: `id`, `title`, `category`, `instructions`, `imageUrl`, `isCustom`, `mood`, `ownerName`.
    - `fromMealApi()` builds a `Recipe` from TheMealDB JSON.
    - `toMap()` / `fromMap()` map to SQLite rows.
  - `user_profile.dart` – user information for login/register.

- `lib/services/`
  - `api_service.dart`
    - `fetchRecipesByKeyword(String keyword)` calls:
      - `https://www.themealdb.com/api/json/v1/1/search.php?s=<keyword>`
    - Parses JSON into a list of `Recipe`.
  - `db_service.dart`
    - Manages SQLite database `moodmeals.db` using `sqflite`.
    - Table `favorites` with columns:
      - `id`, `title`, `category`, `instructions`, `imageUrl`, `isCustom`, `mood`, `ownerName`.
    - CRUD methods:
      - `insertFavorite(Recipe recipe)` – inserts with `ownerName` set from the recipe.
      - `getFavorites(String ownerName)` – returns only rows for that user.
      - `updateFavorite(Recipe recipe)` – updates a row by `id` + `ownerName`.
      - `deleteFavorite(int id, String ownerName)` – deletes only the current user’s entry.
    - On web (`kIsWeb`), uses an in-memory list instead of SQLite so the app still works.

- `lib/providers/`
  - `recipe_provider.dart`
    - Holds:
      - `apiRecipes` (last API results)
      - `favorites` (local SQLite or in-memory) **for the active user only**.
    - Methods:
      - `initDb()` – initializes DB.
      - `setCurrentUser(String? userName)` – sets current user and reloads favorites for them.
      - `fetchRecipesForMood(keyword)` – async API call with loading state.
      - `addFavorite`, `updateFavorite`, `deleteFavorite`, `loadFavorites` – all scoped by `_currentUserName`.
  - `auth_provider.dart`
    - Stores current `UserProfile` and the last **registered user**.
    - Methods:
      - `register(UserProfile user)` – saves the user and logs them in.
      - `login(String name, String password)` – returns true only on correct credentials.
      - `logout()` – clears the current user.

- `lib/widgets/`
  - `recipe_card.dart`
    - Compact card with:
      - Left image (or placeholder / broken-image icon if URL fails).
      - Title and category.
      - Optional trailing row (for edit/delete icons in favorites).

- `lib/pages/`
  - All UI screens described above, connected via named routes in `main.dart`.

---

### 4. Entry Point and Routing

- `lib/main.dart`
  - Initializes Flutter, sets up `RecipeProvider` and its database via `initDb()`.
  - Wraps app with `MultiProvider`:
    - `RecipeProvider`
    - `AuthProvider`
  - Uses `MaterialApp` with Material 3 and a teal-based color scheme.
  - `initialRoute` is `AuthPage` (register/login).
  - Static routes:
    - `/auth` → `AuthPage`
    - `/` → `MoodSelectionPage`
    - `/favorites` → `FavoritesPage`
    - `/add-recipe` → `AddRecipePage`
  - Dynamic routes (via `onGenerateRoute`):
    - `/recipes` → `RecipeListPage` with `RecipeListArgs`.
    - `/recipe-detail` → `RecipeDetailPage` with `RecipeDetailArgs`.
    - `/edit-recipe` → `EditRecipePage` with `EditRecipeArgs`.

---

### 5. How to Run

1. Install Flutter SDK and required platforms (Android SDK, etc.).
2. In the project root, run:
   ```bash
   flutter pub get
   flutter run
   ```
3. To test on web (Chrome), you can run:
   ```bash
   flutter run -d chrome
   ```
   Favorites will be stored in memory only (because SQLite is not available on web).

---

### 6. How to Demo for the Project

1. Open the app – show **register/login**, explain basic validation.
2. After logging in, highlight the **Snackbar greeting** and mood question.
3. Tap different mood buttons (Happy, Sad, etc.) and show the colorful icons and long-press animation.
4. Show how recipes load from API, tap one to open **details**, then save it to **favorites**.
5. Go to **Favorites**:
   - Show the list, open Edit, change title or instructions, save.
   - Delete a recipe and show the Snackbar confirmation.
6. Show **Add Recipe**:
   - Fill in title, choose a mood with the radio buttons, add optional image URL + instructions.
   - Save, then go back to the mood page and show that this custom recipe appears under that mood and in favorites.


