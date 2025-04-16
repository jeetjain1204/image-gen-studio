import 'package:aadi/pages/auth/register_details_page.dart';
import 'package:aadi/pages/main_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/widgets/my_button.dart';
import 'package:aadi/widgets/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isDialog = false;

  // SIGN IN
  Future<void> signIn() async {
    try {
      setState(() {
        isDialog = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print(1);

      final userCredential = await auth.signInWithCredential(credential);
      print('userCredential: ${userCredential.user!.displayName}');

      print(2);
      if (auth.currentUser != null) {
        print(101);

        print(102);
        if (!userCredential.additionalUserInfo!.isNewUser) {
          if (mounted) {
            setState(() {
              isDialog = false;
            });
            print(1003);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
              (route) => false,
            );
            return mySnackBar(
              context,
              'Signed In',
            );
          }
        } else {
          print(11);
          await store.collection('Users').doc(auth.currentUser!.uid).set({
            'Name': auth.currentUser!.displayName,
            'Email': auth.currentUser!.email,
            'Phone Number': auth.currentUser!.phoneNumber,
            'Profile Image': auth.currentUser!.photoURL,
          });
          print(12);
          setState(() {
            isDialog = false;
          });
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const RegisterDetailsPage(),
            ),
            (route) => false,
          );
        }
      } else {
        print(3);
        setState(() {
          isDialog = false;
        });
        if (mounted) {
          return mySnackBar(
            context,
            'Some error occured\nTry signing with Email / Phone Number',
          );
        }
      }
    } catch (e) {
      setState(() {
        isDialog = false;
      });
      if (mounted) {
        print(e.toString());
        return mySnackBar(context, 'Error: ${e.toString()}');
      }
    }
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
            title: const Text('Sign In'),
          ),
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.085,
              child: MyButton(
                text: 'Sign In With Google',
                onTap: () async {
                  await signIn();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
