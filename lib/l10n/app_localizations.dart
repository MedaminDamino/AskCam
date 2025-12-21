import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AskCam'**
  String get appTitle;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'📸 AskCam Reminder'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Scan your documents and understand them with AskCam.'**
  String get reminderBody;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'AskCam Reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Periodic reminders to use AskCam.'**
  String get reminderChannelDescription;

  /// No description provided for @tooltipLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get tooltipLightMode;

  /// No description provided for @tooltipDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get tooltipDarkMode;

  /// No description provided for @authErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {message}'**
  String authErrorMessage(Object message);

  /// No description provided for @routeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get routeErrorTitle;

  /// No description provided for @routeErrorHeading.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get routeErrorHeading;

  /// No description provided for @routeErrorRoute.
  ///
  /// In en, this message translates to:
  /// **'Route: {route}'**
  String routeErrorRoute(Object route);

  /// No description provided for @routeErrorGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get routeErrorGoHome;

  /// No description provided for @routeErrorNoImage.
  ///
  /// In en, this message translates to:
  /// **'No image file provided'**
  String get routeErrorNoImage;

  /// No description provided for @routeErrorInvalidArgs.
  ///
  /// In en, this message translates to:
  /// **'Invalid arguments: {argType}'**
  String routeErrorInvalidArgs(Object argType);

  /// No description provided for @routeErrorImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image file not found'**
  String get routeErrorImageNotFound;

  /// No description provided for @routeErrorMissingTranslate.
  ///
  /// In en, this message translates to:
  /// **'Missing translate arguments'**
  String get routeErrorMissingTranslate;

  /// No description provided for @routeErrorMissingAi.
  ///
  /// In en, this message translates to:
  /// **'Missing AI arguments'**
  String get routeErrorMissingAi;

  /// No description provided for @routeErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeErrorNotFound;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least 1 uppercase letter'**
  String get validationPasswordUppercase;

  /// No description provided for @validationPasswordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least 1 number'**
  String get validationPasswordNumber;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationFieldRequired(Object field);

  /// No description provided for @validationFieldMinLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at least 2 characters'**
  String validationFieldMinLength(Object field);

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get authSignInFailed;

  /// No description provided for @authSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled.'**
  String get authSignInCancelled;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailed;

  /// No description provided for @authRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get authRegistrationFailed;

  /// No description provided for @authResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed. Please try again.'**
  String get authResetFailed;

  /// No description provided for @authSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out. Please try again.'**
  String get authSignOutFailed;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak. Use at least 8 characters, 1 uppercase letter, and 1 number.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Double-check your email and password.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorAccountExistsDifferentMethod.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method.'**
  String get authErrorAccountExistsDifferentMethod;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-in is disabled for this project.'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorPopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Popup blocked. Please allow popups and try again.'**
  String get authErrorPopupBlocked;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorInvalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid Firebase API key. Check your web configuration.'**
  String get authErrorInvalidApiKey;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed ({code}). Please try again.'**
  String authErrorGeneric(Object code);

  /// No description provided for @authErrorGoogleConfig.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in configuration error (SHA/package/OAuth).'**
  String get authErrorGoogleConfig;

  /// No description provided for @authErrorGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed ({code}). Please try again.'**
  String authErrorGoogleSignIn(Object code);

  /// No description provided for @fieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get fieldLastName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @authAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully.'**
  String get authAccountCreated;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join AskCam in a few steps'**
  String get authRegisterSubtitle;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @googleSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignInButton;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNewHere;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get authLoginFailed;

  /// No description provided for @authResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get authResetEmailSent;

  /// No description provided for @authRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed.'**
  String get authRequestFailed;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a reset link.'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authResetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authResetPasswordAction;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get authLogoutConfirmation;

  /// No description provided for @authLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed.'**
  String get authLogoutFailed;

  /// No description provided for @authLoginRequiredToViewGallery.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your gallery.'**
  String get authLoginRequiredToViewGallery;

  /// No description provided for @authLoginRequiredToViewHistory.
  ///
  /// In en, this message translates to:
  /// **'Please login to view history.'**
  String get authLoginRequiredToViewHistory;

  /// No description provided for @authLoginRequiredToSaveImages.
  ///
  /// In en, this message translates to:
  /// **'Please login to save images.'**
  String get authLoginRequiredToSaveImages;

  /// No description provided for @authLoginRequiredToSaveWords.
  ///
  /// In en, this message translates to:
  /// **'Please login to save words.'**
  String get authLoginRequiredToSaveWords;

  /// No description provided for @authLoginRequiredToSaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Please login to save history.'**
  String get authLoginRequiredToSaveHistory;

  /// No description provided for @authGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get authGoToLogin;

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI is not configured. Please run the app with {args}'**
  String aiNotConfigured(Object args);

  /// No description provided for @aiNoImageAvailable.
  ///
  /// In en, this message translates to:
  /// **'No image available for AI analysis.'**
  String get aiNoImageAvailable;

  /// No description provided for @aiUnclearImage.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t detect readable text or a clear question in this image. Please try another image or crop the area you want.'**
  String get aiUnclearImage;

  /// No description provided for @aiServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We could not reach the AI service right now. Please try again later.'**
  String get aiServiceUnavailable;

  /// No description provided for @aiAnswerCopied.
  ///
  /// In en, this message translates to:
  /// **'AI answer copied to clipboard.'**
  String get aiAnswerCopied;

  /// No description provided for @aiAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiAskTitle;

  /// No description provided for @aiAskQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get aiAskQuestionTitle;

  /// No description provided for @aiAskQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: ask AI about the extracted text / image...'**
  String get aiAskQuestionHint;

  /// No description provided for @aiAsking.
  ///
  /// In en, this message translates to:
  /// **'Asking AI...'**
  String get aiAsking;

  /// No description provided for @aiAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiAsk;

  /// No description provided for @aiAskAboutThis.
  ///
  /// In en, this message translates to:
  /// **'Ask AI about this'**
  String get aiAskAboutThis;

  /// No description provided for @aiAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Answer'**
  String get aiAnswerTitle;

  /// No description provided for @aiResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get aiResponseLabel;

  /// No description provided for @aiResponsePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'AI response will appear here.'**
  String get aiResponsePlaceholder;

  /// No description provided for @aiNoImageProvided.
  ///
  /// In en, this message translates to:
  /// **'No image provided'**
  String get aiNoImageProvided;

  /// No description provided for @aiNoAnswerFallback.
  ///
  /// In en, this message translates to:
  /// **'The AI could not come up with an answer. Please try again.'**
  String get aiNoAnswerFallback;

  /// No description provided for @aiEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Ask AI to see step-by-step explanations or hints here.'**
  String get aiEmptyHint;

  /// No description provided for @aiWaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the AI assistant to respond...'**
  String get aiWaitingResponse;

  /// No description provided for @cameraPickImageError.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String cameraPickImageError(Object error);

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture Moment'**
  String get cameraTitle;

  /// No description provided for @cameraClearImage.
  ///
  /// In en, this message translates to:
  /// **'Clear Image'**
  String get cameraClearImage;

  /// No description provided for @cameraNoImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get cameraNoImageSelected;

  /// No description provided for @cameraEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the buttons below to get started'**
  String get cameraEmptyHint;

  /// No description provided for @cameraImageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Image captured successfully'**
  String get cameraImageCaptured;

  /// No description provided for @cameraGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get cameraGallery;

  /// No description provided for @cameraCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraCamera;

  /// No description provided for @cameraScanWithAi.
  ///
  /// In en, this message translates to:
  /// **'Scan Text with AI'**
  String get cameraScanWithAi;

  /// No description provided for @aboutApplication.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get aboutApplication;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AskCam is a Flutter mobile application that allows users to capture or upload images, extract text using ML Kit OCR, translate the extracted text, and ask AI questions to better understand documents and homework.'**
  String get aboutDescription;

  /// No description provided for @aboutMlKitServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'ML Kit services used'**
  String get aboutMlKitServicesTitle;

  /// No description provided for @aboutMlKitTextRecognition.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition (OCR)'**
  String get aboutMlKitTextRecognition;

  /// No description provided for @aboutMlKitTranslation.
  ///
  /// In en, this message translates to:
  /// **'On-device Translation'**
  String get aboutMlKitTranslation;

  /// No description provided for @aboutAiServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI service'**
  String get aboutAiServiceTitle;

  /// No description provided for @aboutAiServiceGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini API'**
  String get aboutAiServiceGemini;

  /// No description provided for @aboutTargetUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Target users'**
  String get aboutTargetUsersTitle;

  /// No description provided for @aboutTargetUsersStudents.
  ///
  /// In en, this message translates to:
  /// **'Students and learners'**
  String get aboutTargetUsersStudents;

  /// No description provided for @galleryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete image?'**
  String get galleryDeleteTitle;

  /// No description provided for @galleryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this image from your gallery?'**
  String get galleryDeleteMessage;

  /// No description provided for @galleryImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image.'**
  String get galleryImageLoadFailed;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTitle;

  /// No description provided for @galleryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load gallery.'**
  String get galleryLoadFailed;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No images yet.'**
  String get galleryEmpty;

  /// No description provided for @savedWordsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete saved word?'**
  String get savedWordsDeleteTitle;

  /// No description provided for @savedWordsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{word}\" from your saved words?'**
  String savedWordsDeleteMessage(Object word);

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete history item?'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this extraction from history?'**
  String get historyDeleteMessage;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @savedWordsTab.
  ///
  /// In en, this message translates to:
  /// **'Saved Words'**
  String get savedWordsTab;

  /// No description provided for @historyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history.'**
  String get historyLoadFailed;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get historyEmpty;

  /// No description provided for @historyNoExtractedText.
  ///
  /// In en, this message translates to:
  /// **'No extracted text'**
  String get historyNoExtractedText;

  /// No description provided for @historyNoText.
  ///
  /// In en, this message translates to:
  /// **'No text to save yet.'**
  String get historyNoText;

  /// No description provided for @historySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to history.'**
  String get historySaved;

  /// No description provided for @historySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save.'**
  String get historySaveFailed;

  /// No description provided for @savedWordsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved words'**
  String get savedWordsSearchHint;

  /// No description provided for @savedWordsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load saved words.'**
  String get savedWordsLoadFailed;

  /// No description provided for @savedWordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved words yet.'**
  String get savedWordsEmpty;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get homeWelcome;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Capture, analyze, and discover insights from your images'**
  String get homeTagline;

  /// No description provided for @homeCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get homeCamera;

  /// No description provided for @homeCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get homeCameraSubtitle;

  /// No description provided for @homeGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get homeGallery;

  /// No description provided for @homeGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse photos'**
  String get homeGallerySubtitle;

  /// No description provided for @homeHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeHistory;

  /// No description provided for @homeHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past scans'**
  String get homeHistorySubtitle;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get homeSettingsSubtitle;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied.'**
  String get reminderPermissionDenied;

  /// No description provided for @ocrErrorUnableToRead.
  ///
  /// In en, this message translates to:
  /// **'We could not read this photo. Please retake it in better lighting.'**
  String get ocrErrorUnableToRead;

  /// No description provided for @ocrUnableToExtract.
  ///
  /// In en, this message translates to:
  /// **'Unable to extract text. Please try another photo.'**
  String get ocrUnableToExtract;

  /// No description provided for @ocrOriginalText.
  ///
  /// In en, this message translates to:
  /// **'Original text'**
  String get ocrOriginalText;

  /// No description provided for @ocrExtractingHint.
  ///
  /// In en, this message translates to:
  /// **'We are extracting text from the photo. Please hold tight.'**
  String get ocrExtractingHint;

  /// No description provided for @ocrTranslatedTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Translated text ({lang})'**
  String ocrTranslatedTextTitle(Object lang);

  /// No description provided for @translationWaitingForOcr.
  ///
  /// In en, this message translates to:
  /// **'Translation will appear once OCR completes.'**
  String get translationWaitingForOcr;

  /// No description provided for @translationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Translating to {language}...'**
  String translationInProgress(Object language);

  /// No description provided for @translateInto.
  ///
  /// In en, this message translates to:
  /// **'Translate into:'**
  String get translateInto;

  /// No description provided for @translationAutoReapplyHint.
  ///
  /// In en, this message translates to:
  /// **'Changing this option re-translates the detected text automatically.'**
  String get translationAutoReapplyHint;

  /// No description provided for @translationUnavailableFallback.
  ///
  /// In en, this message translates to:
  /// **'Translation unavailable right now. Showing the detected text instead.'**
  String get translationUnavailableFallback;

  /// No description provided for @translationUnavailableOriginal.
  ///
  /// In en, this message translates to:
  /// **'Translation unavailable right now. Showing the original text.'**
  String get translationUnavailableOriginal;

  /// No description provided for @translationFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Unable to translate. Please try again.'**
  String get translationFailedTryAgain;

  /// No description provided for @translationCopied.
  ///
  /// In en, this message translates to:
  /// **'Translated text copied to clipboard.'**
  String get translationCopied;

  /// No description provided for @translationInProgressShort.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translationInProgressShort;

  /// No description provided for @translationOutputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Translation will appear here.'**
  String get translationOutputPlaceholder;

  /// No description provided for @translationNoText.
  ///
  /// In en, this message translates to:
  /// **'No text to translate yet.'**
  String get translationNoText;

  /// No description provided for @translateTitle.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translateTitle;

  /// No description provided for @translateInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Text to translate'**
  String get translateInputTitle;

  /// No description provided for @translateInputHint.
  ///
  /// In en, this message translates to:
  /// **'Edit the text to translate...'**
  String get translateInputHint;

  /// No description provided for @translateAction.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translateAction;

  /// No description provided for @translateOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Translated output'**
  String get translateOutputTitle;

  /// No description provided for @ocrExtractResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Extract Result'**
  String get ocrExtractResultTitle;

  /// No description provided for @ocrOriginalExtractedText.
  ///
  /// In en, this message translates to:
  /// **'Original extracted text'**
  String get ocrOriginalExtractedText;

  /// No description provided for @ocrExtractingText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text...'**
  String get ocrExtractingText;

  /// No description provided for @ocrRunning.
  ///
  /// In en, this message translates to:
  /// **'OCR is running...'**
  String get ocrRunning;

  /// No description provided for @ocrEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit the extracted text here.'**
  String get ocrEditHint;

  /// No description provided for @ocrEditInstruction.
  ///
  /// In en, this message translates to:
  /// **'Edit the text if OCR missed anything before translating or asking AI.'**
  String get ocrEditInstruction;

  /// No description provided for @saveWordsNoText.
  ///
  /// In en, this message translates to:
  /// **'No text to save yet.'**
  String get saveWordsNoText;

  /// No description provided for @saveWordsSelectOrTypeError.
  ///
  /// In en, this message translates to:
  /// **'Select a word/phrase first or type one.'**
  String get saveWordsSelectOrTypeError;

  /// No description provided for @saveWordsLengthError.
  ///
  /// In en, this message translates to:
  /// **'Word length must be between 2 and 120 characters.'**
  String get saveWordsLengthError;

  /// No description provided for @saveWordsAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved.'**
  String get saveWordsAlreadySaved;

  /// No description provided for @saveWordsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saveWordsSaved;

  /// No description provided for @saveWordsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save, try again.'**
  String get saveWordsFailed;

  /// No description provided for @saveWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Save words'**
  String get saveWordsTitle;

  /// No description provided for @saveWordsInstruction.
  ///
  /// In en, this message translates to:
  /// **'Select a word or phrase in the text above, or type one below.'**
  String get saveWordsInstruction;

  /// No description provided for @saveWordsHint.
  ///
  /// In en, this message translates to:
  /// **'Type a word or phrase to save'**
  String get saveWordsHint;

  /// No description provided for @historySaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save history'**
  String get historySaveAction;

  /// No description provided for @saveWordsAction.
  ///
  /// In en, this message translates to:
  /// **'Save words'**
  String get saveWordsAction;

  /// No description provided for @actionHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get actionHome;

  /// No description provided for @actionTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get actionTranslate;

  /// No description provided for @actionAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get actionAskAi;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionBackToExtract.
  ///
  /// In en, this message translates to:
  /// **'Back to Extract'**
  String get actionBackToExtract;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted.'**
  String get actionDeleted;

  /// No description provided for @actionDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete. Please try again.'**
  String get actionDeleteFailed;

  /// No description provided for @actionCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get actionCopied;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image to cloud...'**
  String get uploadingImage;

  /// No description provided for @uploadFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get uploadFailedTryAgain;

  /// No description provided for @errorNoInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternetConnection;

  /// No description provided for @cloudinaryNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloudinary is not configured. Please run the app with {args}'**
  String cloudinaryNotConfigured(Object args);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSectionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Sound & Haptics'**
  String get settingsSectionFeedback;

  /// No description provided for @settingsSilentMode.
  ///
  /// In en, this message translates to:
  /// **'Silent mode'**
  String get settingsSilentMode;

  /// No description provided for @settingsSilentModeHint.
  ///
  /// In en, this message translates to:
  /// **'Silent mode disables sound and vibration.'**
  String get settingsSilentModeHint;

  /// No description provided for @settingsSoundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Button sounds'**
  String get settingsSoundEnabled;

  /// No description provided for @settingsVibrationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibrationEnabled;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsSectionReminders;

  /// No description provided for @settingsReminderToggle.
  ///
  /// In en, this message translates to:
  /// **'Usage reminder'**
  String get settingsReminderToggle;

  /// No description provided for @settingsReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Get a reminder every 15 minutes.'**
  String get settingsReminderHint;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionOcr.
  ///
  /// In en, this message translates to:
  /// **'OCR & ML'**
  String get settingsSectionOcr;

  /// No description provided for @settingsAutoEnhanceImages.
  ///
  /// In en, this message translates to:
  /// **'Auto-enhance images before OCR'**
  String get settingsAutoEnhanceImages;

  /// No description provided for @settingsAutoDetectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect language'**
  String get settingsAutoDetectLanguage;

  /// No description provided for @settingsAutoDetectLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'When disabled, the app assumes the selected language.'**
  String get settingsAutoDetectLanguageHint;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Cache'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheWeb.
  ///
  /// In en, this message translates to:
  /// **'Cache cleanup skipped on web.'**
  String get settingsClearCacheWeb;

  /// No description provided for @settingsClearCacheDone.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully.'**
  String get settingsClearCacheDone;

  /// No description provided for @settingsClearCacheFail.
  ///
  /// In en, this message translates to:
  /// **'Unable to clear cache. Please try again.'**
  String get settingsClearCacheFail;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsLoggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get settingsLoggedInAs;

  /// No description provided for @placeholderDash.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get placeholderDash;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
