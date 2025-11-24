import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';
import 'notifications_platform.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'appointments_reminders',
    'Lembretes de Consultas',
    description: 'Notificações um dia antes das consultas agendadas.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web tem suporte limitado; não inicializa plugin aqui.
      return;
    }

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {}

    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initIOS = DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: initAndroid, iOS: initIOS);

    await _plugin.initialize(initSettings);

    await NotificationsPlatform.setupAndroidChannel(_plugin, _channel);
    await NotificationsPlatform.requestPermissions(_plugin);
    _isInitialized = true;
  }

  static int _dayBeforeNotificationId(Appointment a) => a.id * 1000 + 1;

  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  static Future<void> scheduleDayBeforeForAppointments(
      List<Appointment> appointments) async {
    if (kIsWeb) return;
    await ensureInitialized();

    for (final a in appointments) {
      await _scheduleDayBefore(a);
    }
  }

  static Future<void> _scheduleDayBefore(Appointment a) async {
    try {
      final date = DateTime.parse(a.dtAvailability);
      final startRange = a.hrAvailability.split('-').first.trim();
      final parts = startRange.split(':');
      final hour = int.tryParse(parts.elementAt(0)) ?? 0;
      final minute = int.tryParse(parts.elementAt(1)) ?? 0;
      final appointmentDateTime =
          DateTime(date.year, date.month, date.day, hour, minute);

      final trigger = appointmentDateTime.subtract(const Duration(days: 1));
      final now = DateTime.now();
      if (!trigger.isAfter(now)) {
        // Lembrete já passou; não agenda
        return;
      }

      final tzTrigger = tz.TZDateTime.from(trigger, tz.local);
      final id = _dayBeforeNotificationId(a);

      // Evita duplicidade
      await _plugin.cancel(id);

      await _plugin.zonedSchedule(
        id,
        'Lembrete de consulta',
        'Você tem consulta amanhã às ${a.formattedTime}.',
        tzTrigger,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            priority: Priority.high,
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Para agendamento pontual, não é necessário matchDateTimeComponents
      );
    } catch (_) {
      // Silencia erros de parsing/scheduling para não quebrar fluxo
    }
  }

  static Future<void> cancelDayBeforeForAppointment(Appointment a) async {
    if (kIsWeb) return;
    await ensureInitialized();
    await _plugin.cancel(_dayBeforeNotificationId(a));
  }

  static Future<void> showNow(String title, String body) async {
    if (kIsWeb) return;
    await ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}