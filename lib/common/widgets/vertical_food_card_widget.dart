import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_stepper_widget.dart';
import 'package:stackfood_multivendor/common/widgets/verified_avater.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class VerticalFoodCardWidget extends StatelessWidget {
  final Product product;
  final double? width;
  final bool isCampaign;
  final bool showStoreInfo;
  final bool isTopRated;

  const VerticalFoodCardWidget({super.key, required this.product, this.width, this.isCampaign = false, this.showStoreInfo = true, this.isTopRated = false,});

  void _openProduct(BuildContext context) {
    ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
      FoodBottomSheetWidget(product: product, isCampaign: isCampaign),
      backgroundColor: Colors.transparent, isScrollControlled: true,
    ) : Get.dialog(
      Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: isCampaign)),
    );
  }

  Widget _tagWidget(BuildContext context, String image) {
    return Container(
      height: 20, width: 20,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(3),
      margin: const EdgeInsets.only(right: 5),
      child: CustomAssetImageWidget(image, fit: BoxFit.contain),
    );
  }

  Widget _ratingRow(BuildContext context) {
    final TextStyle style = (isTopRated ? context.subHeading.small : context.subHeading.defaultSize)
        .overrideWith(color: context.textBaseMedium);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      CustomAssetImageWidget(Images.starFill, width: Dimensions.fontSizeSmall, color: context.iconBaseMedium),
      const SizedBox(width: 2),
      Text(product.avgRating!.toStringAsFixed(1), style: style),
      if(isTopRated) ...[
        const SizedBox(width: 2),
        Text('(${product.ratingCount ?? 0})', style: style),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double finalWidth = width ?? math.max(100, MediaQuery.sizeOf(context).width * 0.35);
    final double price = product.price ?? 0;
    final double discount = product.discount ?? 0;
    final String discountType = product.discountType ?? 'percent';
    final double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    final bool isAvailable = DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds);

    final bool showHalal = (product.isRestaurantHalalActive ?? false) && (product.isHalalFood ?? false);
    final bool toggleVegNonVeg = Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false;
    final bool showVeg = toggleVegNonVeg && product.veg == 1;
    final bool hasRating = (product.avgRating ?? 0) > 0;
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    List<Map<String, String?>> tags = [];
    if((product.discount ?? 0) > 0) {
      tags.add({'text': '${product.discount}${product.discountType == 'percent' ? '%' : currencySymbol}', 'icon': Images.percentTag});
    }
    for (String tag in product.tags ?? []) {
      tags.add({'text': tag, 'icon': null});
    }

    return CustomInkWellWidget(
      onTap: () => _openProduct(context),
      radius: Dimensions.radiusLarge,
      child: SizedBox(
        width: finalWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: finalWidth,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: context.outline),
            ),
            child: Stack(children: [

              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImageWidget(
                    image: product.imageFullUrl ?? '',
                    fit: BoxFit.cover, isFood: true,
                  ),
                ),
              ),

              Positioned(
                top: Dimensions.paddingSmall, left: Dimensions.paddingSmall,
                child: Row(children: [
                  if(showHalal) _tagWidget(context, Images.halal),
                  if(showVeg) _tagWidget(context, Images.nonVeg),
                ]),
              ),

              if(!isAvailable) NotAvailableWidget(opacity: 0.3, fontSize: 14),
              Positioned(
                right: Dimensions.paddingSmall,
                bottom: Dimensions.paddingSmall,
                child: _cartButton(context, price, discountPrice),
              ),


              GetBuilder<FavouriteController>(builder: (favouriteController) {
                bool isWished = favouriteController.wishProductIdList.contains(product.id);
                return Positioned(
                  top: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
                  child: CustomFavouriteWidget(
                    id: product.id!,
                    isRestaurant: false,
                    isWished: isWished,
                    size: 16,
                    widgetSize: 24,
                    isCircular: true,
                  ),
                );
              }),

            ]),
          ),
          const SizedBox(height: Dimensions.paddingSmall),

          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(showStoreInfo) ...[
                Row(children: [
                  RestaurantVerifiedAvatar(
                    imageUrl: product.restaurantLogoFullUrl != null && product.restaurantLogoFullUrl!.isNotEmpty ? product.restaurantLogoFullUrl : Images.storeIcon,
                    isVerified: product.verifiedSeller ?? false, size: 16,
                  ),
                  const SizedBox(width: 2),

                  Flexible(
                    child: Text(
                      product.restaurantName ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                    ),
                  ),
                  if(!isTopRated && hasRating) ...[
                    const SizedBox(width: 4),
                    _ratingRow(context),
                  ],
                ]),
                const SizedBox(height: Dimensions.padding2xSmall),
              ],

              if(isTopRated && hasRating) ...[
                _ratingRow(context),
                const SizedBox(height: Dimensions.padding2xSmall),
              ],

              Text(
                product.name ?? '',
                maxLines: isTopRated ? 1 : 2, overflow: TextOverflow.ellipsis,
                style: context.heading.defaultSize.medium,
              ),
              const SizedBox(height: Dimensions.padding2xSmall),

              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8, alignment: WrapAlignment.start,
                children: [
                  Text(
                    PriceConverter.convertPrice(discountPrice),
                    style: context.heading.large.strong.overrideWith(color: context.primary),
                  ),
                  if(discountPrice < price)
                    Text(
                      PriceConverter.convertPrice(price),
                      style: context.subHeading.small.copyWith(
                        color: context.primary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: context.primary,
                        decorationThickness: 2,
                      ),
                    ),
                ],
              ),

              if(tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 6, children: tags.map((tag) => OfferBadgeWidget(text: tag['text']!, icon: tag['icon'])).toList()),
              ],

            ]),
          ),

        ]),
      ),
    );
  }

  Widget _cartButton(BuildContext context, double price, double discountPrice) {
    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<CartController>(builder: (cartController) {
        if (product.id == null || product.restaurantId == null) {
          return const SizedBox();
        }
        int cartQty = cartController.cartQuantity(product.id!, product.restaurantId!);
        int bundleIndex, cartIndex;
        (bundleIndex, cartIndex) = cartController.isExistInCart(product.id, product.restaurantId!);

        CartModel? cartModel = (bundleIndex != -1 && cartIndex != -1)
            ? cartController.cartBundleList[bundleIndex].carts![cartIndex] : null;

        return QuantityStepperWidget(
          quantity: cartQty,
          collapsible: false,
          onAdd: () {
            if(!isCampaign && (product.variations == null || product.variations!.isEmpty)) {
              productController.setExistInCart(product);
              OnlineCart onlineCart = OnlineCart(null, product.id, null, product.price!.toString(), [], 1, [], [], [], 'Food', variationOptionIds: [], restaurantId: product.restaurantId);
              Get.find<CartController>().addToCartOnline(onlineCart);
            } else {
              _openProduct(context);
            }
          },
          onDecrement: cartController.isLoading || cartModel == null ? null : () {
            if(cartModel.quantity! > 1) {
              cartController.setQuantity(false, cartModel, cartIndex: cartIndex, restaurantId: product.restaurantId!);
            } else {
              cartController.removeFromCart(cartIndex: cartIndex, restaurantId: product.restaurantId!);
            }
          },
          onIncrement: cartController.isLoading || cartModel == null ? null : () {
            cartController.setQuantity(true, cartModel, cartIndex: cartIndex, restaurantId: product.restaurantId!);
          },
        );
      });
    });
  }
}
