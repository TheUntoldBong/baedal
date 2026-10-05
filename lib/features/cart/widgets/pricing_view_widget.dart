import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cutlary_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/extra_packaging_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/not_available_product_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class PricingViewWidget extends StatelessWidget {
  final CartController cartController;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  final int restaurantId;
  const PricingViewWidget({super.key, required this.cartController, required this.isRestaurantOpen, this.fromDineIn = false, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return Column(children: [
        !isDesktop && !fromDineIn ? ExtraPackagingWidget(cartController: cartController) : const SizedBox(),

        !isDesktop && !fromDineIn ? CutleryViewWidget(restaurantController: restaurantController, cartController: cartController) : const SizedBox(),

        !isDesktop ? NotAvailableProductViewWidget(cartController: cartController) : const SizedBox(),

      ]);
    });
  }
}
