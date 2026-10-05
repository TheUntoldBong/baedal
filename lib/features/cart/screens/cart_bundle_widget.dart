import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/bogo_item_group_widget.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

import '../../../common/models/restaurant_model.dart' as restaurant_common;

class CartBundleWidget extends StatelessWidget {
  final CartBundleModel cartBundleWidget;
  const CartBundleWidget({super.key, required this.cartBundleWidget});

  @override
  Widget build(BuildContext context) {
    final Restaurant? restaurant = cartBundleWidget.restaurant;
    if (restaurant == null) {
      return const SizedBox();
    }

    final carts = cartBundleWidget.carts ?? [];
    final bool hasBogoBundle = carts.any((cart) => cart.isBogoBundle);

    final visibleCarts = hasBogoBundle ? carts.where((cart) => cart.isBogoBundle).toList() : carts;
    final int collapsedItemCount = carts.length - visibleCarts.length;

    // Calculate bundle subtotal
    double bundleSubtotal = 0;
    for (final cart in carts) {
      double itemPrice = (cart.discountedPrice != null && cart.discountedPrice! > 0)
          ? cart.discountedPrice!
          : (cart.price ?? (cart.product?.price ?? 0));
      int qty = cart.quantity ?? 1;
      bundleSubtotal += (itemPrice * qty);
    }

    return GetBuilder<CartController>(builder: (cartController) {
      final bool isDeletingThis = cartController.isDeleting && cartController.deletingRestaurantId == restaurant.id;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.18 : 0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.25 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Restaurant Header
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    image: restaurant.logoFullUrl ?? '',
                    height: 46,
                    width: 46,
                    isRestaurant: true,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () => _openRestaurant(restaurant),
                              child: Text(
                                (restaurant.name ?? '').replaceAll(r"\'", "'").replaceAll(r'\"', '"'),
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault + 1,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (restaurant.verifiedSeller == true) ...[
                            const SizedBox(width: Dimensions.padding2xSmall),
                            const RestaurantVerifiedIconWidget(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${carts.length} ${carts.length == 1 ? 'item'.tr : 'items'.tr}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Direct Delete Trash Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: isDeletingThis ? null : () => _confirmDelete(context, restaurant.id!),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: isDeletingThis
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            )
                          : Icon(
                              CupertinoIcons.trash,
                              size: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food items preview carousel
          if (visibleCarts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
              child: SizedBox(
                height: hasBogoBundle ? 108 : 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                  itemCount: visibleCarts.length + (collapsedItemCount > 0 ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
                  itemBuilder: (context, index) {
                    if (index == visibleCarts.length && collapsedItemCount > 0) {
                      return _MoreItemsBadge(count: collapsedItemCount);
                    }

                    final cart = visibleCarts[index];

                    if (cart.isBogoBundle) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cart.bogoDetails!.offerTitle ?? 'bogo_offer'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: Dimensions.paddingMedium),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BogoItemGroupWidget(
                                label: 'buying_item'.tr,
                                thumbnails: cart.bogoDetails!.buyItemThumbnails,
                              ),
                              const SizedBox(width: Dimensions.paddingDefault),
                              BogoItemGroupWidget(
                                label: 'free_item'.tr,
                                thumbnails: cart.bogoDetails!.freeItemThumbnails,
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    final double itemTotal = (cart.discountedPrice != null && cart.discountedPrice! > 0)
                        ? cart.discountedPrice! * (cart.quantity ?? 1)
                        : (cart.price ?? (cart.product?.price ?? 0)) * (cart.quantity ?? 1);

                    return SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CustomImageWidget(
                                  image: cart.product?.imageFullUrl ?? '',
                                  height: 68,
                                  width: 90,
                                  isFood: true,
                                  fit: BoxFit.cover,
                                  placeholder: Images.foodPlaceholder,
                                ),
                              ),
                              // Veg / Non-Veg Indicator Badge
                              if (cart.product?.veg != null)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 2),
                                      ],
                                    ),
                                    child: CustomAssetImageWidget(
                                      cart.product!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                                      height: 10,
                                      width: 10,
                                    ),
                                  ),
                                ),

                              // Quantity badge pill
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'x${cart.quantity ?? 1}',
                                    style: robotoBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Text(
                            cart.product?.name ?? '',
                            style: robotoMedium.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            PriceConverter.convertPrice(itemTotal),
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Subtotal Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Subtotal',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall + 1,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Text(
                  PriceConverter.convertPrice(bundleSubtotal),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault + 1,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSmall),

          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),

          // Actions Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomInkWellWidget(
                  onTap: () => _openRestaurant(restaurant),
                  radius: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).primaryColor, size: 18),
                        const SizedBox(width: Dimensions.padding2xSmall),
                        Text(
                          'add_more_items'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                CustomButtonWidget(
                  width: 140,
                  height: 38,
                  radius: 12,
                  icon: Icons.arrow_forward_rounded,
                  buttonText: 'view_cart'.tr,
                  fontSize: Dimensions.fontSizeSmall,
                  onPressed: () {
                    Get.toNamed(
                      RouteHelper.getRestaurantRoute(restaurant.id, slug: (restaurant.name ?? '').replaceAll(r"\'", "'").replaceAll(r'\"', '"')),
                      arguments: RestaurantScreen(
                        restaurant: restaurant_common.Restaurant(id: restaurant.id, name: restaurant.name),
                        viewCartAutoNavigate: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      );
    });
  }

  void _openRestaurant(Restaurant restaurant) {
    Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id));
  }

  void _confirmDelete(BuildContext context, int restaurantId) {
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
}

class _MoreItemsBadge extends StatelessWidget {
  final int count;
  const _MoreItemsBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz_rounded, color: Theme.of(context).primaryColor, size: 20),
          Text(
            '+$count',
            style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

