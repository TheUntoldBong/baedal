import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

void showCartSnackBarWidget({int? restaurantId}) {
  Get.showSnackbar(GetSnackBar(
    backgroundColor: Colors.green,
    messageText: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        'item_added_to_cart'.tr,
        style: Get.context!.body.defaultSize.medium.overrideWith(color: Colors.white),
      ),
    ),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(Dimensions.paddingSmall),
    duration: const Duration(seconds: 3),
    borderRadius: Dimensions.radiusExtraSmall,
    isDismissible: true,
    mainButton: TextButton(
      onPressed: () {
        Get.back();
        if(restaurantId != null){
          Get.toNamed(RouteHelper.getCartRoute(restaurantId: restaurantId));
        }
        else{
          Get.toNamed(RouteHelper.getCartBundleListRoute());
        }
      },
      child: Text('view_cart'.tr, style: const TextStyle(color: Colors.white)),
    ),
  ));
}
