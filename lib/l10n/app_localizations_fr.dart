// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AskCam';

  @override
  String get reminderTitle => '📸 Rappel AskCam';

  @override
  String get reminderBody =>
      'Scannez vos documents et comprenez-les avec AskCam.';

  @override
  String get reminderChannelName => 'Rappels AskCam';

  @override
  String get reminderChannelDescription =>
      'Rappels periodiques pour utiliser AskCam.';

  @override
  String get tooltipLightMode => 'Mode clair';

  @override
  String get tooltipDarkMode => 'Mode sombre';

  @override
  String authErrorMessage(Object message) {
    return 'Erreur d\'authentification : $message';
  }

  @override
  String get routeErrorTitle => 'Erreur';

  @override
  String get routeErrorHeading => 'Oups ! Une erreur est survenue';

  @override
  String routeErrorRoute(Object route) {
    return 'Route : $route';
  }

  @override
  String get routeErrorGoHome => 'Aller a l\'accueil';

  @override
  String get routeErrorNoImage => 'Aucun fichier image fourni';

  @override
  String routeErrorInvalidArgs(Object argType) {
    return 'Arguments invalides : $argType';
  }

  @override
  String get routeErrorImageNotFound => 'Fichier image introuvable';

  @override
  String get routeErrorMissingTranslate => 'Arguments de traduction manquants';

  @override
  String get routeErrorMissingAi => 'Arguments IA manquants';

  @override
  String get routeErrorNotFound => 'Route introuvable';

  @override
  String get validationEmailRequired => 'L\'email est obligatoire';

  @override
  String get validationEmailInvalid => 'Entrez une adresse email valide';

  @override
  String get validationPasswordRequired => 'Le mot de passe est obligatoire';

  @override
  String get validationPasswordMinLength =>
      'Le mot de passe doit contenir au moins 8 caracteres';

  @override
  String get validationPasswordUppercase =>
      'Le mot de passe doit contenir au moins 1 majuscule';

  @override
  String get validationPasswordNumber =>
      'Le mot de passe doit contenir au moins 1 chiffre';

  @override
  String validationFieldRequired(Object field) {
    return '$field est obligatoire';
  }

  @override
  String validationFieldMinLength(Object field) {
    return '$field doit contenir au moins 2 caracteres';
  }

  @override
  String get validationConfirmPasswordRequired =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authSignInFailed => 'Echec de connexion. Veuillez reessayer.';

  @override
  String get authSignInCancelled => 'Connexion annulee.';

  @override
  String get authGoogleSignInFailed =>
      'Connexion Google echouee. Veuillez reessayer.';

  @override
  String get authRegistrationFailed =>
      'Inscription echouee. Veuillez reessayer.';

  @override
  String get authResetFailed => 'Reinitialisation echouee. Veuillez reessayer.';

  @override
  String get authSignOutFailed =>
      'Impossible de se deconnecter. Veuillez reessayer.';

  @override
  String get authErrorInvalidEmail => 'L\'adresse email n\'est pas valide.';

  @override
  String get authErrorUserNotFound => 'Aucun utilisateur pour cet email.';

  @override
  String get authErrorWrongPassword =>
      'Mot de passe incorrect. Veuillez reessayer.';

  @override
  String get authErrorEmailInUse => 'Un compte existe deja avec cet email.';

  @override
  String get authErrorWeakPassword =>
      'Mot de passe trop faible. Utilisez au moins 8 caracteres, 1 majuscule et 1 chiffre.';

  @override
  String get authErrorInvalidCredential =>
      'Identifiants invalides. Verifiez votre email et mot de passe.';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'Un compte existe deja avec une methode de connexion differente.';

  @override
  String get authErrorOperationNotAllowed =>
      'La connexion email/mot de passe est desactivee pour ce projet.';

  @override
  String get authErrorUserDisabled => 'Ce compte a ete desactive.';

  @override
  String get authErrorPopupBlocked =>
      'Popup bloquee. Autorisez les popups puis reessayez.';

  @override
  String get authErrorTooManyRequests =>
      'Trop de tentatives. Veuillez reessayer plus tard.';

  @override
  String get authErrorInvalidApiKey =>
      'Cle API Firebase invalide. Verifiez la configuration web.';

  @override
  String get authErrorNetwork =>
      'Erreur reseau. Verifiez votre connexion et reessayez.';

  @override
  String authErrorGeneric(Object code) {
    return 'Echec d\'authentification ($code). Veuillez reessayer.';
  }

  @override
  String get authErrorGoogleConfig =>
      'Erreur de configuration Google (SHA/package/OAuth).';

  @override
  String authErrorGoogleSignIn(Object code) {
    return 'Connexion Google echouee ($code). Veuillez reessayer.';
  }

  @override
  String get fieldFirstName => 'Prenom';

  @override
  String get fieldLastName => 'Nom';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get fieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authAccountCreated => 'Compte cree avec succes.';

  @override
  String get authRegisterSubtitle => 'Rejoignez AskCam en quelques etapes';

  @override
  String get authAlreadyHaveAccount => 'Vous avez deja un compte ?';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get googleSignInButton => 'Continuer avec Google';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authSignInToContinue => 'Connectez-vous pour continuer';

  @override
  String get authForgotPassword => 'Mot de passe oublie ?';

  @override
  String get authNewHere => 'Nouveau ici ?';

  @override
  String get authCreateAccount => 'Creer un compte';

  @override
  String get authLoginFailed => 'Connexion echouee.';

  @override
  String get authResetEmailSent => 'Email de reinitialisation envoye.';

  @override
  String get authRequestFailed => 'Requete echouee.';

  @override
  String get authResetPasswordTitle => 'Reinitialiser le mot de passe';

  @override
  String get authResetPasswordSubtitle =>
      'Entrez votre email et nous vous enverrons un lien de reinitialisation.';

  @override
  String get authResetPasswordAction => 'Envoyer le lien';

  @override
  String get authLogout => 'Se deconnecter';

  @override
  String get authLogoutConfirmation => 'Voulez-vous vous deconnecter ?';

  @override
  String get authLogoutFailed => 'Deconnexion echouee.';

  @override
  String get authLoginRequiredToViewGallery =>
      'Veuillez vous connecter pour voir votre galerie.';

  @override
  String get authLoginRequiredToViewHistory =>
      'Veuillez vous connecter pour voir l\'historique.';

  @override
  String get authLoginRequiredToSaveImages =>
      'Veuillez vous connecter pour enregistrer les images.';

  @override
  String get authLoginRequiredToSaveHistory =>
      'Veuillez vous connecter pour enregistrer l\'historique.';

  @override
  String get authGoToLogin => 'Aller a la connexion';

  @override
  String aiNotConfigured(Object args) {
    return 'L\'IA n\'est pas configuree. Lancez l\'application avec $args';
  }

  @override
  String get aiNoImageAvailable =>
      'Aucune image disponible pour l\'analyse IA.';

  @override
  String get aiUnclearImage =>
      'Je n\'ai pas detecte de texte lisible ou de question claire dans cette image. Essayez une autre image ou recadrez la zone voulue.';

  @override
  String get aiServiceUnavailable =>
      'Impossible de joindre le service IA pour le moment. Veuillez reessayer plus tard.';

  @override
  String get aiAnswerCopied => 'Reponse IA copiee dans le presse-papiers.';

  @override
  String get aiAskTitle => 'Demander a l\'IA';

  @override
  String get aiAskQuestionTitle => 'Poser une question';

  @override
  String get aiAskQuestionHint =>
      'Optionnel : demander a l\'IA a propos du texte ou de l\'image...';

  @override
  String get aiAsking => 'Demande a l\'IA...';

  @override
  String get aiAsk => 'Demander a l\'IA';

  @override
  String get aiAskAboutThis => 'Demander a l\'IA a propos de ceci';

  @override
  String get aiAnswerTitle => 'Reponse IA';

  @override
  String get aiResponseLabel => 'Reponse';

  @override
  String get aiResponsePlaceholder => 'La reponse de l\'IA apparaitra ici.';

  @override
  String get aiNoImageProvided => 'Aucune image fournie';

  @override
  String get aiNoAnswerFallback =>
      'L\'IA n\'a pas pu fournir de reponse. Veuillez reessayer.';

  @override
  String get aiEmptyHint =>
      'Demandez a l\'IA pour voir des explications ou des indices ici.';

  @override
  String get aiWaitingResponse => 'En attente de la reponse de l\'IA...';

  @override
  String cameraPickImageError(Object error) {
    return 'Erreur lors du choix de l\'image : $error';
  }

  @override
  String get cameraTitle => 'Capture';

  @override
  String get cameraClearImage => 'Supprimer l\'image';

  @override
  String get cameraNoImageSelected => 'Aucune image selectionnee';

  @override
  String get cameraEmptyHint =>
      'Appuyez sur les boutons ci-dessous pour commencer';

  @override
  String get cameraImageCaptured => 'Image capturee avec succes';

  @override
  String get cameraGallery => 'Galerie';

  @override
  String get cameraCamera => 'Camera';

  @override
  String get cameraScanWithAi => 'Scanner le texte avec l\'IA';

  @override
  String get aboutApplication => 'A propos de l\'application';

  @override
  String get aboutDescription =>
      'AskCam vous aide a capturer ou importer des images, extraire le texte avec OCR sur l\'appareil, le traduire en plusieurs langues et poser des questions a l\'IA pour mieux comprendre vos documents et devoirs.';

  @override
  String get aboutMlKitServicesTitle => 'Fonctionnalites ML Kit';

  @override
  String get aboutMlKitTextRecognition => 'Reconnaissance de texte (OCR)';

  @override
  String get aboutMlKitTextRecognitionDesc =>
      'Utilise la reconnaissance de texte ML Kit sur l\'appareil pour detecter et extraire le texte des images. Fonctionne hors ligne pour des resultats instantanes.';

  @override
  String get aboutMlKitTextRecognitionLink =>
      'https://developers.google.com/ml-kit/vision/text-recognition';

  @override
  String get aboutMlKitTranslation => 'Traduction linguistique';

  @override
  String get aboutMlKitTranslationDesc =>
      'Utilise la traduction ML Kit sur l\'appareil pour traduire le texte extrait entre langues. Rapide et confidentiel.';

  @override
  String get aboutMlKitTranslationLink =>
      'https://developers.google.com/ml-kit/language/translation';

  @override
  String get aboutAiServiceTitle => 'Comprehension IA';

  @override
  String get aboutAiServiceGemini => 'Gemini IA';

  @override
  String get aboutAiServiceGeminiDesc =>
      'Gemini analyse le texte extrait pour repondre a vos questions et vous aider a comprendre les documents. Propulse par Google AI.';

  @override
  String get aboutAiServiceGeminiLink => 'https://ai.google.dev/gemini-api';

  @override
  String get aboutPrivacyTitle => 'Confidentialite et securite';

  @override
  String get aboutPrivacyDesc =>
      'Les fonctionnalites ML Kit s\'executent sur votre appareil si possible. Vos donnees sont traitees en toute securite et aucune information sensible n\'est stockee inutilement.';

  @override
  String get aboutLearnMore => 'En savoir plus';

  @override
  String get aboutTargetUsersTitle => 'Utilisateurs cibles';

  @override
  String get aboutTargetUsersStudents => 'Etudiants et apprenants';

  @override
  String get galleryDeleteTitle => 'Supprimer l\'image ?';

  @override
  String get galleryDeleteMessage => 'Supprimer cette image de votre galerie ?';

  @override
  String get galleryImageLoadFailed => 'Impossible de charger l\'image.';

  @override
  String get galleryTitle => 'Galerie';

  @override
  String get galleryLoadFailed => 'Impossible de charger la galerie.';

  @override
  String get galleryEmpty => 'Aucune image pour le moment.';

  @override
  String get historyDeleteTitle => 'Supprimer l\'element d\'historique ?';

  @override
  String get historyDeleteMessage =>
      'Supprimer cette extraction de l\'historique ?';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyLoadFailed => 'Impossible de charger l\'historique.';

  @override
  String get historyEmpty => 'Aucun historique pour le moment.';

  @override
  String get historyNoExtractedText => 'Aucun texte extrait';

  @override
  String get historyNoText => 'Aucun texte a enregistrer.';

  @override
  String get historySaved => 'Enregistre dans l\'historique.';

  @override
  String get historySaveFailed => 'Echec de l\'enregistrement.';

  @override
  String get timeJustNow => 'A l\'instant';

  @override
  String get notificationsEnabled => 'Notifications activees';

  @override
  String get notificationsDisabled => 'Notifications desactivees';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get homeWelcome => 'Bienvenue sur';

  @override
  String get homeTagline => 'Capturez, analysez et decouvrez vos images';

  @override
  String get homeCamera => 'Camera';

  @override
  String get homeCameraSubtitle => 'Prendre une photo';

  @override
  String get homeGallery => 'Galerie';

  @override
  String get homeGallerySubtitle => 'Voir les photos';

  @override
  String get homeHistory => 'Historique';

  @override
  String get homeHistorySubtitle => 'Scans precedents';

  @override
  String get homeSettings => 'Parametres';

  @override
  String get homeSettingsSubtitle => 'Preferences';

  @override
  String get reminderPermissionDenied => 'Permission de notification refusee.';

  @override
  String get ocrErrorUnableToRead =>
      'Impossible de lire cette photo. Reprenez-la avec un meilleur eclairage.';

  @override
  String get ocrUnableToExtract =>
      'Impossible d\'extraire le texte. Essayez une autre photo.';

  @override
  String get ocrOriginalText => 'Texte original';

  @override
  String get ocrExtractingHint =>
      'Nous extrayons le texte de la photo. Patientez.';

  @override
  String ocrTranslatedTextTitle(Object lang) {
    return 'Texte traduit ($lang)';
  }

  @override
  String get translationWaitingForOcr =>
      'La traduction apparaitra une fois l\'OCR termine.';

  @override
  String translationInProgress(Object language) {
    return 'Traduction vers $language...';
  }

  @override
  String get translateInto => 'Traduire en :';

  @override
  String get translationAutoReapplyHint =>
      'Changer cette option retraduit automatiquement le texte detecte.';

  @override
  String get translationUnavailableFallback =>
      'Traduction indisponible. Affichage du texte detecte.';

  @override
  String get translationUnavailableOriginal =>
      'Traduction indisponible. Affichage du texte original.';

  @override
  String get translationFailedTryAgain =>
      'Impossible de traduire. Veuillez reessayer.';

  @override
  String get translationCopied => 'Texte traduit copie dans le presse-papiers.';

  @override
  String get translationInProgressShort => 'Traduction...';

  @override
  String get translationOutputPlaceholder => 'La traduction apparaitra ici.';

  @override
  String get translationNoText => 'Aucun texte a traduire pour le moment.';

  @override
  String get translateTitle => 'Traduire';

  @override
  String get translateInputTitle => 'Texte a traduire';

  @override
  String get translateInputHint => 'Modifiez le texte a traduire...';

  @override
  String get translateAction => 'Traduire';

  @override
  String get translateOutputTitle => 'Texte traduit';

  @override
  String get ocrExtractResultTitle => 'Resultat d\'extraction';

  @override
  String get ocrOriginalExtractedText => 'Texte extrait';

  @override
  String get ocrExtractingText => 'Extraction du texte...';

  @override
  String get ocrRunning => 'OCR en cours...';

  @override
  String get ocrEditHint => 'Modifiez le texte extrait ici.';

  @override
  String get ocrEditInstruction =>
      'Modifiez le texte si l\'OCR a manque quelque chose avant de traduire ou demander a l\'IA.';

  @override
  String get historySaveAction => 'Enregistrer l\'historique';

  @override
  String get actionHome => 'Accueil';

  @override
  String get actionTranslate => 'Traduire';

  @override
  String get actionAskAi => 'Demander a l\'IA';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionRetry => 'Reessayer';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionBackToExtract => 'Retour a l\'extraction';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDeleted => 'Supprime.';

  @override
  String get actionDeleteFailed => 'Suppression echouee. Veuillez reessayer.';

  @override
  String get actionCopied => 'Copie dans le presse-papiers.';

  @override
  String get uploadingImage => 'Televersement de l\'image...';

  @override
  String get uploadFailedTryAgain =>
      'Televersement echoue. Veuillez reessayer.';

  @override
  String get errorNoInternetConnection => 'Pas de connexion internet';

  @override
  String cloudinaryNotConfigured(Object args) {
    return 'Cloudinary n\'est pas configure. Lancez l\'application avec $args';
  }

  @override
  String get settingsTitle => 'Parametres';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsSectionFeedback => 'Son et vibration';

  @override
  String get settingsSilentMode => 'Mode silencieux';

  @override
  String get settingsSilentModeHint =>
      'Le mode silencieux desactive le son et la vibration.';

  @override
  String get settingsSoundEnabled => 'Sons des boutons';

  @override
  String get settingsVibrationEnabled => 'Vibration';

  @override
  String get settingsSectionReminders => 'Rappels';

  @override
  String get settingsReminderToggle => 'Rappel d\'utilisation';

  @override
  String get settingsReminderHint =>
      'Recevoir un rappel toutes les 15 minutes.';

  @override
  String get settingsSectionAbout => 'A propos';

  @override
  String get settingsSectionOcr => 'OCR et ML';

  @override
  String get settingsAutoEnhanceImages => 'Ameliorer les images avant OCR';

  @override
  String get settingsAutoDetectLanguage => 'Detecter la langue automatiquement';

  @override
  String get settingsAutoDetectLanguageHint =>
      'Si desactive, l\'application suppose la langue selectionnee.';

  @override
  String get settingsSectionPrivacy => 'Confidentialite et cache';

  @override
  String get settingsClearCache => 'Vider le cache';

  @override
  String get settingsClearCacheWeb => 'Nettoyage du cache ignore sur le web.';

  @override
  String get settingsClearCacheDone => 'Cache vide avec succes.';

  @override
  String get settingsClearCacheFail =>
      'Impossible de vider le cache. Veuillez reessayer.';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsLoggedInAs => 'Connecte en tant que';

  @override
  String get placeholderDash => '-';
}
