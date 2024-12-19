import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';

class PickOrder extends StatefulWidget {
  final OrderModel? currentOrder;

  PickOrder({
    Key? key,
    required this.currentOrder,
  }) : super(key: key);

  @override
  _PickOrderState createState() => _PickOrderState();
}

class _PickOrderState extends State<PickOrder> {
  bool _value = false;
  int val = -1;
  void calculateTimeDifference(String vendorAcceptTime, String fullTimestamp) async{
    // Define date format
    final dateFormat = DateFormat("MMMM d, yyyy hh:mm:ss a");

    try {
      // Clean the strings to remove unwanted text
      // vendorAcceptTime = vendorAcceptTime.replaceAll(RegExp(r'[a-zA-Z]+t'), '').trim();
      // fullTimestamp = fullTimestamp.replaceAll(RegExp(r'[a-zA-Z]+t'), '').trim();
      vendorAcceptTime = vendorAcceptTime
          .replaceAll(RegExp(r'[a-zA-Z]+t'), '')
          .trim()
          .replaceFirst(' pm', ' PM')
          .replaceFirst(' am', ' AM');
      fullTimestamp = fullTimestamp
          .replaceAll(RegExp(r'[a-zA-Z]+t'), '')
          .trim()
          .replaceFirst(' pm', ' PM')
          .replaceFirst(' am', ' AM');

      // Parse the strings to DateTime
      final vendorTime = dateFormat.parse(vendorAcceptTime);
      final fullTime = dateFormat.parse(fullTimestamp);

      // Calculate the difference
      final difference = fullTime.difference(vendorTime);

      // Display the result
      print("Time difference: ${difference.inMinutes} minutes");
      showProgress(context, 'Updating order...', false);
      widget.currentOrder!.status = ORDER_STATUS_IN_TRANSIT;
      widget.currentOrder!.driverpickedtime =fullTimestamp;
      widget.currentOrder!.totaltimediffert =difference.inMinutes.toString();
      print("widget.currentOrder!.totaltimediffertwidget.currentOrder!.totaltimediffert${widget.currentOrder!.totaltimediffert}");
      if (num.parse(speedorderCompleteTime.toString()) >= difference.inMinutes) {
        // Update the field
        updateCompletedOrders(speedCashChallengeid);

        print('Field updated successfully!');
      } else {
        print('Condition not met.');
      }
      await FireStoreUtils.updateOrder(widget.currentOrder!);
      hideProgress();
      setState(() {});
      Navigator.pop(context);
    } catch (e) {
      print("Error parsing time: $e");
    }
  }
  void updateCompletedOrders(String speedCashChallengeid) async {
    final docRef = FirebaseFirestore.instance.collection('speedCashChallenge').doc(speedCashChallengeid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        // વર્તમાન મૂલ્ય મેળવો
        final currentString = docSnapshot.data()?['completedOrdersOfThisTask'] as String? ?? '0';

        // તેને Int માં રૂપાંતરિત કરો, +1 કરો અને પછી ફરીથી String માં ફેરવો
        final updatedValue = (int.tryParse(currentString) ?? 0) + 1;
        if (num.parse(speedcashnumberOfOrders.toString()) == num.parse(updatedValue.toString())) {
          // Update the field
          transaction.update(docRef, {
            'challengeStatus': "complete",
            'end_datetime':fullTimestamp,
          });

          print('Field updated successfully!');
        } else {
          print('Condition not met.');
        }
        // અપડેટ કરો
        transaction.update(docRef, {
          'completedOrdersOfThisTask': updatedValue.toString(),
        });
      }
    }).catchError((error) {
      print('Error updating completedOrdersOfThisTask: $error');
    });
  }



  String? timeZoneOffset;
  String? fullTimestamp;

  void timenow() {
    DateTime now = DateTime.now();

    // Format date and time
    String formattedTime =
    DateFormat("MMMM d, yyyy hh:mm:ss a 'UTC+5:30").format(now);

    timeZoneOffset = now.timeZoneOffset.isNegative
        ? '-${now.timeZoneOffset.inHours.abs()}:${(now.timeZoneOffset.inMinutes % 60).abs().toString().padLeft(2, '0')}'
        : '+${now.timeZoneOffset.inHours}:${(now.timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0')}';

    fullTimestamp = '$formattedTime';
    print('Current Time Stamp is : $fullTimestamp');
    timediffent();
  }
  String? speedcashid;
  String? speedcashnumberOfOrders;
  String? speedorderCompleteTime;
  void timediffent() {
    String vendorAcceptTime = widget.currentOrder?.vendoraccepttime ?? "";
    print("vendorAcceptTimevendorAcceptTimevendorAcceptTime${vendorAcceptTime}");// Replace with actual data
    String fullTimestamp1 = fullTimestamp.toString();
    calculateTimeDifference(vendorAcceptTime, fullTimestamp1);
  }

  Future<void> fetchSpeedcashData(String documentId) async {
    try {
      // Firestore instance મેળવવું
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Document માટે Data મેળવવું
      DocumentSnapshot docSnapshot = await firestore
          .collection('speedcash')
          .doc(documentId) // તમારી જરૂરી ID મૂકો
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Data Access કરો
      setState(() {
        speedcashid = docSnapshot.id; // Document ID
        speedcashnumberOfOrders = data['number_of_orders'] ?? 0;
        speedorderCompleteTime = data['order_complete_time'] ?? 0;
      });

        print('ID: $speedcashid');
        print('Number of Orders: $speedcashnumberOfOrders');
        print('Order Complete Time: ${speedorderCompleteTime}');
        getVendorData(speedcashid ?? "");
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  String speedCashChallengeid = "";
  String vendorId = "";
  String speedCashLevel = "";
  String completedOrdersOfThisTask = "";

  Future<void> getVendorData(String speedcashid) async {
    try {
      // Firestore ના collection ને access કરો
      CollectionReference speedCashChallengeCollection =
      FirebaseFirestore.instance.collection('speedCashChallenge');

      // vendor_id પર આધારિત data filter કરો
      QuerySnapshot querySnapshot = await speedCashChallengeCollection
          .where('speedCashLevel', isEqualTo: speedcashid)
          .get();

      // Snapshot માંથી data મેળવો
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        speedCashChallengeid = doc.id; // Document ID
        vendorId = data['vendor_id'];
    speedCashLevel = data['speedCashLevel'];
         completedOrdersOfThisTask = data['completedOrdersOfThisTask'];

        print('IDdgffdsgfdfgdg: $speedCashChallengeid');
        print('Vendor ID: $vendorId');
        print('Speed Cash Level: $speedCashLevel');
        print('Speed Cash Level: $completedOrdersOfThisTask');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // timenow();
    fetchSpeedcashData(widget.currentOrder?.vendor.speedCashId ?? "");
    print("widget.dhgdfgdfgfdgdfgdgdgdff${widget.currentOrder?.vendoraccepttime ?? ""}");
    print("widget.dhgdfgdfgfdgdfgdgdgdff${widget.currentOrder?.vendor.speedCashId ?? ""}");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: -8,
        title: Text(
          "Pick".tr() + ": ${widget.currentOrder!.id}",
          style: TextStyle(
            color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff000000),
            fontFamily: "Poppinsr",
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey.shade100, width: 0.1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 2.0,
                        spreadRadius: 0.4,
                        offset: Offset(0.2, 0.2)),
                  ],
                  color: isDarkMode(context)
                      ? Color(DARK_CARD_BG_COLOR)
                      : Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'assets/images/order3x.png',
                    height: 25,
                    width: 25,
                    color: Color(COLOR_PRIMARY),
                  ),
                  Text(
                    "Order ready, Pick now !".tr(),
                    style: TextStyle(
                      color: Color(COLOR_PRIMARY),
                      fontFamily: "Poppinsm",
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 28),
            Text(
              "ITEMS".tr(),
              style: TextStyle(
                color: Color(0xff9091A4),
                fontFamily: "Poppinsm",
              ),
            ),
            SizedBox(height: 24),
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.currentOrder!.products.length,
                itemBuilder: (context, index) {
                  return Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CachedNetworkImage(
                                height: 55,
                                // width: 50,
                                imageUrl:
                                    '${widget.currentOrder!.products[index].photo}',
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                          ),
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.currentOrder!.products[index].item ==
                                            "grocery"
                                        ? widget.currentOrder!.products[index]
                                                .name +
                                            "(${widget.currentOrder!.products[index].groceryWeight}${widget.currentOrder!.products[index].groceryUnit})"
                                        : widget
                                            .currentOrder!.products[index].name,
                                    style: TextStyle(
                                        fontFamily: 'Poppinsr',
                                        letterSpacing: 0.5,
                                        color: isDarkMode(context)
                                            ? Color(0xffFFFFFF)
                                            : Color(0xff333333)),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      Text(
                                          '${widget.currentOrder!.products[index].quantity}',
                                          style: TextStyle(
                                            fontFamily: 'Poppinsm',
                                            fontSize: 17,
                                            color: Color(COLOR_PRIMARY),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ));
                  // Card(
                  //   child: Text(widget.currentOrder!.products[index].name),
                  // );
                }),
            SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 0.1),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey.shade200,
                  //       blurRadius: 8.0,
                  //       spreadRadius: 1.2,
                  //       offset: Offset(0.2, 0.2)),
                  // ],
                  color: isDarkMode(context)
                      ? Color(DARK_CARD_BG_COLOR)
                      : Colors.white),
              child: ListTile(
                onTap: () {
                  setState(() {
                    _value = !_value;
                  });
                },
                selected: _value,
                leading: _value
                    ? Image.asset(
                        'assets/images/mark_selected3x.png',
                        height: 21,
                        width: 21,
                      )
                    : Image.asset(
                        'assets/images/mark_unselected3x.png',
                        height: 21,
                        width: 21,
                      ),
                title: Text(
                  "Confirm Items".tr(),
                  style: TextStyle(
                    color: Color(0xff3DAE7D),
                    fontFamily: 'Poppinsm',
                  ),
                ),
              ),
            ),
            SizedBox(height: 26),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 0.1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 2.0,
                        spreadRadius: 0.4,
                        offset: Offset(0.2, 0.2)),
                  ],
                  color: isDarkMode(context)
                      ? Color(DARK_CARD_BG_COLOR)
                      : Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 12),
                    child: Text(
                      "DELIVER".tr(),
                      style: TextStyle(
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(0xff9091A4),
                        fontFamily: "Poppinsr",
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      '${widget.currentOrder!.author.shippingAddress.name}',
                      style: TextStyle(
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(0xff333333),
                        fontFamily: "Poppinsm",
                      ),
                    ),
                    subtitle: Text(
                      '${widget.currentOrder!.author.shippingAddress.line1},'
                      '${widget.currentOrder!.author.shippingAddress.line2},'
                      '${widget.currentOrder!.author.shippingAddress.city}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkMode(context)
                            ? Colors.white
                            : Color(0xff9091A4),
                        fontFamily: "Poppinsr",
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 26),
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              backgroundColor: _value
                  ? Color(COLOR_PRIMARY)
                  : Color(COLOR_PRIMARY).withOpacity(0.5),
            ),
            child: Text(
              "PICKED ORDER".tr(),
              style: TextStyle(letterSpacing: 0.5),
            ),
            onPressed: () async {
              timenow();
              // DateTime now = DateTime.now();
              //
              // Format date and time
              // String formattedTime =
              // DateFormat("MMMM d, yyyy hh:mm:ss a 'UTC+5:30'").format(now);
              //
              // timeZoneOffset = now.timeZoneOffset.isNegative
              //     ? '-${now.timeZoneOffset.inHours.abs()}:${(now.timeZoneOffset.inMinutes % 60).abs().toString().padLeft(2, '0')}'
              //     : '+${now.timeZoneOffset.inHours}:${(now.timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0')}';
              //
              // fullTimestamp = '$formattedTime UTC$timeZoneOffset';
              // print('Current Time Stamp is : $fullTimestamp');
              // print('HomeScreenState.completePickUp');
              // showProgress(context, 'Updating order...', false);
              // widget.currentOrder!.status = ORDER_STATUS_IN_TRANSIT;
              // widget.currentOrder!.driverpickedtime = fullTimestamp;
              // await FireStoreUtils.updateOrder(widget.currentOrder!);
              // hideProgress();
              // setState(() {});
              // Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
