// ignore: file_names
// ignore_for_file: prefer_const_constructors, file_names, duplicate_ignore, prefer_const_literals_to_create_immutables, unused_local_variable

import 'package:a_e_commerce_app/screens/auth-ui/welcome-screen.dart';
import 'package:a_e_commerce_app/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: Text(AppConstant.appMainName),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();

              await googleSignIn.signOut();
              Get.offAll(() => WelcomeScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.logout),
            ),
          )
        ],
      ),
    );
  }
}
