import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/core/services/reminder_notification_service.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/utils/locale_controller.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: settings.reminderEnabled
                ? l10n.notificationsEnabled
                : l10n.notificationsDisabled,
            icon: Icon(
              settings.reminderEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: colors.onSurfaceVariant,
            ),
            onPressed: ButtonFeedbackService.wrap(
              context,
                  () => _toggleReminder(context),
            ),
          ),
          IconButton(
            tooltip: l10n.language,
            icon: Icon(Icons.language_rounded, color: colors.onSurfaceVariant),
            onPressed: ButtonFeedbackService.wrap(
              context,
                  () => _showLanguageSheet(context),
            ),
          ),
          const ThemeToggleButton(),
          IconButton(
            tooltip: l10n.authLogout,
            icon: Icon(Icons.logout, color: colors.onSurfaceVariant),
            onPressed: ButtonFeedbackService.wrap(
              context,
                  () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSpacing.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(child: _HomeHeader()),
            ),
            SliverPadding(
              padding: AppSpacing.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              sliver: SliverToBoxAdapter(child: _HomeGrid()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final l10n = context.l10n;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.authLogout),
          content: Text(l10n.authLogoutConfirmation),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                    () => Navigator.of(dialogContext).pop(false),
              ),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                    () => Navigator.of(dialogContext).pop(true),
              ),
              child: Text(l10n.authLogout),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final controller = context.read<AuthController>();
    final success = await controller.signOut(l10n: l10n);
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
            (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? l10n.authLogoutFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _toggleReminder(BuildContext context) async {
    final settings = context.read<SettingsController>();
    final l10n = context.l10n;

    if (settings.reminderEnabled) {
      await ReminderNotificationService.instance.cancelAll();
      await settings.setReminderEnabled(false);
      return;
    }

    final scheduled =
    await ReminderNotificationService.instance.scheduleReminder(
      title: l10n.reminderTitle,
      body: l10n.reminderBody,
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );

    if (!scheduled) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reminderPermissionDenied)),
      );
      return;
    }

    await settings.setReminderEnabled(true);
  }

  void _showLanguageSheet(BuildContext context) {
    final l10n = context.l10n;
    final localeController = context.read<LocaleController>();
    final settings = context.read<SettingsController>();

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.circular(AppRadius.lg),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                ),
                ListTile(
                  title: Text(l10n.languageEnglish),
                  onTap: () async {
                    await localeController.changeLocale(const Locale('en'));
                    await settings.setLanguageCode('en');
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  title: Text(l10n.languageFrench),
                  onTap: () async {
                    await localeController.changeLocale(const Locale('fr'));
                    await settings.setLanguageCode('fr');
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  title: Text(l10n.languageArabic),
                  onTap: () async {
                    await localeController.changeLocale(const Locale('ar'));
                    await settings.setLanguageCode('ar');
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final titleGradient = LinearGradient(
      colors: [colors.primary, colors.tertiary],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeWelcome,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        ShaderMask(
          shaderCallback: (bounds) => titleGradient.createShader(bounds),
          child: Text(
            l10n.appTitle,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: colors.onSurface,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.homeTagline,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _HomeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final actions = [
      _HomeAction(
        icon: Icons.camera_alt_rounded,
        title: context.l10n.homeCamera,
        subtitle: context.l10n.homeCameraSubtitle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.primary],
        ),
        foreground: colors.onPrimaryContainer,
        onTap: () => Navigator.pushNamed(context, Routes.camera),
      ),
      _HomeAction(
        icon: Icons.image_rounded,
        title: context.l10n.homeGallery,
        subtitle: context.l10n.homeGallerySubtitle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.secondaryContainer, colors.secondary],
        ),
        foreground: colors.onSecondaryContainer,
        onTap: () => Navigator.pushNamed(context, Routes.gallery),
      ),
      _HomeAction(
        icon: Icons.history_rounded,
        title: context.l10n.homeHistory,
        subtitle: context.l10n.homeHistorySubtitle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.tertiaryContainer, colors.tertiary],
        ),
        foreground: colors.onTertiaryContainer,
        onTap: () => Navigator.pushNamed(context, Routes.history),
      ),
      _HomeAction(
        icon: Icons.settings_rounded,
        title: context.l10n.homeSettings,
        subtitle: context.l10n.homeSettingsSubtitle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surfaceContainerHighest, colors.primaryContainer],
        ),
        foreground: colors.onSurface,
        onTap: () => Navigator.pushNamed(context, Routes.settings),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,

        // ✅ IMPORTANT: make tiles taller to avoid overflow
        // (lower ratio = taller cards)
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return _HomeFeatureCard(action: actions[index]);
      },
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  final _HomeAction action;

  const _HomeFeatureCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final radius = AppRadius.circular(AppRadius.lg);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ButtonFeedbackService.wrap(context, action.onTap),
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: action.gradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            // ✅ smaller padding in grid = more space for text
            padding: AppSpacing.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container (looks clean in grid)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.foreground,
                    size: 26,
                  ),
                ),

                const Spacer(),

                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: action.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: action.foreground.withOpacity(0.92),
                    height: 1.2,
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

class _HomeAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color foreground;
  final VoidCallback onTap;

  _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.foreground,
    required this.onTap,
  });
}


