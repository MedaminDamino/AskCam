// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'AskCam';

  @override
  String get reminderTitle => '📸 تذكير AskCam';

  @override
  String get reminderBody => 'امسح مستنداتك وافهمها باستخدام AskCam.';

  @override
  String get reminderChannelName => 'تذكيرات AskCam';

  @override
  String get reminderChannelDescription => 'تذكيرات دورية لاستخدام AskCam.';

  @override
  String get tooltipLightMode => 'الوضع الفاتح';

  @override
  String get tooltipDarkMode => 'الوضع الداكن';

  @override
  String authErrorMessage(Object message) {
    return 'خطأ في المصادقة: $message';
  }

  @override
  String get routeErrorTitle => 'خطأ';

  @override
  String get routeErrorHeading => 'عذرًا! حدث خطأ ما';

  @override
  String routeErrorRoute(Object route) {
    return 'المسار: $route';
  }

  @override
  String get routeErrorGoHome => 'اذهب إلى الرئيسية';

  @override
  String get routeErrorNoImage => 'لم يتم توفير ملف صورة';

  @override
  String routeErrorInvalidArgs(Object argType) {
    return 'وسائط غير صالحة: $argType';
  }

  @override
  String get routeErrorImageNotFound => 'لم يتم العثور على ملف الصورة';

  @override
  String get routeErrorMissingTranslate => 'وسائط الترجمة مفقودة';

  @override
  String get routeErrorMissingAi => 'وسائط الذكاء الاصطناعي مفقودة';

  @override
  String get routeErrorNotFound => 'المسار غير موجود';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validationEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validationPasswordMinLength =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get validationPasswordUppercase =>
      'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';

  @override
  String get validationPasswordNumber =>
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';

  @override
  String validationFieldRequired(Object field) {
    return '$field مطلوب';
  }

  @override
  String validationFieldMinLength(Object field) {
    return 'يجب أن يحتوي $field على حرفين على الأقل';
  }

  @override
  String get validationConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authSignInFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get authSignInCancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get authGoogleSignInFailed =>
      'فشل تسجيل الدخول عبر Google. حاول مرة أخرى.';

  @override
  String get authRegistrationFailed => 'فشل التسجيل. حاول مرة أخرى.';

  @override
  String get authResetFailed => 'فشلت إعادة التعيين. حاول مرة أخرى.';

  @override
  String get authSignOutFailed => 'تعذر تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get authErrorInvalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get authErrorUserNotFound => 'لا يوجد مستخدم بهذا البريد الإلكتروني.';

  @override
  String get authErrorWrongPassword => 'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get authErrorEmailInUse => 'يوجد حساب بالفعل لهذا البريد الإلكتروني.';

  @override
  String get authErrorWeakPassword =>
      'كلمة المرور ضعيفة جدًا. استخدم 8 أحرف على الأقل، وحرفًا كبيرًا واحدًا، ورقمًا واحدًا.';

  @override
  String get authErrorInvalidCredential =>
      'بيانات الاعتماد غير صالحة. تحقق من البريد وكلمة المرور.';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'يوجد حساب بالفعل بطريقة تسجيل مختلفة.';

  @override
  String get authErrorOperationNotAllowed =>
      'تسجيل الدخول بالبريد وكلمة المرور معطل لهذا المشروع.';

  @override
  String get authErrorUserDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get authErrorPopupBlocked =>
      'تم حظر النافذة المنبثقة. اسمح بالنوافذ المنبثقة ثم حاول مرة أخرى.';

  @override
  String get authErrorTooManyRequests => 'محاولات كثيرة جدًا. حاول لاحقًا.';

  @override
  String get authErrorInvalidApiKey =>
      'مفتاح Firebase API غير صالح. تحقق من إعدادات الويب.';

  @override
  String get authErrorNetwork =>
      'خطأ في الشبكة. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String authErrorGeneric(Object code) {
    return 'فشلت المصادقة ($code). حاول مرة أخرى.';
  }

  @override
  String get authErrorGoogleConfig =>
      'خطأ في إعدادات تسجيل Google (SHA/الحزمة/OAuth).';

  @override
  String authErrorGoogleSignIn(Object code) {
    return 'فشل تسجيل الدخول عبر Google ($code). حاول مرة أخرى.';
  }

  @override
  String get fieldFirstName => 'الاسم الأول';

  @override
  String get fieldLastName => 'اسم العائلة';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authAccountCreated => 'تم إنشاء الحساب بنجاح.';

  @override
  String get authRegisterSubtitle => 'انضم إلى AskCam في بضع خطوات';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get googleSignInButton => 'المتابعة باستخدام Google';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get authSignInToContinue => 'سجل الدخول للمتابعة';

  @override
  String get authForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get authNewHere => 'جديد هنا؟';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authLoginFailed => 'فشل تسجيل الدخول.';

  @override
  String get authResetEmailSent => 'تم إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get authRequestFailed => 'فشل الطلب.';

  @override
  String get authResetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل رابط إعادة التعيين.';

  @override
  String get authResetPasswordAction => 'إرسال رابط إعادة التعيين';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authLogoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get authLogoutFailed => 'فشل تسجيل الخروج.';

  @override
  String get authLoginRequiredToViewGallery => 'يرجى تسجيل الدخول لعرض المعرض.';

  @override
  String get authLoginRequiredToViewHistory => 'يرجى تسجيل الدخول لعرض السجل.';

  @override
  String get authLoginRequiredToSaveImages => 'يرجى تسجيل الدخول لحفظ الصور.';

  @override
  String get authLoginRequiredToSaveWords => 'يرجى تسجيل الدخول لحفظ الكلمات.';

  @override
  String get authLoginRequiredToSaveHistory => 'يرجى تسجيل الدخول لحفظ السجل.';

  @override
  String get authGoToLogin => 'اذهب إلى تسجيل الدخول';

  @override
  String aiNotConfigured(Object args) {
    return 'الذكاء الاصطناعي غير مُهيأ. شغّل التطبيق باستخدام $args';
  }

  @override
  String get aiNoImageAvailable =>
      'لا توجد صورة متاحة لتحليل الذكاء الاصطناعي.';

  @override
  String get aiUnclearImage =>
      'تعذر اكتشاف نص مقروء أو سؤال واضح في هذه الصورة. جرّب صورة أخرى أو قص الجزء المطلوب.';

  @override
  String get aiServiceUnavailable =>
      'لا يمكن الوصول إلى خدمة الذكاء الاصطناعي حاليًا. حاول لاحقًا.';

  @override
  String get aiAnswerCopied => 'تم نسخ إجابة الذكاء الاصطناعي.';

  @override
  String get aiAskTitle => 'اسأل الذكاء الاصطناعي';

  @override
  String get aiAskQuestionTitle => 'اطرح سؤالًا';

  @override
  String get aiAskQuestionHint =>
      'اختياري: اسأل الذكاء الاصطناعي عن النص المستخرج/الصورة...';

  @override
  String get aiAsking => 'جارٍ سؤال الذكاء الاصطناعي...';

  @override
  String get aiAsk => 'اسأل الذكاء الاصطناعي';

  @override
  String get aiAskAboutThis => 'اسأل الذكاء الاصطناعي عن هذا';

  @override
  String get aiAnswerTitle => 'إجابة الذكاء الاصطناعي';

  @override
  String get aiResponseLabel => 'الرد';

  @override
  String get aiResponsePlaceholder => 'ستظهر إجابة الذكاء الاصطناعي هنا.';

  @override
  String get aiNoImageProvided => 'لم يتم توفير صورة';

  @override
  String get aiNoAnswerFallback =>
      'لم يتمكن الذكاء الاصطناعي من تقديم إجابة. حاول مرة أخرى.';

  @override
  String get aiEmptyHint =>
      'اسأل الذكاء الاصطناعي لعرض شروحات خطوة بخطوة أو تلميحات هنا.';

  @override
  String get aiWaitingResponse => 'بانتظار رد مساعد الذكاء الاصطناعي...';

  @override
  String cameraPickImageError(Object error) {
    return 'خطأ أثناء اختيار الصورة: $error';
  }

  @override
  String get cameraTitle => 'التقاط اللحظة';

  @override
  String get cameraClearImage => 'مسح الصورة';

  @override
  String get cameraNoImageSelected => 'لم يتم اختيار صورة';

  @override
  String get cameraEmptyHint => 'اضغط الأزرار بالأسفل للبدء';

  @override
  String get cameraImageCaptured => 'تم التقاط الصورة بنجاح';

  @override
  String get cameraGallery => 'المعرض';

  @override
  String get cameraCamera => 'الكاميرا';

  @override
  String get cameraScanWithAi => 'مسح النص بالذكاء الاصطناعي';

  @override
  String get aboutApplication => 'حول التطبيق';

  @override
  String get aboutDescription =>
      'AskCam هو تطبيق Flutter للهواتف يتيح للمستخدمين التقاط أو تحميل الصور، واستخراج النص باستخدام ML Kit OCR، وترجمة النص المستخرج، وطرح أسئلة على الذكاء الاصطناعي لفهم المستندات والواجبات بشكل أفضل.';

  @override
  String get aboutMlKitServicesTitle => 'خدمات ML Kit المستخدمة';

  @override
  String get aboutMlKitTextRecognition => 'التعرّف على النص (OCR)';

  @override
  String get aboutMlKitTranslation => 'الترجمة على الجهاز';

  @override
  String get aboutAiServiceTitle => 'خدمة الذكاء الاصطناعي';

  @override
  String get aboutAiServiceGemini => 'واجهة Gemini';

  @override
  String get aboutTargetUsersTitle => 'الفئة المستهدفة';

  @override
  String get aboutTargetUsersStudents => 'الطلاب والمتعلمون';

  @override
  String get galleryDeleteTitle => 'حذف الصورة؟';

  @override
  String get galleryDeleteMessage => 'إزالة هذه الصورة من المعرض؟';

  @override
  String get galleryImageLoadFailed => 'تعذر تحميل الصورة.';

  @override
  String get galleryTitle => 'المعرض';

  @override
  String get galleryLoadFailed => 'تعذر تحميل المعرض.';

  @override
  String get galleryEmpty => 'لا توجد صور بعد.';

  @override
  String get savedWordsDeleteTitle => 'حذف الكلمة المحفوظة؟';

  @override
  String savedWordsDeleteMessage(Object word) {
    return 'إزالة \"$word\" من الكلمات المحفوظة؟';
  }

  @override
  String get historyDeleteTitle => 'حذف عنصر السجل؟';

  @override
  String get historyDeleteMessage => 'إزالة هذا الاستخراج من السجل؟';

  @override
  String get historyTitle => 'السجل';

  @override
  String get historyTab => 'السجل';

  @override
  String get savedWordsTab => 'الكلمات المحفوظة';

  @override
  String get historyLoadFailed => 'تعذر تحميل السجل.';

  @override
  String get historyEmpty => 'لا يوجد سجل بعد.';

  @override
  String get historyNoExtractedText => 'لا يوجد نص مستخرج';

  @override
  String get historyNoText => 'لا يوجد نص للحفظ بعد.';

  @override
  String get historySaved => 'تم الحفظ في السجل.';

  @override
  String get historySaveFailed => 'فشل الحفظ.';

  @override
  String get savedWordsSearchHint => 'البحث في الكلمات المحفوظة';

  @override
  String get savedWordsLoadFailed => 'تعذر تحميل الكلمات المحفوظة.';

  @override
  String get savedWordsEmpty => 'لا توجد كلمات محفوظة بعد.';

  @override
  String get timeJustNow => 'الآن';

  @override
  String get notificationsEnabled => 'الإشعارات مفعلة';

  @override
  String get notificationsDisabled => 'الإشعارات معطلة';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get homeWelcome => 'مرحبًا بك في';

  @override
  String get homeTagline => 'التقط، حلل، واكتشف رؤى من صورك';

  @override
  String get homeCamera => 'الكاميرا';

  @override
  String get homeCameraSubtitle => 'التقط صورة';

  @override
  String get homeGallery => 'المعرض';

  @override
  String get homeGallerySubtitle => 'تصفّح الصور';

  @override
  String get homeHistory => 'السجل';

  @override
  String get homeHistorySubtitle => 'عمليات مسح سابقة';

  @override
  String get homeSettings => 'الإعدادات';

  @override
  String get homeSettingsSubtitle => 'التفضيلات';

  @override
  String get reminderPermissionDenied => 'تم رفض إذن الإشعارات.';

  @override
  String get ocrErrorUnableToRead =>
      'تعذر قراءة هذه الصورة. التقطها مجددًا بإضاءة أفضل.';

  @override
  String get ocrUnableToExtract => 'تعذر استخراج النص. جرّب صورة أخرى.';

  @override
  String get ocrOriginalText => 'النص الأصلي';

  @override
  String get ocrExtractingHint =>
      'نقوم باستخراج النص من الصورة. يرجى الانتظار.';

  @override
  String ocrTranslatedTextTitle(Object lang) {
    return 'النص المترجم ($lang)';
  }

  @override
  String get translationWaitingForOcr =>
      'ستظهر الترجمة بعد اكتمال التعرف على النص.';

  @override
  String translationInProgress(Object language) {
    return 'جارٍ الترجمة إلى $language...';
  }

  @override
  String get translateInto => 'ترجم إلى:';

  @override
  String get translationAutoReapplyHint =>
      'تغيير هذا الخيار يعيد ترجمة النص المكتشف تلقائيًا.';

  @override
  String get translationUnavailableFallback =>
      'الترجمة غير متاحة حاليًا. سيتم عرض النص المكتشف.';

  @override
  String get translationUnavailableOriginal =>
      'الترجمة غير متاحة حاليًا. سيتم عرض النص الأصلي.';

  @override
  String get translationFailedTryAgain => 'تعذرت الترجمة. حاول مرة أخرى.';

  @override
  String get translationCopied => 'تم نسخ النص المترجم.';

  @override
  String get translationInProgressShort => 'جارٍ الترجمة...';

  @override
  String get translationOutputPlaceholder => 'ستظهر الترجمة هنا.';

  @override
  String get translationNoText => 'لا يوجد نص للترجمة بعد.';

  @override
  String get translateTitle => 'ترجمة';

  @override
  String get translateInputTitle => 'نص للترجمة';

  @override
  String get translateInputHint => 'عدّل النص المراد ترجمته...';

  @override
  String get translateAction => 'ترجمة';

  @override
  String get translateOutputTitle => 'الناتج المترجم';

  @override
  String get ocrExtractResultTitle => 'نتيجة الاستخراج';

  @override
  String get ocrOriginalExtractedText => 'النص المستخرج الأصلي';

  @override
  String get ocrExtractingText => 'جارٍ استخراج النص...';

  @override
  String get ocrRunning => 'التعرف على النص يعمل...';

  @override
  String get ocrEditHint => 'عدّل النص المستخرج هنا.';

  @override
  String get ocrEditInstruction =>
      'عدّل النص إذا فات التعرف على شيء قبل الترجمة أو سؤال الذكاء الاصطناعي.';

  @override
  String get saveWordsNoText => 'لا يوجد نص للحفظ بعد.';

  @override
  String get saveWordsSelectOrTypeError =>
      'حدد كلمة/عبارة أولًا أو اكتب واحدة.';

  @override
  String get saveWordsLengthError => 'يجب أن يكون طول الكلمة بين 2 و120 حرفًا.';

  @override
  String get saveWordsAlreadySaved => 'تم حفظها بالفعل.';

  @override
  String get saveWordsSaved => 'تم الحفظ.';

  @override
  String get saveWordsFailed => 'فشل الحفظ، حاول مرة أخرى.';

  @override
  String get saveWordsTitle => 'حفظ الكلمات';

  @override
  String get saveWordsInstruction =>
      'حدد كلمة أو عبارة من النص أعلاه أو اكتب واحدة أدناه.';

  @override
  String get saveWordsHint => 'اكتب كلمة أو عبارة للحفظ';

  @override
  String get historySaveAction => 'حفظ السجل';

  @override
  String get saveWordsAction => 'حفظ الكلمات';

  @override
  String get actionHome => 'الرئيسية';

  @override
  String get actionTranslate => 'ترجمة';

  @override
  String get actionAskAi => 'اسأل الذكاء الاصطناعي';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionBackToExtract => 'العودة إلى الاستخراج';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDeleted => 'تم الحذف.';

  @override
  String get actionDeleteFailed => 'فشل الحذف. حاول مرة أخرى.';

  @override
  String get actionCopied => 'تم النسخ إلى الحافظة.';

  @override
  String get uploadingImage => 'جارٍ رفع الصورة إلى السحابة...';

  @override
  String get uploadFailedTryAgain => 'فشل الرفع. حاول مرة أخرى.';

  @override
  String get errorNoInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String cloudinaryNotConfigured(Object args) {
    return 'Cloudinary غير مُهيأ. شغّل التطبيق باستخدام $args';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionPreferences => 'التفضيلات';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsSectionFeedback => 'الصوت والاهتزاز';

  @override
  String get settingsSilentMode => 'الوضع الصامت';

  @override
  String get settingsSilentModeHint => 'الوضع الصامت يعطل الصوت والاهتزاز.';

  @override
  String get settingsSoundEnabled => 'أصوات الأزرار';

  @override
  String get settingsVibrationEnabled => 'الاهتزاز';

  @override
  String get settingsSectionReminders => 'التذكيرات';

  @override
  String get settingsReminderToggle => 'تذكير الاستخدام';

  @override
  String get settingsReminderHint => 'احصل على تذكير كل 15 دقيقة.';

  @override
  String get settingsSectionAbout => 'حول';

  @override
  String get settingsSectionOcr => 'OCR و ML';

  @override
  String get settingsAutoEnhanceImages => 'تحسين الصور تلقائيًا قبل OCR';

  @override
  String get settingsAutoDetectLanguage => 'كشف اللغة تلقائيًا';

  @override
  String get settingsAutoDetectLanguageHint =>
      'عند التعطيل، يفترض التطبيق اللغة المحددة.';

  @override
  String get settingsSectionPrivacy => 'الخصوصية والذاكرة المؤقتة';

  @override
  String get settingsClearCache => 'مسح الذاكرة المؤقتة';

  @override
  String get settingsClearCacheWeb =>
      'تم تخطي تنظيف الذاكرة المؤقتة على الويب.';

  @override
  String get settingsClearCacheDone => 'تم مسح الذاكرة المؤقتة بنجاح.';

  @override
  String get settingsClearCacheFail =>
      'تعذر مسح الذاكرة المؤقتة. حاول مرة أخرى.';

  @override
  String get settingsSectionAccount => 'الحساب';

  @override
  String get settingsLoggedInAs => 'تم تسجيل الدخول كـ';

  @override
  String get placeholderDash => '-';
}
