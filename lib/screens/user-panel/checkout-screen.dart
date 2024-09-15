// ignore_for_file: avoid_print, sized_box_for_whitespace, sort_child_properties_last

import 'package:a_e_commerce_app/controllers/get-customer-device-token-controller.dart';
import 'package:a_e_commerce_app/models/cart-model.dart';
import 'package:a_e_commerce_app/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../service/place-orders-service.dart';
import '../../controllers/cart-price-controller.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreen();
}

class _CheckOutScreen extends State<CheckOutScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? customerToken;
  String? name;
  String? phone;
  String? address;

  final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Checkout Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: Get.height / 5.5,
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(child: Text("No products found!"));
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              CartModel cartModel = CartModel(
                productId: productData['productId'],
                categoryId: productData['categoryId'],
                productName: productData['productName'],
                categoryName: productData['categoryName'],
                salePrice: productData['salePrice'],
                fullPrice: productData['fullPrice'],
                productImages: List<String>.from(productData['productImages']),
                deliveryTime: productData['deliveryTime'],
                isSale: productData['isSale'],
                productDescription: productData['productDescription'],
                createdAt: productData['createdAt'],
                updatedAt: productData['updatedAt'],
                productQuantity: productData['productQuantity'],
                productTotalPrice: productData['productTotalPrice'],
              );

              // calculate price
              productPriceController.fetchProductPrice();

              return SwipeActionCell(
                key: ObjectKey(cartModel.productId),
                trailingActions: [
                  SwipeAction(
                    title: "Delete",
                    forceAlignmentToBoundary: true,
                    performsFirstActionWithFullSwipe: true,
                    onTap: (CompletionHandler handler) async {
                      await FirebaseFirestore.instance
                          .collection('cart')
                          .doc(user!.uid)
                          .collection('cartOrders')
                          .doc(cartModel.productId)
                          .delete();
                      handler;
                    },
                  ),
                ],
                child: Card(
                  elevation: 5,
                  color: AppConstant.appTextColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstant.appMainColor,
                      backgroundImage: NetworkImage(
                          cartModel.productImages.isNotEmpty
                              ? cartModel.productImages[0]
                              : ''),
                    ),
                    title: Text(cartModel.productName),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(cartModel.productTotalPrice.toString()),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                " Total: ${productPriceController.totalPrice.value.toStringAsFixed(1)} : BDT",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
                    child: const Text(
                      "Confirm Order",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    onPressed: showCustomBottomSheet,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCustomBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstant.appMainColor,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      name = nameController.text.trim();
                      phone = phoneController.text.trim();
                      address = addressController.text.trim();
                    });

                    customerToken = await getCustomerDeviceToken();

                    var options = {
                      'key': 'rzp_test_7DQ1Jh1sVp38cO',
                      'amount': 1000,
                      'currency': 'USD',
                      'name': 'Rafsan Chowdhury.',
                      'description': 'Fine T-Shirt',
                      'prefill': {
                        'contact': '8888888888',
                        'email': 'test@razorpay.com'
                      }
                    };

                    _razorpay.open(options);
                  } else {
                    print("Fill the details");
                  }
                },
                child: const Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      elevation: 6,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Check if the variables are not null before using them
    if (name != null &&
        phone != null &&
        address != null &&
        customerToken != null) {
      placeOrder(
        context: context,
        customerName: name!,
        customerPhone: phone!,
        customerAddress: address!,
        customerDeviceToken: customerToken!,
      );
    } else {
      print("Error: One or more required fields are null.");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    _razorpay.clear();
    super.dispose();
  }
}
