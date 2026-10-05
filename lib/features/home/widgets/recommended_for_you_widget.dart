import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/features/search/helper/restaurant_tag_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RecommendedForYouWidget extends StatelessWidget {
  const RecommendedForYouWidget({super.key});

  static const double _cardHeight = 94;
  static const double _rowGap = Dimensions.paddingSmall;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final List<Restaurant>? restaurants = restController.recommendedRestaurantList;

      if (restaurants != null && restaurants.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        color: context.surfaceContainer,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          HomeSectionHeaderWidget(name: 'recommended_for_you'),
          SizedBox(height: Dimensions.paddingMedium,),

          restaurants == null ? const _RecommendedShimmer() : SizedBox(
            height: (_cardHeight * 2) + _rowGap,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: Dimensions.paddingLarge),
              itemCount: (restaurants.length / 2).ceil() + 1,
              itemBuilder: (context, colIndex) {
                if (colIndex == (restaurants.length / 2).ceil()) {
                  return SectionViewAllTile(
                    leftPadding: Dimensions.paddingSmall,
                    rightPadding: Dimensions.paddingExtraLarge,
                    onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('recommended')),
                  );
                }
                final int topIndex = colIndex * 2;
                final int bottomIndex = topIndex + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingMedium),
                  child: SizedBox(
                    width: !ResponsiveHelper.isMobile(context) ? 360 :  MediaQuery.of(context).size.width * 0.84,
                    child: Column(children: [
                      SizedBox(height: _cardHeight, child: _RecommendedRestaurantCard(restaurant: restaurants[topIndex])),
                      if (bottomIndex < restaurants.length) ...[
                        const SizedBox(height: _rowGap),
                        SizedBox(height: _cardHeight, child: _RecommendedRestaurantCard(restaurant: restaurants[bottomIndex])),
                      ],
                    ]),
                  ),
                );
              },
            ),
          ),

        ]),
      );
    });
  }
}

class _RecommendedRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RecommendedRestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final Color hintColor = context.textBaseMedium;
    final Color iconColor = context.iconNeutralLight;

    final double deliveryFee = num.tryParse(restaurant.deliveryFee ?? '')?.toDouble() ?? 0;
    final String deliveryFeeText = PriceConverter.convertPrice(deliveryFee);
    final bool isNew = restaurant.isNew ?? false;
    final bool isVerified = restaurant.verifiedSeller == true;
    final bool hasOffers = RestaurantTagHelper.offerTags(restaurant).isNotEmpty;

    final String distanceText = restaurant.distanceLabel ?? '';

    return CustomInkWellWidget(
      onTap: () => Get.toNamed(
        RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''),
        arguments: RestaurantScreen(restaurant: restaurant),
      ),
      radius: Dimensions.radiusDefault,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImageWidget(
              image: '${restaurant.logoFullUrl}',
              height: 94, width: 88, fit: BoxFit.cover, isRestaurant: true,
            ),
          ),

          Positioned(
            top: 6, left: 6,
            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
              final bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
              return Center(child: CustomFavouriteWidget(
                isWished: isWished, isRestaurant: true, id: restaurant.id!, size: 13, widgetSize: 25, isCircular: true,
              ));
            }),
          ),
        ]),
        const SizedBox(width: Dimensions.paddingMedium),

        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  (restaurant.name ?? '').replaceAll(r"\'", "'").replaceAll(r'\"', '"'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.heading.defaultSize,
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(children: [
                  Icon(Icons.access_time, size: 15, color: iconColor),
                  const SizedBox(width: 4),
                  Text(restaurant.deliveryTime ?? '', style: context.subHeading.small),
                  if (distanceText.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Flexible(child: Text(
                      '($distanceText)',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.body.small.overrideWith(color: hintColor),
                    )),
                  ],
                  if(deliveryFee > 0)...[
                    const SizedBox(width: Dimensions.paddingSmall),
                    Icon(Icons.pedal_bike, size: 16, color: iconColor),
                    const SizedBox(width: 4),
                    Text(deliveryFeeText, style: context.subHeading.small),
                  ]
                ]),

                if (hasOffers) ...[
                  const SizedBox(height: Dimensions.padding2xSmall),
                  OfferTagsRow(data: restaurant, maxVisible: 1,),
                ],

                if (isNew || isVerified) ...[
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Row(children: [
                    if (isNew) _NewBadge(),
                    if (isNew && isVerified) const SizedBox(width: Dimensions.padding2xSmall),
                    if (isVerified) _verifiedWidget(context),
                  ]),
                ],

              ],
            ),
          ),
        ),

      ]),
    );
  }

  Container _verifiedWidget(BuildContext context) => Container(
    height: 18, width: 20,
    decoration: BoxDecoration(
      color: context.bgInfoMedium,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
    ),
    child: Center(child: const RestaurantVerifiedIconWidget(size: 12)),
  );
}

class _NewBadge extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall + 1, vertical: 3),
      decoration: BoxDecoration(
        color: context.bgWarningMedium,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: Text('new'.tr, style: context.heading.small.overrideWith(color: context.textWarningMedium,)),
    );
  }
}

class _RecommendedShimmer extends StatelessWidget {
  const _RecommendedShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (RecommendedForYouWidget._cardHeight * 2) + RecommendedForYouWidget._rowGap,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
            child: SizedBox(
              width: ResponsiveHelper.isDesktop(context) ? 360 : MediaQuery.of(context).size.width * 0.84,
              child: Column(children: List.generate(2, (i) => Padding(
                padding: EdgeInsets.only(bottom: i == 0 ? RecommendedForYouWidget._rowGap : 0),
                child: Container(
                  height: RecommendedForYouWidget._cardHeight,
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: context.outline),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Shimmer(child: Container(
                      height: 72, width: 68,
                      decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    )),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Shimmer(child: Container(height: 14, width: 110, color: Theme.of(context).shadowColor)),
                        Shimmer(child: Container(height: 12, width: 160, color: Theme.of(context).shadowColor)),
                        Shimmer(child: Container(height: 16, width: 70, color: Theme.of(context).shadowColor)),
                      ],
                    )),
                  ]),
                ),
              ))),
            ),
          );
        },
      ),
    );
  }
}
