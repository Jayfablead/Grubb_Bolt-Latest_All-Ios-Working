import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  print("Background Message :: ${message.messageId}");
  // Create an instance of NotificationService and show notification
  NotificationService notificationService = NotificationService();
  await notificationService.showNotification(message);
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      NotificationSettings settings = await _messaging.requestPermission(
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
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('tune'),
        enableVibration: true,
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
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received a message: ${message.data.toString()}");
        showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print(
            "Handling message when app is opened: ${message.data.toString()}");
        handleMessage(message);
      });

      // Handle token refresh
      _messaging.onTokenRefresh.listen((String? token) {
        print("Token refreshed: $token");
        // Optionally update your server with the new token
      });
    } catch (e) {
      print("Error initializing Firebase messaging: $e");
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      print("Preparing to show notification");
      String title = message.notification?.title ?? "Default Title";
      String body = message.notification?.body ?? "Default Body";

      print("Notification title: $title");
      print("Notification body: $body");

      if (body.isEmpty) {
        print("Notification body is empty, not showing notification");
        return;
      }

      var androidNotificationDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Show important notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('tune'),
        enableLights: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      var platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
      );

      int notificationId = DateTime.now().millisecondsSinceEpoch;

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  Future<String> getDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      print("Device token: $token");
      return token ?? "";
    } catch (e) {
      print("Error getting device token: $e");
      return "";
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleMessage(message);
      });

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          handleMessage(message);
        }
      });
    } catch (e) {
      print("Error setting up message interaction: $e");
    }
  }

  void handleMessage(RemoteMessage message) {
    print("Handling message with data: ${message.data}");
    if (message.data['redirect'] == 'product') {
      print("Redirecting to product page");
      // Navigate to product page or handle as needed
    }
  }
}
