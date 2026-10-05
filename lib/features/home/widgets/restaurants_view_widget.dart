import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_distance_cliper_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

const double _cardDetailsHeight = 95;

class RestaurantsViewWidget extends StatelessWidget {
  final List<Restaurant?>? restaurants;
  final void Function(Restaurant restaurant)? onRestaurantTap;
  const RestaurantsViewWidget({super.key, this.restaurants, this.onRestaurantTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: restaurants != null ? restaurants!.isNotEmpty ? ((ResponsiveHelper.isMobile(context) && !ResponsiveHelper.isTab(context))
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: restaurants!.length,
            separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingExtraLarge),
            itemBuilder: (context, index) => RestaurantCardWidget.detailed(
              restaurant: restaurants![index]!, isQuick: false,
              onTap: onRestaurantTap == null ? null : () => onRestaurantTap!(restaurants![index]!),
            ),
          )
        : LayoutBuilder(builder: (context, constraints) {
            final int crossAxisCount = ResponsiveHelper.isTab(context) ? 2 : 4;
            final double tileWidth = (constraints.maxWidth - (Dimensions.paddingDefault * (crossAxisCount - 1))) / crossAxisCount;

            return GridView.builder(
              shrinkWrap: true,
              itemCount: restaurants!.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: Dimensions.paddingDefault,
                crossAxisSpacing: Dimensions.paddingDefault,
                mainAxisExtent: (tileWidth / 2) + _cardDetailsHeight,
              ),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(child: RestaurantCardWidget.detailed(
                      restaurant: restaurants![index]!, isQuick: false,
                      onTap: onRestaurantTap == null ? null : () => onRestaurantTap!(restaurants![index]!),
                    )),
                  ],
                );
              },
            );
          })) : Center(child: Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingOverLarge),
        child: Column(
          children: [
            const SizedBox(height: 110),
            const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text('there_is_no_restaurant'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
          ],
        ),
      )) : ((ResponsiveHelper.isMobile(context) && !ResponsiveHelper.isTab(context))
        ? const RestaurantCardShimmerListWidget()
        : LayoutBuilder(builder: (context, constraints) {
            final int crossAxisCount = ResponsiveHelper.isTab(context) ? 2 : 4;
            final double tileWidth = (constraints.maxWidth - (Dimensions.paddingDefault * (crossAxisCount - 1))) / crossAxisCount;

            return GridView.builder(
              shrinkWrap: true,
              itemCount: 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: Dimensions.paddingDefault,
                crossAxisSpacing: Dimensions.paddingDefault,
                mainAxisExtent: (tileWidth / 2) + _cardDetailsHeight,
              ),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => const RestaurantCardShimmerWidget.detailed(),
            );
          })),

    );
  }
}

class RestaurantView extends StatelessWidget {
  final Restaurant restaurant;
  final Function()? onTap;
  final bool isSelected;
  const RestaurantView({super.key, required this.restaurant, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}${v.trim()}';
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        border: isSelected ? Border.all(color: context.primary, width: 1) : null,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: CustomInkWellWidget(
        onTap: onTap ?? () {
          if(restaurant.restaurantStatus == 1){
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''), arguments: RestaurantScreen(restaurant: restaurant));
          }else if(restaurant.restaurantStatus == 0){
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        radius: Dimensions.radiusDefault,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                child: CustomImageWidget(
                  image: '${restaurant.coverPhotoFullUrl}',
                  fit: BoxFit.cover, height: 110, width: double.infinity,
                  isRestaurant: true,
                ),
              ),
            ),

            !isAvailable ? Positioned(child: Container(
              height: 110, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              ),
            )) : const SizedBox(),

            !isAvailable ? Positioned(top: 10, left: 10, child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge)
              ),
              padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraLarge, vertical: Dimensions.padding2xSmall),
              child: Row(children: [
                Icon(Icons.access_time, size: 12, color: context.surfaceContainer),
                const SizedBox(width: Dimensions.padding2xSmall),

                Text(
                  restaurant.restaurantOpeningTime == 'closed' ? 'closed_now'.tr : '${'closed_now'.tr} ${!restaurant.active! ? '' : '(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(restaurant.restaurantOpeningTime!)})'}',
                  style: context.subHeading.small.medium.overrideWith(color: context.surfaceContainer),
                ),
              ]),
            )) : const SizedBox(),

            Positioned(
              top: 70, left: 10, right: 0,
              child: Column(
                children: [
                  Container(
                    height: 70, width: 70,
                    decoration:  BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      border: Border.all(color: context.outline, width: 2.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.5),
                      child: CustomImageWidget(
                        image: '${restaurant.logoFullUrl}',
                        fit: BoxFit.cover, height: 70, width: 70,
                        isRestaurant: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Flexible(
                      child: Text(
                        restaurant.name ?? '',
                        style: context.heading.defaultSize.strong,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if(restaurant.verifiedSeller == true) ...[
                      const SizedBox(width: Dimensions.padding2xSmall),
                      const RestaurantVerifiedIconWidget(),
                    ],
                  ]),
                  SizedBox(height: characteristics != '' ? Dimensions.padding2xSmall : Dimensions.paddingSmall),

                  characteristics != '' ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      characteristics,
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    ),
                  ) : const SizedBox(),
                  SizedBox(height: characteristics != '' ? Dimensions.padding2xSmall : 0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      restaurant.ratingCount! > 0 ? IconWithTextRowWidget(
                        icon: Icons.star, text: restaurant.avgRating!.toStringAsFixed(1),
                        style: context.heading.extraSmall.strong,
                      ) : const SizedBox(),
                      SizedBox(width: restaurant.ratingCount! > 0 ? Dimensions.paddingDefault : 0),

                      restaurant.freeDelivery! ? ImageWithTextRowWidget(
                        widget: CustomAssetImageWidget(Images.deliveryIcon, height: 20, width: 20),
                        text: 'free'.tr,
                        style: context.body.extraSmall.regular,
                      ) : const SizedBox(),
                      SizedBox(width: restaurant.freeDelivery! ? Dimensions.paddingDefault : 0),

                      IconWithTextRowWidget(
                        icon: Icons.access_time_outlined, text: '${restaurant.deliveryTime}',
                        style: context.body.extraSmall.regular,
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
              child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                return CustomFavouriteWidget(
                  isWished: isWished,
                  isRestaurant: true,
                  id: restaurant.id!,
                );
              }),
            ),

            (restaurant.distanceLabel?.isNotEmpty ?? false) ? Positioned(
              top: 86, right: 20,
              child: ClipPath(
                clipper: CurvedTopClipper(),
                child: Container(
                  height: 25,
                  color: context.surfaceContainer,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                  child: Center(
                    child: Text(restaurant.distanceLabel!,
                        style: context.subHeading.extraSmall.medium.overrideWith(color: context.primary)),
                  ),
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class WebRestaurantShimmer extends StatelessWidget {
  final bool isDineInRestaurant;
  const WebRestaurantShimmer({super.key, this.isDineInRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        color: Theme.of(context).shadowColor,
        border: Border.all(color: Theme.of(context).shadowColor),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Stack(clipBehavior: Clip.none, children: [

            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              child: Shimmer(
                child: Container(
                  height: 93, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 60, left: 10, right: isDineInRestaurant ? null : 0,
              child: Column(
                crossAxisAlignment: isDineInRestaurant ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    height: 70, width: 70,
                    decoration:  BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    child: Shimmer(
                      child: Container(height: 15, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    child: Shimmer(
                      child: Container(height: 10, width: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconWithTextRowWidget(
                        icon: Icons.star_border, text: '0.0',
                        color: Theme.of(context).shadowColor,
                        style: context.heading.extraSmall.strong.overrideWith(color: Theme.of(context).shadowColor),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                        child: ImageWithTextRowWidget(
                          widget: CustomAssetImageWidget(Images.deliveryIcon, height: 20, width: 20, color: Theme.of(context).shadowColor),
                          text: 'free'.tr,
                          style: context.body.extraSmall.regular.overrideWith(color: Theme.of(context).shadowColor),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingDefault),

                      IconWithTextRowWidget(
                        icon: Icons.access_time_outlined, text: '10-30 min',
                        color: Theme.of(context).shadowColor,
                        style: context.body.extraSmall.regular.overrideWith(color: Theme.of(context).shadowColor),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
              child: Icon(
                Icons.favorite,  size: 20,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}