import 'package:askcam/features/presentation/auth/auth_controller.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController controller) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (!kIsWeb) {
      TextInput.finishAutofillContext();
    }

    final success = await controller.sendPasswordReset(
      email: _emailController.text,
      l10n: context.l10n,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authResetEmailSent)),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      final message = controller.errorMessage ?? context.l10n.authRequestFailed;
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppCard(
                padding: AppSpacing.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authResetPasswordTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authResetPasswordSubtitle,
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
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                controller.validateEmail(value ?? '', l10n),
                            labelText: l10n.fieldEmail,
                            prefixIcon: Icon(Icons.email_outlined),
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
                            label: l10n.authResetPasswordAction,
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
                        ],
                      ),
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
