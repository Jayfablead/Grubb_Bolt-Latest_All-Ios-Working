import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_driver/constants.dart';
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color(COLOR_PRIMARY),
            ),
            child: Text(
              'Location Access Required',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
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
                          text:
                              '[Grubb Bolt] collects and transmits your location data to enable real-time order tracking and delivery services, even when the app is closed or not in use.',
                          style: TextStyle(fontSize: 15)),
                      TextSpan(
                        text:
                            'By tapping "Agree," you consent to the use of your location data as described above and agree to the app’s Privacy Policy and Terms & Conditions.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      TextSpan(
                        text: '\n\n'
                            'Important: If you do not agree, the app will not be functional, and you will not be able to receive orders or use any features.',
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.red),
                    width: 110,
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
                    width: 110,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Color(COLOR_PRIMARY),
                    ),
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
