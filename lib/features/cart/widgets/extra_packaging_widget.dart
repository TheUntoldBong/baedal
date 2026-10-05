import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ExtraPackagingWidget extends StatelessWidget {
  final CartController cartController;
  const ExtraPackagingWidget({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {

      Restaurant? restaurant = restaurantController.restaurant;

      return (restaurant != null && restaurant.isExtraPackagingActive! && restaurant.extraPackagingAmount != null && restaurant.extraPackagingAmount != 0 && !restaurant.extraPackagingStatusIsMandatory!) ? Column(mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${'need_extra_packaging'.tr}?', style: context.heading.large),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  'an_additional_amount_will_be_applied'.trParams({'amount': PriceConverter.convertPrice(restaurant.extraPackagingAmount)}),
                  style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
                ),
              ]),
            ),
            const SizedBox(width: Dimensions.paddingDefault),

            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                activeColor: context.primary,
                side: BorderSide(color: context.outline, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                value: cartController.needExtraPackage,
                onChanged: (bool? isChecked) {
                  cartController.toggleExtraPackage();
                },
              ),
            ),

          ]),
        ),

        Divider(height: 1, thickness: 1, indent: Dimensions.paddingDefault, endIndent: Dimensions.paddingDefault, color: context.outlineVariant),

      ]) : const SizedBox();
    });
  }
}
