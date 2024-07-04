import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodie_driver/ui/home/pick_order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../constants.dart';
import '../../model/OrderModel.dart';
import '../../model/User.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/helper.dart';
import '../chat_screen/chat_screen.dart';

class OrderActionScreeen extends StatefulWidget {
  final OrderModel? currentOrder;

  const OrderActionScreeen({super.key, this.currentOrder});

  @override
  State<OrderActionScreeen> createState() => _OrderActionScreeenState();
}

bool _value = false;
User? _driverModel = User();
Map<PolylineId, Polyline> polyLines = {};
PolylinePoints polylinePoints = PolylinePoints();
final Map<String, Marker> _markers = {};
GoogleMapController? _mapController;

class _OrderActionScreeenState extends State<OrderActionScreeen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildOrderActionsCard(),
    );
  }

  Widget buildOrderActionsCard() {
    late String title;
    String? buttonText;
    if (widget.currentOrder!.status == ORDER_STATUS_SHIPPED ||
        widget.currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED) {
      title = '${widget.currentOrder!.vendor.title}';
      buttonText = 'REACHED STORE FOR PICKUP'.tr();
    } else if (widget.currentOrder!.status == ORDER_STATUS_IN_TRANSIT) {
      title = 'Deliver to {}'
          .tr(args: ['${widget.currentOrder!.author.firstName}']);
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
            if (widget.currentOrder!.status == ORDER_STATUS_SHIPPED ||
                widget.currentOrder!.status == ORDER_STATUS_DRIVER_ACCEPTED)
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
                        '${widget.currentOrder!.vendor.location}',
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
                              "tel://${widget.currentOrder!.vendor.phonenumber}"));
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
                            '${widget.currentOrder!.id}',
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
                        '${widget.currentOrder!.author.shippingAddress.name}',
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
            if (widget.currentOrder!.status == ORDER_STATUS_IN_TRANSIT)
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
                      '${widget.currentOrder!.author.shippingAddress.name}',
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
                              '${widget.currentOrder!.id} ',
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
                                  "tel://${widget.currentOrder!.author.phoneNumber}"));
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
                        '${widget.currentOrder!.author.shippingAddress.line1},${widget.currentOrder!.author.shippingAddress.line2},${widget.currentOrder!.author.shippingAddress.city},${widget.currentOrder!.author.shippingAddress.country}',
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
                    if (widget.currentOrder!.status == ORDER_STATUS_SHIPPED ||
                        widget.currentOrder!.status ==
                            ORDER_STATUS_DRIVER_ACCEPTED) {
                      push(
                        context,
                        PickOrder(currentOrder: widget.currentOrder),
                      );
                    } else if (widget.currentOrder!.status ==
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
                              "Deliver".tr() + ": ${widget.currentOrder!.id}",
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
                                                    "tel://${widget.currentOrder!.author.phoneNumber}"));
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
                                        '${widget.currentOrder!.author.shippingAddress.name}',
                                        style: TextStyle(
                                            color: Color(0xff333333),
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${widget.currentOrder!.author.shippingAddress.line1},'
                                          '${widget.currentOrder!.author.shippingAddress.line2},'
                                          '${widget.currentOrder!.author.shippingAddress.city}',
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
                                    itemCount:
                                        widget.currentOrder!.products.length,
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
                                                        '${widget.currentOrder!.products[index].name}',
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
                                                              '${widget.currentOrder!.products[index].quantity}',
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
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _value = !_value;
                                    });
                                    print(
                                        'HomeScreenState.completePickUp${_value}');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Color(0xffC2C4CE)),
                                        color: Colors.white),
                                    child: ListTile(
                                      minLeadingWidth: 20,
                                      onTap: () {
                                        setState(() {
                                          _value = !_value;
                                        });
                                        print(
                                            'HomeScreenState.completePickUp${_value}');
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
                                        "Given".tr() +
                                            " ${widget.currentOrder!.products.length} " +
                                            "item to customer".tr(),
                                        style: TextStyle(
                                            color: Color(0xff3DAE7D),
                                            fontFamily: 'Poppinsm',
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 26),
                              ],
                            ),
                          ),
                          bottomNavigationBar: Padding(
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
                          ),
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

  openChatWithCustomer() async {
    await showProgress(context, "Please wait".tr(), false);

    User? customer =
        await FireStoreUtils.getCurrentUser(widget.currentOrder!.authorID);
    print(widget.currentOrder!.driverID);
    User? driver = await FireStoreUtils.getCurrentUser(
        widget.currentOrder!.driverID.toString());

    hideProgress();
    push(
        context,
        ChatScreens(
          customerName: customer!.firstName + " " + customer.lastName,
          restaurantName: driver!.firstName + " " + driver.lastName,
          orderId: widget.currentOrder!.id,
          restaurantId: driver.userID,
          customerId: customer.userID,
          customerProfileImage: customer.profilePictureURL,
          restaurantProfileImage: driver.profilePictureURL,
          token: customer.fcmToken,
          chatType: 'Driver',
        ));
  }

  completeOrder() async {
    showProgress(context, 'Completing Delivery...'.tr(), false);
    widget.currentOrder!.status = ORDER_STATUS_COMPLETED;
    updateWallateAmount(widget.currentOrder!);
    await FireStoreUtils.updateOrder(widget.currentOrder!);
    await FireStoreUtils.sendFcmMessage(
        driverCompleted, widget.currentOrder!.author.fcmToken);
    await FireStoreUtils.sendFcmMessage(
        driverAccepted, widget.currentOrder!.vendor.fcmToken);
    await FireStoreUtils.getFirestOrderOrNOt(widget.currentOrder!)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmount(widget.currentOrder!);
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
}
