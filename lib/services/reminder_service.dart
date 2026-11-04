import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 每日记账提醒：本地定时通知 + 设置持久化 (适配 flutter_local_notifications v22+)
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _kEnabled = 'reminder_enabled';
  static const _kHour = 'reminder_hour';
  static const _kMinute = 'reminder_minute';
  static const int _notificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _inited = false;
  bool enabled = false;
  int hour = 20;
  int minute = 0;

  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    // 时区设置
    tzdata.initializeTimeZones();
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      final String name =
      tzInfo is String ? tzInfo : tzInfo.identifier as String;
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('timezone init failed: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // v20+ 必须使用命名参数 settings:
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(_kEnabled) ?? false;
    hour = prefs.getInt(_kHour) ?? 20;
    minute = prefs.getInt(_kMinute) ?? 0;

    if (enabled) await _schedule();
  }

  /// 申请通知权限，返回是否拿到
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> enable({required int hour, required int minute}) async {
    this.hour = hour;
    this.minute = minute;
    enabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    await prefs.setInt(_kHour, hour);
    await prefs.setInt(_kMinute, minute);
    await _schedule();
  }

  Future<void> disable() async {
    enabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    // v20+ cancel 必须使用命名参数 id:
    await _plugin.cancel(id: _notificationId);
  }

  Future<void> _schedule() async {
    await _plugin.cancel(id: _notificationId);

    // v20+ zonedSchedule 必须使用全命名参数
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: '记账提醒',
      body: '今天还没记账，花 10 秒记一笔吧 💰',
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '每日记账提醒',
          channelDescription: '每天固定时间提醒记账',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}