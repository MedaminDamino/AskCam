import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  static const int _reminderId = 15001;
  static const String _channelId = 'askcam_reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notifications plugin (safe to call multiple times).
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Request notification permissions when the user enables reminders.
  Future<bool> requestPermissions() async {
    await initialize();
    if (kIsWeb) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      case TargetPlatform.iOS:
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      default:
        return true;
    }
  }

  /// Schedule a repeating reminder every 15 minutes.
  Future<bool> scheduleReminder({
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
  }) async {
    await initialize();
    if (kIsWeb) return false;
    final granted = await requestPermissions();
    if (!granted) return false;

    await cancelAll();
    await _plugin.periodicallyShowWithDuration(
      _reminderId,
      title,
      body,
      const Duration(minutes: 15),
      _notificationDetails(channelName, channelDescription),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  /// Cancel all scheduled reminder notifications.
  Future<void> cancelAll() async {
    await initialize();
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  NotificationDetails _notificationDetails(
    String channelName,
    String channelDescription,
  ) {
    final android = AndroidNotificationDetails(
      _channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }
}
