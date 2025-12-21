import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/widgets/google_sign_in_button.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/features/presentation/widgets/language_selector_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController controller) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      l10n: context.l10n,
    );

    if (success && mounted) {
      debugPrint('Login success, navigating to Home.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
      return;
    }

    if (!success && mounted) {
      final message = controller.errorMessage ?? context.l10n.authLoginFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _submitGoogle(AuthController controller) async {
    final success = await controller.signInWithGoogle(
      l10n: context.l10n,
    );

    if (success && mounted) {
      debugPrint('Google sign-in success, navigating to Home.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
      return;
    }

    if (!success && mounted) {
      final message =
          controller.errorMessage ?? context.l10n.authGoogleSignInFailed;
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          LanguageSelectorButton(),
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppCard(
                padding: AppSpacing.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authWelcomeBack,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authSignInToContinue,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                controller.validateEmail(value ?? '', l10n),
                            labelText: l10n.fieldEmail,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                controller.validatePassword(value ?? '', l10n),
                            labelText: l10n.fieldPassword,
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
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
                          SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: ButtonFeedbackService.wrap(
                                context,
                                () => Navigator.pushNamed(
                                  context,
                                  Routes.forgotPassword,
                                ),
                              ),
                              child: Text(l10n.authForgotPassword),
                            ),
                          ),
                          if (controller.errorMessage != null)
                            Padding(
                              padding: AppSpacing.only(top: AppSpacing.sm),
                              child: Text(
                                controller.errorMessage!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.error,
                                ),
                              ),
                            ),
                          SizedBox(height: AppSpacing.lg),
                          AppButton.primary(
                            label: l10n.authSignIn,
                            onPressed: ButtonFeedbackService.wrap(
                              context,
                              controller.isLoading
                                  ? null
                                  : () => _submit(controller),
                            ),
                            icon: controller.isLoading
                                ? SizedBox(
                                    width: AppSpacing.lg,
                                    height: AppSpacing.lg,
                                    child: CircularProgressIndicator(
                                      strokeWidth: AppSpacing.xs,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          GoogleSignInButton(
                            isLoading: controller.isLoading,
                            onPressed: () => _submitGoogle(controller),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authNewHere,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: ButtonFeedbackService.wrap(
                            context,
                            () => Navigator.pushNamed(
                              context,
                              Routes.register,
                            ),
                          ),
                          child: Text(l10n.authCreateAccount),
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
    );
  }
}
