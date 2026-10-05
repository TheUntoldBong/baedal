import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class DineInRestaurantsCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  const DineInRestaurantsCardWidget({super.key, required this.restaurant});


  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active! ;
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSmall),
      child: Stack(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? double.infinity : 400,
            height: 150,
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: context.primary),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      height: 65, width: 65,
                      decoration:  BoxDecoration(
                        color: context.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        child: CustomImageWidget(
                          image: '${restaurant.logoFullUrl}',
                          fit: BoxFit.cover, height: 65, width: 65,
                          isRestaurant: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(
                                restaurant.name!,
                                overflow: TextOverflow.ellipsis, maxLines: 1,
                                style: context.heading.defaultSize.semiBold,
                              ),
                            ),
                            if(restaurant.verifiedSeller == true) ...[
                              const SizedBox(width: Dimensions.padding2xSmall),
                              const RestaurantVerifiedIconWidget(),
                            ],
                          ]),
                          SizedBox(height: Dimensions.padding2xSmall),

                          characteristics.isNotEmpty ? Text(characteristics, style: context.body.small.regular) : const SizedBox(),
                          SizedBox(height: characteristics.isNotEmpty ? Dimensions.padding2xSmall : 0),

                          Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                            IconWithTextRowWidget(
                              icon: Icons.star_border, text: restaurant.avgRating!.toStringAsFixed(1),
                              style: context.heading.small.strong
                            ),

                          ]),
                        ],
                      ),
                    ),
                  ]),

                restaurant.cuisineNames?.isNotEmpty ?? false ? Wrap(
                  children: restaurant.cuisineNames!.map((cuisine) {
                    return Text(
                      '${cuisine.name!}, ' , style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    );
                  }).toList(),
                ) : const SizedBox(),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.access_time, color: isAvailable ? Colors.green : Colors.red, size: 20),
                    Text(isAvailable ? 'open_now'.tr : 'closed_now'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: isAvailable ? Colors.green : Colors.red)),
                  ]),

                  (restaurant.distanceLabel?.isNotEmpty ?? false) ? ImageWithTextRowWidget(
                    widget: CustomAssetImageWidget(Images.distanceKm, height: 20, width: 20),
                    text: restaurant.distanceLabel!,
                    style: context.body.small.regular,
                  ) : const SizedBox(),

                ]),
              ]),
            ),
          ),

          Positioned(
            top: 10, right: 10,
            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
              bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
              return CustomFavouriteWidget(
                isWished: isWished,
                isRestaurant: true,
                id: restaurant.id!,
              );
            }),
          ),
        ],
      ),
    );
  }
}
