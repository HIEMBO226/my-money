import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  });
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _budgetChannelId = 'my_money_budget_alerts';
  static const String _budgetChannelName = 'Budget Alerts';
  static const String _budgetChannelDescription =
      'Local notifications when monthly category budgets reach 80% or 100%.';

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } on Object {
      // Safely ignore plugin unavailability in test/unsupported environments.
    }
  }

  @override
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        _budgetChannelId,
        _budgetChannelName,
        channelDescription: _budgetChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } on Object {
      // Ignore notification delivery errors so financial saves are never blocked.
    }
  }
}
