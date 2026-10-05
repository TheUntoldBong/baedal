import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_stepper_widget.dart';
import 'package:stackfood_multivendor/common/widgets/readmore_widget.dart';
import 'package:stackfood_multivendor/common/widgets/verified_avater.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';


class HorizontalFoodCardWidget extends StatelessWidget {
  final Product product;
  final Restaurant? restaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool fromCartSuggestion;
  final EdgeInsets? padding;
  final bool showStoreInfo;
  final bool isBogoOfferItem;
  final int? bogoQuantity;
  final String? bogoVariationText;
  final String? bogoAddOnText;
  final bool isTopRated;

  const HorizontalFoodCardWidget({super.key, required this.product, required this.restaurant,
    this.index = 0, this.length, this.inRestaurant = false, this.isCampaign = false, this.fromCartSuggestion = false,
    this.showStoreInfo = false, this.padding, this.isBogoOfferItem = false, this.bogoQuantity, this.bogoVariationText, this.bogoAddOnText, this.isTopRated = false});

  void _openProduct(BuildContext context) {
    Get.bottomSheet(
      FoodBottomSheetWidget(product: product, inRestaurantPage: inRestaurant, isCampaign: isCampaign),
      backgroundColor: Colors.transparent, isScrollControlled: true,
    );
  }

  Widget _ratingRow(BuildContext context, {required bool inline}) {
    final TextStyle style = context.heading.defaultSize.overrideWith(color: context.textBaseMedium);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      CustomAssetImageWidget(
        Images.starFill,
        color: inline ? context.iconBaseMedium : context.iconNeutralLight,
        height: inline ? 10 : 12,
      ),
      SizedBox(width: inline ? 2 : Dimensions.padding2xSmall),
      Text((product.avgRating ?? 0).toStringAsFixed(1), style: style),
      if (isTopRated) ...[
        const SizedBox(width: 2),
        Text('(${product.ratingCount ?? 0})', style: style),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double price = product.price ?? 0;
    final double discount = product.discount ?? 0;
    final String discountType = product.discountType ?? 'percent';
    final double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    final bool hasDiscount = discount > 0;
    final bool hasFreeDelivery = restaurant?.delivery == true && restaurant?.freeDelivery == true;
    final bool isAvailable = DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds);
    final bool showHalal = (product.isRestaurantHalalActive ?? false) && (product.isHalalFood ?? false);
    final bool showVeg = (Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false) && product.veg == 1;
    final bool hasRating = (product.avgRating ?? 0) > 0;

    final Widget content = Padding(
        padding: padding ?? const EdgeInsets.all(Dimensions.paddingSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (showStoreInfo) ...[
                  Row(children: [
                    RestaurantVerifiedAvatar(
                      imageUrl: product.restaurantLogoFullUrl != null && product.restaurantLogoFullUrl!.isNotEmpty ? product.restaurantLogoFullUrl : Images.storeIcon,
                      isVerified: product.verifiedSeller ?? false, size: 16,
                    ),
                    const SizedBox(width: Dimensions.padding2xSmall),
                    Expanded(child: Text(
                      product.restaurantName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                    )),
                    if (hasRating) ...[
                      const SizedBox(width: Dimensions.padding2xSmall),
                      _ratingRow(context, inline: true),
                    ],
                  ]),
                  const SizedBox(height: 8),
                ] else if (hasRating) ...[
                  _ratingRow(context, inline: false),
                  const SizedBox(height: 8),
                ],
                Text(
                  product.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: context.heading.defaultSize.medium,
                ),
                const SizedBox(height: 7),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8, alignment: WrapAlignment.start,
                  children: [
                    Text(
                      PriceConverter.convertPrice(discountPrice),
                      textDirection: TextDirection.ltr,
                      style: context.heading.large.strong.overrideWith(color: context.primary),
                    ),
                    if (discountPrice < price)
                      Text(
                        PriceConverter.convertPrice(price),
                        textDirection: TextDirection.ltr,
                        style: context.subHeading.small.copyWith(
                          color: context.primary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: context.primary,
                          decorationThickness: 2,
                        ),
                      ),
                  ],
                ),
                if (isBogoOfferItem) ...[
                  if (bogoQuantity != null) ...[
                    const SizedBox(height: Dimensions.paddingSmall),
                    Text('${'qty'.tr} : $bogoQuantity', style: context.heading.defaultSize.medium),
                  ],
                  if (bogoVariationText != null && bogoVariationText!.isNotEmpty) ...[
                    const SizedBox(height: Dimensions.padding2xSmall),
                    ReadMoreText(
                      bogoVariationText!,
                      trimMode: TrimMode.Line,
                      trimLines: 2,
                      style: context.body.small.regular,
                      colorClickableText: context.primary,
                      lessStyle: context.body.small.strong.overrideWith(color: context.primary),
                      moreStyle: context.body.small.strong.overrideWith(color: context.primary),
                      trimCollapsedText: 'show_more'.tr,
                      trimExpandedText: ' ${'show_less'.tr}',
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: Dimensions.paddingSmall),
                  Wrap(spacing: 7, runSpacing: 7, children: [
                    if (hasDiscount) OfferBadgeWidget(text: _discountBadgeText(discount, discountType), icon: Images.discountPercentIcon),
                    if (hasFreeDelivery) OfferBadgeWidget(text: 'free'.tr, freeDelivery: true),
                  ]),
                ],
                if (bogoAddOnText != null && bogoAddOnText!.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Text('${'addons'.tr} : $bogoAddOnText', style: context.body.small.regular),
                ],
              ]),
            ),
          ),
          SizedBox(width: 115, height: 115,
            child: ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomImageWidget(image: product.imageFullUrl ?? '', width: 120, height: 120, fit: BoxFit.cover, isFood: true),
                ),
                Positioned(top: 8, left: 8,
                  child: Row(children: [
                    if (showHalal) const _ImageRoundBadge(assetPath: Images.halal),
                    if (showHalal && showVeg) const SizedBox(width: 5),
                    if (showVeg) const _ImageRoundBadge(assetPath: Images.nonVeg),
                  ]),
                ),
                if (!isAvailable) const NotAvailableWidget(fontSize: 12),
                if (!fromCartSuggestion) Positioned(top: 8, right: 8,
                  child: GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                      final bool isWished = favouriteController.wishProductIdList.contains(product.id);
                      return  CustomFavouriteWidget(id: product.id!, isWished: isWished, size: 16, widgetSize: 24, isCircular: true,);
                    },
                  ),
                ),
                if (!isBogoOfferItem) Positioned(right: 7, bottom: 7, child: _cartButton(context, price, discountPrice)),

              ]),
            ),
          ),
        ]),
      );

    if (isBogoOfferItem) {
      return content;
    }
    return CustomInkWellWidget(onTap: () => _openProduct(context), child: content);
  }

  String _discountBadgeText(double discount, String discountType) {
    if (discountType == 'percent') return '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%';
    return PriceConverter.convertPrice(discount);
  }

  Widget _cartButton(BuildContext context, double price, double discountPrice) {
    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<CartController>(builder: (cartController) {
        if (product.id == null || product.restaurantId == null) {
          return const SizedBox();
        }
        final int cartQty = cartController.cartQuantity(product.id!, product.restaurantId!);
        int bundleIndex, cartIndex;
        (bundleIndex, cartIndex) = cartController.isExistInCart(product.id, product.restaurantId!);

        final CartModel? cartModel = (bundleIndex != -1 && cartIndex != -1)
            ? cartController.cartBundleList[bundleIndex].carts![cartIndex] : null;

        return QuantityStepperWidget(
          quantity: cartQty,
          collapsible: false,
          onAdd: () {
            if (!isCampaign && (product.variations == null || product.variations!.isEmpty)) {
              productController.setExistInCart(product);
              OnlineCart onlineCart = OnlineCart(null, product.id, null, product.price!.toString(), [], 1, [], [], [], 'Food', variationOptionIds: [], restaurantId: product.restaurantId);
              Get.find<CartController>().addToCartOnline(onlineCart);
            } else {
              _openProduct(context);
            }
          },
          onDecrement: cartController.isLoading || cartModel == null ? null : () {
            if (cartModel.quantity! > 1) {
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

class _ImageRoundBadge extends StatelessWidget {
  final String assetPath;

  const _ImageRoundBadge({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26, width: 26,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CustomAssetImageWidget(assetPath),
    );
  }
}
