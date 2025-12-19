import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/features/presentation/screens/auth/login_page.dart';
import 'package:askcam/features/presentation/screens/home.pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _didUpdateLastLogin = false;

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();

    return StreamBuilder<User?>(
      stream: authController.authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (snapshot.hasError) {
          return _AuthErrorScreen(
            message: snapshot.error.toString(),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          _didUpdateLastLogin = false;
          return const LoginPage();
        }

        if (!_didUpdateLastLogin) {
          _didUpdateLastLogin = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authController.updateLastLogin();
          });
        }

        return const HomeScreen();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  final String message;

  const _AuthErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Authentication error: $message',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
