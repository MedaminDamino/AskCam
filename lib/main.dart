import 'package:askcam/core/utils/image_cache_manager.dart';
import 'package:askcam/core/utils/locale_controller.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/utils/settings_storage.dart';
import 'package:askcam/core/theme/app_theme.dart';
import 'package:askcam/core/theme/theme_controller.dart';
import 'package:askcam/core/services/reminder_notification_service.dart';
import 'package:askcam/features/data/auth/auth_service.dart';
import 'package:askcam/features/data/auth/user_profile_service.dart';
import 'package:askcam/features/domain/auth/auth_repository.dart';
import 'package:askcam/features/domain/auth/auth_repository_impl.dart';
import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:askcam/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Provide AI_API_KEY at runtime (ex: flutter run --dart-define=AI_API_KEY=YOUR_KEY).
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
  final localeController = LocaleController(
    storage: SettingsStorage(),
  );
  await localeController.loadSavedLocale();
  if (settingsController.reminderEnabled) {
    final locale =
        localeController.locale ?? Locale(settingsController.languageCode);
    final l10n = await AppLocalizations.delegate.load(locale);
    final scheduled = await ReminderNotificationService.instance.scheduleReminder(
      title: l10n.reminderTitle,
      body: l10n.reminderBody,
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );
    if (!scheduled) {
      await settingsController.setReminderEnabled(false);
    }
  }

  runApp(MyApp(
    themeController: themeController,
    settingsController: settingsController,
    localeController: localeController,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  final SettingsController settingsController;
  final LocaleController localeController;

  const MyApp({
    super.key,
    required this.themeController,
    required this.settingsController,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(
          value: themeController,
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<LocaleController>.value(
          value: localeController,
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
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, themeController, localeController, _) {
          final platformBrightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          final effectiveBrightness = themeController.mode == ThemeMode.system
              ? platformBrightness
              : themeController.mode == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light;
          final scheme = effectiveBrightness == Brightness.dark
              ? AppTheme.dark.colorScheme
              : AppTheme.light.colorScheme;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: effectiveBrightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: scheme.background,
              systemNavigationBarIconBrightness:
                  effectiveBrightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
            ),
          );

          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.mode,
            locale: localeController.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) {
                return const Locale('en');
              }
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
              return const Locale('en');
            },
            initialRoute: Routes.home,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
