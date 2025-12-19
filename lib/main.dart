import 'package:askcam/core/utils/image_cache_manager.dart';
import 'package:askcam/core/theme/app_theme.dart';
import 'package:askcam/core/theme/theme_controller.dart';
import 'package:askcam/features/data/auth/auth_service.dart';
import 'package:askcam/features/data/auth/user_profile_service.dart';
import 'package:askcam/features/domain/auth/auth_repository.dart';
import 'package:askcam/features/domain/auth/auth_repository_impl.dart';
import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ImageCacheManager().clearOldCache();
  final themeController = ThemeController();
  await themeController.loadThemeMode();


  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(
          value: themeController,
        ),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            authService: AuthService(),
            userProfileService: UserProfileService(),
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            repository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          final platformBrightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          final effectiveBrightness = themeController.mode == ThemeMode.system
              ? platformBrightness
              : themeController.mode == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: effectiveBrightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor:
                  effectiveBrightness == Brightness.dark
                      ? const Color(0xFF0A0E21)
                      : const Color(0xFFF6F8FC),
              systemNavigationBarIconBrightness:
                  effectiveBrightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'AskCam',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.mode,
            initialRoute: Routes.home,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
