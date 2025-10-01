import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      print('Notification service initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();

      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Check if scheduled time is in the past
      if (scheduledTime.isBefore(DateTime.now())) {
        print('Cannot schedule notification in the past');
        return;
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Reminder notifications from Jarvis',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Notification scheduled: $title at $scheduledTime (ID: $id)');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Show instant notification with sound
  Future<void> showNotificationWithSound({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      // Show notification
      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Reminder notifications from Jarvis',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification.mp3',
          ),
        ),
      );

      // Play sound 3 times with delay
      for (int i = 0; i < 3; i++) {
        await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      print('Instant notification shown with sound');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Play notification sound manually (3 times)
  Future<void> playNotificationSound() async {
    try {
      for (int i = 0; i < 3; i++) {
        await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('Notification cancelled: $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Get active notifications
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        return await androidPlugin.getActiveNotifications();
      }
      return [];
    } catch (e) {
      print('Error getting active notifications: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
