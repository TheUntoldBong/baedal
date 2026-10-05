import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;
  const ItemCardWidget({super.key, required this.product, this.isBestItem, this.isPopularNearbyItem = false, this.isCampaignItem = false, this.width = 190});

  @override
  Widget build(BuildContext context) {
    double price = product.price!;
    double discount = product.discount!;
    String discountType = product.discountType!;
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;
    bool isAvailable = DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds);

    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], isCampaignItem, product, [], product.cartQuantityLimit, [],
    );

    return Container(
      width: isPopularNearbyItem! ? double.infinity : width,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CustomInkWellWidget(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            FoodBottomSheetWidget(product: product, isCampaign: isCampaignItem),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: isCampaignItem)),
          );
        },
        radius: Dimensions.radiusDefault,
        child: Column(children: [
          Expanded(
            flex: ResponsiveHelper.isDesktop(context) ? 5 : 6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: isCampaignItem ? const EdgeInsets.all(0) : const EdgeInsets.only(top: Dimensions.padding2xSmall, left: Dimensions.padding2xSmall, right: Dimensions.padding2xSmall),
                  child: ClipRRect(
                    borderRadius: isCampaignItem ? const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)) :
                    BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImageWidget(
                      image: !isCampaignItem ? '${product.imageFullUrl}' : '${product.imageFullUrl}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                      isFood: true,
                    ),
                  ),
                ),

                !isCampaignItem ? Positioned(
                  top: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
                  child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                    bool isWished = favouriteController.wishProductIdList.contains(product.id);
                    return CustomFavouriteWidget(
                      id: product.id!,
                      isRestaurant: false,
                      isWished: isWished,
                    );
                  }),
                ) : const SizedBox(),

                product.isRestaurantHalalActive! && product.isHalalFood! ? Positioned(
                  top: isCampaignItem ? 10 : 40, right: 9,
                  child: const CustomAssetImageWidget(
                    Images.halal,
                    height: 30, width: 30,
                  ),
                ) : const SizedBox(),

                DiscountTagWidget(
                  discount: discount,
                  discountType: discountType,
                  fromTop: isCampaignItem ? 7 : 10, fontSize: Dimensions.fontSizeExtraSmall, paddingVertical: 7, fromLeft: isCampaignItem ? -7 : -2,
                ),

                Positioned(
                  bottom: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
                  child: GetBuilder<ProductController>(builder: (productController) {
                    return GetBuilder<CartController>(builder: (cartController) {
                      int cartQty = cartController.cartQuantity(product.id!, product.restaurantId!);
                      int bundleIndex, cartIndex;
                      (bundleIndex, cartIndex) = cartController.isExistInCart(product.id, product.restaurantId!,);

                      return cartQty != 0 ? Container(
                        decoration: BoxDecoration(
                          color: context.primary,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: Row(children: [
                          InkWell(
                            onTap: cartController.isLoading ? (){} : () {
                              if (cartController.cartBundleList[bundleIndex].carts![cartIndex].quantity! > 1) {
                                cartController.setQuantity(false, cartModel, cartIndex: cartIndex, restaurantId: product.restaurantId!,);
                              }else {
                                cartController.removeFromCart(cartIndex: cartIndex, restaurantId: product.restaurantId!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                              child: Icon(
                                Icons.remove, size: 16, color: context.primary,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                            child: Text(
                              cartQty.toString(),
                              style: context.subHeading.small.medium.overrideWith(color: context.surfaceContainer),
                            ),
                          ),

                          InkWell(
                            onTap: cartController.isLoading ?  (){}  : () {
                              cartController.setQuantity(true, cartModel, cartIndex: cartIndex, restaurantId: product.restaurantId!);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                              child: Icon(
                                Icons.add, size: 16, color: context.primary,
                              ),
                            ),
                          ),
                        ]),
                      ) : InkWell(
                        onTap: () {
                          if(isCampaignItem) {
                            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              FoodBottomSheetWidget(product: product, isCampaign: true),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            ) : Get.dialog(
                              Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: true)),
                            );
                          } else {
                            if(product.variations == null || (product.variations != null && product.variations!.isEmpty)) {

                              productController.setExistInCart(product);

                              OnlineCart onlineCart = OnlineCart(null, product.id, null, product.price!.toString(), [], 1, [], [], [], 'Food', variationOptionIds: [], restaurantId: product.restaurantId);
                              Get.find<CartController>().addToCartOnline(onlineCart);
                            } else {
                              ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                FoodBottomSheetWidget(product: product, isCampaign: false),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              ) : Get.dialog(
                                Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: false)),
                              );
                            }
                          }

                        },
                        child: Container(
                          height: 24, width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.surfaceContainer,
                          ),
                          child: Icon(Icons.add, color: context.primary, size: 20),
                        ),
                      );
                    });
                  }),
                ),

                isAvailable ? const SizedBox() : NotAvailableWidget(
                  opacity: 0.3,
                  fontSize: 14,
                ),

              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(
                crossAxisAlignment: isBestItem == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisAlignment: product.ratingCount! > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
                children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        product.restaurantName ?? '', style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                      ),
                    ),
                    if(product.verifiedSeller == true) ...[
                      const SizedBox(width: Dimensions.padding2xSmall),
                      const RestaurantVerifiedIconWidget(size: 12),
                    ],
                  ],
                ),

                Row(mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Flexible(child: Text(product.name ?? '', style: context.heading.defaultSize.medium, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    const SizedBox(width: Dimensions.padding2xSmall),

                    (Get.find<SplashController>().configModel!.toggleVegNonVeg!)? CustomAssetImageWidget(
                      product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 10, width: 10, fit: BoxFit.contain,
                    ) : const SizedBox(),
                  ],
                ),

                if(product.ratingCount! > 0)
                  Row(
                    mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Text(product.avgRating!.toStringAsFixed(1), style: context.subHeading.extraSmall.regular),
                      const SizedBox(width: Dimensions.padding2xSmall),

                      Icon(Icons.star, color: context.primary, size: 15),
                      const SizedBox(width: Dimensions.padding2xSmall),

                      Text('(${product.ratingCount})', style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                    ],
                  ),

                Wrap(
                  alignment: isBestItem == true ? WrapAlignment.center : WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    discountPrice < price ? Text(PriceConverter.convertPrice(price),
                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium).copyWith(decoration: TextDecoration.lineThrough, decorationColor: context.textBaseMedium)): const SizedBox(),
                    discountPrice < price ? const SizedBox(width: Dimensions.padding2xSmall) : const SizedBox(),

                    Text(PriceConverter.convertPrice(discountPrice), style: context.heading.defaultSize.strong),
                  ],
                ),

              ],
            ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const ItemCardShimmer({super.key, this.isPopularNearbyItem});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: (isPopularNearbyItem! && ResponsiveHelper.isMobile(context)) ? 1 : 5,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                    height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).shadowColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: ResponsiveHelper.isDesktop(context) ? 5 : 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                              child: Shimmer(child: Container(color: Theme.of(context).shadowColor)),
                            ),
                          ),
                        ),
              
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  child: Shimmer(
                                    child: Container(height: 15, width: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  child: Shimmer(
                                    child: Container(height: 12, width: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}
