import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/model/AddressModel.dart';
import 'package:foodie_driver/model/OrderModel.dart';

class User with ChangeNotifier {
  String email;

  String firstName;

  String lastName;

  UserSettings settings;

  String phoneNumber;

  bool isActive;
  bool active;

  Timestamp? lastOnlineTimestamp;
  Timestamp? createdAt;

  String userID;

  String profilePictureURL;

  String appIdentifier;

  String fcmToken;

  UserLocation location;

  AddressModel shippingAddress;

  String role;

  String carName;

  String carNumber;

  String carPictureURL;

  String? inProgressOrderID;

  OrderModel? orderRequestData;
  UserBankDetails userBankDetails;

  num walletAmount;
  num? rotation;

  User(
      {this.email = '',
      this.userID = '',
      this.profilePictureURL = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.isActive = false,
      this.active = true,
      lastOnlineTimestamp,
      settings,
      this.fcmToken = '',
      location,
      shippingAddress,
      geoFireData,
      coordinates,
      this.rotation,
      this.role = USER_ROLE_DRIVER,
      this.carName = 'Uber Car',
      this.carNumber = 'No Plates',
      this.carPictureURL = DEFAULT_CAR_IMAGE,
      this.inProgressOrderID,
      this.walletAmount = 0.0,
      userBankDetails,
      this.createdAt,
      this.orderRequestData})
      : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.appIdentifier = 'Grubb Bolt${Platform.operatingSystem}',
        this.shippingAddress = shippingAddress ?? AddressModel(),
        this.userBankDetails = userBankDetails ?? UserBankDetails(),
        this.location = location ?? UserLocation();

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        rotation: parsedJson['rotation'] ?? 0.0,
        userBankDetails: parsedJson.containsKey('userBankDetails')
            ? UserBankDetails.fromJson(parsedJson['userBankDetails'])
            : UserBankDetails(),
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        isActive: parsedJson['isActive'] ?? false,
        active: parsedJson['active'] ?? true,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        settings: parsedJson.containsKey('settings')
            ? UserSettings.fromJson(parsedJson['settings'])
            : UserSettings(),
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location')
            ? UserLocation.fromJson(parsedJson['location'])
            : UserLocation(),
        shippingAddress: parsedJson.containsKey('shippingAddress')
            ? AddressModel.fromJson(parsedJson['shippingAddress'])
            : AddressModel(),
        role: parsedJson['role'] ?? '',
        carName: parsedJson['carName'] ?? '',
        carNumber: parsedJson['carNumber'] ?? '',
        carPictureURL: parsedJson['carPictureURL'] ?? '',
        inProgressOrderID: parsedJson['inProgressOrderID'],
        createdAt: parsedJson['createdAt'],
        orderRequestData: parsedJson.containsKey('orderRequestData') &&
                parsedJson['orderRequestData'] != null
            ? OrderModel.fromJson(parsedJson['orderRequestData'])
            : null);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'wallet_amount': this.walletAmount,
      "userBankDetails": this.userBankDetails.toJson(),
      'id': this.userID,
      'isActive': this.isActive,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'shippingAddress': this.shippingAddress.toJson(),
      'role': this.role,
      'createdAt': this.createdAt,
      'orderRequestData': this.orderRequestData != null
          ? this.orderRequestData!.toJson()
          : null,
    };
    if (this.role == USER_ROLE_DRIVER) {
      json.addAll({
        'role': this.role,
        'carName': this.carName,
        'carNumber': this.carNumber,
        'carPictureURL': this.carPictureURL,
        'rotation': this.rotation,
      });
    }
    if (this.inProgressOrderID != null) {
      json.addAll({'inProgressOrderID': this.inProgressOrderID});
    }
    return json;
  }
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  UserSettings(
      {this.pushNewMessages = true,
      this.orderUpdates = true,
      this.newArrivals = true,
      this.promotions = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      orderUpdates: parsedJson['orderUpdates'] ?? true,
      newArrivals: parsedJson['newArrivals'] ?? true,
      promotions: parsedJson['promotions'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
    };
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserLocation(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String businessname;
  String businesstype;
  String pancard;
  String holderName;
  String accountNumber;
  String otherDetails;
  String gstnumber;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.businessname = '',
    this.accountNumber = '',
    this.holderName = '',
    this.businesstype = '',
    this.gstnumber = '',
    this.pancard = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      businessname: parsedJson['businessname'] ?? '',
      pancard: parsedJson['pancard'] ?? '',
      gstnumber: parsedJson['gstnumber'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
      businesstype: parsedJson['businesstype'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': this.bankName,
      'branchName': this.branchName,
      'holderName': this.holderName,
      'accountNumber': this.accountNumber,
      'pancard': this.pancard,
      'gstnumber': this.gstnumber,
      'otherDetails': this.otherDetails,
      'businessname': this.businessname,
      'legalbusinessname': this.businesstype,
    };
  }
}
