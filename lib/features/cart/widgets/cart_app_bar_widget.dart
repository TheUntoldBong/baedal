import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class CartAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final int restaurantId;
  final bool isBackButtonExist;
  const CartAppBarWidget({super.key, required this.restaurantId, this.isBackButtonExist = true});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return GetBuilder<CartController>(builder: (cartController) {

        final bool cartNotEmpty = cartController.cartList(restaurantId).isNotEmpty;
        final bool isLoading = cartNotEmpty && restaurantController.restaurant == null;
        final String? storeName = restaurantController.restaurant?.name;
        final int itemCount = cartController.cartList(restaurantId).length;
        final bool isVerified = restaurantController.restaurant?.verifiedSeller ?? false;

        return AppBar(
          titleSpacing: 0,
          toolbarHeight: 60,
          backgroundColor: context.surfaceContainer,
          surfaceTintColor: context.surfaceContainer,
          shadowColor: context.shadow,
          elevation: 2,
          automaticallyImplyLeading: false,
          leading: isBackButtonExist ? Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingMedium, right: Dimensions.paddingSmall),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Center(
                child: Container(
                  height: 40, width: 40,
                  decoration: BoxDecoration(color: context.surfaceContainerLowest, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(Icons.close, size: 20, color: context.iconBaseDefault, weight: 2),
                ),
              ),
            ),
          ) : null,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

            Row(children: [
              Text('${'cart'.tr} - ', style: context.heading.extraLarge),

              if(isLoading) ...[
                const _CartAppBarShimmer(height: 16, width: 16, isCircle: true),
                const SizedBox(width: 4),
                const _CartAppBarShimmer(height: 14, width: 90),
              ] else ...[
                if(storeName != null && storeName.isNotEmpty) Flexible(child: Text(
                  storeName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.heading.extraLarge,
                )),
                if(isVerified) ...[
                  SizedBox(width: Dimensions.padding2xSmall),
                  RestaurantVerifiedIconWidget(),
                ],
              ],
            ]),
            const SizedBox(height: 2),

            if(isLoading)
              const _CartAppBarShimmer(height: 11, width: 70)
            else if(cartNotEmpty)
              Text(
                '$itemCount ${itemCount == 1 ? 'item'.tr : 'items'.tr} ${'added'.tr}',
                style: context.body.small,
              ),
          ]),
          actions: [
            if(cartNotEmpty) Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
              child: InkWell(
                onTap: () => _confirmClearCart(),
                child: Icon(CupertinoIcons.trash, size: 22, color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      });
    });
  }

  void _confirmClearCart() {
    showCustomDialog(
      child: ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'are_you_sure_to_delete'.tr,
      description: 'all_items_from_this_restaurant_will_be_removed_from_your_cart'.tr,
      isLogOut: true,
      isDelete: true,
      onYesPressed: () {
        Get.back();
        Get.find<CartController>().removeCartBundle(restaurantId);
      },
    ),
      isDismissible: false,
    );
  }

  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, ResponsiveHelper.isDesktop(Get.context) ? 100 : 60);
}

class _CartAppBarShimmer extends StatelessWidget {
  final double height;
  final double width;
  final bool isCircle;
  const _CartAppBarShimmer({required this.height, required this.width, this.isCircle = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Container(
        height: height, width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(Dimensions.radiusExtraSmall),
        ),
      ),
    );
  }
}
