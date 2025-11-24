import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> setupAndroidChannel(
  FlutterLocalNotificationsPlugin plugin,
  AndroidNotificationChannel channel,
) async {
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> requestPermissions(
  FlutterLocalNotificationsPlugin plugin,
) async {
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  await plugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}