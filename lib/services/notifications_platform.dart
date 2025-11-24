import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notifications_platform_stub.dart'
    if (dart.library.io) 'notifications_platform_mobile.dart' as impl;

class NotificationsPlatform {
  static Future<void> setupAndroidChannel(
    FlutterLocalNotificationsPlugin plugin,
    AndroidNotificationChannel channel,
  ) {
    return impl.setupAndroidChannel(plugin, channel);
  }

  static Future<void> requestPermissions(
    FlutterLocalNotificationsPlugin plugin,
  ) {
    return impl.requestPermissions(plugin);
  }
}