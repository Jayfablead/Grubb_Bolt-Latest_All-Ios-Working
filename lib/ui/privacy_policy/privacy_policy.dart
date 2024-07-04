// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:foodie_driver/constants.dart';
//
// class PrivacyPolicyScreen extends StatefulWidget {
//   const PrivacyPolicyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
// }
//
// class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
//   String? termsAndCondition;
//
//   @override
//   void initState() {
//     FirebaseFirestore.instance.collection(Setting).doc("privacyPolicy").get().then((value) {
//       setState(() {
//         termsAndCondition = value['privacy_policy'];
//       });
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const Icon(
//             Icons.arrow_back,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: termsAndCondition != null
//               ? HtmlWidget(
//                   // the first parameter (`html`) is required
//                   '''
//                   $termsAndCondition
//                    ''',
//                   onErrorBuilder: (context, element, error) => Text('$element error: $error'),
//                   onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
//                 )
//               : const Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? termsAndCondition;
  String? downloadversion;
  String currentVersion = '';
  int currentVersionCode = 0;
  var versions;
  var version;
  var link;
  static var httpClient = new HttpClient();

  Future<void> downloadFileWithProgress(
      String link, BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Please Wait\nChecking File ...',
      progressWidget: Container(
        height: 15,
        width: 15,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    progressDialog.show();

    try {
      // Get the temporary directory
      const downloadsFolderPath = '/storage/emulated/0/Download';
      Directory dir = Platform.isAndroid
          ? Directory(downloadsFolderPath)
          : await getApplicationDocumentsDirectory();

      // Get file name from the URL
      String fileName = link.split('/').last; // Extract filename from URL

      // Generate a unique filename
      String uniqueFileName = _generateUniqueFileName(dir);

      // Start the download
      http.Client client = http.Client();
      var request = http.Request('GET', Uri.parse(link));
      var streamedResponse = await client.send(request);

      // Get total file size
      int totalBytes = streamedResponse.contentLength ?? 0;
      int downloadedBytes = 0;

      // Open file to write
      final String filePath = '${dir.path}/${uniqueFileName}';
      final File file = File(filePath);
      var sink = file.openWrite();

      // Listen for data received and write to file
      streamedResponse.stream.listen(
        (List<int> data) {
          sink.add(data);
          downloadedBytes += data.length;

          // Calculate download progress
          double progress = downloadedBytes / totalBytes;

          // Convert total file size to megabytes
          double totalMB = totalBytes / (1024 * 1024); // Bytes to MB

          // Convert downloaded size to megabytes
          double downloadedMB = downloadedBytes / (1024 * 1024); // Bytes to MB

          // Update progress dialog
          progressDialog.update(
            progress: progress * 100,
            // Progress should be in percentage (0 to 100)
            message:
                'Downloading... \n${(progress * 100).toStringAsFixed(2)}%\n${downloadedMB.toStringAsFixed(2)} MB / ${totalMB.toStringAsFixed(2)} MB ', // Update progress message
          );
        },
        onDone: () {
          // Close file and progress dialog when download is complete
          sink.close();
          progressDialog.hide();

          // Show completion message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('File Downloaded at || ${filePath} ||.'),
            ),
          );
        },
        onError: (error) {
          // Close file and progress dialog on error
          sink.close();
          progressDialog.hide();

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: Failed to download file.'),
            ),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      // Handle errors here
      progressDialog.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }

// Function to generate a unique filename with random characters
  String _generateUniqueFileName(Directory directory) {
    // Define allowed characters for random filename
    const allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    // Define the length of the random filename
    const length = 2;

    // Generate random filename
    String randomChars = String.fromCharCodes(Iterable.generate(length,
        (_) => allowedChars.codeUnitAt(Random().nextInt(allowedChars.length))));

    // Combine random characters and file extension
    return 'Grubb Driver_${randomChars}.apk';
  }

  void fetchUpdates() async {
    var appUpdate = FirebaseFirestore.instance
        .collection('settings')
        .doc("merchant_app_update");

    try {
      var snapshots = await appUpdate.get();
      var updatesData = snapshots.data();
      if (updatesData != null) {
        versions = updatesData['versionsDriver'];
        version = versions[0];
        link = versions[1];
        print("Api App Version $version");
      }
    } catch (e) {
      print('Error fetching updates: $e');
    }
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        currentVersion = packageInfo.version;
        currentVersionCode = int.parse(packageInfo.buildNumber);
        print("current App Version is : ${currentVersion}");
        print("current App Version Code is : ${currentVersionCode}");
      });
    } catch (e) {
      print('Failed to get package info: $e');
    }
  }

  @override
  void initState() {
    print("Abc");

    FirebaseFirestore.instance
        .collection(Setting)
        .doc("privacyPolicy")
        .get()
        .then((value) {
      setState(() {
        termsAndCondition = value['privacy_policy'];
        print("termsAndCondition${termsAndCondition}");
      });
    });
    fetchUpdates();
    _getAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                version == currentVersion ||
                        version == '' ||
                        version == null ||
                        currentVersion == '' ||
                        currentVersion == null
                    ? Text(
                        "UpDate App Available",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppinsm",
                            fontSize: 17),
                      )
                    : InkWell(
                        onTap: () async {
                          print("Abc");
                          await downloadFileWithProgress(link, context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.deepOrange),
                          child: Text(
                            "UpDate App Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppinsm",
                                fontSize: 17),
                          ),
                        ),
                      ),
              ],
            ),
            version == currentVersion ||
                    version == '' ||
                    version == null ||
                    currentVersion == '' ||
                    currentVersion == null
                ? Container()
                : SizedBox(height: 10),
            version == currentVersion ||
                    version == '' ||
                    version == null ||
                    currentVersion == '' ||
                    currentVersion == null
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      textAlign: TextAlign.center,
                      "*Note* New App Update is Available Please Update to Latest Version",
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: "Poppinsl",
                          fontSize: 13),
                    ),
                  ),

            // SizedBox(
            //   height: 15,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10),
            //   child: termsAndCondition != null
            //       ? HtmlWidget(
            //           // the first parameter (`html`) is required
            //           '''
            //           $termsAndCondition
            //            ''',
            //           onErrorBuilder: (context, element, error) =>
            //               Text('$element error: $error'),
            //           onLoadingBuilder: (context, element, loadingProgress) =>
            //               const CircularProgressIndicator(),
            //         )
            //       : const Center(child: CircularProgressIndicator()),
            // ),
          ],
        ),
      ),
    );
  }
}
