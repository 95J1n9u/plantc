import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/plant.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android 13+ 알림 권한 요청
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // 식물 물주기 알림 스케줄
  Future<void> schedulePlantWateringNotification(Plant plant) async {
    if (plant.id == null) return;

    final scheduledDate = tz.TZDateTime.from(
      plant.nextWateringDate,
      tz.local,
    );

    // 오전 9시로 알림 시간 설정
    final notificationTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, // 오전 9시
      0,
    );

    await _notifications.zonedSchedule(
      id: plant.id!,
      title: '${plant.name} 물 주실 시간이에요! 💧',
      body: '${plant.name}에게 물을 주세요',
      scheduledDate: notificationTime,
      payload: plant.id.toString(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'plant_watering_channel',
          '식물 물주기 알림',
          channelDescription: '식물에 물을 줄 시간을 알려드립니다',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 알림 취소
  Future<void> cancelPlantNotification(int plantId) async {
    await _notifications.cancel(id: plantId);
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 즉시 테스트 알림 보내기
  Future<void> showTestNotification() async {
    await _notifications.show(
      id: 0,
      title: '테스트 알림',
      body: '알림이 정상적으로 작동합니다!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          '테스트 알림',
          channelDescription: '테스트용 알림 채널',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
