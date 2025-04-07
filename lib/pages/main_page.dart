import 'package:aadi/pages/auth/register_details_page.dart';
import 'package:aadi/pages/auth/sign_in_page.dart';
import 'package:aadi/pages/gallery_page.dart';
import 'package:aadi/pages/home_page.dart';
import 'package:aadi/pages/profile_page.dart';
import 'package:aadi/provider/main_page_provider.dart';
import 'package:aadi/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final auth = FirebaseAuth.instance;
  final store = FirebaseFirestore.instance;
  bool isCheckingDone = false;

  // INIT STATE
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checking();
    });
  }

  // CHECKING
  Future<void> checking() async {
    final user = auth.currentUser;
    print('user: ${user?.uid}');

    if (user == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
        (route) => false,
      );
    } else {
      final userSnap = await store.collection('Users').doc(user.uid).get();

      if (userSnap.exists) {
        final userData = userSnap.data()!;

        if (userData['Name'] == null || userData['Phone Number'] == null) {
          setState(() {
            isCheckingDone = true;
          });
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => RegisterDetailsPage(),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            isCheckingDone = true;
          });
        }
      } else {
        print('sending to sign in page');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SignInPage(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainPageProvider = Provider.of<MainPageProvider>(context);
    final loadedPages = mainPageProvider.loadedPages;
    final current = mainPageProvider.index;

    List<Widget> allPages = [
      const HomePage(),
      loadedPages.contains(0) ? const GalleryPage() : Container(),
      loadedPages.contains(0) ? const ProfilePage() : Container(),
    ];

    return Scaffold(
      body: !isCheckingDone
          ? Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: current,
              children: allPages,
            ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: primaryDark,
        ),
        useLegacyColorScheme: false,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(
          size: 24,
          color: primaryDark,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          color: black.withOpacity(0.5),
        ),
        currentIndex: current,
        onTap: (index) {
          mainPageProvider.changeIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.home,
            ),
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.grid_view_sharp,
            ),
            icon: Icon(
              Icons.grid_view_outlined,
            ),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.person,
            ),
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
