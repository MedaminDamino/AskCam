import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/widgets/google_sign_in_button.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController controller) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (!kIsWeb) {
      TextInput.finishAutofillContext();
    }

    final success = await controller.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      debugPrint('Registration success, navigating to Home.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _submitGoogle(AuthController controller) async {
    final success = await controller.signInWithGoogle();

    if (success && mounted) {
      debugPrint('Google sign-up success, navigating to Home.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
      return;
    }

    if (!success && mounted) {
      final message = controller.errorMessage ?? 'Google sign-in failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onBackground,
        elevation: 0,
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 12,
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create account',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join AskCam in a few steps',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 420;
                                if (isWide) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          key: const ValueKey(
                                            'register-first-name',
                                          ),
                                          controller: _firstNameController,
                                          textInputAction: TextInputAction.next,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                          ),
                                          validator: (value) =>
                                              controller.validateName(
                                            value ?? '',
                                            'First name',
                                          ),
                                          decoration: _inputDecoration(
                                            context,
                                            label: 'First name',
                                            icon: Icons.person_outline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          key: const ValueKey(
                                            'register-last-name',
                                          ),
                                          controller: _lastNameController,
                                          textInputAction: TextInputAction.next,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                          ),
                                          validator: (value) =>
                                              controller.validateName(
                                            value ?? '',
                                            'Last name',
                                          ),
                                          decoration: _inputDecoration(
                                            context,
                                            label: 'Last name',
                                            icon: Icons.person_outline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    TextFormField(
                                      key: const ValueKey(
                                        'register-first-name',
                                      ),
                                      controller: _firstNameController,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: colors.onSurface,
                                      ),
                                      validator: (value) =>
                                          controller.validateName(
                                        value ?? '',
                                        'First name',
                                      ),
                                      decoration: _inputDecoration(
                                        context,
                                        label: 'First name',
                                        icon: Icons.person_outline,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      key: const ValueKey('register-last-name'),
                                      controller: _lastNameController,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: colors.onSurface,
                                      ),
                                      validator: (value) =>
                                          controller.validateName(
                                        value ?? '',
                                        'Last name',
                                      ),
                                      decoration: _inputDecoration(
                                        context,
                                        label: 'Last name',
                                        icon: Icons.person_outline,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const ValueKey('register-email'),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.newUsername],
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: colors.onSurface),
                              validator: (value) =>
                                  controller.validateEmail(value ?? ''),
                              decoration: _inputDecoration(
                                context,
                                label: 'Email',
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const ValueKey('register-password'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: colors.onSurface),
                              validator: (value) =>
                                  controller.validatePassword(value ?? ''),
                              decoration: _inputDecoration(
                                context,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  onPressed: ButtonFeedbackService.wrap(
                                    context,
                                    () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const ValueKey('register-confirm-password'),
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: TextStyle(color: colors.onSurface),
                              validator: (value) =>
                                  controller.validateConfirmPassword(
                                _passwordController.text,
                                value ?? '',
                              ),
                              decoration: _inputDecoration(
                                context,
                                label: 'Confirm password',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  onPressed: ButtonFeedbackService.wrap(
                                    context,
                                    () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            if (controller.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  controller.errorMessage!,
                                  style: TextStyle(
                                    color: colors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: ButtonFeedbackService.wrap(
                                  context,
                                  controller.isLoading
                                      ? null
                                      : () => _submit(controller),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: controller.isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: colors.onPrimary,
                                        ),
                                      )
                                    : const Text(
                                        'Create account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GoogleSignInButton(
                              isLoading: controller.isLoading,
                              onPressed: () => _submitGoogle(controller),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: ButtonFeedbackService.wrap(
                              context,
                              () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.surfaceVariant.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.4),
      ),
    );
  }
}
