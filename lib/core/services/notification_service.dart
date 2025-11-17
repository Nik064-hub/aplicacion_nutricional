// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    tz.initializeTimeZones();
    final String tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));
  }

  Future<void> scheduleMealReminder({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
  }) async {
    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tz.TZDateTime.from(fechaHora, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plan_comidas',
          'Recordatorios de Comidas',
          channelDescription: 'Recordatorios automáticos del plan semanal',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
