  # AskCam Architecture and Code Explanation

  ## Project Overview

  AskCam is a Flutter mobile app that captures images, extracts text with OCR, and then helps users translate or ask AI questions about the extracted content. It also stores user history and a personal image gallery in the cloud.

  Main use cases
  - Capture or import an image, run OCR, and review the extracted text.
  - Translate extracted text into a chosen language.
  - Ask an AI assistant questions about the extracted text or about the image itself.
  - Save OCR history, save key words or phrases, and review past scans.
  - Manage settings such as theme, language, sound, and OCR preferences.

  Target users
  - Students and learners who want quick explanations of printed text.
  - Users who need translation from captured images.
  - Anyone who wants to organize OCR results and saved words.

  Core features
  - Camera and gallery image capture.
  - OCR text extraction (Google ML Kit).
  - Translation (Google Translator package).
  - AI assistance (Gemini via HTTP).
  - Cloud gallery storage (Cloudinary + Firestore metadata).
  - Auth (Email/Password and Google Sign-In).
  - History and saved words (Firestore).
  - Settings (theme, language, sound, vibration, OCR tuning).

  High-level flow
  - App launch -> Firebase init -> AuthGate -> Login/Register or Home.
  - Home -> Camera -> OCR -> Edit text -> Translate or Ask AI.
  - Optional: Save to History and Gallery.

  ## Architecture Overview

  Top-level structure
  - `lib/` contains all app code.
  - `assets/` contains static assets like the UI click sound.
  - `android/`, `ios/`, `macos/`, `web/` contain platform scaffolding.

  Key folders inside `lib/`
  - `core/`: shared utilities, services, config, themes, and models.
  - `features/`: feature modules, mostly in presentation layer with specific data/domain where needed.
  - `routes/`: centralized routing and route names.
  - `main.dart`: app entry point.

  Why this architecture
  - Clear separation between app-wide utilities (`core/`) and user-facing features (`features/`).
  - Auth and Gallery use a layered approach (presentation -> domain -> data) for testability and clear ownership.
  - Other features (OCR, AI, translation) are shared services in `core/` with screen-specific UI in `features/presentation/`.

  Data flow (typical)
  - UI Screen -> Controller/Service -> Repository -> Firebase/Cloudinary
  - Example: Login -> `AuthController` -> `AuthRepositoryImpl` -> `AuthService` -> FirebaseAuth.
  - Example: Save OCR history -> `ExtractResultPage` -> `HistoryService` -> Firestore.

  Firebase in the architecture
  - Firebase Auth handles sign-in, sign-up, sign-out, and auth state changes.
  - Cloud Firestore stores user profile data, history, saved words, and gallery metadata.
  - Firebase configuration is provided by `lib/firebase_options.dart`.

  ## App Entry and Bootstrapping (`lib/main.dart`)

  Block-by-block explanation
  - Imports: theme, settings, auth, routes, and Firebase.
  - `main()` ensures Flutter bindings are ready, initializes Firebase, clears old image cache, and loads theme and settings from storage.
  - `runApp(MyApp(...))` passes controllers to the widget tree.

  Startup sequence
  1) `WidgetsFlutterBinding.ensureInitialized()`
  2) `Firebase.initializeApp(...)` using `DefaultFirebaseOptions.currentPlatform`
  3) `ImageCacheManager().clearOldCache()` for temp files
  4) Load `ThemeController` and `SettingsController`
  5) Build `MyApp` with `MultiProvider`
  6) `MaterialApp` uses `AppTheme`, `Routes.home`, and `AppRouter.generateRoute`

  Key code shape
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await ImageCacheManager().clearOldCache();
    final themeController = ThemeController();
    await themeController.loadThemeMode();
    final settingsController = SettingsController(
      storage: SettingsStorage(),
    );
    await settingsController.load();
    runApp(MyApp(
      themeController: themeController,
      settingsController: settingsController,
    ));
  }
  ```

  Inside `MyApp`
  - `MultiProvider` provides `ThemeController`, `SettingsController`, and `AuthController` to the app.
  - System UI overlay colors are updated based on effective brightness.
  - `MaterialApp` sets themes and routing via `AppRouter.generateRoute`.

  ## Routing and Navigation (`lib/routes/app_routes.dart`)

  How routes are defined
  - `Routes` is a class of string constants (e.g., `/camera`, `/translate`).
  - `AppRouter.generateRoute` is the centralized switch for route creation.

  Navigation behavior
  - Initial route is `Routes.home` which loads `AuthGate`.
  - `AuthGate` decides between `LoginPage` and `HomeScreen`.
  - From Home, navigation uses `Navigator.pushNamed` to feature screens.

  Route arguments
  - `Routes.textRecognition` expects `ExtractResultArgs`.
  - `Routes.translate` expects `TranslatePageArgs`.
  - `Routes.askAi` expects `AskAiArgs`.
  - The router validates argument types and can show an error screen when arguments are invalid.

  ## Authentication Flow

  Key files
  - `lib/features/presentation/auth/auth_gate.dart`
  - `lib/features/presentation/auth/auth_controller.dart`
  - `lib/features/data/auth/auth_service.dart`
  - `lib/features/data/auth/user_profile_service.dart`
  - `lib/features/domain/auth/auth_repository.dart`
  - `lib/features/domain/auth/auth_repository_impl.dart`

  Login flow (email/password)
  1) `LoginPage` validates input using `AuthController`.
  2) `AuthController.signIn()` calls `AuthRepository.signIn()`.
  3) `AuthRepositoryImpl` delegates to `AuthService.signIn()`.
  4) `FirebaseAuth.signInWithEmailAndPassword` completes.
  5) On success, UI navigates to `Routes.home` and `AuthGate` shows `HomeScreen`.

  Google sign-in flow
  - `LoginPage` or `RegisterPage` calls `AuthController.signInWithGoogle()`.
  - `AuthService.signInWithGoogle()` handles web popup or native Google sign-in.
  - `AuthRepositoryImpl` ensures a Firestore profile exists via `UserProfileService`.

  Signup flow
  1) `RegisterPage` validates inputs.
  2) `AuthController.register()` calls `AuthRepository.signUp()`.
  3) `AuthService.signUp()` creates Firebase user.
  4) `UserProfileService.createUserProfile()` writes a user document.

  Logout flow
  - `SettingsPage` or `HomeScreen` triggers `AuthController.signOut()`.
  - `AuthService.signOut()` signs out of Firebase.
  - UI navigates to `Routes.login`.

  ## Feature-by-Feature Breakdown

  ### Camera / Image Capture
  Purpose
  - Capture from camera or select from gallery, optionally compress for OCR.

  Key screen
  - `lib/features/presentation/screens/camera_screen.pages.dart` (`CameraScreen`).

  Services used
  - `image_picker` for camera/gallery selection.
  - `image` for compression.
  - `SettingsController` to decide auto-enhance.

  Data flow
  - User picks image -> optional compression -> `ExtractResultArgs` -> `Routes.textRecognition`.

  ### OCR / Text Extraction
  Purpose
  - Extract readable text from images.

  Key screens
  - `ExtractResultPage` (`lib/features/presentation/screens/result_screen.pages.dart`)
  - `TextRecognitionScreen` (`lib/features/presentation/screens/text_recognition_screen.pages.dart`)

  Services used
  - `MLKitManager` queues text recognition operations.
  - `google_mlkit_text_recognition` for OCR.

  Data flow (ExtractResult)
  - Image file -> ML Kit -> cleaned text -> editable text field.
  - Optional actions: save history, save words, translate, ask AI.

  ML Kit plugins used (current code)
  - `google_mlkit_text_recognition`: used in `TextRecognitionScreen` and `ExtractResultPage` by creating `TextRecognizer(script: TextRecognitionScript.latin)` and calling `processImage(InputImage.fromFile(imageFile))`. Results are post-processed to normalize spacing and punctuation before display.
  - `google_mlkit_translation`: listed in `pubspec.yaml` but not referenced in `lib/` code. Translation is handled by `TranslationService` (the `translator` package) instead.
  - `google_mlkit_entity_extraction`: listed in `pubspec.yaml` but not referenced in `lib/` code.

  ### Ask AI
  Purpose
  - Provide answers based on extracted text or image content.

  Key screen
  - `AskAiPage` (`lib/features/presentation/screens/ask_ai_page.dart`).

  Services used
  - `AiService` (Gemini API via HTTP).
  - `AppRuntimeConfig` for config validation.
  - `image_bytes_loader` for image data (non-web).

  Data flow
  - Text present -> `AiService.askText()`.
  - No text -> `AiService.askVision()` with image bytes.
  - AI response -> displayed with copy action.

  ### Translation
  Purpose
  - Translate OCR text to the target language.

  Key screen
  - `TranslatePage` (`lib/features/presentation/screens/translate_page.dart`).

  Services used
  - `TranslationService` (Google Translator package).

  Data flow
  - Text -> translate -> display output, with copy button.

  ### Gallery / Cloudinary
  Purpose
  - Store images in the cloud and browse them later.

  Key screen
  - `GalleryScreen` (`lib/features/presentation/screens/gallery_screen.pages.dart`).

  Services used
  - `ImageUploadService` uploads to Cloudinary.
  - `GalleryRepository` stores metadata in Firestore and streams the gallery.

  Data flow
  - `ExtractResultPage` uploads image -> Cloudinary URL -> Firestore `users/{uid}/gallery`.
  - Gallery screen watches Firestore and renders a grid.

  ### History
  Purpose
  - Store OCR results and saved words for later reference.

  Key screen
  - `HistoryScreen` (`lib/features/presentation/screens/history_screen.pages.dart`).

  Services used
  - `HistoryService` for OCR history.
  - `SavedWordsService` for saved words.

  Data flow
  - From `ExtractResultPage` -> `HistoryService.saveExtractionToHistory()`.
  - From save words sheet -> `SavedWordsService.saveWord()`.
  - `HistoryScreen` streams and displays both collections.

  ### Settings
  Purpose
  - Adjust theme, language, sound, vibration, and OCR preferences.

  Key screen
  - `SettingsPage` (`lib/features/presentation/screens/settings_page.dart`).

  Services used
  - `ThemeController` and `SettingsController`.
  - `SettingsStorage` for persistence.
  - `ImageCacheManager` for cache clear.

  Data flow
  - User toggles -> controller updates state -> storage writes to SharedPreferences.

  ## Core Layer Explanation

  `lib/core/services/`
  - `ai_service.dart`: Gemini API client, model resolution, and response parsing.
  - `button_feedback_service.dart`: plays click sound and haptic feedback based on settings.
  - `history_service.dart`: Firestore CRUD for OCR history.
  - `image_upload_service.dart`: Cloudinary upload via multipart HTTP.
  - `saved_words_service.dart`: Firestore CRUD for saved words.

  `lib/core/utils/`
  - `ai_service.dart`: export shim for `core/services/ai_service.dart`.
  - `image_bytes_loader.dart`: conditional import for web vs IO image bytes loading.
  - `image_bytes_loader_io.dart`: reads local file bytes on mobile/desktop.
  - `image_bytes_loader_web.dart`: returns null (no file path on web).
  - `image_cache_manager.dart`: clears temp image cache on startup or via settings.
  - `ml_kit_manager.dart`: serializes ML Kit operations and checks WiFi.
  - `settings_storage.dart`: SharedPreferences persistence for settings.
  - `translation_service.dart`: wrapper around Google Translator.

  `lib/core/theme/`
  - `app_theme.dart`: light and dark theme definitions (Material 3, Poppins).
  - `theme_controller.dart`: load and store theme mode.

  `lib/core/config/`
  - `ai_config.dart`: `AI_API_KEY`, `AI_BASE_URL`, and model names.
  - `app_runtime_config.dart`: checks missing keys and builds run args.
  - `cloudinary_config.dart`: `CLOUDINARY_CLOUD_NAME` and preset.

  `lib/core/models/`
  - `ai_result.dart`: simple success/error wrapper for AI responses.
  - `ask_ai_args.dart`: route args for Ask AI screen.
  - `history_item.dart`: Firestore history data model.
  - `saved_word.dart`: Firestore saved word model.

  ## Key Files Explained

  ### `lib/main.dart` (annotated)
  Key blocks and what they do:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await ImageCacheManager().clearOldCache();
    final themeController = ThemeController();
    await themeController.loadThemeMode();
    final settingsController = SettingsController(
      storage: SettingsStorage(),
    );
    await settingsController.load();
    runApp(MyApp(
      themeController: themeController,
      settingsController: settingsController,
    ));
  }
  ```
  - Ensure Flutter bindings are ready for async startup.
  - Initialize Firebase for the current platform.
  - Clear old temp images before app UI starts.
  - Load persisted theme and settings.
  - Start the widget tree with `MyApp`.

  Inside `MyApp.build`:
  ```dart
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeController>.value(...),
      ChangeNotifierProvider<SettingsController>.value(...),
      Provider<AuthRepository>(create: (_) => AuthRepositoryImpl(...)),
      ChangeNotifierProvider<AuthController>(create: (context) => AuthController(...)),
    ],
    child: Consumer<ThemeController>(
      builder: (context, themeController, _) {
        // Update system UI colors for status and nav bars.
        return MaterialApp(x
          title: 'AskCam',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          initialRoute: Routes.home,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    ),
  );
  ```
  - Providers expose global controllers and repositories to the app.
  - `MaterialApp` routes to `AuthGate` via `Routes.home`.

  ### `lib/firebase_options.dart` (annotated)
  - Generated by FlutterFire CLI and used by `Firebase.initializeApp`.
  - `DefaultFirebaseOptions.currentPlatform` selects the correct config:
    - Web -> `web`
    - Android -> `android`
    - iOS -> `ios`
    - macOS -> `macos`
  - Each config includes `apiKey`, `appId`, `projectId`, and other Firebase IDs.

  ### `lib/routes/app_routes.dart` (annotated)
  Route constants:
  ```dart
  class Routes {
    static const String home = '/';
    static const String camera = '/camera';
    static const String textRecognition = '/text-recognition';
    static const String gallery = '/gallery';
    static const String history = '/history';
    static const String settings = '/settings';
    static const String translate = '/translate';
    static const String askAi = '/ask-ai';
    static const String login = '/login';
    static const String register = '/register';
    static const String forgotPassword = '/forgot-password';
  }
  ```
  Route generation:
  ```dart
  switch (settings.name) {
    case Routes.home:
      return _buildRoute(const AuthGate());
    case Routes.textRecognition:
      // Validate ExtractResultArgs and file existence.
      return _buildRoute(ExtractResultPage(args: args));
    case Routes.translate:
      // Validate TranslatePageArgs.
      return _buildRoute(TranslatePage(args: settings.arguments as TranslatePageArgs));
    case Routes.askAi:
      // Validate AskAiArgs.
      return _buildRoute(AskAiPage(args: settings.arguments as AskAiArgs));
    default:
      return _buildRoute(_ErrorScreen(...));
  }
  ```
  - `AppRouter` validates arguments and falls back to `_ErrorScreen` on failures.

  ### Auth screens (annotated)
  `login_page.dart`
  - Form fields use `AuthController.validateEmail` and `validatePassword`.
  - On submit, calls `AuthController.signIn`.
  - On success, navigates to `Routes.home`.

  `register_page.dart`
  - Collects first name, last name, email, and password.
  - Calls `AuthController.register`, which creates Firebase user and Firestore profile.

  `forgot_password_page.dart`
  - Validates email and calls `AuthController.sendPasswordReset`.
  - Shows a success message and returns to previous screen.

  ### Major services (annotated)
  - `AuthService`: wraps FirebaseAuth operations (`signIn`, `signUp`, `signOut`, `sendPasswordResetEmail`).
  - `UserProfileService`: writes and updates Firestore docs under `users/{uid}`.
  - `AiService`: builds Gemini prompts, posts JSON to `generateContent`, parses `AiResult`.
  - `ImageUploadService`: Cloudinary upload with `upload_preset` into a user folder.
  - `HistoryService` and `SavedWordsService`: stream and delete docs in user subcollections.

  ### Argument classes (annotated)
  ```dart
  class ExtractResultArgs {
    final File imageFile;
    final String source;
  }
  class TranslatePageArgs {
    final String text;
    final File? imageFile;
  }
  class AskAiArgs {
    final Uint8List? imageBytes;
    final String? imagePath;
    final String extractedText;
  }
  ```
  - These classes move data between routes without relying on globals.

  ## State and Data Management

  State handling
  - Global app state uses `ChangeNotifier` + `Provider`.
  - `ThemeController`, `SettingsController`, and `AuthController` are provided in `main.dart`.
  - Local screen state uses `StatefulWidget` with `setState` and `TextEditingController`.

  Async operations
  - Most async flows are handled with `async`/`await` and explicit loading flags.
  - ML Kit operations are serialized with `MLKitManager.queueOperation()`.

  Error handling
  - `try/catch` around network and Firebase calls.
  - UI feedback via `SnackBar` and inline error messages.
  - Routing errors handled by `_ErrorScreen`.

  ## Environment and Configuration

  Runtime variables (Dart define)
  - AI: `AI_API_KEY`, `AI_BASE_URL`, `AI_MODEL_TEXT`, `AI_MODEL_VISION`.
  - Cloudinary: `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET`.

  How secrets are used
  - Values are compiled into the app at build or run time using `--dart-define`.
  - `AiConfig` and `CloudinaryConfig` read these values from `String.fromEnvironment`.
  - `AppRuntimeConfig` checks missing values and can log required run args.

  ## Common Execution Flows (Text Diagrams)

  1) App launch -> login -> OCR -> AI
  ```
  App start
    -> Firebase.initializeApp
    -> AuthGate
      -> LoginPage (if not signed in)
      -> HomeScreen (if signed in)
    -> CameraScreen
    -> ExtractResultPage (OCR)
    -> TranslatePage or AskAiPage
  ```

  2) Upload image -> Cloudinary -> Gallery
  ```
  CameraScreen -> ExtractResultPage
    -> ImageUploadService.uploadImage
    -> GalleryRepository.addImage
    -> GalleryScreen (stream Firestore gallery)
  ```

  3) Save result -> History
  ```
  ExtractResultPage
    -> HistoryService.saveExtractionToHistory
    -> HistoryScreen (stream Firestore history)
  ```

  ## Summary

  Strengths
  - Clear separation of concerns with shared core services and feature screens.
  - Provider-based state management keeps global state simple and explicit.
  - Cloudinary and Firestore integration gives persistent galleries and history.

  How a new developer should approach the codebase
  - Start with `lib/main.dart` to see app startup and providers.
  - Review `lib/routes/app_routes.dart` to understand navigation.
  - Follow the main user path: `AuthGate` -> `HomeScreen` -> `CameraScreen` -> `ExtractResultPage`.
  - Then read supporting services in `lib/core/services/` and config in `lib/core/config/`.

  Where to start reading code
  - `lib/main.dart`
  - `lib/routes/app_routes.dart`
  - `lib/features/presentation/auth/auth_gate.dart`
  - `lib/features/presentation/screens/home.pages.dart`
  - `lib/features/presentation/screens/camera_screen.pages.dart`
  - `lib/features/presentation/screens/result_screen.pages.dart`
