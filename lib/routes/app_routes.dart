
import 'package:askcam/features/presentation/screens/camera_screen.pages.dart';
import 'package:askcam/features/presentation/screens/home.pages.dart';
import 'package:askcam/features/presentation/screens/text_recognition_screen.pages.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// Route names as constants for type safety
class Routes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String textRecognition = '/text-recognition';
  static const String gallery = '/gallery';
  static const String history = '/history';
  static const String settings = '/settings';
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
        return _buildRoute(const HomeScreen());

      case Routes.camera:
        debugPrint('✅ Matched CAMERA route');
        return _buildRoute(const CameraScreen());

      case Routes.textRecognition:
        debugPrint('✅ Matched TEXT RECOGNITION route');

        // Safe argument validation
        if (settings.arguments == null) {
          debugPrint('❌ ERROR: No arguments provided for text recognition');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'No image file provided',
          ));
        }

        if (settings.arguments is! File) {
          debugPrint('❌ ERROR: Invalid argument type: ${settings.arguments.runtimeType}');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Invalid argument type: expected File, got ${settings.arguments.runtimeType}',
          ));
        }

        final imageFile = settings.arguments as File;

        // Validate file exists
        if (!imageFile.existsSync()) {
          debugPrint('❌ ERROR: File does not exist: ${imageFile.path}');
          return _buildRoute(_ErrorScreen(
            routeName: settings.name ?? 'Unknown',
            errorMessage: 'Image file not found',
          ));
        }

        debugPrint('✅ Image file validated: ${imageFile.path}');
        return _buildRoute(
          TextRecognitionScreen(imageFile: imageFile),
        );

      case Routes.gallery:
        debugPrint('⚠️ Gallery route not implemented yet');
        return _buildRoute(_ErrorScreen(
          routeName: settings.name ?? 'Unknown',
          errorMessage: 'Gallery screen not implemented',
        ));

      case Routes.history:
        debugPrint('⚠️ History route not implemented yet');
        return _buildRoute(_ErrorScreen(
          routeName: settings.name ?? 'Unknown',
          errorMessage: 'History screen not implemented',
        ));

      case Routes.settings:
        debugPrint('⚠️ Settings route not implemented yet');
        return _buildRoute(_ErrorScreen(
          routeName: settings.name ?? 'Unknown',
          errorMessage: 'Settings screen not implemented',
        ));

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

  /// Custom fade transition (optional)
  static PageRouteBuilder _buildRouteWithFade(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, Routes.home);
            }
          },
        ),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routeName',
                style: const TextStyle(
                  color: Colors.white60,
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
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
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