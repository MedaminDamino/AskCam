import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
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
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Capture, analyze, and discover insights from your images',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take a photo',
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
                      title: 'Gallery',
                      subtitle: 'Browse photos',
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
                      title: 'History',
                      subtitle: 'Past scans',
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
                      title: 'Settings',
                      subtitle: 'Preferences',
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
            ],
          ),
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
        onTap: onTap,
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
}