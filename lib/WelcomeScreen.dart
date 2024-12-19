import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/services/helper.dart';


import '../../constants.dart';
import '../../model/mail_setting.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  void initializeFlutterFire() async {
    try {
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("globalSettings")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists &&
            dineinresult.data() != null &&
            dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(
              dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
        }
      });


      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("googleMapKey")
          .get()
          .then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });

      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          mailSettings = MailSettings.fromJson(value.data()!);
        }
      });
    } catch (e) {
      print(e.toString() + "==========ERROR");
    }
  }
  Future<String?> getImageUrl() async {
    try {
      // Firestore na instance mate reference lo
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Firestore ma collection ane document no path specify karo
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await firestore
          .collection('settings')
          .doc('refRiderScreen')
          .get();

      if (docSnapshot.exists) {
        // Document ma thi imageURL fetch karo
        final data = docSnapshot.data();
        Timer(
          Duration(seconds: 10),
              () {
            pushReplacement(context, OnBoarding());
          },
        );
        return data?['image'];


      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeFlutterFire();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body:  FutureBuilder<String?>(
        future: getImageUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return Center(child: Text('No image URL found'));
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.network(snapshot.data!,fit: BoxFit.fitHeight),
            );
          }
        },
      ),
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   child: Image.asset('assets/images/grubb_splash_two'),
      // ),
    );
  }
}
