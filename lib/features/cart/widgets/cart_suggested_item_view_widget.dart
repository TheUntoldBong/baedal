import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartSuggestedItemViewWidget extends StatelessWidget {
  final List<CartModel> cartList;
  final int? restaurantId;
  const CartSuggestedItemViewWidget({super.key, required this.cartList, this.restaurantId});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0 : 1),
        borderRadius: BorderRadius.circular(isDesktop ? Dimensions.radiusDefault : 0),
        boxShadow: isDesktop ? [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)] : [],
      ),
      width: double.infinity,
      child: GetBuilder<RestaurantController>(builder: (restaurantController) {
        List<Product> suggestedItems = [];
        List<int> cartIds = [];
        for (CartModel cartItem in cartList) {
          if (!cartItem.isBogoBundle && cartItem.product?.id != null) {
            cartIds.add(cartItem.product!.id!);
          }
        }

        // 1. First priority: Backend cart suggested items
        if (restaurantController.suggestedItems != null && restaurantController.suggestedItems!.isNotEmpty) {
          for (Product item in restaurantController.suggestedItems!) {
            if (!cartIds.contains(item.id)) {
              suggestedItems.add(item);
            }
          }
        }

        // 2. Fallback priority: Menu items from the same restaurant
        if (suggestedItems.isEmpty && restaurantController.restaurantProducts != null && restaurantController.restaurantProducts!.isNotEmpty) {
          for (Product item in restaurantController.restaurantProducts!) {
            if (!cartIds.contains(item.id)) {
              suggestedItems.add(item);
            }
          }
        }

        // If items are still empty and we have a restaurantId, trigger load
        if (suggestedItems.isEmpty && restaurantController.restaurantProducts == null && restaurantId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            restaurantController.getRestaurantProductList(restaurantId, 1, VegType.all, false);
          });
        }

        if (suggestedItems.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSmall),

            // Section Header with Icon and Badge
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingLarge,
                vertical: Dimensions.paddingSmall,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, size: 14, color: primary),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended with your meal',
                          style: context.heading.small.overrideWith(color: context.textBaseDefault, fontWeight: FontWeight.w700).copyWith(fontSize: 15),
                        ),
                        Text(
                          'Popular additions from this restaurant',
                          style: context.body.small.overrideWith(color: context.textBaseLight).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Horizontal Recommended Foods Carousel
            SizedBox(
              height: 205,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedItems.length > 10 ? 10 : suggestedItems.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                itemBuilder: (context, index) {
                  final Product product = suggestedItems[index];
                  return _RecommendedItemCard(product: product, primary: primary);
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingMedium),
          ],
        );
      }),
    );
  }
}

class _RecommendedItemCard extends StatelessWidget {
  final Product product;
  final Color primary;
  const _RecommendedItemCard({required this.product, required this.primary});

  void _openProduct(BuildContext context) {
    ResponsiveHelper.isMobile(context)
        ? Get.bottomSheet(
            FoodBottomSheetWidget(product: product, isCampaign: false),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          )
        : Get.dialog(
            Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: false)),
          );
  }

  @override
  Widget build(BuildContext context) {
    double? price = product.price;
    double? discount = product.discount;
    String? discountType = product.discountType;
    double? discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType);
    bool isVeg = (product.veg ?? 0) == 1;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.outline.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openProduct(context),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Veg Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  child: CustomImageWidget(
                    image: product.imageFullUrl ?? '',
                    height: 95,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),

                // Veg / Non-Veg Indicator
                if (Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 9,
                        color: isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),

                // Discount Badge if available
                if (discount != null && discount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        PriceConverter.percentageCalculation(price.toString(), discount.toString(), discountType ?? ''),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            // Item Details
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.subHeading.small.strong.overrideWith(color: context.textBaseDefault).copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),

                  // Price & ADD Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PriceConverter.convertPrice(discountPrice),
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            if (discount != null && discount > 0)
                              Text(
                                PriceConverter.convertPrice(price),
                                style: TextStyle(
                                  color: context.textBaseLight,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Chic "+ ADD" button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primary.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Text(
                          '+ ADD',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
