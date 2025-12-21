import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:askcam/features/domain/auth/auth_repository.dart';
import 'package:askcam/l10n/app_localizations.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({required AuthRepository repository})
      : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<User?> get authState => _repository.authStateChanges();
  User? get currentUser => _repository.currentUser;

  String? validateEmail(String value, AppLocalizations l10n) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.validationEmailRequired;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  String? validatePassword(String value, AppLocalizations l10n) {
    if (value.isEmpty) return l10n.validationPasswordRequired;
    if (value.length < 8) return l10n.validationPasswordMinLength;
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.validationPasswordUppercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.validationPasswordNumber;
    }
    return null;
  }

  String? validateName(String value, String label, AppLocalizations l10n) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.validationFieldRequired(label);
    if (trimmed.length < 2) return l10n.validationFieldMinLength(label);
    return null;
  }

  String? validateConfirmPassword(
    String password,
    String confirm,
    AppLocalizations l10n,
  ) {
    if (confirm.isEmpty) return l10n.validationConfirmPasswordRequired;
    if (password != confirm) return l10n.validationPasswordMismatch;
    return null;
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    final sanitizedEmail = email.trim();
    final sanitizedPassword = password.trim();
    final emailError = validateEmail(sanitizedEmail, l10n);
    final passwordError = validatePassword(sanitizedPassword, l10n);
    if (emailError != null || passwordError != null) {
      _setError(emailError ?? passwordError);
      return false;
    }

    _setLoading(true);
    try {
      await _repository.signIn(
        email: sanitizedEmail,
        password: sanitizedPassword,
      );
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthException(e, l10n));
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error signIn: $e');
      debugPrintStack(stackTrace: stackTrace);
      final message = e.toString().trim();
      _setError(
        message.isNotEmpty ? message : l10n.authSignInFailed,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle({
    required AppLocalizations l10n,
  }) async {
    _setLoading(true);
    try {
      final credential = await _repository.signInWithGoogle();
      if (credential == null) {
        _setError(l10n.authSignInCancelled);
        return false;
      }
      _clearError();
      return true;
    } on PlatformException catch (e) {
      debugPrint('GoogleSignIn PlatformException: ${e.code} - ${e.message}');
      if (_hasAuthenticatedUser()) {
        _clearError();
        return true;
      }
      _setError(_mapGooglePlatformException(e, l10n));
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthException signInWithGoogle: ${e.code} - ${e.message}',
      );
      if (_hasAuthenticatedUser()) {
        _clearError();
        return true;
      }
      _setError(_mapAuthException(e, l10n));
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error signInWithGoogle: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (_hasAuthenticatedUser()) {
        _clearError();
        return true;
      }
      final message = e.toString().trim();
      _setError(
        message.isNotEmpty ? message : l10n.authGoogleSignInFailed,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required AppLocalizations l10n,
  }) async {
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();
    final sanitizedEmail = email.trim();
    final sanitizedPassword = password.trim();
    final sanitizedConfirm = confirmPassword.trim();

    final firstNameError =
        validateName(sanitizedFirstName, l10n.fieldFirstName, l10n);
    final lastNameError =
        validateName(sanitizedLastName, l10n.fieldLastName, l10n);
    final emailError = validateEmail(sanitizedEmail, l10n);
    final passwordError = validatePassword(sanitizedPassword, l10n);
    final confirmError =
        validateConfirmPassword(sanitizedPassword, sanitizedConfirm, l10n);

    final firstError = firstNameError ??
        lastNameError ??
        emailError ??
        passwordError ??
        confirmError;

    if (firstError != null) {
      _setError(firstError);
      return false;
    }

    _setLoading(true);
    try {
      _debugLogSignUpPayload(
        email: sanitizedEmail,
        password: sanitizedPassword,
      );
      await _repository.signUp(
        email: sanitizedEmail,
        password: sanitizedPassword,
        firstName: sanitizedFirstName,
        lastName: sanitizedLastName,
      );
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthException(e, l10n));
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error register: $e');
      debugPrintStack(stackTrace: stackTrace);
      final message = e.toString().trim();
      _setError(
        message.isNotEmpty ? message : l10n.authRegistrationFailed,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset({
    required String email,
    required AppLocalizations l10n,
  }) async {
    final emailError = validateEmail(email, l10n);
    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    _setLoading(true);
    try {
      await _repository.resetPassword(email: email.trim());
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthException(e, l10n));
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error sendPasswordReset: $e');
      debugPrintStack(stackTrace: stackTrace);
      final message = e.toString().trim();
      _setError(message.isNotEmpty ? message : l10n.authResetFailed);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signOut({required AppLocalizations l10n}) async {
    _setLoading(true);
    try {
      await _repository.signOut();
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthException(e, l10n));
      return false;
    } catch (_) {
      _setError(l10n.authSignOutFailed);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLastLogin() async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _repository.updateLastLogin(user.uid);
    } catch (_) {
      // Best-effort update; ignore failures here.
    }
  }

  String _mapAuthException(
    FirebaseAuthException exception,
    AppLocalizations l10n,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return l10n.authErrorInvalidEmail;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'email-already-in-use':
        return l10n.authErrorEmailInUse;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'invalid-credential':
        return l10n.authErrorInvalidCredential;
      case 'account-exists-with-different-credential':
        return l10n.authErrorAccountExistsDifferentMethod;
      case 'operation-not-allowed':
        return l10n.authErrorOperationNotAllowed;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return l10n.authSignInCancelled;
      case 'popup-blocked':
        return l10n.authErrorPopupBlocked;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'invalid-api-key':
        return l10n.authErrorInvalidApiKey;
      case 'network-request-failed':
        return l10n.authErrorNetwork;
      default:
        return exception.message ??
            l10n.authErrorGeneric(exception.code);
    }
  }

  String _mapGooglePlatformException(
    PlatformException exception,
    AppLocalizations l10n,
  ) {
    final message = exception.message ?? '';
    if (exception.code == 'network_error') {
      return l10n.authErrorNetwork;
    }
    if (exception.code == 'sign_in_canceled' ||
        exception.code == 'sign_in_cancelled') {
      return l10n.authSignInCancelled;
    }
    if (exception.code == 'sign_in_failed' &&
        message.contains('ApiException: 10')) {
      return l10n.authErrorGoogleConfig;
    }
    if (message.isNotEmpty) {
      return message;
    }
    return l10n.authErrorGoogleSignIn(exception.code);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  bool _hasAuthenticatedUser() => _repository.currentUser != null;

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _debugLogSignUpPayload({
    required String email,
    required String password,
  }) {
    assert(() {
      debugPrint(
        'Firebase signUp payload -> email: $email, password: $password',
      );
      return true;
    }());
  }
}
