import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/see_all_card_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/features/search/helper/restaurant_tag_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantAndItemsWidget extends StatelessWidget {
  final Restaurant restaurant;
  final EdgeInsetsGeometry? restaurantHeaderPadding;
  final EdgeInsetsGeometry? itemHorizontalPadding;
  const RestaurantAndItemsWidget({super.key, required this.restaurant, this.restaurantHeaderPadding, this.itemHorizontalPadding});

  void _openRestaurant() {
    Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''), arguments: RestaurantScreen(restaurant: restaurant));
  }

  String _deliveryFeeLabel(Restaurant restaurant) {
    if((restaurant.minimumShippingCharge ?? 0) > 0) {
      return PriceConverter.convertPrice(restaurant.minimumShippingCharge);
    }
    final String rawFee = restaurant.deliveryFee ?? '';
    if(rawFee == 'free_delivery') {
      return 'free_delivery'.tr;
    }
    if(rawFee == 'out_of_range') {
      return 'out_of_range'.tr;
    }
    final double? parsedFee = double.tryParse(rawFee);
    return parsedFee != null ? PriceConverter.convertPrice(parsedFee) : rawFee;
  }

  void _openProduct(BuildContext context, Foods food) {
    Product product = Product(id: food.id);
    ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
      FoodBottomSheetWidget(product: product),
      backgroundColor: Colors.transparent, isScrollControlled: true,
    ) : Get.dialog(Dialog(child: FoodBottomSheetWidget(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    List<Map<String, String?>> tags = RestaurantTagHelper.offerTags(restaurant);
    bool isAd = restaurant.ad ?? false;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
        padding: restaurantHeaderPadding ?? EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        child: CustomInkWellWidget(
          onTap: _openRestaurant,
          radius: Dimensions.radiusDefault,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
            Stack(clipBehavior: Clip.none, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImageWidget(image: restaurant.logoFullUrl ?? '', height: 64, width: 64, fit: BoxFit.cover, isRestaurant: true),
              ),
              if(!isAvailable) NotAvailableWidget(isRestaurant: true, opacity: 0.6, fontSize: 8),
              if(isAd) Positioned(
                left: 2, bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: context.bgNeutralDefault, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                  child: Text('AD', style: context.subHeading.extraSmall.overrideWith(color: Colors.white)),
                ),
              ),
            ]),
            const SizedBox(width: Dimensions.paddingSmall),
        
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(
                    restaurant.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: context.subHeading.large.strong,
                  )),
                  if(restaurant.verifiedSeller == true) ...[
                    const SizedBox(width: Dimensions.padding2xSmall), const RestaurantVerifiedIconWidget(size: Dimensions.paddingDefault),
                  ],
                ]),
                const SizedBox(height: Dimensions.padding2xSmall),
        
                Row(children: [
                  if((restaurant.avgRating ?? 0) > 0) ...[
                    CustomAssetImageWidget(Images.starFill, width: 10, height: 10, color: context.iconWarningLight,),
                    const SizedBox(width: Dimensions.paddingOverSmall),
                    Text(
                      '${restaurant.avgRating!.toStringAsFixed(1)} (${restaurant.ratingCount! > 150 ? '150+' : restaurant.ratingCount})',
                      style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),
                  ],
                  if(restaurant.deliveryTime != null) ...[
                    CustomAssetImageWidget(Images.timeIcon, width: 10, height: 10,),
                    const SizedBox(width: Dimensions.paddingOverSmall),
                    Text('${restaurant.deliveryTime}', style: context.subHeading.small),
                    const SizedBox(width: Dimensions.paddingSmall),
                  ],
                  if(restaurant.distance != null) ...[
                    CustomAssetImageWidget(Images.rideIcon, width: 10, height: 10),
                    const SizedBox(width: Dimensions.paddingOverSmall),
                    Text(
                      _deliveryFeeLabel(restaurant),
                      style: context.subHeading.small,
                    ),
                  ],
                ]),
        
                if(tags.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSmall),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for(int i = 0; i < tags.length && i < 2; i++) OfferBadgeWidget(text: tags[i]['text']!, icon: tags[i]['icon']),
                    if(tags.length > 2) OfferBadgeWidget(text: '+${tags.length - 2}'),
                  ]),
                ],
              ]),
            ),
            Container(height: 32, width: 32, padding: EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.surfaceContainer,
                boxShadow: [BoxShadow(color: context.shadow, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.arrow_forward, size: 20),
            ),
          ]),
        ),
      ),

      if(restaurant.foods != null && restaurant.foods!.isNotEmpty) ...[
        const SizedBox(height: Dimensions.paddingMedium),
        Builder(builder: (context) {
          bool showSeeAllFoods = restaurant.foods!.length > 4;
          int foodItemCount = showSeeAllFoods ? 5 : restaurant.foods!.length;
        
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: itemHorizontalPadding ?? EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(foodItemCount, (index) {
                  final bool isLast = index == foodItemCount - 1;
                  final double rightPadding = isLast ? 0 : Dimensions.paddingMedium;

                  if(showSeeAllFoods && index == 4) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSmall, top: Dimensions.paddingLarge),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SeeAllCardWidget(width: 54, height: 54, onTap: _openRestaurant),
                      ),
                    );
                  }
              
                    Foods food = restaurant.foods![index];
                    double price = food.price ?? 0;
                    double discountPrice = PriceConverter.convertWithDiscount(price, food.discount, food.discountType) ?? price;
              
                    return Padding(
                      padding: EdgeInsets.only(right: rightPadding),
                      child: CustomInkWellWidget(
                        onTap: () => _openProduct(context, food),
                        radius: Dimensions.radiusDefault,
                        child: SizedBox(
                        width: 100,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            width: 100, height: 100,
                            child: Stack(children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault+2),
                                  child: CustomImageWidget(image: food.imageFullUrl ?? '', fit: BoxFit.cover, isFood: true),
                                ),
                              ),
                              Positioned(
                                right: 4, bottom: 4,
                                child: Container(
                                  height: 37, width: 37,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer, borderRadius: BorderRadius.circular(8),
                                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 6, offset: const Offset(0, 2))],
                                  ),
                                  child: Icon(Icons.add, size: 24),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),
                      
                          Text(
                            food.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: context.subHeading.defaultSize.medium,
                          ),
                          const SizedBox(height: Dimensions.paddingExtraSmall),
                      
                          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 4, children: [
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
                          ]),
                        ]),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ],
    ]);
  }
}
