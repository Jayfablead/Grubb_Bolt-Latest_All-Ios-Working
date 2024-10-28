import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    await firebaseInit();
    await requestNotificationPermission();
    await initLocalNotification();
  }

  Future<void> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      print("Requesting permission");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("Permission granted");
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print("User granted provisional permission");
      } else {
        print("User denied permission");
      }
    } catch (e) {
      print("Error requesting notification permission: $e");
    }
  }

  Future<void> initLocalNotification() async {
    try {
      print("Initializing Local Notification");

      var androidInitializationSettings =
          const AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
            'tune'), // Custom sound file without extension
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      print("Error initializing local notifications: $e");
    }
  }

  Future<void> firebaseInit() async {
    try {
      print("Initializing Firebase");

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received a message: ${message.data.toString()}");
        showNotification(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessageBackgroundHandle);

      // Handle when app is terminated and opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        showNotification(message);
      });
    } catch (e) {
      print("Error initializing Firebase messaging: $e");
    }
  }

  Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
    try {
      print("Background Message :: ${message.messageId}");
      await NotificationService().showNotification(message);
    } catch (e) {
      print("Error handling background message: $e");
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      print("Preparing to show notification");
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";

      print("Notification title: $title");
      print("Notification body: $body");

      if (body.isEmpty) {
        print("Notification body is empty, not showing notification");
        return;
      }

      var androidNotificationDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Show foodie Notification',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('tune'),
        // Custom sound file without extension
        enableLights: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      var iOSNotificationDetails = DarwinNotificationDetails(
        sound: 'tune.aiff', // Custom sound file with extension
      );

      var platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      const int notificationId = 0;

      // Check if the app is in the foreground
      if (message.data['data'] != null &&
          message.data['data']['foreground'] == '1') {
        // Handle foreground notification
        await _flutterLocalNotificationsPlugin.show(
          notificationId,
          title,
          body,
          platformChannelSpecifics,
        );
      } else {
        // Handle background or terminated app notification
        await _flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch,
          title,
          body,
          platformChannelSpecifics,
        );
      }
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      print("Device token: $token");
      return token!;
    } catch (e) {
      print("Error getting device token: $e");
      return "";
    }
  }

  void isTokenRefresh() async {
    try {
      messaging.onTokenRefresh.listen((event) {
        print("Token refreshed: $event");
      });
    } catch (e) {
      print("Error listening to token refresh: $e");
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        handleMessage(context, initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        handleMessage(context, event);
      });
    } catch (e) {
      print("Error setting up message interaction: $e");
    }
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    print("Handling message with data: ${message.data}");
    if (message.data['redirect'] == 'product') {
      print("Redirecting to product page");
      // Implement navigation to the product page or other appropriate action
    }
  }
}
