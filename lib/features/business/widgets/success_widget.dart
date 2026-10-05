import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class SuccessWidget extends StatelessWidget {
  const SuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (businessController) {
      return Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

            const SizedBox(height: Dimensions.paddingLarge),
            SizedBox(height: context.height * 0.2),

            CustomAssetImageWidget(Images.checked, height: 90,width: 90),
            const SizedBox(height: Dimensions.paddingLarge),

            Text('congratulations'.tr, style: context.heading.extraOverLarge.strong),
            const SizedBox(height: Dimensions.paddingSmall),

            Text(
              'your_registration_has_been_completed_successfully'.tr,
              style: context.body.small.medium, textAlign: TextAlign.center, softWrap: true,
            ),

          ]),
        ),
      );
    });
  }
}