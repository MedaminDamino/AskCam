import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:askcam/features/domain/auth/auth_repository.dart';

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

  String? validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must include at least 1 uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include at least 1 number';
    }
    return null;
  }

  String? validateName(String value, String label) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '$label is required';
    if (trimmed.length < 2) return '$label must be at least 2 characters';
    return null;
  }

  String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final sanitizedEmail = email.trim();
    final sanitizedPassword = password.trim();
    final emailError = validateEmail(sanitizedEmail);
    final passwordError = validatePassword(sanitizedPassword);
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
      _setError(_mapAuthException(e));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
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
  }) async {
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();
    final sanitizedEmail = email.trim();
    final sanitizedPassword = password.trim();
    final sanitizedConfirm = confirmPassword.trim();

    final firstNameError = validateName(sanitizedFirstName, 'First name');
    final lastNameError = validateName(sanitizedLastName, 'Last name');
    final emailError = validateEmail(sanitizedEmail);
    final passwordError = validatePassword(sanitizedPassword);
    final confirmError =
        validateConfirmPassword(sanitizedPassword, sanitizedConfirm);

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
      _setError(_mapAuthException(e));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    final emailError = validateEmail(email);
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
      _setError(_mapAuthException(e));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signOut() async {
    _setLoading(true);
    try {
      await _repository.signOut();
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthException(e));
      return false;
    } catch (_) {
      _setError('Unable to sign out. Please try again.');
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

  String _mapAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 8 characters, 1 uppercase letter, and 1 number.';
      case 'invalid-credential':
        return 'Invalid credentials. Double-check your email and password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled for this project.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-api-key':
        return 'Invalid Firebase API key. Check your web configuration.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return exception.message ??
            'Authentication failed (${exception.code}). Please try again.';
    }
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
