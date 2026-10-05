import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class BottomCartWidget extends StatelessWidget {
  final int? restaurantId;
  final bool fromDineIn;
  final bool showGlobalCardWise;
  const BottomCartWidget({super.key, this.restaurantId, this.fromDineIn = false, required this.showGlobalCardWise});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: GetPlatform.isIOS ? 80 : 70,
              width: Get.width > 600 ? 600 : Get.width,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, -1))],
              ),
              child: Row(children: [

              if(showGlobalCardWise)...[
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${'item'.tr}: ${cartController.itemCountOfGlobalCart()}', style: context.subHeading.defaultSize.medium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Text(
                    '${'total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCartGlobal())}',
                    style: context.heading.large.medium.overrideWith(color: context.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ])),
              ]
              else Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'item'.tr}: ${cartController.cartList(restaurantId!).length}', style: context.subHeading.defaultSize.medium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  '${'total'.tr}: ${PriceConverter.convertPrice(cartController.subTotalOf(restaurantId!))}',
                  style: context.heading.large.medium.overrideWith(color: context.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ])),

              const SizedBox(width: Dimensions.paddingDefault),
              CustomButtonWidget(buttonText: 'view_cart'.tr, width: 150, height: 40, onPressed: () async {
                await Get.toNamed(showGlobalCardWise ? RouteHelper.getCartBundleListRoute() : RouteHelper.getCartRoute(fromDineIn: fromDineIn, restaurantId: restaurantId!));
                if(showGlobalCardWise) {
                  return;
                }
                Get.find<RestaurantController>().makeEmptyRestaurant();
                if(restaurantId != null) {
                  Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                }
              })
            ]),
            ),
          ),
        );
      });
  }
}
