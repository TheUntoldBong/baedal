import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class NotLoggedInScreen extends StatelessWidget {
  final Function(bool success) callBack;
  const NotLoggedInScreen({super.key, required this.callBack});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              CustomAssetImageWidget(
                Images.guest,
                width: MediaQuery.of(context).size.height*0.25,
                height: MediaQuery.of(context).size.height*0.25,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),

              Text(
                'sorry'.tr,
                style: context.heading.extraLarge.strong.overrideWith(color: context.primary).copyWith(fontSize: MediaQuery.of(context).size.height*0.023),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),

              Text(
                'you_are_not_logged_in'.tr,
                style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium).copyWith(fontSize: MediaQuery.of(context).size.height*0.0175),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),

              SizedBox(
                width: 200,
                child: CustomButtonWidget(buttonText: 'login_to_continue'.tr, onPressed: () async {
                  await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                  if(Get.find<OrderController>().showBottomSheet) {
                    Get.find<OrderController>().showRunningOrders();
                  }
                  callBack(true);

                }),
              ),

            ]),
          ),
        ),
      ),
    );
  }
}
