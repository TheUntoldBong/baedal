import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PickupWarningBottomSheet extends StatelessWidget {
  final String orderType;
  const PickupWarningBottomSheet({super.key, required this.orderType});

  @override
  Widget build(BuildContext context) {
    bool isTakeAway = orderType == 'take_away';

    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          Align(alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Get.back(result: false),
              child: Container( width: 32, height: 32,
                margin: const EdgeInsets.all(Dimensions.padding2xSmall),
                decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
                child:  Icon(Icons.clear, color: context.iconBaseMedium),
              ),
            ),
          ),

        

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault+1),
            child: Column(children: [
              Text(
                isTakeAway ? 'pickup_from_restaurant'.tr : 'dine_in_at_restaurant'.tr,
                textAlign: TextAlign.center,
                style: context.subHeading.extraLarge.strong,
              ),
              const SizedBox(height: Dimensions.paddingSmall),
            
              Text(
                isTakeAway
                    ? 'you_have_chosen_takeaway_for_this_order_please_pick_up_your_order_directly_from_the_restaurant_when_its_ready'.tr
                    : 'you_have_chosen_dine_in_for_this_order_please_visit_the_restaurant_to_enjoy_your_meal'.tr,
                textAlign: TextAlign.center,
                style: context.body.small.regular,
              ),
              const SizedBox(height: Dimensions.paddingLarge),
            
              CustomButtonWidget(
                width: 240,
                buttonText: 'okay_got_it'.tr,
                fontSize: Dimensions.fontSizeDefault,
                onPressed: () => Get.back(result: true),
              ),
              const SizedBox(height: Dimensions.paddingSmall),
            
              CustomButtonWidget(
                width: 240,
                buttonText: 'change_to_home_delivery'.tr,
                fontSize: Dimensions.fontSizeDefault,
                color: context.bgNeutralLight,
                onPressed: () => Get.back(result: false),
              ),
            
              const SizedBox(height: Dimensions.paddingLarge),
            ]),
          ),
        ]),
      ),
    );
  }
}
