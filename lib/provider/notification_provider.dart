import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saint_rita/services/not_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType { general, daily, hourly }

/// Key used by the FCM background isolate to queue messages that arrive while
/// the app is closed. The provider merges them into the inbox on next start.
const String kPendingRemoteNotificationsKey = 'pending_remote_notifications';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String imagePath;
  final bool isActive;
  final NotificationType type;
  final int? platformNotificationId;

  /// FCM message id, used to avoid logging the same push twice.
  final String? remoteId;
  bool isRead;
  bool hasBeenShown;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.imagePath,
    required this.isActive,
    required this.type,
    this.platformNotificationId,
    this.remoteId,
    this.isRead = false,
    this.hasBeenShown = false,
  });

  /// A scheduled reminder only becomes visible once its time has come.
  bool get isDue => !timestamp.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'imagePath': imagePath,
    'isActive': isActive,
    'isRead': isRead,
    'type': type.index,
    'platformNotificationId': platformNotificationId,
    'remoteId': remoteId,
    'hasBeenShown': hasBeenShown,
  };

  static AppNotification? tryParse(String raw, Set<String> shownIds) {
    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      final typeIndex = (data['type'] as int?) ?? 0;
      return AppNotification(
        id: data['id'] as int,
        title: (data['title'] ?? '').toString(),
        message: (data['message'] ?? '').toString(),
        timestamp: DateTime.parse(data['timestamp'] as String),
        imagePath: (data['imagePath'] ?? '').toString(),
        isActive: (data['isActive'] as bool?) ?? true,
        isRead: (data['isRead'] as bool?) ?? false,
        type: typeIndex >= 0 && typeIndex < NotificationType.values.length
            ? NotificationType.values[typeIndex]
            : NotificationType.general,
        platformNotificationId: data['platformNotificationId'] as int?,
        remoteId: data['remoteId'] as String?,
        hasBeenShown:
            shownIds.contains(data['id'].toString()) ||
            ((data['hasBeenShown'] as bool?) ?? false),
      );
    } catch (e) {
      debugPrint('Skipping corrupt notification entry: $e');
      return null;
    }
  }
}

class NotificationProvider with ChangeNotifier {
  static const int _maxInboxSize = 100;
  static const int _generalId = 0;
  static const int _dailyBaseId = 100;
  static const int _hourlyBaseId = 200;

  final NotServices _notServices = NotServices();

  bool _generalReminder = true;
  bool _dailyReminder = false;
  bool _hourlyReminder = false;

  bool get generalReminder => _generalReminder;
  bool get dailyReminder => _dailyReminder;
  bool get hourlyReminder => _hourlyReminder;

  TimeOfDay _dailyTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get dailyTime => _dailyTime;

  TimeOfDay _hourlyTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get hourlyTime => _hourlyTime;

  bool _isSwahili = false;

  List<AppNotification> _notifications = [];

  /// Inbox entries whose time has come (or that the user already opened),
  /// newest first.
  List<AppNotification> get notifications =>
      _notifications.where((n) => n.isDue || n.isRead).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // Unread counts are derived from the inbox so they can never drift.
  int _unreadOf(NotificationType type) =>
      _notifications.where((n) => n.type == type && n.isDue && !n.isRead).length;

  int get unreadGeneral => _unreadOf(NotificationType.general);
  int get unreadDaily => _unreadOf(NotificationType.daily);
  int get unreadHourly => _unreadOf(NotificationType.hourly);
  int get totalUnread =>
      _notifications.where((n) => n.isDue && !n.isRead).length;

  NotificationProvider() {
    ready = _init();
  }

  late final Future<void> ready;

  Future<void> _init() async {
    await _notServices.initNotification();
    await _loadPrefs();
    await _loadNotifications();
    await mergePendingRemoteNotifications(notify: false);
    await rescheduleAll();
    notifyListeners();
  }

  /// Re-creates every enabled reminder. IDs are stable, so this replaces
  /// existing platform alarms instead of duplicating them. Safe to call on
  /// app resume, after a language change or after a timezone change.
  Future<void> rescheduleAll() async {
    await _refreshLanguage();
    if (_generalReminder) {
      await scheduleGeneralNotification();
    } else {
      await _notServices.cancelNotification(_generalId);
    }
    if (_dailyReminder) {
      await scheduleDailyPrayer();
    } else {
      await _notServices.cancelNotification(1);
      await _cancelNotificationRange(_dailyBaseId, 9);
    }
    if (_hourlyReminder) {
      await scheduleHourlyPrayer();
    } else {
      await _cancelNotificationRange(2, 15);
      await _cancelNotificationRange(_hourlyBaseId, 15);
    }
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _refreshLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isSwahili = (prefs.getString('preferredLanguage') ?? 'en') == 'sw';
  }

  String _t(String sw, String en) => _isSwahili ? sw : en;

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _generalReminder = prefs.getBool('generalReminder') ?? true;
    _dailyReminder = prefs.getBool('dailyReminder') ?? false;
    _hourlyReminder = prefs.getBool('hourlyReminder') ?? false;
    _dailyTime = TimeOfDay(
      hour: prefs.getInt('dailyHour') ?? 7,
      minute: prefs.getInt('dailyMinute') ?? 0,
    );
    _hourlyTime = TimeOfDay(
      hour: prefs.getInt('hourlyHour') ?? 7,
      minute: prefs.getInt('hourlyMinute') ?? 0,
    );
    await _refreshLanguage();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('generalReminder', _generalReminder);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setBool('hourlyReminder', _hourlyReminder);
    await prefs.setInt('dailyHour', _dailyTime.hour);
    await prefs.setInt('dailyMinute', _dailyTime.minute);
    await prefs.setInt('hourlyHour', _hourlyTime.hour);
    await prefs.setInt('hourlyMinute', _hourlyTime.minute);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('notifications') ?? [];
    final shown = (prefs.getStringList('shown_notifications') ?? []).toSet();
    _notifications = raw
        .map((entry) => AppNotification.tryParse(entry, shown))
        .whereType<AppNotification>()
        .toList();
    _dedupeAndTrim();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'notifications',
      _notifications.map((n) => json.encode(n.toJson())).toList(),
    );
  }

  /// Removes repeated copies of the same scheduled reminder (left behind by
  /// older app versions) and caps the inbox size.
  void _dedupeAndTrim() {
    final seen = <String>{};
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _notifications.retainWhere((n) {
      final key = n.remoteId != null
          ? 'r:${n.remoteId}'
          : n.platformNotificationId != null
          ? 'p:${n.platformNotificationId}:${n.timestamp.millisecondsSinceEpoch ~/ 60000}'
          : 'i:${n.id}';
      return seen.add(key);
    });
    if (_notifications.length > _maxInboxSize) {
      _notifications = _notifications.sublist(0, _maxInboxSize);
    }
  }

  // ---------------------------------------------------------------------------
  // Inbox operations
  // ---------------------------------------------------------------------------

  int _nextId() {
    var id = DateTime.now().microsecondsSinceEpoch;
    while (_notifications.any((n) => n.id == id)) {
      id++;
    }
    return id;
  }

  int addNotification(
    NotificationType type,
    String title,
    String body,
    String imagePath, {
    DateTime? scheduledTime,
    int? platformNotificationId,
    String? remoteId,
    bool notify = true,
  }) {
    final timestamp = scheduledTime ?? DateTime.now();

    if (remoteId != null) {
      final existing = _notifications.where((n) => n.remoteId == remoteId);
      if (existing.isNotEmpty) return existing.first.id;
    }

    if (platformNotificationId != null) {
      // Same reminder at the same minute is already logged: reuse it.
      final sameSlot = _notifications.where(
        (n) =>
            n.platformNotificationId == platformNotificationId &&
            n.timestamp.difference(timestamp).inMinutes.abs() < 1,
      );
      if (sameSlot.isNotEmpty) return sameSlot.first.id;

      // A reschedule replaces a still-pending entry for this alarm slot.
      _notifications.removeWhere(
        (n) =>
            n.platformNotificationId == platformNotificationId &&
            !n.isDue &&
            !n.hasBeenShown,
      );
    }

    final entry = AppNotification(
      id: _nextId(),
      title: title,
      message: body,
      timestamp: timestamp,
      imagePath: imagePath,
      isActive: true,
      type: type,
      platformNotificationId: platformNotificationId,
      remoteId: remoteId,
    );
    _notifications.insert(0, entry);
    _dedupeAndTrim();
    _saveNotifications();
    if (notify) notifyListeners();
    return entry.id;
  }

  /// Finds an inbox entry by its own id, or — for a platform alarm id — the
  /// most recent entry for that alarm that is already due.
  AppNotification? _find(int id) {
    for (final n in _notifications) {
      if (n.id == id) return n;
    }
    final matches =
        _notifications
            .where((n) => n.platformNotificationId == id && n.isDue)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matches.isEmpty ? null : matches.first;
  }

  void markAsShown(int id) {
    final entry = _find(id);
    if (entry == null || entry.hasBeenShown) return;
    entry.hasBeenShown = true;
    _saveNotifications();
    _notServices.handleNotificationDisplayed(entry.id);
    notifyListeners();
  }

  void markAsRead(int id) {
    final entry = _find(id);
    if (entry == null || entry.isRead) return;
    entry.isRead = true;
    _saveNotifications();
    notifyListeners();
  }

  void markAllAsRead([NotificationType? type]) {
    var changed = false;
    for (final n in _notifications) {
      if (n.isDue && !n.isRead && (type == null || n.type == type)) {
        n.isRead = true;
        changed = true;
      }
    }
    if (!changed) return;
    _saveNotifications();
    notifyListeners();
  }

  void removeNotification(int id) {
    final before = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    if (_notifications.length == before) return;
    _saveNotifications();
    notifyListeners();
  }

  void clearAll(NotificationType type) {
    _notifications.removeWhere((n) => n.type == type && n.isDue);
    _saveNotifications();
    notifyListeners();
  }

  /// Kept for older call sites; unread counts are derived from the inbox now.
  void incrementUnread(NotificationType type) => notifyListeners();

  /// Kept for older call sites: marks everything of [type] as read.
  void resetUnread(NotificationType type) => markAllAsRead(type);

  /// Moves pushes received while the app was closed into the inbox.
  Future<void> mergePendingRemoteNotifications({bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final pending = prefs.getStringList(kPendingRemoteNotificationsKey) ?? [];
    if (pending.isEmpty) return;
    for (final raw in pending) {
      try {
        final data = json.decode(raw) as Map<String, dynamic>;
        addNotification(
          notificationTypeFromPayload(data['type']?.toString()),
          (data['title'] ?? '').toString(),
          (data['body'] ?? '').toString(),
          '',
          scheduledTime: DateTime.tryParse(data['timestamp']?.toString() ?? ''),
          remoteId: data['remoteId']?.toString(),
          notify: false,
        );
      } catch (e) {
        debugPrint('Skipping queued push: $e');
      }
    }
    await prefs.remove(kPendingRemoteNotificationsKey);
    if (notify) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<void> toggleReminder(
    NotificationType type,
    bool value,
    BuildContext context,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await _refreshLanguage();
    if (value) {
      // Android 13+ needs the runtime permission before anything can show.
      await _notServices.requestPermissions();
    }
    switch (type) {
      case NotificationType.general:
        _generalReminder = value;
        if (value) {
          await scheduleGeneralNotification();
        } else {
          await _notServices.cancelNotification(_generalId);
          _removeUpcomingNotifications(NotificationType.general);
        }
        break;
      case NotificationType.daily:
        _dailyReminder = value;
        if (value) {
          await scheduleDailyPrayer();
        } else {
          await _notServices.cancelNotification(1);
          await _cancelNotificationRange(_dailyBaseId, 9);
          _removeUpcomingNotifications(NotificationType.daily);
        }
        break;
      case NotificationType.hourly:
        _hourlyReminder = value;
        if (value) {
          await scheduleHourlyPrayer();
        } else {
          await cancelAllHourlyNotifications();
          await _cancelNotificationRange(2, 15);
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('novenaHourScheduleStart');
          _removeUpcomingNotifications(NotificationType.hourly);
        }
        break;
    }

    await _savePrefs();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          value
              ? _t('Kikumbusho kimewashwa', 'Reminder turned on')
              : _t('Kikumbusho kimezimwa', 'Reminder turned off'),
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> setDailyTime(TimeOfDay time) async {
    _dailyTime = time;
    await _savePrefs();
    if (_dailyReminder) await scheduleDailyPrayer();
    notifyListeners();
  }

  Future<void> setHourlyTime(TimeOfDay time) async {
    _hourlyTime = time;
    await _savePrefs();
    if (_hourlyReminder) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('novenaHourScheduleStart');
      await scheduleHourlyPrayer();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  String _formatTime(DateTime time) =>
      DateFormat(_isSwahili ? 'HH:mm' : 'h:mm a').format(time);

  Future<void> scheduleGeneralNotification() async {
    final now = DateTime.now();
    var notifyTime = DateTime(now.year, now.month, now.day, 7);
    if (!notifyTime.isAfter(now)) {
      notifyTime = notifyTime.add(const Duration(days: 1));
    }

    final title = _t('Novena ya Mt. Rita', 'St. Rita Novena');
    final body = _t(
      'Ni muda wa kusali Novena ya Mt. Rita wa Kashia!',
      'It is time to pray the Novena to St. Rita of Cascia.',
    );

    await _notServices.scheduleGeneralNotification(
      id: _generalId,
      title: title,
      body: body,
      hour: notifyTime.hour,
      minute: notifyTime.minute,
    );

    addNotification(
      NotificationType.general,
      title,
      body,
      'images/rita 3.png',
      scheduledTime: notifyTime,
      platformNotificationId: _generalId,
      notify: false,
    );
  }

  Future<void> scheduleDailyPrayer() async {
    if (!_dailyReminder) return;
    await _refreshLanguage();

    final prefs = await SharedPreferences.getInstance();
    final progress = (prefs.getInt('novenaProgress') ?? 0).clamp(0, 9);
    final completed = prefs.getBool('novenaCompleted') ?? progress >= 9;

    // Remove both legacy repeating alarms and this finite reminder sequence.
    await _notServices.cancelNotification(1);
    await _cancelNotificationRange(_dailyBaseId, 9);
    _removeUpcomingNotifications(NotificationType.daily);

    if (completed || progress >= 9) return;

    final now = DateTime.now();
    final lastPrayerMillis = prefs.getInt('lastPrayerDate');
    final lastPrayerDate = lastPrayerMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastPrayerMillis);
    final prayedToday =
        lastPrayerDate != null &&
        lastPrayerDate.year == now.year &&
        lastPrayerDate.month == now.month &&
        lastPrayerDate.day == now.day;

    var firstDay = DateTime(now.year, now.month, now.day);
    if (prayedToday) firstDay = firstDay.add(const Duration(days: 1));
    var firstPrayerTime = DateTime(
      firstDay.year,
      firstDay.month,
      firstDay.day,
      _dailyTime.hour,
      _dailyTime.minute,
    );
    // Need at least the 5-minute lead time, otherwise start tomorrow.
    if (!firstPrayerTime
        .subtract(const Duration(minutes: 5))
        .isAfter(now)) {
      firstPrayerTime = firstPrayerTime.add(const Duration(days: 1));
    }

    for (var offset = 0; offset < 9 - progress; offset++) {
      // Build from calendar fields so DST changes keep the wall-clock time.
      final prayerTime = DateTime(
        firstPrayerTime.year,
        firstPrayerTime.month,
        firstPrayerTime.day + offset,
        _dailyTime.hour,
        _dailyTime.minute,
      );
      final reminderTime = prayerTime.subtract(const Duration(minutes: 5));
      final dayNumber = progress + offset + 1;
      final id = _dailyBaseId + offset;
      final title = _t('Kikumbusho cha Siku $dayNumber', 'Novena day $dayNumber');
      final body = _t(
        'Dakika 5 zimebaki kabla ya sala ya Siku ya $dayNumber saa ${_formatTime(prayerTime)}.',
        'Day $dayNumber prayer begins in 5 minutes (${_formatTime(prayerTime)}).',
      );

      await _notServices.scheduleDailyNotification(
        id: id,
        title: title,
        body: body,
        scheduledAt: reminderTime,
      );
      addNotification(
        NotificationType.daily,
        title,
        body,
        'images/rita 2.png',
        scheduledTime: reminderTime,
        platformNotificationId: id,
        notify: false,
      );
    }
    notifyListeners();
  }

  Future<void> scheduleHourlyPrayer() async {
    if (!_hourlyReminder) return;
    await _refreshLanguage();

    final prefs = await SharedPreferences.getInstance();
    final progress = (prefs.getInt('novenaHourProgress') ?? 0).clamp(0, 15);
    final completed = prefs.getBool('novenaHourCycleCompleted') ?? false;

    await cancelAllHourlyNotifications();
    await _cancelNotificationRange(2, 15);
    _removeUpcomingNotifications(NotificationType.hourly);

    if (completed || progress >= 15) return;

    final now = DateTime.now();
    final anchorMillis = prefs.getInt('novenaHourScheduleStart');
    var anchor = anchorMillis == null
        ? _nextSelectedPrayerTime(now).subtract(Duration(hours: progress))
        : DateTime.fromMillisecondsSinceEpoch(anchorMillis);

    // If the next prayer slot was missed, move the remaining sequence ahead
    // by an hour while preserving the current progress index.
    var nextPrayerTime = anchor.add(Duration(hours: progress));
    if (!nextPrayerTime.isAfter(now.add(const Duration(minutes: 5)))) {
      nextPrayerTime = now.add(const Duration(hours: 1));
      anchor = nextPrayerTime.subtract(Duration(hours: progress));
    }
    await prefs.setInt('novenaHourScheduleStart', anchor.millisecondsSinceEpoch);

    for (var prayerIndex = progress; prayerIndex < 15; prayerIndex++) {
      final prayerTime = anchor.add(Duration(hours: prayerIndex));
      final reminderTime = prayerTime.subtract(const Duration(minutes: 5));
      if (!reminderTime.isAfter(now)) continue;
      final hourNumber = prayerIndex + 1;
      final id = _hourlyBaseId + prayerIndex;
      final title = _t('Kikumbusho cha Saa $hourNumber', 'Novena hour $hourNumber of 15');
      final body = _t(
        'Dakika 5 zimebaki kabla ya sala ya saa ya $hourNumber (${_formatTime(prayerTime)}).',
        'Hour $hourNumber prayer begins in 5 minutes (${_formatTime(prayerTime)}).',
      );

      await _notServices.scheduleHourlyNotification(
        id: id,
        title: title,
        body: body,
        scheduledAt: reminderTime,
      );
      addNotification(
        NotificationType.hourly,
        title,
        body,
        'images/rita 3.png',
        scheduledTime: reminderTime,
        platformNotificationId: id,
        notify: false,
      );
    }
    notifyListeners();
  }

  DateTime _nextSelectedPrayerTime(DateTime now) {
    var selected = DateTime(
      now.year,
      now.month,
      now.day,
      _hourlyTime.hour,
      _hourlyTime.minute,
    );
    if (!selected.isAfter(now.add(const Duration(minutes: 5)))) {
      selected = selected.add(const Duration(days: 1));
    }
    return selected;
  }

  Future<void> _cancelNotificationRange(int firstId, int count) async {
    for (var offset = 0; offset < count; offset++) {
      await _notServices.cancelNotification(firstId + offset);
    }
  }

  void _removeUpcomingNotifications(NotificationType type) {
    _notifications.removeWhere(
      (n) => n.type == type && !n.hasBeenShown && !n.isDue,
    );
    _saveNotifications();
    notifyListeners();
  }

  Future<void> cancelAllHourlyNotifications() async {
    await _cancelNotificationRange(_hourlyBaseId, 15);
  }
}

NotificationType notificationTypeFromPayload(String? payload) =>
    switch (payload) {
      'daily' => NotificationType.daily,
      'hourly' => NotificationType.hourly,
      _ => NotificationType.general,
    };
