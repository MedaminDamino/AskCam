import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/widgets/google_sign_in_button.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';

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
      l10n: context.l10n,
    );

    if (!mounted) return;

    if (success) {
      debugPrint('Registration success, navigating to Home.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authAccountCreated)),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
    } else {
      final message = controller.errorMessage ?? context.l10n.authRegistrationFailed;
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
      debugPrint('Google sign-up success, navigating to Home.');
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
        foregroundColor: colors.onBackground,
        elevation: 0,
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                padding: AppSpacing.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authCreateAccount,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authRegisterSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
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
                                      child: AppTextField(
                                        controller: _firstNameController,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            controller.validateName(
                                              value ?? '',
                                              l10n.fieldFirstName,
                                              l10n,
                                            ),
                                        labelText: l10n.fieldFirstName,
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: AppTextField(
                                        controller: _lastNameController,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            controller.validateName(
                                              value ?? '',
                                              l10n.fieldLastName,
                                              l10n,
                                            ),
                                        labelText: l10n.fieldLastName,
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  AppTextField(
                                    controller: _firstNameController,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        controller.validateName(
                                          value ?? '',
                                          l10n.fieldFirstName,
                                          l10n,
                                        ),
                                    labelText: l10n.fieldFirstName,
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  SizedBox(height: AppSpacing.lg),
                                  AppTextField(
                                    controller: _lastNameController,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        controller.validateName(
                                          value ?? '',
                                          l10n.fieldLastName,
                                          l10n,
                                        ),
                                    labelText: l10n.fieldLastName,
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
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
                            textInputAction: TextInputAction.next,
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
                          SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                controller.validateConfirmPassword(
                              _passwordController.text,
                              value ?? '',
                              l10n,
                            ),
                            labelText: l10n.fieldConfirmPassword,
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
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
                          SizedBox(height: AppSpacing.xl),
                          AppButton.primary(
                            label: l10n.authCreateAccount,
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
                          l10n.authAlreadyHaveAccount,
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
                          child: Text(l10n.authSignIn),
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
