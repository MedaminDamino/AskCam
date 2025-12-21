import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Map<String, Map<String, String>> _labels = {
    'en': {
      'welcome': 'Welcome to',
      'tagline': 'Capture, analyze, and discover insights from your images',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'history': 'History',
      'settings': 'Settings',
      'cameraSubtitle': 'Take a photo',
      'gallerySubtitle': 'Browse photos',
      'historySubtitle': 'Past scans',
      'settingsSubtitle': 'Preferences',
    },
    'fr': {
      'welcome': 'Bienvenue sur',
      'tagline': 'Capturez, analysez et decouvrez vos images',
      'camera': 'Camera',
      'gallery': 'Galerie',
      'history': 'Historique',
      'settings': 'Parametres',
      'cameraSubtitle': 'Prendre une photo',
      'gallerySubtitle': 'Voir les photos',
      'historySubtitle': 'Scans precedents',
      'settingsSubtitle': 'Preferences',
    },
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();
    final labels = _labels[settings.languageCode] ?? _labels['en']!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout, color: colors.onSurfaceVariant),
            onPressed: ButtonFeedbackService.wrap(
              context,
              () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = 2;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        labels['welcome']!,
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: colors.onSurfaceVariant,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00F5FF), Color(0xFFFF00FF)],
                          ).createShader(bounds),
                          child: Text(
                            'AskCam',
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      Text(
                        labels['tagline']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildListDelegate(
                      [
                        _buildFeatureCard(
                          context,
                          icon: Icons.camera_alt_rounded,
                          title: labels['camera']!,
                          subtitle: labels['cameraSubtitle']!,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.camera);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.image_rounded,
                          title: labels['gallery']!,
                          subtitle: labels['gallerySubtitle']!,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.gallery);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.history_rounded,
                          title: labels['history']!,
                          subtitle: labels['historySubtitle']!,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.history);
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.settings_rounded,
                          title: labels['settings']!,
                          subtitle: labels['settingsSubtitle']!,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.settings);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ButtonFeedbackService.wrap(context, onTap),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(false),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.of(dialogContext).pop(true),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final controller = context.read<AuthController>();
    final success = await controller.signOut();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? 'Logout failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
