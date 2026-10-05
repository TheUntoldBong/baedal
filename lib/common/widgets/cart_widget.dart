import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CartWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final bool fromRestaurant;
  final String? imageIcon;
  final IconData? icon;
  const CartWidget({super.key, required this.color, required this.size, this.fromRestaurant = false, this.imageIcon, this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      icon != null
          ? Icon(icon, size: size, color: color)
          : CustomAssetImageWidget(imageIcon ?? Images.orderIcon, height: size, width: size),

      GetBuilder<CartController>(builder: (cartController) {
        return cartController.itemCountOfGlobalCart() > 0 ? Positioned(
          top: 0, right: -5,
          child: Container(
            height: size < 20 ? 10 : size/2, width: size < 20 ? 10 : size/2, alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: fromRestaurant ? context.surfaceContainer : context.primary,
              border: Border.all(width: size < 20 ? 0.7 : 1, color: fromRestaurant ? context.primary : context.outline),
            ),
            child: Text(
              cartController.itemCountOfGlobalCart().toString(),
              style: context.body.extraSmall.regular.overrideWith(
                color: fromRestaurant ? context.primary : context.surfaceContainer,
              ).copyWith(fontSize: size < 20 ? size/3 : size/3.8),
            ),
          ),
        ) : const SizedBox();
      }),
    ]);
  }
}
