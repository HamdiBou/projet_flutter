import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';
import 'quiz_setup_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _scheduleDailyNotification();
  }

  Future<void> _initializeNotifications() async {
    // Initialize awesome_notifications
    await NotificationService.initialize();

    // Request permission to show notifications
    await NotificationService.requestPermissions();

    // Set up notification listeners if needed
    NotificationService.listenToNotificationEvents(
          (receivedNotification) {
        // Handle notification creation
        debugPrint('Notification created: ${receivedNotification.title}');
      },
          (receivedNotification) {
        // Handle notification display
        debugPrint('Notification displayed: ${receivedNotification.title}');
      },
          (receivedAction) {
        // Handle notification action (e.g., when user taps on notification)
        debugPrint('Notification action received: ${receivedAction.buttonKeyPressed}');

        // Navigate to QuizSetupScreen when notification is tapped
        if (receivedAction.payload?['screen'] == 'quiz_setup') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuizSetupScreen(),
            ),
          );
        }
      },
    );
  }

  Future<void> _scheduleDailyNotification() async {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 18, 00, 0); // 6:00 PM
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await NotificationService.scheduleNotification(
      title: 'Quiz Time!',
      body: 'Ready to test your knowledge? Come and play a quiz!',
      scheduledDate: scheduledTime,
      payload: 'screen=quiz_setup',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('quiz_app')),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeService>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSetupScreen(),
                  ),
                );
              },
              child: Text(LocalizationService.of(context)!.translate('start_quiz')),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
              child: Text(LocalizationService.of(context)!.translate('about')),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingScreen(),
                  ),
                );
              },
              child: Text(LocalizationService.of(context)!.translate('rankings')),
            ),
          ],
        ),
      ),
    );
  }
}