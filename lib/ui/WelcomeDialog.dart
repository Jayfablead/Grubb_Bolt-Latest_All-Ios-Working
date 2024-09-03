import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/userPrefrence.dart';
import 'package:get/get.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/logo.png', // Path to your background image
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            color: Colors.lightGreen,
            child: Text(
              'Location Disclosure',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: 'With your explicit consent, ',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        text:
                            'ParkPal utilizes the device\'s location in the background to search for available Parkings nearby as per your location.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      TextSpan(
                        text: '\n\n'
                            'These insights are crucial for the app to function. The app would not be able to search for Parkings nearby if it can not access your location.\n\n'
                            'You can choose not to allow the permission, but the app won\'t be functional. Please allow the app to access your location.',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    SystemNavigator.pop();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.red),
                    width: 120,
                    height: 40,
                    child: Text(
                      'NOT NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Poppinsr",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5), // Add space between buttons
                GestureDetector(
                  onTap: () async {
                    // Set user agreement to true
                    await UserPreference.setBoolean(
                        UserPreference.userAgreementKey, true);
                    print("Agree clicked");
                    // Navigate to OnBoarding and remove WelcomeDialog from the navigation stack
                    Get.off(OnBoarding());
                  },
                  child: Container(
                    width: 120,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.green),
                    child: Text(
                      'AGREE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Poppinsr",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
