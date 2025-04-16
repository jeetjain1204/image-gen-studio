import 'package:aadi/pages/auth/sign_in_page.dart';
import 'package:aadi/widgets/profile_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const SignInPage(),
                ),
                (route) => false,
              );
            },
            color: Colors.red,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: width * 0.2,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: auth.currentUser?.photoURL != null
                          ? NetworkImage(auth.currentUser!.photoURL!)
                          : null,
                      // child: const Icon(
                      //   Icons.person,
                      //   size: 100,
                      //   color: Colors.white,
                      // ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    auth.currentUser?.displayName ?? 'User Name',
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    auth.currentUser?.email ?? 'Email',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                  ProfileContainer(
                    width: width,
                    text: 'Your Gallery',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
