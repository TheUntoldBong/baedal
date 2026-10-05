import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get_utils/get_utils.dart';
class CutleryViewWidget extends StatelessWidget {
  final RestaurantController restaurantController;
  final CartController cartController;
  const CutleryViewWidget({super.key, required this.restaurantController, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return (restaurantController.restaurant != null && restaurantController.restaurant!.cutlery != null && restaurantController.restaurant!.cutlery!) ? Column(mainAxisSize: MainAxisSize.min, children: [

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('add_cutlery'.tr, style: context.heading.large),
              const SizedBox(height: Dimensions.padding2xSmall),

              Text('no_cutlery_provided_note'.tr, style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium)),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingDefault),

          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: cartController.addCutlery,
              activeTrackColor: context.primary,
              onChanged: (bool? value) {
                cartController.updateCutlery();
              },
              inactiveTrackColor: context.primary.withValues(alpha: 0.2),
            ),
          ),

        ]),
      ),

      Divider(height: 1, thickness: 1, indent: Dimensions.paddingLarge, endIndent: Dimensions.paddingLarge),

    ]) : const SizedBox();
  }
}
