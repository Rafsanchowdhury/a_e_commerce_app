// ignore_for_file: file_names, must_be_immutable, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unused_local_variable, avoid_print

import 'package:a_e_commerce_app/models/cart-model.dart';
import 'package:a_e_commerce_app/models/product-model.dart';
import 'package:a_e_commerce_app/utils/app-constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatefulWidget {
  ProductModel productModel;
  ProductDetailsScreen({super.key, required this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: Text("Product Details"),
      ),
      body: Container(
        child: Column(children: [
          // Product images
          SizedBox(
            height: Get.height / 60,
          ),
          CarouselSlider(
            items: widget.productModel.productImages
                .map(
                  (imageUrls) => ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrls,
                      fit: BoxFit.cover,
                      width: Get.width - 10,
                      placeholder: (context, url) => ColoredBox(
                        color: Colors.white,
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                )
                .toList(),
            options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              aspectRatio: 2.5,
              viewportFraction: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.productModel.productName,
                          ),
                          Icon(Icons.favorite_outline)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          widget.productModel.isSale == true &&
                                  widget.productModel.salePrice != ''
                              ? Text(
                                  "BDT: " + widget.productModel.salePrice,
                                )
                              : Text(
                                  "BDT: " + widget.productModel.fullPrice,
                                ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Category: " + widget.productModel.categoryName,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Description: " +
                            widget.productModel.productDescription,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          child: Container(
                            width: Get.width / 3.0,
                            height: Get.height / 16,
                            decoration: BoxDecoration(
                              color: AppConstant.appScendaryColor,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextButton(
                              child: Text(
                                "WhatsApp",
                                style:
                                    TextStyle(color: AppConstant.appTextColor),
                              ),
                              onPressed: () {
                                // Get.to(() => SignInScreen());
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Material(
                          child: Container(
                            width: Get.width / 3.0,
                            height: Get.height / 16,
                            decoration: BoxDecoration(
                              color: AppConstant.appScendaryColor,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextButton(
                              child: Text(
                                "Add to cart",
                                style:
                                    TextStyle(color: AppConstant.appTextColor),
                              ),
                              onPressed: () async {
                                // Get.to(() => SignInScreen());
                                await checkProductExistance(uId: user!.uid);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  // check  product exits or not
  Future<void> checkProductExistance({
    required String uId,
    int quantityIncrement = 1,
  }) async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(uId)
        .collection('cartOrders')
        .doc(widget.productModel.productId.toString());

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int currentQuantty = snapshot['productQuantity'];
      int updatedQuantity = currentQuantty + quantityIncrement;
      double totalPrice = double.parse(widget.productModel.isSale
              ? widget.productModel.salePrice
              : widget.productModel.fullPrice) *
          updatedQuantity;
      await documentReference.update({
        'productQuantity': updatedQuantity,
        'productTotalPrice': totalPrice
      });
      print("Product exists");
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(uId).set(
        {
          'uId': uId,
          'createdAt': DateTime.now(),
        },
      );
      CartModel cartModel = CartModel(
        productId: widget.productModel.productId,
        categoryId: widget.productModel.categoryId,
        productName: widget.productModel.productName,
        categoryName: widget.productModel.categoryName,
        salePrice: widget.productModel.salePrice,
        fullPrice: widget.productModel.fullPrice,
        productImages: widget.productModel.productImages,
        deliveryTime: widget.productModel.deliveryTime,
        isSale: widget.productModel.isSale,
        productDescription: widget.productModel.productDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productQuantity: 1,
        productTotalPrice: double.parse(widget.productModel.isSale
            ? widget.productModel.salePrice
            : widget.productModel.fullPrice),
      );

      await documentReference.set(cartModel.toMap());

      print("Product added");
    }
  }
}
