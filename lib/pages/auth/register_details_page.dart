import 'package:aadi/pages/main_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:aadi/widgets/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterDetailsPage extends StatefulWidget {
  const RegisterDetailsPage({
    super.key,
  });

  @override
  State<RegisterDetailsPage> createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String countryCode = '+91';
  bool isLoading = true;
  bool isDialog = false;

  // INIT STATE
  @override
  void initState() {
    getData();
    super.initState();
  }

  // GET DATA
  Future<void> getData() async {
    final userSnap =
        await store.collection('Users').doc(auth.currentUser!.uid).get();
    final userData = userSnap.data()!;

    if (userData['Name'] != null) {
      nameController.text = userData['Name'];
    }
    if (userData['Phone Number'] != null) {
      phoneNumberController.text = userData['Phone Number'];
    }

    setState(() {
      isLoading = false;
    });
  }

  // NEXT
  Future<void> next() async {
    if (nameController.text.isEmpty) {
      return mySnackBar(
        context,
        'Please enter your name',
      );
    }
    if (phoneNumberController.text.isEmpty) {
      return mySnackBar(
        context,
        'Please enter your phone number',
      );
    }

    setState(() {
      isDialog = true;
    });

    await store.collection('Users').doc(auth.currentUser!.uid).update({
      'Name': nameController.text,
      'Phone Number': '$countryCode${phoneNumberController.text}',
    });

    setState(() {
      isDialog = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDialog ? false : true,
      child: ModalProgressHUD(
        inAsyncCall: isDialog,
        color: primaryDark,
        blur: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Registration Details'),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      return Padding(
                        padding: EdgeInsets.all(width * 0.02250),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyTextField(
                                hintText: 'Name',
                                controller: nameController,
                                verticalPadding: 12,
                              ),
                              IntlPhoneField(
                                initialCountryCode: 'IN',
                                autofocus: false,
                                onCountryChanged: (value) {
                                  setState(() {
                                    countryCode = value.code;
                                  });
                                },
                                controller: phoneNumberController,
                                keyboardType: TextInputType.numberWithOptions(),
                                cursorColor: primaryDark,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: primaryDark,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              MyButton(
                                  text: 'NEXT',
                                  onTap: () async {
                                    await next();
                                  }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
