// ignore_for_file: file_names

import 'dart:math';

String genrateOrderId() {
  DateTime now = DateTime.now();

  int randomNumbers = Random().nextInt(99999);

  String id = '${now.microsecondsSinceEpoch}_$randomNumbers';

  return id;
}
