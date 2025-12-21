// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AskCam';

  @override
  String get reminderTitle => '📸 AskCam Reminder';

  @override
  String get reminderBody =>
      'Scan your documents and understand them with AskCam.';

  @override
  String get reminderChannelName => 'AskCam Reminders';

  @override
  String get reminderChannelDescription => 'Periodic reminders to use AskCam.';

  @override
  String get tooltipLightMode => 'Light mode';

  @override
  String get tooltipDarkMode => 'Dark mode';

  @override
  String authErrorMessage(Object message) {
    return 'Authentication error: $message';
  }

  @override
  String get routeErrorTitle => 'Error';

  @override
  String get routeErrorHeading => 'Oops! Something went wrong';

  @override
  String routeErrorRoute(Object route) {
    return 'Route: $route';
  }

  @override
  String get routeErrorGoHome => 'Go to Home';

  @override
  String get routeErrorNoImage => 'No image file provided';

  @override
  String routeErrorInvalidArgs(Object argType) {
    return 'Invalid arguments: $argType';
  }

  @override
  String get routeErrorImageNotFound => 'Image file not found';

  @override
  String get routeErrorMissingTranslate => 'Missing translate arguments';

  @override
  String get routeErrorMissingAi => 'Missing AI arguments';

  @override
  String get routeErrorNotFound => 'Route not found';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordUppercase =>
      'Password must include at least 1 uppercase letter';

  @override
  String get validationPasswordNumber =>
      'Password must include at least 1 number';

  @override
  String validationFieldRequired(Object field) {
    return '$field is required';
  }

  @override
  String validationFieldMinLength(Object field) {
    return '$field must be at least 2 characters';
  }

  @override
  String get validationConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get authSignInFailed => 'Sign-in failed. Please try again.';

  @override
  String get authSignInCancelled => 'Sign-in cancelled.';

  @override
  String get authGoogleSignInFailed =>
      'Google sign-in failed. Please try again.';

  @override
  String get authRegistrationFailed => 'Registration failed. Please try again.';

  @override
  String get authResetFailed => 'Reset failed. Please try again.';

  @override
  String get authSignOutFailed => 'Unable to sign out. Please try again.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserNotFound => 'No user found for that email.';

  @override
  String get authErrorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authErrorEmailInUse => 'An account already exists for that email.';

  @override
  String get authErrorWeakPassword =>
      'Your password is too weak. Use at least 8 characters, 1 uppercase letter, and 1 number.';

  @override
  String get authErrorInvalidCredential =>
      'Invalid credentials. Double-check your email and password.';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'An account already exists with a different sign-in method.';

  @override
  String get authErrorOperationNotAllowed =>
      'Email/password sign-in is disabled for this project.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorPopupBlocked =>
      'Popup blocked. Please allow popups and try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrorInvalidApiKey =>
      'Invalid Firebase API key. Check your web configuration.';

  @override
  String get authErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String authErrorGeneric(Object code) {
    return 'Authentication failed ($code). Please try again.';
  }

  @override
  String get authErrorGoogleConfig =>
      'Google sign-in configuration error (SHA/package/OAuth).';

  @override
  String authErrorGoogleSignIn(Object code) {
    return 'Google sign-in failed ($code). Please try again.';
  }

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get authAccountCreated => 'Account created successfully.';

  @override
  String get authRegisterSubtitle => 'Join AskCam in a few steps';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get googleSignInButton => 'Continue with Google';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInToContinue => 'Sign in to continue';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNewHere => 'New here?';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLoginFailed => 'Login failed.';

  @override
  String get authResetEmailSent => 'Password reset email sent.';

  @override
  String get authRequestFailed => 'Request failed.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordSubtitle =>
      'Enter your email and we will send a reset link.';

  @override
  String get authResetPasswordAction => 'Send reset link';

  @override
  String get authLogout => 'Logout';

  @override
  String get authLogoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get authLogoutFailed => 'Logout failed.';

  @override
  String get authLoginRequiredToViewGallery =>
      'Please login to view your gallery.';

  @override
  String get authLoginRequiredToViewHistory => 'Please login to view history.';

  @override
  String get authLoginRequiredToSaveImages => 'Please login to save images.';

  @override
  String get authLoginRequiredToSaveHistory => 'Please login to save history.';

  @override
  String get authGoToLogin => 'Go to Login';

  @override
  String aiNotConfigured(Object args) {
    return 'AI is not configured. Please run the app with $args';
  }

  @override
  String get aiNoImageAvailable => 'No image available for AI analysis.';

  @override
  String get aiUnclearImage =>
      'I couldn\'t detect readable text or a clear question in this image. Please try another image or crop the area you want.';

  @override
  String get aiServiceUnavailable =>
      'We could not reach the AI service right now. Please try again later.';

  @override
  String get aiAnswerCopied => 'AI answer copied to clipboard.';

  @override
  String get aiAskTitle => 'Ask AI';

  @override
  String get aiAskQuestionTitle => 'Ask a question';

  @override
  String get aiAskQuestionHint =>
      'Optional: ask AI about the extracted text / image...';

  @override
  String get aiAsking => 'Asking AI...';

  @override
  String get aiAsk => 'Ask AI';

  @override
  String get aiAskAboutThis => 'Ask AI about this';

  @override
  String get aiAnswerTitle => 'AI Answer';

  @override
  String get aiResponseLabel => 'Response';

  @override
  String get aiResponsePlaceholder => 'AI response will appear here.';

  @override
  String get aiNoImageProvided => 'No image provided';

  @override
  String get aiNoAnswerFallback =>
      'The AI could not come up with an answer. Please try again.';

  @override
  String get aiEmptyHint =>
      'Ask AI to see step-by-step explanations or hints here.';

  @override
  String get aiWaitingResponse => 'Waiting for the AI assistant to respond...';

  @override
  String cameraPickImageError(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String get cameraTitle => 'Capture Moment';

  @override
  String get cameraClearImage => 'Clear Image';

  @override
  String get cameraNoImageSelected => 'No image selected';

  @override
  String get cameraEmptyHint => 'Tap the buttons below to get started';

  @override
  String get cameraImageCaptured => 'Image captured successfully';

  @override
  String get cameraGallery => 'Gallery';

  @override
  String get cameraCamera => 'Camera';

  @override
  String get cameraScanWithAi => 'Scan Text with AI';

  @override
  String get aboutApplication => 'About Application';

  @override
  String get aboutDescription =>
      'AskCam helps you capture or upload images, extract text using on-device OCR, translate it into multiple languages, and ask AI questions to better understand documents and homework.';

  @override
  String get aboutMlKitServicesTitle => 'ML Kit Features';

  @override
  String get aboutMlKitTextRecognition => 'Text Recognition (OCR)';

  @override
  String get aboutMlKitTextRecognitionDesc =>
      'Uses ML Kit on-device text recognition to detect and extract text from images. Works offline for instant results.';

  @override
  String get aboutMlKitTextRecognitionLink =>
      'https://developers.google.com/ml-kit/vision/text-recognition';

  @override
  String get aboutMlKitTranslation => 'Language Translation';

  @override
  String get aboutMlKitTranslationDesc =>
      'Uses ML Kit on-device translation to translate extracted text between languages. Fast and private.';

  @override
  String get aboutMlKitTranslationLink =>
      'https://developers.google.com/ml-kit/language/translation';

  @override
  String get aboutAiServiceTitle => 'AI Understanding';

  @override
  String get aboutAiServiceGemini => 'Gemini AI';

  @override
  String get aboutAiServiceGeminiDesc =>
      'Gemini analyzes extracted text to answer your questions and help you understand documents. Powered by Google AI.';

  @override
  String get aboutAiServiceGeminiLink => 'https://ai.google.dev/gemini-api';

  @override
  String get aboutPrivacyTitle => 'Privacy & Security';

  @override
  String get aboutPrivacyDesc =>
      'ML Kit features run on your device where possible. Your data is processed securely, and no sensitive information is stored unnecessarily.';

  @override
  String get aboutLearnMore => 'Learn more';

  @override
  String get aboutTargetUsersTitle => 'Target users';

  @override
  String get aboutTargetUsersStudents => 'Students and learners';

  @override
  String get galleryDeleteTitle => 'Delete image?';

  @override
  String get galleryDeleteMessage => 'Remove this image from your gallery?';

  @override
  String get galleryImageLoadFailed => 'Unable to load image.';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get galleryLoadFailed => 'Unable to load gallery.';

  @override
  String get galleryEmpty => 'No images yet.';

  @override
  String get historyDeleteTitle => 'Delete history item?';

  @override
  String get historyDeleteMessage => 'Remove this extraction from history?';

  @override
  String get historyTitle => 'History';

  @override
  String get historyLoadFailed => 'Unable to load history.';

  @override
  String get historyEmpty => 'No history yet.';

  @override
  String get historyNoExtractedText => 'No extracted text';

  @override
  String get historyNoText => 'No text to save yet.';

  @override
  String get historySaved => 'Saved to history.';

  @override
  String get historySaveFailed => 'Failed to save.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get homeWelcome => 'Welcome to';

  @override
  String get homeTagline =>
      'Capture, analyze, and discover insights from your images';

  @override
  String get homeCamera => 'Camera';

  @override
  String get homeCameraSubtitle => 'Take a photo';

  @override
  String get homeGallery => 'Gallery';

  @override
  String get homeGallerySubtitle => 'Browse photos';

  @override
  String get homeHistory => 'History';

  @override
  String get homeHistorySubtitle => 'Past scans';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeSettingsSubtitle => 'Preferences';

  @override
  String get reminderPermissionDenied => 'Notification permission denied.';

  @override
  String get ocrErrorUnableToRead =>
      'We could not read this photo. Please retake it in better lighting.';

  @override
  String get ocrUnableToExtract =>
      'Unable to extract text. Please try another photo.';

  @override
  String get ocrOriginalText => 'Original text';

  @override
  String get ocrExtractingHint =>
      'We are extracting text from the photo. Please hold tight.';

  @override
  String ocrTranslatedTextTitle(Object lang) {
    return 'Translated text ($lang)';
  }

  @override
  String get translationWaitingForOcr =>
      'Translation will appear once OCR completes.';

  @override
  String translationInProgress(Object language) {
    return 'Translating to $language...';
  }

  @override
  String get translateInto => 'Translate into:';

  @override
  String get translationAutoReapplyHint =>
      'Changing this option re-translates the detected text automatically.';

  @override
  String get translationUnavailableFallback =>
      'Translation unavailable right now. Showing the detected text instead.';

  @override
  String get translationUnavailableOriginal =>
      'Translation unavailable right now. Showing the original text.';

  @override
  String get translationFailedTryAgain =>
      'Unable to translate. Please try again.';

  @override
  String get translationCopied => 'Translated text copied to clipboard.';

  @override
  String get translationInProgressShort => 'Translating...';

  @override
  String get translationOutputPlaceholder => 'Translation will appear here.';

  @override
  String get translationNoText => 'No text to translate yet.';

  @override
  String get translateTitle => 'Translate';

  @override
  String get translateInputTitle => 'Text to translate';

  @override
  String get translateInputHint => 'Edit the text to translate...';

  @override
  String get translateAction => 'Translate';

  @override
  String get translateOutputTitle => 'Translated output';

  @override
  String get ocrExtractResultTitle => 'Extract Result';

  @override
  String get ocrOriginalExtractedText => 'Original extracted text';

  @override
  String get ocrExtractingText => 'Extracting text...';

  @override
  String get ocrRunning => 'OCR is running...';

  @override
  String get ocrEditHint => 'Edit the extracted text here.';

  @override
  String get ocrEditInstruction =>
      'Edit the text if OCR missed anything before translating or asking AI.';

  @override
  String get historySaveAction => 'Save history';

  @override
  String get actionHome => 'Home';

  @override
  String get actionTranslate => 'Translate';

  @override
  String get actionAskAi => 'Ask AI';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionBack => 'Back';

  @override
  String get actionBackToExtract => 'Back to Extract';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDeleted => 'Deleted.';

  @override
  String get actionDeleteFailed => 'Failed to delete. Please try again.';

  @override
  String get actionCopied => 'Copied to clipboard.';

  @override
  String get uploadingImage => 'Uploading image to cloud...';

  @override
  String get uploadFailedTryAgain => 'Upload failed. Please try again.';

  @override
  String get errorNoInternetConnection => 'No internet connection';

  @override
  String cloudinaryNotConfigured(Object args) {
    return 'Cloudinary is not configured. Please run the app with $args';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsSectionFeedback => 'Sound & Haptics';

  @override
  String get settingsSilentMode => 'Silent mode';

  @override
  String get settingsSilentModeHint =>
      'Silent mode disables sound and vibration.';

  @override
  String get settingsSoundEnabled => 'Button sounds';

  @override
  String get settingsVibrationEnabled => 'Vibration';

  @override
  String get settingsSectionReminders => 'Reminders';

  @override
  String get settingsReminderToggle => 'Usage reminder';

  @override
  String get settingsReminderHint => 'Get a reminder every 15 minutes.';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionOcr => 'OCR & ML';

  @override
  String get settingsAutoEnhanceImages => 'Auto-enhance images before OCR';

  @override
  String get settingsAutoDetectLanguage => 'Auto-detect language';

  @override
  String get settingsAutoDetectLanguageHint =>
      'When disabled, the app assumes the selected language.';

  @override
  String get settingsSectionPrivacy => 'Privacy & Cache';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsClearCacheWeb => 'Cache cleanup skipped on web.';

  @override
  String get settingsClearCacheDone => 'Cache cleared successfully.';

  @override
  String get settingsClearCacheFail =>
      'Unable to clear cache. Please try again.';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsLoggedInAs => 'Signed in as';

  @override
  String get placeholderDash => '-';
}
