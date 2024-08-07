// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
//   print("Background Message :: ${message.messageId}");
//   // Create an instance of NotificationService and show notification
//   NotificationService notificationService = NotificationService();
//   await notificationService.showNotification(message);
// }
//
// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static final NotificationService _instance = NotificationService._internal();
//
//   factory NotificationService() {
//     return _instance;
//   }
//
//   NotificationService._internal() {
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await firebaseInit();
//     await requestNotificationPermission();
//     await initLocalNotification();
//   }
//
//   Future<void> requestNotificationPermission() async {
//     try {
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true,
//       );
//
//       print("Requesting permission");
//
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print("Permission granted");
//       } else if (settings.authorizationStatus ==
//           AuthorizationStatus.provisional) {
//         print("User granted provisional permission");
//       } else {
//         print("User denied permission");
//       }
//     } catch (e) {
//       print("Error requesting notification permission: $e");
//     }
//   }
//
//   Future<void> initLocalNotification() async {
//     try {
//       print("Initializing Local Notification");
//
//       var androidInitializationSettings =
//           const AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       var initializationSetting = InitializationSettings(
//         android: androidInitializationSettings,
//       );
//
//       await _flutterLocalNotificationsPlugin.initialize(
//         initializationSetting,
//       );
//
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'high_importance_channel',
//         'High Importance Notifications',
//         description: 'This channel is used for important notifications.',
//         importance: Importance.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('tune'),
//         enableVibration: true,
//       );
//
//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//     } catch (e) {
//       print("Error initializing local notifications: $e");
//     }
//   }
//
//   Future<void> firebaseInit() async {
//     try {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print("Received a message: ${message.data.toString()}");
//         showNotification(message);
//       });
//
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         print(
//             "Handling message when app is opened: ${message.data.toString()}");
//         handleMessage(message);
//       });
//
//       // Handle token refresh
//       _messaging.onTokenRefresh.listen((String? token) {
//         print("Token refreshed: $token");
//         // Optionally update your server with the new token
//       });
//     } catch (e) {
//       print("Error initializing Firebase messaging: $e");
//     }
//   }
//
//   Future<void> showNotification(RemoteMessage message) async {
//     try {
//       print("Preparing to show notification");
//       String title = message.notification?.title ?? "Default Title";
//       String body = message.notification?.body ?? "Default Body";
//
//       print("Notification title: $title");
//       print("Notification body: $body");
//
//       if (body.isEmpty) {
//         print("Notification body is empty, not showing notification");
//         return;
//       }
//
//       var androidNotificationDetails = AndroidNotificationDetails(
//         'high_importance_channel',
//         'High Importance Notifications',
//         channelDescription: 'Show important notifications',
//         importance: Importance.high,
//         priority: Priority.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('tune'),
//         enableLights: true,
//         enableVibration: true,
//         styleInformation: BigTextStyleInformation(body),
//       );
//
//       var platformChannelSpecifics = NotificationDetails(
//         android: androidNotificationDetails,
//       );
//
//       int notificationId = DateTime.now().millisecondsSinceEpoch;
//
//       await _flutterLocalNotificationsPlugin.show(
//         notificationId,
//         title,
//         body,
//         platformChannelSpecifics,
//       );
//     } catch (e) {
//       print("Error showing notification: $e");
//     }
//   }
//
//   Future<String> getDeviceToken() async {
//     try {
//       String? token = await _messaging.getToken();
//       print("Device token: $token");
//       return token ?? "";
//     } catch (e) {
//       print("Error getting device token: $e");
//       return "";
//     }
//   }
//
//   Future<void> setupInteractMessage(BuildContext context) async {
//     try {
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         handleMessage(message);
//       });
//
//       FirebaseMessaging.instance
//           .getInitialMessage()
//           .then((RemoteMessage? message) {
//         if (message != null) {
//           handleMessage(message);
//         }
//       });
//     } catch (e) {
//       print("Error setting up message interaction: $e");
//     }
//   }
//
//   void handleMessage(RemoteMessage message) {
//     print("Handling message with data: ${message.data}");
//     if (message.data['redirect'] == 'product') {
//       print("Redirecting to product page");
//       // Navigate to product page or handle as needed
//     }
//   }
// }
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:math';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:foodie_driver/constants.dart';
// import 'package:foodie_driver/main.dart';
// import 'package:foodie_driver/model/OrderModel.dart';
// import 'package:foodie_driver/model/User.dart';
// import 'package:foodie_driver/services/FirebaseHelper.dart';
// import 'package:http/http.dart' as http;
// import 'package:foodie_driver/services/helper.dart';
//
//
// Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
//   //log("BackGround Message :: ${message.messageId}");
// }
//
// class NotificationService {
//
//   FirebaseMessaging messaging=FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
//
//
//   void requestNotificationPermission()async{
//     NotificationSettings settings= await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true
//     );
//
//     print("ask permission");
//
//
//     if(settings.authorizationStatus==AuthorizationStatus.authorized){
//       print("permission granted");
//     }else if(settings.authorizationStatus==AuthorizationStatus.provisional){
//       print("user granted provision permission");
//     }else{
//       print("user denied permission");
//     }
//
//   }
//
//   void initLocalNotification(RemoteMessage message)async{
//     print("ask Local");
//     var androidInitializationSetting=const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iosInitializationSetting=const DarwinInitializationSettings();
//
//     var initializationSetting = InitializationSettings(
//         android: androidInitializationSetting,
//         iOS: iosInitializationSetting);
//
//     await _flutterLocalNotificationsPlugin.initialize(
//         initializationSetting,
//         onDidReceiveNotificationResponse: (payload){
//           // handleMessage(context, message);
//         }
//     );
//   }
//
//
//   void firebaseInit(){
//     print("ask firebase");
//     FirebaseMessaging.onMessage.listen((message) {
//       print("Data Message 2  "+message.data['title'].toString());
//       // print(message.notification!.body.toString());
//       // print(message.data.toString());
//       if(message !=null){
//         print("ask firebase Message");
//         initLocalNotification(message);
//         showNotification(message);
//       }else{
//         print("ask Null firebase Message");
//       }
//     });
//   }
//
//   Future<void> showNotification(RemoteMessage event) async{
//
//     print("ask Show Data");
//     String imgUrl="";
//     if(event.data['image'] !=null){
//       imgUrl=event.data['image'];
//     }else{
//       imgUrl="";
//     }
//
//     print("image url  $imgUrl");
//     if(imgUrl==""){
//       AndroidNotificationChannel channel = AndroidNotificationChannel(
//           Random.secure().nextInt(999999).toString(),
//           'foodie-driver'
//       );
//
//       AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
//         channelDescription: 'Show foodie Notification',
//         importance: Importance.high,
//         priority: Priority.high,
//         ticker: 'ticker',
//         playSound: true,
//         enableLights: true,
//         enableVibration: true,
//         sound: RawResourceAndroidNotificationSound("tune"),
//         // sound: const UriAndroidNotificationSound("assets/tune/tune.mp3"),
//       );
//
//       DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//
//
//       NotificationDetails notificationDetails = NotificationDetails(
//         android: androidNotificationDetails,
//         iOS: darwinNotificationDetails,
//       );
//
//       Future.delayed(Duration.zero, (){
//
//         _flutterLocalNotificationsPlugin.show(0, event.data['title'].toString(), event.data['body'], notificationDetails);
//       });
//     }else{
//       final http.Response response = await http.get(Uri.parse(imgUrl));
//       BigPictureStyleInformation bigPictureStyleInformation =
//       BigPictureStyleInformation(
//         ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
//         largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
//       );
//
//       AndroidNotificationChannel channel = AndroidNotificationChannel(
//           Random.secure().nextInt(999999).toString(),
//           'foodie-driver'
//       );
//
//       AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
//         channelDescription: 'Show foodie Notification',
//         importance: Importance.high,
//         priority: Priority.high,
//         ticker: 'ticker',
//         styleInformation: bigPictureStyleInformation,
//         playSound: true,
//
//         enableLights: true,
//         enableVibration: true,
//         sound:  RawResourceAndroidNotificationSound("tune"),
//       );
//
//       DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//
//
//       NotificationDetails notificationDetails = NotificationDetails(
//         android: androidNotificationDetails,
//         iOS: darwinNotificationDetails,
//       );
//
//       Future.delayed(Duration.zero, (){
//
//         _flutterLocalNotificationsPlugin.show(0, event.data['title'].toString(), event.data['body'], notificationDetails);
//       });
//     }
//
//   }
//
//
//   Future<String> getDeviceToken()async{
//     String? token=await messaging.getToken();
//     return token!;
//   }
//
//   void isTokenRefresh()async{
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//     });
//   }
//
//
//   Future<void> setupInteractMessage(BuildContext context)async{
//     RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();
//
//     if(initialMessage !=null){
//       handleMessage(context, initialMessage);
//     }
//
//     // when app is in background
//
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       handleMessage(context, event);
//     });
//
//   }
//
//   void handleMessage(BuildContext context,RemoteMessage message){
//
//     if(message.data['redirect']=='product'){
//       // Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
//     }
//   }
//
//
//
//
//
//
//
// /*
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   initInfo() async {
//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     var request = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
//       const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//       var iosInitializationSettings = const DarwinInitializationSettings();
//       final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
//       await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {});
//       setupInteractedMessage();
//     }
//   }
//
//   Future<void> setupInteractedMessage() async {
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       log("::::::::::::onMessage:::::::::::::::::");
//       if (message.notification != null) {
//         log(message.notification.toString());
//         display(message);
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       log("::::::::::::onMessageOpenedApp:::::::::::::::::");
//       if (message.notification != null) {
//         log(message.notification.toString());
//         display(message);
//       }
//     });
//     log("::::::::::::Permission authorized:::::::::::::::::");
//     await FirebaseMessaging.instance.subscribeToTopic("QuicklAI");
//   }
//
//   static getToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     return token!;
//   }
//
//   void display(RemoteMessage message) async {
//     log('Got a message whilst in the foreground!');
//     log('Message data: ${message.notification!.body.toString()}');
//     try {
//       // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//
//       AndroidNotificationChannel channel = const AndroidNotificationChannel(
//         '0',
//         'foodie-driver',
//         description: 'Show foodie Notification',
//         importance: Importance.max,
//       );
//       AndroidNotificationDetails notificationDetails =
//           AndroidNotificationDetails(channel.id, channel.name, channelDescription: 'your channel Description', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
//       const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
//       NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
//       await FlutterLocalNotificationsPlugin().show(
//         0,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetailsBoth,
//         payload: jsonEncode(message.data),
//       );
//     } on Exception catch (e) {
//       log(e.toString());
//     }
//   }
//
//    */
// }


///
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static final NotificationService _instance = NotificationService._internal();
//
//   factory NotificationService() {
//     return _instance;
//   }
//
//   NotificationService._internal() {
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await firebaseInit();
//     await requestNotificationPermission();
//     await initLocalNotification();
//   }
//
//   Future<void> requestNotificationPermission() async {
//     try {
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true,
//       );
//
//       print("Requesting permission");
//
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print("Permission granted");
//       } else if (settings.authorizationStatus ==
//           AuthorizationStatus.provisional) {
//         print("User granted provisional permission");
//       } else {
//         print("User denied permission");
//       }
//     } catch (e) {
//       print("Error requesting notification permission: $e");
//     }
//   }
//
//   Future<void> initLocalNotification() async {
//     try {
//       print("Initializing Local Notification");
//
//       var androidInitializationSettings =
//       const AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       var initializationSetting = InitializationSettings(
//         android: androidInitializationSettings,
//         iOS: const DarwinInitializationSettings(),
//       );
//
//       await _flutterLocalNotificationsPlugin.initialize(
//         initializationSetting,
//       );
//     } catch (e) {
//       print("Error initializing local notifications: $e");
//     }
//   }
//
//   Future<void> showNotification(RemoteMessage message) async {
//     try {
//       print("Preparing to show notification");
//       String title = message.notification?.title ?? "Default Title";
//       String body = message.notification?.body ?? "Default Body";
//
//       print("Notification title: $title");
//       print("Notification body: $body");
//
//       if (body.isEmpty) {
//         print("Notification body is empty, not showing notification");
//         return;
//       }
//
//       var androidNotificationDetails = AndroidNotificationDetails(
//         'high_importance_channel',
//         'High Importance Notifications',
//         channelDescription: 'Show important notifications',
//         importance: Importance.high,
//         priority: Priority.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('tune'),
//         enableLights: true,
//         enableVibration: true,
//         styleInformation: BigTextStyleInformation(body),
//       );
//
//       var iosNotificationDetails = DarwinNotificationDetails(
//         sound: 'tune.aiff',
//       );
//
//       var platformChannelSpecifics = NotificationDetails(
//         android: androidNotificationDetails,
//         iOS: iosNotificationDetails,
//       );
//
//       int notificationId = DateTime.now().millisecondsSinceEpoch;
//
//       await _flutterLocalNotificationsPlugin.show(
//         notificationId,
//         title,
//         body,
//         platformChannelSpecifics,
//       );
//     } catch (e) {
//       print("Error showing notification: $e");
//     }
//   }
//
//   Future<void> firebaseInit() async {
//     try {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print("Received a message: ${message.data.toString()}");
//         showNotification(message);
//       });
//
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         print(
//             "Handling message when app is opened: ${message.data.toString()}");
//         handleMessage(message);
//       });
//
//       // Handle token refresh
//       _messaging.onTokenRefresh.listen((String? token) {
//         print("Token refreshed: $token");
//         // Optionally update your server with the new token
//       });
//     } catch (e) {
//       print("Error initializing Firebase messaging: $e");
//     }
//   }
//
//   Future<String> getDeviceToken() async {
//     try {
//       String? token = await _messaging.getToken();
//       print("Device token: $token");
//       return token ?? "";
//     } catch (e) {
//       print("Error getting device token: $e");
//       return "";
//     }
//   }
//
//   Future<void> setupInteractMessage(BuildContext context) async {
//     try {
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         handleMessage(message);
//       });
//
//       FirebaseMessaging.instance
//           .getInitialMessage()
//           .then((RemoteMessage? message) {
//         if (message != null) {
//           handleMessage(message);
//         }
//       });
//     } catch (e) {
//       print("Error setting up message interaction: $e");
//     }
//   }
//
//   void handleMessage(RemoteMessage message) {
//     print("Handling message with data: ${message.data}");
//     if (message.data['redirect'] == 'product') {
//       print("Redirecting to product page");
//       // Navigate to product page or handle as needed
//     }
//   }
// }
 ///
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    await requestNotificationPermission();
    await initLocalNotification();
    await firebaseInit();
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
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
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

      var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();

      var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
      );
    } catch (e) {
      print("Error initializing local notifications: $e");
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      print("Preparing to show notification");
      String title = message.notification?.title ?? "Default Title";
      String body = message.notification?.body ?? "Default Body";

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

      var iosNotificationDetails = DarwinNotificationDetails(
        sound: 'tune.aiff',
      );

      var platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      int notificationId = DateTime.now().millisecondsSinceEpoch;

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
      );
      print("Notification displayed successfully");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  Future<void> firebaseInit() async {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received a message: ${message.data.toString()}");
        showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Handling message when app is opened: ${message.data.toString()}");
        handleMessage(message);
      });

      _messaging.onTokenRefresh.listen((String? token) {
        print("Token refreshed: $token");
      });
    } catch (e) {
      print("Error initializing Firebase messaging: $e");
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

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
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
