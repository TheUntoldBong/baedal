import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class OfflineSuccessDialog extends StatelessWidget {
  final int? orderId;
  final bool isDineIn;
  const OfflineSuccessDialog({super.key, required this.orderId, this.isDineIn = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingLarge),
          child: SingleChildScrollView(
            child: Column(children: [

              isDineIn
                  ? CustomAssetImageWidget(Images.successAnimationDineIn, height: 100, width: 100,)
                  : const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: Dimensions.paddingLarge),

              Text(
                'order_placed_successfully'.tr ,
                style: context.heading.large.strong,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingDefault),

              !isDineIn ? RichText(textAlign: TextAlign.center, text: TextSpan(children: [
                TextSpan(text: 'your_payment_has_been_successfully_processed_and_your_order'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                TextSpan(text: ' #$orderId ', style: context.body.defaultSize.strong.overrideWith(color: context.primary)),
                TextSpan(text: 'has_been_placed'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
              ])) : const SizedBox(),
              SizedBox(height: !isDineIn ? Dimensions.paddingLarge : 0),

              isDineIn ?  Text(
                'your_order_place_successfully'.tr ,
                style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                textAlign: TextAlign.center,
              ) : Column(children: [

                GetBuilder<OrderController>(
                    builder: (orderController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          border: Border.all(color: context.primary.withValues(alpha: 0.2)),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingDefault),
                        child: orderController.trackModel != null ? ListView.builder(
                            itemCount: orderController.trackModel!.offlinePayment!.input!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index){
                              Input data = orderController.trackModel!.offlinePayment!.input![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                                child: Row(children: [

                                  Expanded(child: Text(data.userInput.toString().replaceAll('_', ' '), style: context.subHeading.small.regular)),

                                  Text(':', style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  Expanded(child: Text(data.userData.toString(), style: context.subHeading.small.regular)),

                                ]),
                              );
                            }) : const SizedBox(),
                      );
                    }
                ),

                const SizedBox(height: Dimensions.paddingDefault),

                RichText(textAlign: TextAlign.center, text: TextSpan(children: [
                  TextSpan(text: '*', style: context.body.defaultSize.medium.overrideWith(color: Colors.red)),
                  TextSpan(text: 'offline_order_note'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                ])),

              ]),
              const SizedBox(height: Dimensions.paddingLarge),

              CustomButtonWidget(
                width: isDineIn ? 500 : 100,
                color: isDineIn ? context.primary : context.textBaseDefault.withValues(alpha: 0.8),
                buttonText: 'ok'.tr,
                onPressed: () {
                  Get.back();
                },
              )

            ]),
          ),
        ),
      ),
    );
  }
}
