import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // static final FlutterLocalNotificationsPlugin _localNotifications =
  //     FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize notification services
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for notifications
      await _requestPermission();
      
      // Initialize local notifications
      // await _initializeLocalNotifications();
      
      // Configure FCM
      await _configureFCM();
      
      // Get and save FCM token
      await _saveFCMToken();
      
      _isInitialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  // Request notification permissions
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  // Initialize local notifications
  /*
  static Future<void> _initializeLocalNotifications() async {
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosInitializationSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  */

  // Configure FCM message handlers
  static Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background/terminated app messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification when app is in foreground
      // await _showLocalNotification(message);
      print('Foreground message: ${message.notification?.title} - ${message.notification?.body}');
  }

  // Handle background messages (when app is opened via notification)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Opened app via notification: ${message.messageId}');
    
    // Handle navigation or actions based on notification data
    _handleNotificationAction(message.data);
  }

  // Handle notification tap
  /*
  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    // Handle notification tap actions
    if (response.payload != null) {
      // Parse payload and navigate accordingly
      _handleNotificationAction({'action': response.payload!});
    }
  }
  */

  // Show local notification
  /*
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'firebase_learning_channel',
      'Firebase Learning Notifications',
      channelDescription: 'Notifications for Firebase Learning App',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosNotificationDetails = DarwinNotificationDetails();
    
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Firebase Learning',
      message.notification?.body ?? 'You have a new notification',
      notificationDetails,
      payload: message.data['action'] ?? 'default',
    );
  }
  */

  // Handle notification actions
  static void _handleNotificationAction(Map<String, dynamic> data) {
    final action = data['action'] as String?;
    
    switch (action) {
      case 'open_todos':
        // Navigate to todos screen
        print('Navigate to todos screen');
        break;
      case 'open_profile':
        // Navigate to profile screen
        print('Navigate to profile screen');
        break;
      default:
        // Default action - open home screen
        print('Open home screen');
        break;
    }
  }

  // Get and save FCM token
  static Future<void> _saveFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        
        // Save token to user profile in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get current FCM token
  static Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Send test notification (for demo purposes)
  static Future<void> sendTestNotification() async {
    print('Test Notification: This is a test notification from Firebase Learning App');
    // await _showLocalNotification(
    //   RemoteMessage(
    //     notification: const RemoteNotification(
    //       title: 'Test Notification',
    //       body: 'This is a test notification from Firebase Learning App',
    //     ),
    //     data: {'action': 'test'},
    //   ),
    // );
  }

  // Show welcome notification for new users
  static Future<void> showWelcomeNotification(String userName) async {
    print('Welcome Notification: Selamat Datang, $userName!');
    // await _showLocalNotification(
    //   RemoteMessage(
    //     notification: RemoteNotification(
    //       title: 'Selamat Datang, $userName!',
    //       body: 'Terima kasih telah bergabung dengan Firebase Learning App',
    //     ),
    //     data: {'action': 'welcome'},
    //   ),
    // );
  }

  // Show todo completion notification
  static Future<void> showTodoCompletedNotification(String todoTitle) async {
    print('Todo Completion Notification: Todo Selesai! 🎉 - $todoTitle');
    // await _showLocalNotification(
    //   RemoteMessage(
    //     notification: RemoteNotification(
    //       title: 'Todo Selesai! 🎉',
    //       body: 'Anda telah menyelesaikan: $todoTitle',
    //     ),
    //     data: {'action': 'todo_completed'},
    //   ),
    // );
  }

  // Show daily reminder notification
  static Future<void> showDailyReminderNotification() async {
    print('Daily Reminder Notification: Jangan Lupa! ⏰ - Periksa daftar tugas Anda hari ini');
    // await _showLocalNotification(
    //   RemoteMessage(
    //     notification: const RemoteNotification(
    //       title: 'Jangan Lupa! ⏰',
    //       body: 'Periksa daftar tugas Anda hari ini',
    //     ),
    //     data: {'action': 'daily_reminder'},
    //   ),
    // );
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      // await _localNotifications.cancelAll();
      print('All notifications cleared (disabled local notifications)');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Show error notification
  static void showErrorNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success notification
  static void showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Handle token refresh
  static void handleTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Save the new token
      _saveFCMToken();
    });
  }
}
