import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'main_channel',
          channelName: 'Main Channel',
          channelDescription: 'Main channel for notifications',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Channel',
          channelDescription: 'Scheduled channel for notifications',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Notification ID
        channelKey: 'main_channel',
        title: title,
        body: body,
        payload: payload != null ? {'payload': payload} : null,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        payload: payload != null ? {'payload': payload} : null,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Listen to notification events
  static void listenToNotificationEvents(
      Function(ReceivedNotification) onNotificationCreated,
      Function(ReceivedNotification) onNotificationDisplayed,
      Function(ReceivedAction) onActionReceived,
      ) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: (receivedNotification) => onNotificationCreated(receivedNotification),
      onNotificationDisplayedMethod: (receivedNotification) => onNotificationDisplayed(receivedNotification),
      onActionReceivedMethod: (receivedAction) => onActionReceived(receivedAction),
    );
  }
}