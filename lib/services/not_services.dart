import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/glassmorphism/screens/glass_notification_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotServices {
  NotServices._();
  static final NotServices instance = NotServices._();
  factory NotServices() => instance;

  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _notificationPlugin;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  Future<void>? _initializing;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize notifications
  Future<void> initNotification({
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (navigatorKey != null) _navigatorKey = navigatorKey;
    if (_isInitialized) return;
    final pendingInitialization = _initializing;
    if (pendingInitialization != null) {
      await pendingInitialization;
      return;
    }

    _initializing = _initialize();
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String currentTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimezone));

      // Android init
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS init
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'rita_prayer_updates_v2',
              'Arifa za sala',
              description: 'Taarifa na vikumbusho vya novena',
              importance: Importance.high,
              sound: RawResourceAndroidNotificationSound(
                'notification_general',
              ),
            ),
          );

      final androidNotifications = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidNotifications?.createNotificationChannel(
        const AndroidNotificationChannel(
          'general_channel_v2',
          'General reminders',
          description: 'General Saint Rita updates',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_general'),
        ),
      );
      await androidNotifications?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_channel_v2',
          'Daily prayer reminders',
          description: 'Reminders for the nine-day novena',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(
            'notification_verification_reminder',
          ),
        ),
      );
      await androidNotifications?.createNotificationChannel(
        const AndroidNotificationChannel(
          'hourly_channel_v2',
          'Hourly prayer reminders',
          description: 'Reminders for the fifteen-hour novena',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_alert'),
        ),
      );

      // On notification click or when it pops
      await _notificationPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              final payload = response.payload ?? 'general';
              debugPrint('Notification clicked with payload: $payload');

              final key = _navigatorKey;
              if (response.id != null) {
                try {
                  final context = key?.currentContext;
                  if (context != null) {
                    final provider = Provider.of<NotificationProvider>(
                      context,
                      listen: false,
                    );
                    provider.markAsShown(response.id!);
                    provider.markAsRead(response.id!);
                  }
                } catch (e) {
                  debugPrint('Error updating notification state: $e');
                }
              }

              if (key?.currentState != null) {
                try {
                  int index = 0;
                  if (payload == 'daily') index = 1;
                  if (payload == 'hourly') index = 2;

                  key!.currentState!.push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GlassNotificationScreen(initialIndex: index),
                    ),
                  );
                } catch (e) {
                  debugPrint('Error handling notification click: $e');
                }
              }
            },
      );

      _isInitialized = true;
      debugPrint('Notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _notificationPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Exact alarms keep "5 minutes before" reminders on time. Android 14+
  /// denies them by default, so fall back to inexact delivery when needed.
  Future<AndroidScheduleMode> _scheduleMode() async {
    try {
      final canExact = await _android?.canScheduleExactNotifications();
      if (canExact ?? false) return AndroidScheduleMode.exactAllowWhileIdle;
    } catch (e) {
      debugPrint('Exact alarm check failed: $e');
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Asks for the Android 13+ / iOS runtime permission. Returns whether
  /// notifications are allowed (null when the platform does not say).
  Future<bool?> requestPermissions() async {
    if (!_isInitialized) await initNotification();
    try {
      final android = _android;
      if (android != null) return await android.requestNotificationsPermission();
      final ios = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return null;
    }
  }

  /// Whether the user currently allows notifications (Android only).
  Future<bool?> areNotificationsEnabled() async =>
      _android?.areNotificationsEnabled();

  /// Opens the system screen where the user can allow exact alarms.
  Future<void> requestExactAlarmPermission() async =>
      _android?.requestExactAlarmsPermission();

  /// Notification details
  NotificationDetails _notificationDetails(
    String channelId,
    String channelName,
    String soundName,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: '$channelName Channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundName),
      ),
      iOS: DarwinNotificationDetails(sound: '$soundName.mp3'),
    );
  }

  /// Schedule general daily notification at 7:00 AM
  DateTime _resolveScheduledAt(DateTime? scheduledAt, int? hour, int? minute) {
    if (scheduledAt != null) return scheduledAt;
    final now = DateTime.now();
    var result = DateTime(now.year, now.month, now.day, hour ?? 7, minute ?? 0);
    if (!result.isAfter(now)) result = result.add(const Duration(days: 1));
    return result;
  }

  Future<void> scheduleGeneralNotification({
    int id = 0,
    String title = "Novena ya Mt. Rita",
    String body = "Ni muda wa kusali Novena ya Mt. Rita wa Kashia!",
    int hour = 7,
    int minute = 0,
  }) async {
    if (!_isInitialized) await initNotification();

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(
        'general_channel_v2',
        'General Notifications',
        'notification_general',
      ),
      androidScheduleMode: await _scheduleMode(),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'general',
    );

    debugPrint('General notification scheduled at $hour:$minute');
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    DateTime? scheduledAt,
    int? hour,
    int? minute,
  }) async {
    if (!_isInitialized) await initNotification();
    final date = _resolveScheduledAt(scheduledAt, hour, minute);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );
    await _notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(
        'daily_channel_v2',
        'Daily Notifications',
        'notification_verification_reminder',
      ),
      androidScheduleMode: await _scheduleMode(),
      payload: 'daily',
    );
  }

  Future<void> scheduleHourlyNotification({
    required int id,
    required String title,
    required String body,
    DateTime? scheduledAt,
    int? hour,
    int? minute,
  }) async {
    if (!_isInitialized) await initNotification();
    final date = _resolveScheduledAt(scheduledAt, hour, minute);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );
    await _notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(
        'hourly_channel_v2',
        'Hourly Notifications',
        'notification_alert',
      ),
      androidScheduleMode: await _scheduleMode(),
      payload: 'hourly',
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    required String payload,
    int? notificationId,
  }) async {
    if (!_isInitialized) await initNotification();

    const android = AndroidNotificationDetails(
      'general_channel_v2',
      'General Notifications',
      channelDescription: 'General Saint Rita updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_general'),
    );

    const ios = DarwinNotificationDetails(sound: 'notification_general.mp3');
    const details = NotificationDetails(android: android, iOS: ios);

    final id =
        notificationId ??
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    await _notificationPlugin.show(id, title, body, details, payload: payload);

    // Mark as shown immediately
    await handleNotificationDisplayed(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initNotification();
    await _notificationPlugin.cancelAll();
    await updateBadgeCount();
  }

  /// Cancel single notification
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initNotification();
    await _notificationPlugin.cancel(id);
    await updateBadgeCount();
  }

  /// Handle when notification is displayed on device
  Future<void> handleNotificationDisplayed(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> shownNotifications =
          prefs.getStringList('shown_notifications') ?? [];

      if (!shownNotifications.contains(id.toString())) {
        shownNotifications.add(id.toString());
        await prefs.setStringList('shown_notifications', shownNotifications);
      }

      await updateBadgeCount();
      debugPrint('Notification $id marked as shown');
    } catch (e) {
      debugPrint('Error marking notification as shown: $e');
    }
  }

  /// Update badge count
  Future<void> updateBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shownNotifications =
          prefs.getStringList('shown_notifications') ?? [];
      int badgeCount = shownNotifications.length;

      debugPrint('Notifications count: $badgeCount');
    } catch (e) {
      debugPrint('Error updating notifications count: $e');
    }
  }
}
