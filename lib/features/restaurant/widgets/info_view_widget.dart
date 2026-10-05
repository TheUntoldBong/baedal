import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class InfoViewWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final double scrollingRate;
  const InfoViewWidget({super.key, required this.restaurant, required this.restController, required this.scrollingRate});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [

        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.primary, width: 0.2),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Stack(children: [
              CustomImageWidget(
                image: '${restaurant.logoFullUrl}',
                height: 60 - (scrollingRate * 15), width: 60 - (scrollingRate * 15), fit: BoxFit.cover,
              ),
              restController.isRestaurantOpenNow(restaurant.active!, restaurant.schedules) ? const SizedBox() : Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusExtraSmall)),
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: Text(
                    'closed_now'.tr, textAlign: TextAlign.center,
                    style: context.body.small.regular.overrideWith(color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Flexible(
              child: Text(
                restaurant.name!, style: context.heading.large.medium.overrideWith(color: context.textBaseDefault)
                    .copyWith(fontSize: Dimensions.fontSizeLarge - (scrollingRate * 3)),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),

            (restaurant.verifiedSeller ?? false) ? const SizedBox(width: Dimensions.padding2xSmall) : const SizedBox(),
            (restaurant.verifiedSeller ?? false) ? RestaurantVerifiedIconWidget(size: 16 - (scrollingRate * 4)) : const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.padding2xSmall),

          Text(
            restaurant.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: context.body.small.regular.overrideWith(color: context.textBaseMedium).copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * 2)),
          ),

          Row(children: [
            Text('start_from'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)
                .copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2))),
            const SizedBox(width: Dimensions.padding2xSmall),
            Text(
              PriceConverter.convertPrice(restaurant.priceStartFrom), textDirection: TextDirection.ltr,
              style: context.body.extraSmall.medium.overrideWith(color: context.primary).copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2)),
            ),
          ]),

        ])),
        const SizedBox(width: Dimensions.paddingSmall),

        Column(children: [
          GetBuilder<FavouriteController>(builder: (favouriteController) {
              bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
              return CustomFavouriteWidget(
                isWished: isWished,
                isRestaurant: true,
                id: restaurant.id!,
                size: 24  - (scrollingRate * 4),
              );
            }),

          const SizedBox(height: Dimensions.paddingSmall),

          AppConstants.webHostedUrl.isNotEmpty ? InkWell(
            onTap: (){
              String shareUrl = '${AppConstants.webHostedUrl}${restController.filteringUrl(restaurant.slug ?? '')}';
              SharePlus.instance.share(
                ShareParams(text: shareUrl),
              );
            },
            child: Icon(
              Icons.share, size: 20  - (scrollingRate * 4),
            ),
          ) : const SizedBox(),
        ]),
        const SizedBox(width: Dimensions.paddingLarge),

      ]),
      SizedBox(height: Dimensions.paddingLarge - (scrollingRate * (Dimensions.paddingLarge))),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Expanded(child: SizedBox()),

        Column(children: [
          Icon(Icons.access_time, color: context.primary, size: 20 - (scrollingRate * (20))),

          Text(restaurant.deliveryTime!, style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color)
              .copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * (Dimensions.fontSizeSmall)))),
        ]),
        const Expanded(child: SizedBox()),

        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getMapRoute(
            AddressModel(
              id: restaurant.id, address: restaurant.address, latitude: restaurant.latitude,
              longitude: restaurant.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
            ), 'restaurant',
            restaurantName: restaurant.name,
          )),
          child: Column(children: [
            CustomAssetImageWidget(Images.restaurantLocationIcon, height: 20 - (scrollingRate * (20)), width: 20 - (scrollingRate * (20)), color: context.primary),
            const SizedBox(width: Dimensions.padding2xSmall),

            Text('location'.tr, style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color)
                .copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * (Dimensions.fontSizeSmall)))),
          ]),
        ),
        const Expanded(child: SizedBox()),

        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant.id, restaurant.name, restaurant)),
          child: Column(children: [
            Row(children: [
              Icon(Icons.star, color: context.primary, size: 20 - (scrollingRate * (20))),
              const SizedBox(width: Dimensions.padding2xSmall),
              Text(
                restaurant.avgRating!.toStringAsFixed(1),
                style: context.body.small.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color)
                    .copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * (Dimensions.fontSizeSmall))),
              ),
            ]),
            const SizedBox(width: Dimensions.padding2xSmall),

            Text(
              '${restaurant.ratingCount} + ${'ratings'.tr}',
              style: context.body.small.regular.overrideWith(color: context.primary)
                  .copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * (Dimensions.fontSizeSmall))),
            ),
          ]),
        ),

        (restaurant.delivery! && restaurant.freeDelivery!) ? const Expanded(child: SizedBox()) : const SizedBox(),

        (restaurant.delivery! && restaurant.freeDelivery!) ? Column(children: [
          Icon(Icons.money_off, color: context.primary, size: 20 - (scrollingRate * (20))),
          const SizedBox(width: Dimensions.padding2xSmall),
          Text(
            'free_delivery'.tr,
            style: context.body.extraSmall.regular.overrideWith(color: context.textBaseDefault)
                .copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * (Dimensions.fontSizeExtraSmall))),
          ),
        ]) : const SizedBox(),

        const Expanded(child: SizedBox()),

      ]),
    ]);
  }
}