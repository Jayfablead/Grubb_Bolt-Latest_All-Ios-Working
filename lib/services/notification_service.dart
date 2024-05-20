import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:http/http.dart' as http;
import 'package:foodie_driver/services/helper.dart';


Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  //log("BackGround Message :: ${message.messageId}");
}

class NotificationService {

  FirebaseMessaging messaging=FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();


  void requestNotificationPermission()async{
    NotificationSettings settings= await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );

    print("ask permission");


    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("permission granted");
    }else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("user granted provision permission");
    }else{
      print("user denied permission");
    }

  }

  void initLocalNotification(RemoteMessage message)async{
    print("ask Local");
    var androidInitializationSetting=const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSetting=const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSetting,
        iOS: iosInitializationSetting);

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (payload){
          // handleMessage(context, message);
        }
    );
  }


  void firebaseInit(){
    print("ask firebase");
    FirebaseMessaging.onMessage.listen((message) {
      print("Data Message 2  "+message.data['title'].toString());
      // print(message.notification!.body.toString());
      // print(message.data.toString());
      if(message !=null){
        print("ask firebase Message");
        initLocalNotification(message);
        showNotification(message);
      }else{
        print("ask Null firebase Message");
      }
    });
  }

  Future<void> showNotification(RemoteMessage event) async{

    print("ask Show Data");
    String imgUrl="";
    if(event.data['image'] !=null){
      imgUrl=event.data['image'];
    }else{
      imgUrl="";
    }

    print("image url  $imgUrl");
    if(imgUrl==""){
      AndroidNotificationChannel channel = AndroidNotificationChannel(
          Random.secure().nextInt(999999).toString(),
          'foodie-driver'
      );

      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
        channelDescription: 'Show foodie Notification',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableLights: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound("tune"),
       // sound: const UriAndroidNotificationSound("assets/tune/tune.mp3"),
      );

      DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );



      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      Future.delayed(Duration.zero, (){

        _flutterLocalNotificationsPlugin.show(0, event.data['title'].toString(), event.data['body'], notificationDetails);
      });
    }else{
      final http.Response response = await http.get(Uri.parse(imgUrl));
      BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
      );

      AndroidNotificationChannel channel = AndroidNotificationChannel(
          Random.secure().nextInt(999999).toString(),
          'foodie-driver'
      );

      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.name.toString(),
        channelDescription: 'Show foodie Notification',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: bigPictureStyleInformation,
        playSound: true,

        enableLights: true,
        enableVibration: true,
        sound:  RawResourceAndroidNotificationSound("tune"),
      );

      DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );



      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      Future.delayed(Duration.zero, (){

        _flutterLocalNotificationsPlugin.show(0, event.data['title'].toString(), event.data['body'], notificationDetails);
      });
    }

  }


  Future<String> getDeviceToken()async{
    String? token=await messaging.getToken();
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }


  Future<void> setupInteractMessage(BuildContext context)async{
    RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage !=null){
      handleMessage(context, initialMessage);
    }

    // when app is in background

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }

  void handleMessage(BuildContext context,RemoteMessage message){

    if(message.data['redirect']=='product'){
     // Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
    }
  }







  /*
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {});
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("::::::::::::onMessageOpenedApp:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("QuicklAI");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        '0',
        'foodie-driver',
        description: 'Show foodie Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name, channelDescription: 'your channel Description', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

   */
}
