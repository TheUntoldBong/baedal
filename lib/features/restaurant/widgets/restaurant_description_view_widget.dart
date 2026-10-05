import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class RestaurantDescriptionViewWidget extends StatelessWidget {
  final Restaurant? restaurant;
  const RestaurantDescriptionViewWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {

    return Column(children: [
      SizedBox(height: Dimensions.paddingSmall),

      IntrinsicHeight(
        child: Row(children: [
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant!.id, restaurant!.name, restaurant!)),
            child: Column(children: [
              Row(children: [
                Icon(Icons.star, color: context.primary, size: 20),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text(
                  restaurant!.avgRating!.toStringAsFixed(1),
                  style: context.body.small.medium,
                ),
              ]),
              const SizedBox(height: Dimensions.padding2xSmall),
              Text(
                '${restaurant!.ratingCount} + ${'ratings'.tr}',
                style: context.body.small.regular,
              ),
            ]),
          ),
          const Expanded(child: SizedBox()),

          const VerticalDivider(color: Colors.white, thickness: 1),
          const Expanded(child: SizedBox()),

          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getMapRoute(
              AddressModel(
                id: restaurant!.id, address: restaurant!.address, latitude: restaurant!.latitude,
                longitude: restaurant!.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
              ), 'restaurant',
            )),
            child: Column(children: [
              CustomAssetImageWidget(Images.restaurantLocationIcon, height: 20, width: 20),
              const SizedBox(height: Dimensions.padding2xSmall),
              Text('location'.tr, style: context.body.small.regular),
            ]),
          ),
          const Expanded(child: SizedBox()),
          const VerticalDivider(color: Colors.white, thickness: 1),
          const Expanded(child: SizedBox()),

          Column(children: [
            Row(children: [
              CustomAssetImageWidget(Images.restaurantDeliveryTimeIcon, height: 20, width: 20),
              const SizedBox(width: Dimensions.padding2xSmall),
            ]),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text(restaurant!.deliveryTime!, style: context.body.small.medium),
          ]),
          (restaurant!.delivery! && restaurant!.freeDelivery!) ? const Expanded(child: SizedBox()) : const SizedBox(),
          (restaurant!.delivery! && restaurant!.freeDelivery!) ? Column(children: [
            Icon(Icons.money_off, color: context.primary, size: 20),
            const SizedBox(width: Dimensions.padding2xSmall),
            Text('free_delivery'.tr, style: context.body.small.regular),
          ]) : const SizedBox(),
          const Expanded(child: SizedBox()),
        ]),
      ),

    ]);
  }
}