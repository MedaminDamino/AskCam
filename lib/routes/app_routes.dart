
import 'package:askcam/features/presentation/auth/auth_gate.dart';
import 'package:askcam/features/presentation/screens/auth/forgot_password_page.dart';
import 'package:askcam/features/presentation/screens/auth/login_page.dart';
import 'package:askcam/features/presentation/screens/auth/register_page.dart';
import 'package:askcam/features/presentation/screens/ask_ai_page.dart';
import 'package:askcam/features/presentation/screens/camera_screen.pages.dart';
import 'package:askcam/core/models/ask_ai_args.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/features/presentation/screens/result_screen.pages.dart';
import 'package:askcam/features/presentation/screens/gallery_screen.pages.dart';
import 'package:askcam/features/presentation/screens/history_screen.pages.dart';
import 'package:askcam/features/presentation/screens/settings_page.dart';
import 'package:askcam/features/presentation/screens/translate_page.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';

/// Route names as constants for type safety
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

/// Main route generator
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('🔍 Route requested: ${settings.name}');
    debugPrint('🔍 Arguments type: ${settings.arguments.runtimeType}');
    debugPrint('🔍 Arguments value: ${settings.arguments}');

    switch (settings.name) {
      case Routes.home:
        debugPrint('✅ Matched HOME route');
        return _buildRoute(const AuthGate());

      case Routes.camera:
        debugPrint('✅ Matched CAMERA route');
        return _buildRoute(const CameraScreen());

      case Routes.textRecognition:
        debugPrint('Matched EXTRACT RESULT route');

        // Safe argument validation
        if (settings.arguments == null) {
          debugPrint('ERROR: No arguments provided for extract result');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'No image file provided',
          ));
        }

        if (settings.arguments is! ExtractResultArgs) {
          debugPrint('ERROR: Invalid argument type: ${settings.arguments.runtimeType}');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage:
                'Invalid argument type: expected ExtractResultArgs, got ${settings.arguments.runtimeType}',
          ));
        }

        final args = settings.arguments as ExtractResultArgs;
        final imageFile = args.imageFile;

        // Validate file exists
        if (!imageFile.existsSync()) {
          debugPrint('ERROR: File does not exist: ${imageFile.path}');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Image file not found',
          ));
        }

        debugPrint('Image file validated: ${imageFile.path}');
        return _buildRoute(
          ExtractResultPage(args: args),
        );

      case Routes.login:
        debugPrint('Matched LOGIN route');
        return _buildRoute(const LoginPage());

      case Routes.register:
        debugPrint('Matched REGISTER route');
        return _buildRoute(const RegisterPage());

      case Routes.forgotPassword:
        debugPrint('Matched FORGOT PASSWORD route');
        return _buildRoute(const ForgotPasswordPage());

      case Routes.gallery:
        debugPrint('Matched GALLERY route');
        return _buildRoute(const GalleryScreen());

      case Routes.history:
        debugPrint('Matched HISTORY route');
        return _buildRoute(const HistoryScreen());

      case Routes.settings:
        debugPrint('Matched SETTINGS route');
        return _buildRoute(const SettingsPage());

      case Routes.translate:
        debugPrint('Matched TRANSLATE route');
        if (settings.arguments is! TranslatePageArgs) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Missing translate arguments',
          ));
        }
        return _buildRoute(
          TranslatePage(args: settings.arguments as TranslatePageArgs),
        );

      case Routes.askAi:
        debugPrint('Matched ASK AI route');
        if (settings.arguments is! AskAiArgs) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Missing AI arguments',
          ));
        }
        return _buildRoute(
          AskAiPage(args: settings.arguments as AskAiArgs),
        );

      default:
        debugPrint('❌ NO MATCH - showing error screen');
        return _buildRoute(
          _ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Route not found',
          ),
        );
    }
  }

  /// Build route with custom transitions
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }

}

/// Error screen for undefined routes or errors
class _ErrorScreen extends StatelessWidget {
  final String routeName;
  final String errorMessage;

  const _ErrorScreen({
    required this.routeName,
    this.errorMessage = 'Unknown error',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, Routes.home);
            }
          },
        ),
        actions: const [
          ThemeToggleButton(),
        ],
        title: Text(
          'Error',
          style: TextStyle(color: colors.onBackground),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: colors.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routeName',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home,
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
