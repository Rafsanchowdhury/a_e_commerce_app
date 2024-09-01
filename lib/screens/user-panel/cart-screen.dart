// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:a_e_commerce_app/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: Text('Cart Screen'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 20,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              color: AppConstant.appTextColor,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppConstant.appMainColor,
                  child: Text("N"),
                ),
                title: Text("New Dress for Womens"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("2000"),
                    SizedBox(
                      width: Get.width / 20.0,
                    ),
                    CircleAvatar(
                      radius: 14.0,
                      backgroundColor: AppConstant.appMainColor,
                      child: Text('-'),
                    ),
                    SizedBox(
                      width: Get.width / 20.0,
                    ),
                    CircleAvatar(
                      radius: 14.0,
                      backgroundColor: AppConstant.appMainColor,
                      child: Text('+'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("   Total:"),
            Text(
              "BDT 12,00",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                child: Container(
                  width: Get.width / 2.0,
                  height: Get.height / 18,
                  decoration: BoxDecoration(
                    color: AppConstant.appScendaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextButton(
                    child: Text(
                      "Checkout",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
