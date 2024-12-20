import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/OrderCretedRazorpayModal.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/chat_screen/chat_screen.dart';
import 'package:foodie_driver/ui/home/pick_order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();
  double razorpayamout = 0.0;
  GoogleMapController? _mapController;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/location_orange3x.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/location_orange3x.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/food_delivery.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  updateDriverOrder() async {
    await FireStoreUtils.firestore
        .collection(Setting)
        .doc("DriverNearBy")
        .get()
        .then((value) {
      setState(() {
        minimumDepositToRideAccept =
            value.data()!['minimumDepositToRideAccept'];
      });
    });

    Timestamp startTimestamp = Timestamp.now();
    DateTime currentDate = startTimestamp.toDate();
    currentDate = currentDate.subtract(Duration(hours: 3));
    startTimestamp = Timestamp.fromDate(currentDate);

    List<OrderModel> orders = [];

    print('-->startTime${startTimestamp.toDate()}');
    await FirebaseFirestore.instance
        .collection(ORDERS)
        .where('status',
            whereIn: [ORDER_STATUS_ACCEPTED, ORDER_STATUS_DRIVER_REJECTED])
        .where('createdAt', isGreaterThan: startTimestamp)
        .get()
        .then((value) async {
          print('---->${value.docs.length}');
          await Future.forEach(value.docs,
              (QueryDocumentSnapshot<Map<String, dynamic>> element) {
            try {
              orders.add(OrderModel.fromJson(element.data()));
            } catch (e, s) {
              print('watchOrdersStatus parse error ${element.id}$e $s');
            }
          });
        });

    orders.forEach((element) {
      OrderModel orderModel = element;
      print('---->${orderModel.id}');
      orderModel.triggerDelevery = Timestamp.now();
      FirebaseFirestore.instance
          .collection(ORDERS)
          .doc(element.id)
          .set(orderModel.toJson(), SetOptions(merge: true))
          .then((order) {
        print('Done.');
      });
    });
  }

  RxBool _value = false.obs;

  @override
  void initState() {
    _value.value = false;
    NotificationService notificationService = NotificationService();
    notificationService.requestNotificationPermission();
    notificationService.initLocalNotification();
    notificationService.firebaseInit();
    notificationService.setupInteractMessage(context);
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit();
    notificationService.getDeviceToken().then((value) {
      print("device token    $value");
    });
    getRazorpayCredentials();
    getDriver();
    setIcons();
    updateDriverOrder();
    getLocation();

    super.initState();
  }

  getLocation() async {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationDataFinal!.latitude ?? 0.0,
              locationDataFinal!.longitude ?? 0.0),
          zoom: 20,
          bearing: double.parse(_driverModel!.rotation.toString()),
        ),
      ),
    );
    setState(() {});
  }

  late Stream<OrderModel?> ordersFuture;
  OrderModel? currentOrder;

  late Stream<User> driverStream;
  User? _driverModel = User();

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils()
        .getOrderByID(_driverModel!.inProgressOrderID.toString());
    ordersFuture.listen((event) {
      print("razorpayamoutrazorpayamoutrazorpayamout${event!.status}");
      print("------->${event!.status}");
      setState(() {
        currentOrder = event;
        getDirections();
      });
    });
  }

  getDriver() {
    driverStream = FireStoreUtils()
        .getDriver(MyAppState.currentUser?.userID.toString() ?? "");
    driverStream.listen((event) {
      _driverModel = event;
      setState(() {
        MyAppState.currentUser = _driverModel;
      });
      getDirections();
      print("driver${_driverModel!.isActive}");
      if (_driverModel!.isActive) {
        print("--->${_driverModel!.orderRequestData}");
        if (_driverModel!.orderRequestData != null) {
          showDriverBottomSheet();
          playSound();
        }
      }
      if (_driverModel!.inProgressOrderID != null) {
        getCurrentOrder();
      }

      if (_driverModel!.orderRequestData == null) {
        setState(() {
          _markers.clear();
          polyLines.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController!.dispose();
    FireStoreUtils().driverStreamSub.cancel();
    FireStoreUtils().ordersStreamController.close();
    FireStoreUtils().ordersStreamSub.cancel();

    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (isDarkMode(context))
      _mapController?.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
  }

  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    isDarkMode(context)
        ? _mapController?.setMapStyle('[{"featureType": "all","'
            'elementType": "'
            'geo'
            'met'
            'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]')
        : _mapController?.setMapStyle(null);

    return Scaffold(
      body: Column(
        children: [
          Visibility(
            visible: _driverModel!.inProgressOrderID == null &&
                _driverModel!.walletAmount <=
                    double.parse(minimumDepositToRideAccept),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      " You have to top up wallet with minimum of ${amountShow(amount: minimumDepositToRideAccept.toString())} to start receiving orders.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled:
                  _driverModel!.inProgressOrderID != null ? false : true,
              myLocationButtonEnabled: true,
              mapType: MapType.terrain,
              zoomControlsEnabled: true,
              polylines: Set<Polyline>.of(polyLines.values),
              markers: _markers.values.toSet(),
              initialCameraPosition: CameraPosition(
                zoom: 15,
                target: LatLng(_driverModel!.location.latitude,
                    _driverModel!.location.longitude),
              ),
            ),
          ),
          _driverModel!.inProgressOrderID != null &&
                  currentOrder != null &&
                  isShow == true
              ? buildOrderActionsCard()
              : Container(),
          _driverModel!.orderRequestData != null
              ? showDriverBottomSheet()
              : Container()
        ],
      ),
      floatingActionButton: _driverModel!.orderRequestData != null ||
              _driverModel!.inProgressOrderID == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (isShow == true) {
                    isShow = false;
                  } else {
                    isShow = true;
                  }
                });
              },
              child: Icon(
                isShow ? Icons.close : Icons.remove_red_eye,
                color: Colors.white,
                size: 29,
              ),
              backgroundColor: Colors.black,
              // backgroundColor: Color(COLOR_PRIMARY),
              tooltip: 'Capture Picture',
              elevation: 5,
              splashColor: Colors.grey,
            ),
    );
  }

  openChatWithCustomer() async {
    await showProgress(context, "Please wait".tr(), false);

    User? customer =
        await FireStoreUtils.getCurrentUser(currentOrder!.authorID);
    print(currentOrder!.driverID);
    User? driver =
        await FireStoreUtils.getCurrentUser(currentOrder!.driverID.toString());

    hideProgress();
    push(
        context,
        ChatScreens(
          customerName: customer!.firstName + " " + customer.lastName,
          restaurantName: driver!.firstName + " " + driver.lastName,
          orderId: currentOrder!.id,
          restaurantId: driver.userID,
          customerId: customer.userID,
          customerProfileImage: customer.profilePictureURL,
          restaurantProfileImage: driver.profilePictureURL,
          token: customer.fcmToken,
          chatType: 'Driver',
        ));
  }

  showDriverBottomSheet() {
    double distanceInMeters = Geolocator.distanceBetween(
        _driverModel!.orderRequestData!.vendor.latitude,
        _driverModel!.orderRequestData!.vendor.longitude,
        _driverModel!
            .orderRequestData!.author.shippingAddress.location.latitude,
        _driverModel!
            .orderRequestData!.author.shippingAddress.location.longitude);
    double kilometer = distanceInMeters / 1000;
    num deliverycharge = num.parse(
            kilometer.toStringAsFixed(currencyModel!.decimal)) *
        num.parse(_driverModel!.orderRequestData!.deliveryCharge.toString());
    razorpayamout = double.parse(
        (_driverModel!.orderRequestData?.deliveryCharge).toString());
    print("razorpayamoutrazorpayamoutrazorpayamout${razorpayamout}");
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xff212121),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    "Trip Distance".tr(),
                    style: TextStyle(
                        color: Color(0xffADADAD),
                        fontFamily: "Poppinsr",
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  // '0',
                  "${kilometer.toStringAsFixed(currencyModel!.decimal)} km",
                  style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontFamily: "Poppinsm",
                      letterSpacing: 0.5),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    "paymentMethod : -".tr(),
                    style: TextStyle(
                        color: Color(0xffADADAD),
                        fontFamily: "Poppinsr",
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  // '0',
                  _driverModel!.orderRequestData!.paymentMethod.toString(),
                  style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontFamily: "Poppinsm",
                      letterSpacing: 0.5),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    "Delivery charge".tr(),
                    style: TextStyle(
                        color: Color(0xffADADAD),
                        fontFamily: "Poppinsr",
                        letterSpacing: 0.5),
                  ),
                ),
                Text(
                  // '0',
                  "${amountShow(amount: _driverModel!.orderRequestData!.deliveryCharge.toString())}",
                  style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontFamily: "Poppinsm",
                      letterSpacing: 0.5),
                ),
              ],
            ),
            SizedBox(height: 5),
            Card(
              color: Color(0xffFFFFFF),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/location3x.png',
                      height: 55,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 270,
                          child: Text(
                            "${_driverModel!.orderRequestData!.vendor.location} ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontFamily: "Poppinsr",
                                letterSpacing: 0.5),
                          ),
                        ),
                        SizedBox(height: 22),
                        SizedBox(
                          width: 270,
                          child: Text(
                            "${_driverModel!.orderRequestData!.address.line1} "
                            "${_driverModel!.orderRequestData!.address.line2} "
                            "${_driverModel!.orderRequestData!.address.city}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontFamily: "Poppinsr",
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      backgroundColor: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                          color: Color(0xffFFFFFF),
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5),
                    ),
                    onPressed: () async {
                      showProgress(context, 'Rejecting order...'.tr(), false);
                      try {
                        audioPlayer.stop();
                        await rejectOrder();
                        hideProgress();
                        setState(() {});
                      } catch (e) {
                        hideProgress();
                        print('HomeScreenState.showDriverBottomSheet $e');
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        backgroundColor: Color(COLOR_PRIMARY),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      child: Text(
                        'Accept'.tr(),
                        style: TextStyle(
                            color: Color(0xffFFFFFF),
                            fontFamily: "Poppinsm",
                            letterSpacing: 0.5),
                      ),
                      onPressed: () async {
                        showProgress(context, 'Accepting order...'.tr(), false);
                        audioPlayer.stop();
                        await acceptOrder();
                        hideProgress();
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderActionsCard() {
    late String title;
    String? buttonText;
    if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
        currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
      title = '${currentOrder!.vendor.title}';

      buttonText = 'REACHED STORE FOR PICKUP'.tr();
    } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
      title = 'Deliver to {}'.tr(args: ['${currentOrder!.author.firstName}']);
      // buttonText = 'Complete Pick Up'.tr();
      buttonText = 'REACHED DROP LOCATION'.tr();
    }

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(18)),
        color: isDarkMode(context) ? Color(0xff000000) : Color(0xffFFFFFF),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
                currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
              Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: TextStyle(
                          color: isDarkMode(context)
                              ? Color(0xffFFFFFF)
                              : Color(0xff000000),
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.vendor.location}',
                        maxLines: 2,
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff000000),
                            fontFamily: "Poppinsr",
                            letterSpacing: 0.5),
                      ),
                    ),
                    trailing: TextButton.icon(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(color: Color(0xff3DAE7D)),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(85, 30),
                          alignment: Alignment.center,
                          backgroundColor: Color(0xffFFFFFF),
                        ),
                        onPressed: () {
                          UrlLauncher.launchUrl(Uri.parse(
                              "tel://${currentOrder!.vendor.phonenumber}"));
                        },
                        icon: Image.asset(
                          'assets/images/call3x.png',
                          height: 14,
                          width: 14,
                        ),
                        label: Text(
                          "CALL",
                          style: TextStyle(
                              color: Color(0xff3DAE7D),
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5),
                        )),
                  ),
                  ListTile(
                    tileColor: Color(0xffF1F4F8),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    title: Row(
                      children: [
                        Text(
                          'ORDER ID '.tr(),
                          style: TextStyle(
                              color: isDarkMode(context)
                                  ? Color(0xffFFFFFF)
                                  : Color(0xff555555),
                              fontFamily: "Poppinsr",
                              letterSpacing: 0.5),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            '${currentOrder!.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: isDarkMode(context)
                                    ? Color(0xffFFFFFF)
                                    : Color(0xff000000),
                                fontFamily: "Poppinsr",
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.author.shippingAddress.name}',
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontFamily: "Poppinsm",
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
              Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/user3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      '${currentOrder!.author.shippingAddress.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDarkMode(context)
                              ? Color(0xffFFFFFF)
                              : Color(0xff000000),
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5),
                    ),
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ORDER ID '.tr(),
                            style: TextStyle(
                                color: Color(0xff555555),
                                fontFamily: "Poppinsr",
                                letterSpacing: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Text(
                              '${currentOrder!.id} ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0xff000000),
                                  fontFamily: "Poppinsr",
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(85, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () {
                              UrlLauncher.launchUrl(Uri.parse(
                                  "tel://${currentOrder!.author.phoneNumber}"));
                            },
                            icon: Image.asset(
                              'assets/images/call3x.png',
                              height: 14,
                              width: 14,
                            ),
                            label: Text(
                              "CALL".tr(),
                              style: TextStyle(
                                  color: Color(0xff3DAE7D),
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/delivery_location3x.png',
                      height: 42,
                      width: 42,
                      color: Color(COLOR_PRIMARY),
                    ),
                    title: Text(
                      'DELIVER'.tr(),
                      style: TextStyle(
                          color: Color(0xff9091A4),
                          fontFamily: "Poppinsr",
                          letterSpacing: 0.5),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${currentOrder!.author.shippingAddress.line1},${currentOrder!.author.shippingAddress.line2},${currentOrder!.author.shippingAddress.city},${currentOrder!.author.shippingAddress.country}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Color(0xffFFFFFF)
                                : Color(0xff333333),
                            fontFamily: "Poppinsr",
                            letterSpacing: 0.5),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                side: BorderSide(color: Color(0xff3DAE7D)),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(100, 30),
                              alignment: Alignment.center,
                              backgroundColor: Color(0xffFFFFFF),
                            ),
                            onPressed: () => openChatWithCustomer(),
                            icon: Icon(
                              Icons.message,
                              size: 16,
                              color: Color(0xff3DAE7D),
                            ),
                            // Image.asset(
                            //   'assets/images/call3x.png',
                            //   height: 14,
                            //   width: 14,
                            // ),
                            label: Text(
                              "Message",
                              style: TextStyle(
                                  color: Color(0xff3DAE7D),
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    backgroundColor: Color(COLOR_PRIMARY),
                  ),
                  onPressed: () async {
                    if (currentOrder!.status == ORDER_STATUS_SHIPPED ||
                        currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
                      push(
                        context,
                        PickOrder(currentOrder: currentOrder),
                      );
                    } else if (currentOrder!.status ==
                        ORDER_STATUS_IN_TRANSIT) {
                      push(
                        context,
                        Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: () => Navigator.pop(context),
                            ),
                            titleSpacing: -8,
                            title: Text(
                              "Deliver".tr() + ": ${currentOrder!.id}",
                              style: TextStyle(
                                  color: isDarkMode(context)
                                      ? Color(0xffFFFFFF)
                                      : Color(0xff000000),
                                  fontFamily: "Poppinsr",
                                  letterSpacing: 0.5),
                            ),
                            centerTitle: false,
                          ),
                          body: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                          color: Colors.grey.shade100,
                                          width: 0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 2.0,
                                          spreadRadius: 0.4,
                                          offset: Offset(0.2, 0.2),
                                        ),
                                      ],
                                      color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DELIVER'.tr().toUpperCase(),
                                            style: TextStyle(
                                                color: Color(0xff9091A4),
                                                fontFamily: "Poppinsr",
                                                letterSpacing: 0.5),
                                          ),
                                          TextButton.icon(
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  side: BorderSide(
                                                      color: Color(0xff3DAE7D)),
                                                ),
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(85, 30),
                                                alignment: Alignment.center,
                                                backgroundColor:
                                                    Color(0xffFFFFFF),
                                              ),
                                              onPressed: () {
                                                UrlLauncher.launchUrl(Uri.parse(
                                                    "tel://${currentOrder!.author.phoneNumber}"));
                                              },
                                              icon: Image.asset(
                                                'assets/images/call3x.png',
                                                height: 14,
                                                width: 14,
                                              ),
                                              label: Text(
                                                "CALL".tr().toUpperCase(),
                                                style: TextStyle(
                                                    color: Color(0xff3DAE7D),
                                                    fontFamily: "Poppinsm",
                                                    letterSpacing: 0.5),
                                              )),
                                        ],
                                      ),
                                      Text(
                                        '${currentOrder!.author.shippingAddress.name}',
                                        style: TextStyle(
                                            color: Color(0xff333333),
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${currentOrder!.author.shippingAddress.line1},'
                                          '${currentOrder!.author.shippingAddress.line2},'
                                          '${currentOrder!.author.shippingAddress.city}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xff9091A4),
                                              fontFamily: "Poppinsr",
                                              letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 28),
                                Text(
                                  "ITEMS".tr().toUpperCase(),
                                  style: TextStyle(
                                      color: Color(0xff9091A4),
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5),
                                ),
                                SizedBox(height: 24),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: currentOrder!.products.length,
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
                                                        '${currentOrder!.products[index].photo}',
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                        )),
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        currentOrder!
                                                                    .products[
                                                                        index]
                                                                    .item ==
                                                                "grocery"
                                                            ? currentOrder!
                                                                    .products[
                                                                        index]
                                                                    .name +
                                                                "(${currentOrder!.products[index].groceryWeight}${currentOrder!.products[index].groceryUnit})"
                                                            : currentOrder!
                                                                .products[index]
                                                                .name,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppinsr',
                                                            letterSpacing: 0.5,
                                                            color: isDarkMode(
                                                                    context)
                                                                ? Color(
                                                                    0xffFFFFFF)
                                                                : Color(
                                                                    0xff333333)),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.close,
                                                            size: 15,
                                                            color: Color(
                                                                COLOR_PRIMARY),
                                                          ),
                                                          Text(
                                                              '${currentOrder!.products[index].quantity}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppinsm',
                                                                letterSpacing:
                                                                    0.5,
                                                                color: Color(
                                                                    COLOR_PRIMARY),
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
                                Obx(() => Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Color(0xffC2C4CE)),
                                          color: Colors.white),
                                      child: ListTile(
                                        minLeadingWidth: 20,
                                        onTap: () {
                                          setState(() {
                                            _value.value = !_value.value;
                                          });
                                          print(
                                              'HomeScreenState.completePickUp${_value}');
                                        },
                                        selected: _value.value,
                                        leading: _value.value
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
                                          "Given".tr() +
                                              " ${currentOrder!.products.length} " +
                                              "item to customer".tr(),
                                          style: TextStyle(
                                              color: Color(0xff3DAE7D),
                                              fontFamily: 'Poppinsm',
                                              letterSpacing: 0.5),
                                        ),
                                      ),
                                    )),
                                SizedBox(height: 26),
                              ],
                            ),
                          ),
                          bottomNavigationBar: Obx(() => _value.value
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 26),
                                  child: SizedBox(
                                    height: 45,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        backgroundColor: Color(COLOR_PRIMARY),
                                      ),
                                      child: Text(
                                        "MARK ORDER DELIVER".tr(),
                                        style: TextStyle(
                                          letterSpacing: 0.5,
                                          fontFamily: 'Poppinsm',
                                        ),
                                      ),
                                      onPressed: () => completeOrder(),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 26),
                                  child: SizedBox(
                                    height: 45,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        backgroundColor: Color(COLOR_PRIMARY),
                                      ),
                                      child: Text(
                                        "MARK ORDER DELIVER".tr(),
                                        style: TextStyle(
                                          letterSpacing: 0.5,
                                          fontFamily: 'Poppinsm',
                                        ),
                                      ),
                                      onPressed: () {
                                        final snackBar = SnackBar(
                                          content: Text('Please Confirm Order'),
                                        );

                                        // Find the ScaffoldMessenger in the widget tree and use it to show a SnackBar.
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                    ),
                                  ),
                                )),
                        ),
                      );
                    }
                  },
                  child: Text(
                    buttonText ?? "",
                    style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontFamily: "Poppinsm",
                        letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateAllDriversExceptCurrent(String orderModeid) async {
    // Assume _driverModel is your current user's driver model.
    final String currentUserId = _driverModel!.userID;
    final CollectionReference driversCollection =
        FirebaseFirestore.instance.collection('users');

    // Fetch all drivers except the current user.
    QuerySnapshot querySnapshot =
        await driversCollection.where('role', isEqualTo: 'driver').get();

    // Begin a batch update
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Iterate through each document (driver) and update the 'orderRequestData' to null if it matches the orderModeid.
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['orderRequestData'] != null &&
          data['orderRequestData']['id'] == orderModeid) {
        batch.update(doc.reference, {'orderRequestData': null});
      }
    }

    // Commit the batch update
    await batch.commit();
  }

  acceptOrder() async {
    print("user data ");
    audioPlayer.stop();
    OrderModel orderModel = _driverModel!.orderRequestData!;
    // loginapp();
    _driverModel!.orderRequestData = null;
    _driverModel!.inProgressOrderID = orderModel.id;

    await FireStoreUtils.updateCurrentUser(_driverModel!);
    updateAllDriversExceptCurrent(orderModel.id);

    orderModel.status = ORDER_STATUS_DRIVER_ACCEPTED;
    orderModel.driverID = _driverModel!.userID;
    orderModel.driver = _driverModel!;

    await FireStoreUtils.updateOrder(orderModel);

    await FireStoreUtils.sendFcmMessage(
        driverAccepted, orderModel.author.fcmToken);
    await FireStoreUtils.sendOneNotification(
      type: driverAccepted,
      token: orderModel.author.fcmToken,
    );
    await FireStoreUtils.sendOneNotification(
      type: driverAccepted,
      token: orderModel.vendor.fcmToken,
    );
    await FireStoreUtils.sendFcmMessage(
        driverAccepted, orderModel.vendor.fcmToken);
    setState(() {
      isShow = true;
    });
  }

  completeOrder() async {
    showProgress(context, 'Completing Delivery...'.tr(), false);
    currentOrder!.status = ORDER_STATUS_COMPLETED;
    updateWallateAmount(currentOrder!);
    await FireStoreUtils.updateOrder(currentOrder!);
    await FireStoreUtils.sendFcmMessage(
        driverCompleted, currentOrder!.author.fcmToken);
    await FireStoreUtils.sendOneNotification(
      type: driverCompleted,
      token: currentOrder!.author.fcmToken,
    );
    await FireStoreUtils.sendOneNotification(
      type: driverAccepted,
      token: currentOrder!.vendor.fcmToken,
    );
    await FireStoreUtils.sendFcmMessage(
        driverAccepted, currentOrder!.vendor.fcmToken);
    await FireStoreUtils.getFirestOrderOrNOt(currentOrder!).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmount(currentOrder!);
      }
    });
    Position? locationData = await getCurrentLocation();

    _driverModel!.inProgressOrderID = null;
    _driverModel!.location = UserLocation(
        latitude: locationData.latitude, longitude: locationData.longitude);
    await FireStoreUtils.updateCurrentUser(_driverModel!);
    hideProgress();
    _markers.clear();
    polyLines.clear();
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(locationData.latitude, locationData.longitude),
            zoom: 20,
            bearing: double.parse(_driverModel!.rotation.toString())),
      ),
    );
    setState(() {});
    Navigator.pop(context);
  }

  rejectOrder() async {
    audioPlayer.stop();
    OrderModel orderModel = _driverModel!.orderRequestData!;
    if (orderModel.rejectedByDrivers == null) {
      orderModel.rejectedByDrivers = [];
    }
    orderModel.rejectedByDrivers!.add(_driverModel!.userID);
    orderModel.status = ORDER_STATUS_DRIVER_REJECTED;
    await FireStoreUtils.updateOrder(orderModel);
    _driverModel!.orderRequestData = null;
    await FireStoreUtils.updateCurrentUser(_driverModel!);
  }

  getDirections() async {
    print("------>$currentOrder");
    if (currentOrder != null) {
      if (currentOrder!.status == ORDER_STATUS_SHIPPED) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          PointLatLng(
              currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));
        });

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(
              currentOrder!.vendor.latitude, currentOrder!.vendor.longitude),
          icon: destinationIcon!,
        );
        addPolyLine(polylineCoordinates);
      } else if (currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          PointLatLng(currentOrder!.author.shippingAddress.location.latitude,
              currentOrder!.author.shippingAddress.location.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
            markerId: const MarkerId('Driver'),
            infoWindow: const InfoWindow(title: "Driver"),
            position: LatLng(_driverModel!.location.latitude,
                _driverModel!.location.longitude),
            rotation: double.parse(_driverModel!.rotation.toString()),
            icon: taxiIcon!,
          );
        });

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: "Destination"),
          position: LatLng(
              currentOrder!.author.shippingAddress.location.latitude,
              currentOrder!.author.shippingAddress.location.longitude),
          icon: destinationIcon!,
        );
        addPolyLine(polylineCoordinates);
      }
    } else {
      if (_driverModel!.orderRequestData != null) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          PointLatLng(_driverModel!.orderRequestData!.vendor.latitude,
              _driverModel!.orderRequestData!.vendor.longitude),
          travelMode: TravelMode.driving,
        );

        print("----?${result.points}");
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        setState(() {
          _markers.remove("Driver");
          _markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position: LatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              icon: taxiIcon!,
              rotation: double.parse(_driverModel!.rotation.toString()));
        });

        _markers.remove("Destination");
        _markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(_driverModel!.orderRequestData!.vendor.latitude,
                _driverModel!.orderRequestData!.vendor.longitude),
            icon: destinationIcon!);
        addPolyLine(polylineCoordinates);
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(COLOR_PRIMARY),
      points: polylineCoordinates,
      width: 8,
      geodesic: true,
    );
    setState(() {
      polyLines[id] = polyline;
    });
    updateCameraLocation(
        polylineCoordinates.first, polylineCoordinates.last, _mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: source,
          zoom: 20,
          bearing: double.parse(_driverModel!.rotation.toString()),
        ),
      ),
    );
    // if (mapController == null) return;
    //
    // LatLngBounds bounds;
    //
    // if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
    //   bounds = LatLngBounds(southwest: destination, northeast: source);
    // } else if (source.longitude > destination.longitude) {
    //   bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    // } else if (source.latitude > destination.latitude) {
    //   bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    // } else {
    //   bounds = LatLngBounds(southwest: source, northeast: destination);
    // }
    //
    // CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    //
    // return checkCameraLocation(cameraUpdate, mapController);
  }

  OrderCretedRazorpayModal? ordercretedrazorpaymodal;
  String? razorpayKey;
  String? razorpaySecret;

  Future<void> getRazorpayCredentials() async {
    try {
      // Collection અને Document નું path આપો
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('razorpaySettings') // તમારા document નું ID નાખો
          .get();

      if (documentSnapshot.exists) {
        // Document માંથી data મેળવવું
        razorpayKey = documentSnapshot.get('razorpayKey');
        razorpaySecret = documentSnapshot.get('razorpaySecret');

        print('Razorpay Key: $razorpayKey');
        print('Razorpay Secret: $razorpaySecret');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching Razorpay credentials: $e');
    }
  }

  // loginapp() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text(("please wait")),
  //   ));
  //
  //   String keyId = razorpayKey.toString();
  //   String secret = razorpaySecret.toString();
  //   String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$secret'));
  //   final Map<String, dynamic> data = {
  //     "amount": razorpayamout * 100,
  //     "payment_capture": 1,
  //     "currency": "INR",
  //     "transfers": [
  //       {
  //         "account": MyAppState?.currentUser?.userBankDetails?.gstnumber ?? "",
  //         //Please replace with appropriate ID.
  //         "amount": razorpayamout * 100,
  //         "currency": "INR",
  //         "notes": {
  //           "branch": "Acme Corp Bangalore South",
  //           "name": MyAppState?.currentUser?.userBankDetails?.holderName ?? ""
  //         },
  //         "linked_account_notes": ["branch"],
  //         "on_hold": false,
  //         "on_hold_until": null
  //       }
  //     ]
  //   };
  //   // Convert 'billing' to a string
  //
  //   print("datadatadatadatadata${data}");
  //   final apiUrl = "https://api.razorpay.com/v1/orders";
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'authorization': basicAuth,
  //   };
  //   // Construct the request body
  //   final requestBody = json.encode(data);
  //
  //   // Make the API call using http.post
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: headers,
  //     body: requestBody,
  //   );
  //
  //   print("requestBody${requestBody}");
  //   print("responsefkglkfdlgkfdg${response}");
  //
  //   // Handle the response
  //
  //   if (response.statusCode == 200) {
  //     ordercretedrazorpaymodal =
  //         OrderCretedRazorpayModal.fromJson(json.decode(response.body));
  //     print("loginapp api sucessfuuly ");
  //
  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //     // Payment data to be stored
  //     Map<String, dynamic> paymentData = {
  //       "amount": razorpayamout,
  //       "payment_capture": 1,
  //       "currency": "INR",
  //       "transfers": [
  //         {
  //           "account":
  //               MyAppState?.currentUser?.userBankDetails?.holderName ?? "",
  //           "amount": razorpayamout,
  //           "currency": "INR",
  //           "notes": {
  //             "branch": "Acme Corp Bangalore South",
  //             "name":
  //                 MyAppState?.currentUser?.userBankDetails?.holderName ?? "",
  //           },
  //           "linked_account_notes": ["branch"],
  //           "on_hold": false,
  //           "on_hold_until": null,
  //         }
  //       ]
  //     };
  //
  //     // Adding the data to a Firestore collection (e.g., 'payments')
  //     await firestore
  //         .collection('razorpayLinkedAccountsPayments')
  //         .add(paymentData);
  //     setState(() {
  //       razorpayamout = 0.0;
  //     });
  //   } else {
  //     // errorresponse = ErrorResponse.fromJson(json.decode(response.body));
  //     print("sdsdfsdfsdfsdfsdf");
  //     print("sgssfsd${response.body}");
  //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //   content: Text((errorresponse?.error?.description ?? "")),
  //     // ));
  //   }
  // }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    print("------>");
    print(l1);
    print(l2);
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == 90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  // playSound() async {
  //   final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");
  //
  //   audioPlayer.setSourceBytes(path.buffer.asUint8List());
  //   audioPlayer.setReleaseMode(ReleaseMode.loop);
  //   //audioPlayer.setSourceUrl(url);
  //   audioPlayer.play(BytesSource(path.buffer.asUint8List()),
  //       volume: 15,
  //       ctx: AudioContext(
  //           android:
  //               AudioContextAndroid(contentType: AndroidContentType.music, isSpeakerphoneOn: true, stayAwake: true, usageType: AndroidUsageType.alarm, audioFocus: AndroidAudioFocus.gainTransient),
  //           iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: [])));
  // }
  playSound() async {
    print("audioplayer");
    await audioPlayer.setSource(
        AssetSource('audio/mixkit-happy-bells-notification-937.mp3'));
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(
      AssetSource('audio/mixkit-happy-bells-notification-937.mp3'),
      volume: 0.5,
      ctx: AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [],
        ),
      ),
    );
  }
}
