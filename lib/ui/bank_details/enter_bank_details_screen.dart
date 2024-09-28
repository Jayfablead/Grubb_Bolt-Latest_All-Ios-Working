import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/ErrorResponse.dart';
import 'package:foodie_driver/model/ProducatErrorResponseModal.dart';
import 'package:foodie_driver/model/RazorUpdateProductModal.dart';
import 'package:foodie_driver/model/RazorproductsModal.dart';
import 'package:foodie_driver/model/StackholderErrorResponseModal.dart';
import 'package:foodie_driver/model/StakeholdersModal.dart';
import 'package:foodie_driver/model/UpdateProducatErrorResponseModal.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart'as http;

import '../../model/RazorAddBankModal.dart';

class EnterBankDetailScreen extends StatefulWidget {
  final bool isNewAccount;

  const EnterBankDetailScreen({Key? key, required this.isNewAccount})
      : super(key: key);

  @override
  State<EnterBankDetailScreen> createState() => _EnterBankDetailScreenState();
}

class _EnterBankDetailScreenState extends State<EnterBankDetailScreen> {
  User? user;

  GlobalKey<FormState> _bankDetailFormKey = GlobalKey();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController otherInfoController = TextEditingController();
  final Uuid _uuid = Uuid();
  String _uniqueId = '';
  String generateRandomEmail() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();

    // Generate random username (part before '@')
    String username = List.generate(8, (index) => chars[random.nextInt(chars.length)]).join('');

    // Generate random domain (part after '@')
    String domain = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join('');

    return '$username@$domain.com';
  }
  void _generateUniqueId() {
    setState(() {
      _uniqueId = _uuid.v4().substring(0, 4); // Take the first 4 characters
      print("_uniqueId: $_uniqueId");
    });
  }
  String randomEmail="";
  @override
  void initState() {
    super.initState();
    _generateUniqueId();
    randomEmail = generateRandomEmail();
    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;

        bankNameController =
            TextEditingController(text: user!.userBankDetails.bankName);
        branchNameController =
            TextEditingController(text: user!.userBankDetails.branchName);
        holderNameController =
            TextEditingController(text: user!.userBankDetails.holderName);
        accountNoController =
            TextEditingController(text: user!.userBankDetails.accountNumber);
        otherInfoController =
            TextEditingController(text: user!.userBankDetails.otherDetails);
      });
    });
    //user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
            ),
          ),
          title: Text(
            widget.isNewAccount ? "Add Bank".tr() : "Edit Bank".tr(),
            style: TextStyle(
                color: isDarkMode(context) ? Colors.white : Colors.black),
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          child: Form(
            key: _bankDetailFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  buildTextFiled(
                      validator: validateName,
                      title: "Bank Name".tr(),
                      controller: bankNameController),
                  buildTextFiled(
                      validator: validateOthers,
                      title: "Ifsc code".tr(),
                      controller: branchNameController),
                  buildTextFiled(
                      validator: validateOthers,
                      title: "Holder Name".tr(),
                      controller: holderNameController),
                  buildTextFiled(
                      validator: validateOthers,
                      title: "Account Number".tr(),
                      controller: accountNoController),
                  buildTextFiled(
                      validator: (String? value) {
                        return null;
                      },
                      title: "Other Information".tr(),
                      controller: otherInfoController),
                  Padding(
                    padding: const EdgeInsets.only(top: 45.0, bottom: 25),
                    child: buildButton(context,
                        title: widget.isNewAccount
                            ? "Add Bank".tr()
                            : "Edit Bank".tr(), onPress: () async {
                      if (_bankDetailFormKey.currentState!.validate()) {
                        loginapp();
                        print("----<");
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFiled(
      {required title,
      required String? Function(String?)? validator,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validator,
              controller: controller,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    new EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                fillColor: isDarkMode(context)
                    ? Color(DARK_CARD_BG_COLOR)
                    : Colors.black.withOpacity(0.06),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide:
                        BorderSide(color: Color(COLOR_PRIMARY), width: 1.50)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildButton(context, {required String title, required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.8,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Color(COLOR_PRIMARY),
        height: 45,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 19, color: Colors.white),
        ),
      ),
    );
  }
  loginapp() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(("please wait")),
    ));

    String keyId = 'rzp_live_aiiEEnXaiz5Rp1';
    String secret = '4S1VTjOF4jDmN0o85vQbScPL';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$secret'));
    final Map<String, dynamic> data = {

    // "email":widget.isNewAccount=="Edit Bank"?randomEmail:MyAppState?.currentUser?.email==null||MyAppState?.currentUser?.email==""?randomEmail:MyAppState?.currentUser?.email ?? "",
      "email":"abc123456@gmail.com",
      "phone":MyAppState?.currentUser?.phoneNumber ?? "",
      "type":"route",
      "reference_id":_uniqueId,
      "legal_business_name":holderNameController.text.trim().toString(),
      "business_type":"partnership",
      "contact_name":MyAppState?.currentUser?.firstName ?? "",
      "profile":{
        "category":"healthcare",
        "subcategory":"clinic",
        "addresses":{
          "registered":{
            "street1":"507, fghdfgdfgdfg 1st block",
            "street2":"MG Road",
            "city":"Surat",
            "state":"Karnataka",
            "postal_code":"560034",
            "country":"Gujarat",

          }
        }
      },
      // "legal_info":{
      //   // "pan":pancard.text.toString(),
      //   "pan":"AAACL1234C",
      //   "gst":gstnumber.text.trim().toString()
      // }

    };
    // Convert 'billing' to a string

    print(data);
    final apiUrl = "https://api.razorpay.com/v2/accounts";


    final headers = {
      'Content-Type': 'application/json',
      'authorization':basicAuth,

    };
    // Construct the request body
    final requestBody = json.encode(data);

    // Make the API call using http.post
    final response = await http.post(
      Uri.parse(apiUrl),
      headers:headers,
      body: requestBody,
    );


    print("responsefkglkfdlgkfdg${response}");


    // Handle the response

    if (response.statusCode == 200) {
      razoraddbankmodal = RazorAddBankModal.fromJson(json.decode(response.body));
      print("loginapp api sucessfuuly ");
      stakeholders(razoraddbankmodal?.id ?? "");


    } else {
      errorresponse = ErrorResponse.fromJson(json.decode(response.body));
      print("sdsdfsdfsdfsdfsdf");
      print("sgssfsd${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((errorresponse?.error?.description ?? "")),
      ));
    }
  }
  StackholderErrorResponseModal? stackholdererrorresponsemodal;
  stakeholders(String id) async {
    String keyId = 'rzp_live_aiiEEnXaiz5Rp1';
    String secret = '4S1VTjOF4jDmN0o85vQbScPL';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$secret'));
    final Map<String, dynamic> data = {


      "name":holderNameController.text.trim().toString(),
      "email":MyAppState?.currentUser?.email ?? "",
      "addresses":{
        "residential":{
          "street":"507, fghdfgdfgdfg 1st block",
          "city":"Surat",
          "state":"Karnataka",
          "postal_code":"560034",
          "country":"IN"

        }
      },
      // "kyc":{
      //   // "pan":"CGCPM8368K",
      //   "pan":pancard.text.trim().toString(),
      // },
      "notes":{
        "random_key":"random_value"
      }

    };
    // Convert 'billing' to a string

    print(data);
    final apiUrl = "https://api.razorpay.com/v2/accounts/${id}/stakeholders";
    print("apiUrl${apiUrl}");

    final headers = {
      'Content-Type': 'application/json',
      'authorization':basicAuth,

    };
    // Construct the request body
    final requestBody = json.encode(data);

    // Make the API call using http.post
    final response = await http.post(
      Uri.parse(apiUrl),
      headers:headers,
      body: requestBody,
    );


    print("responsefkglkfdlgkfdg${response}");


    // Handle the response

    if (response.statusCode == 200) {
      stakeholdersmodal = StakeholdersModal.fromJson(json.decode(response.body));
      print("stakeholders api sucessfuuly ");


      producatui(razoraddbankmodal?.id ?? "");

    } else {
      stackholdererrorresponsemodal = StackholderErrorResponseModal.fromJson(json.decode(response.body));
      print("sdsdfsdfsdfsdfsdf");
      print("sgssfsd${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((stackholdererrorresponsemodal?.error?.description ?? "")),
      ));
      print("jay lo gando${response.body}");
    }
  }
  ProducatErrorResponseModal? producaterrorresponsemodal;
  producatui(String id) async {
    String keyId = 'rzp_live_aiiEEnXaiz5Rp1';
    String secret = '4S1VTjOF4jDmN0o85vQbScPL';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$secret'));
    final Map<String, dynamic> data = {


      "product_name":"route",
      "tnc_accepted":true

    };
    // Convert 'billing' to a string

    print(data);
    final apiUrl = "https://api.razorpay.com/v2/accounts/${id}/products";


    final headers = {
      'Content-Type': 'application/json',
      'authorization':basicAuth,

    };
    // Construct the request body
    final requestBody = json.encode(data);

    // Make the API call using http.post
    final response = await http.post(
      Uri.parse(apiUrl),
      headers:headers,
      body: requestBody,
    );


    print("responsefkglkfdlgkfdg${response}");


    // Handle the response

    if (response.statusCode == 200) {
      razorproductsmodal = RazorproductsModal.fromJson(json.decode(response.body));

      print("ram mer urfe zabalu ${response.body}");
      updateproducatui(razoraddbankmodal?.id ?? "",razorproductsmodal?.id ?? "");

    } else {
      producaterrorresponsemodal = ProducatErrorResponseModal.fromJson(json.decode(response.body));
      print("sdsdfsdfsdfsdfsdf");
      print("sgssfsd${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((producaterrorresponsemodal?.error?.description ?? "")),
      ));
      print("ram mer urfe zabalu ${response.body}");
    }
  }
  UpdateProducatErrorResponseModal? updateproducaterrorresponsemodal;
  updateproducatui(String acid,String pid) async {
    String keyId = 'rzp_live_aiiEEnXaiz5Rp1';
    String secret = '4S1VTjOF4jDmN0o85vQbScPL';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$secret'));
    final Map<String, dynamic> data = {
      "settlements": {
        "account_number": accountNoController?.text.trim().toString(),
        "ifsc_code":branchNameController.text.trim().toString(),
        "beneficiary_name":holderNameController.text.trim().toString()
      },
      "tnc_accepted": true
    };
    // Convert 'billing' to a string

    print(data);
    final apiUrl = "https://api.razorpay.com/v2/accounts/${acid}/products/${pid}";
    print("apiUrlapiUrlapiUrl${apiUrl}");


    final headers = {
      'Content-Type': 'application/json',
      'authorization':basicAuth,

    };
    // Construct the request body
    final requestBody = json.encode(data);

    // Make the API call using http.post
    final response = await http.patch(
      Uri.parse(apiUrl),
      headers:headers,
      body: requestBody,
    );


    print("responsefkglkfdlgkfdg${response}");


    // Handle the response

    if (response.statusCode == 200) {
      razorupdateproductmodal = RazorUpdateProductModal.fromJson(json.decode(response.body));
      print("ram mer urfe zabalu hali gau che ${response.body}");

      print("----<");
      user!.userBankDetails.accountNumber =
          accountNoController.text;
      print("----<");
      print(user!.userBankDetails.accountNumber);
      user!.userBankDetails.bankName =
          bankNameController.text;
      user!.userBankDetails.branchName =
          branchNameController.text;
      user!.userBankDetails.holderName =
          holderNameController.text;
      user!.userBankDetails.otherDetails =
          otherInfoController.text;
      user!.userBankDetails.otherDetails =otherInfoController.text;
      user!.userBankDetails.pancard ="";
      user!.userBankDetails.gstnumber =razoraddbankmodal?.id ?? "";
      user!.userBankDetails.businessname ="";
      user!.userBankDetails.businesstype ="";

      var updatedUser =
      await FireStoreUtils.updateCurrentUser(user!);
      if (updatedUser != null) {
        MyAppState.currentUser = updatedUser;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Bank Details saved successfully'.tr(),
              style: TextStyle(fontSize: 17),
            ).tr()));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "notSaveDetailsTryAgain",
              style: TextStyle(fontSize: 17),
            ).tr()));
        Navigator.pop(context, false);
      }

    } else {
      updateproducaterrorresponsemodal = UpdateProducatErrorResponseModal.fromJson(json.decode(response.body));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((updateproducaterrorresponsemodal?.error?.description ?? "")),
      ));
      print("haresh mer ${response.body}");
    }
  }
  StakeholdersModal? stakeholdersmodal;
  ErrorResponse? errorresponse;
  final _formKey = GlobalKey<FormState>();
  RazorAddBankModal? razoraddbankmodal;
  RazorproductsModal? razorproductsmodal;
  RazorUpdateProductModal? razorupdateproductmodal;
}
