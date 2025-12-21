import 'package:askcam/core/models/ask_ai_args.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/features/presentation/auth/auth_gate.dart';
import 'package:askcam/features/presentation/screens/ask_ai_page.dart';
import 'package:askcam/features/presentation/screens/auth/forgot_password_page.dart';
import 'package:askcam/features/presentation/screens/auth/login_page.dart';
import 'package:askcam/features/presentation/screens/auth/register_page.dart';
import 'package:askcam/features/presentation/screens/camera_screen.pages.dart';
import 'package:askcam/features/presentation/screens/gallery_screen.pages.dart';
import 'package:askcam/features/presentation/screens/history_screen.pages.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/features/presentation/screens/result_screen.pages.dart';
import 'package:askcam/features/presentation/screens/settings_page.dart';
import 'package:askcam/features/presentation/screens/translate_page.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_spacing.dart';

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
    debugPrint('Route requested: ${settings.name}');
    debugPrint('Arguments type: ${settings.arguments.runtimeType}');
    debugPrint('Arguments value: ${settings.arguments}');

    switch (settings.name) {
      case Routes.home:
        return _buildRoute(const AuthGate());

      case Routes.camera:
        return _buildRoute(const CameraScreen());

      case Routes.textRecognition:
        // Safe argument validation
        if (settings.arguments == null) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorNoImage,
          ));
        }

        if (settings.arguments is! ExtractResultArgs) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorInvalidArgs(
              settings.arguments.runtimeType.toString(),
            ),
          ));
        }

        final args = settings.arguments as ExtractResultArgs;
        final imageFile = args.imageFile;

        // Validate file exists
        if (!imageFile.existsSync()) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorImageNotFound,
          ));
        }

        return _buildRoute(
          ExtractResultPage(args: args),
        );

      case Routes.login:
        return _buildRoute(const LoginPage());

      case Routes.register:
        return _buildRoute(const RegisterPage());

      case Routes.forgotPassword:
        return _buildRoute(const ForgotPasswordPage());

      case Routes.gallery:
        return _buildRoute(const GalleryScreen());

      case Routes.history:
        return _buildRoute(const HistoryScreen());

      case Routes.settings:
        return _buildRoute(const SettingsPage());

      case Routes.translate:
        if (settings.arguments is! TranslatePageArgs) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorMissingTranslate,
          ));
        }
        return _buildRoute(
          TranslatePage(args: settings.arguments as TranslatePageArgs),
        );

      case Routes.askAi:
        if (settings.arguments is! AskAiArgs) {
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorMissingAi,
          ));
        }
        return _buildRoute(
          AskAiPage(args: settings.arguments as AskAiArgs),
        );

      default:
        return _buildRoute(
          _ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: (context) => context.l10n.routeErrorNotFound,
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
  final String Function(BuildContext context) errorMessage;

  const _ErrorScreen({
    required this.routeName,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          context.l10n.routeErrorTitle,
          style: textTheme.titleLarge?.copyWith(color: colors.onBackground),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSpacing.xxl,
                color: colors.error,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.routeErrorHeading,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                errorMessage(context),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.routeErrorRoute(routeName),
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: context.l10n.routeErrorGoHome,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home,
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
