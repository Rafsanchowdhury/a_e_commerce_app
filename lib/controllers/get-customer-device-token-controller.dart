// ignore_for_file: avoid_print, file_names, unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> getCustomerDeviceToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      return token;
    } else {
      throw Exception("Error");
    }
  } catch (e) {
    print("Error $e");
    throw Exception("Error");
  }
}
