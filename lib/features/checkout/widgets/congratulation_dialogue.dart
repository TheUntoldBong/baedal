import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';


class CongratulationDialogue extends StatelessWidget {
  const CongratulationDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(Dimensions.paddingExtraLarge),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CustomAssetImageWidget(Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox, width: 100, height: 100),

                Text('congratulations'.tr , style: context.subHeading.large.medium),
                const SizedBox(height: Dimensions.paddingSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                  child: Text(
                    '${'you_will_earn'.tr} ${Get.find<LoyaltyController>().getEarningPint()} ${'points_after_completing_this_order'.tr}',
                    style: context.subHeading.large.regular.overrideWith(color: context.textBaseMedium),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingLarge),

                CustomButtonWidget(
                  buttonText: 'visit_loyalty_points'.tr,
                  onPressed: (){
                    Get.find<LoyaltyController>().saveEarningPoint('');
                    Get.back();
                    Get.toNamed(RouteHelper.getLoyaltyRoute());
                  },
                )
              ]),
            ),

            Positioned(
              top: 5, right: 5,
              child: InkWell(
                onTap: (){
                  Get.find<LoyaltyController>().saveEarningPoint('');
                  Get.back();
                },
                child: const Icon(Icons.clear, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
