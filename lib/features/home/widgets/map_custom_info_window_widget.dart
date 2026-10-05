import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MapCustomInfoWindowWidget extends StatelessWidget {
  final Restaurant? restaurant;
  final UserInfoModel? userInfoModel;
  const MapCustomInfoWindowWidget({super.key, this.restaurant, this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, width: 200,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.primary, width: 0.1),
        ),
        padding: const EdgeInsets.all(Dimensions.padding2xSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImageWidget(
              image: restaurant != null ? '${restaurant?.logoFullUrl}' : '${userInfoModel?.imageFullUrl}',
              fit: BoxFit.fill, height: 30, width: 30,
            ),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),

          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            restaurant != null ? Row(children: [
              Flexible(
                child: Text(
                  restaurant?.name ?? userInfoModel?.fName ?? 'guest_user'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.heading.small.medium,
                ),
              ),
              if(restaurant?.verifiedSeller == true) ...[
                const SizedBox(width: Dimensions.padding2xSmall),
                const RestaurantVerifiedIconWidget(size: 12),
              ],
            ]) : Text(
              userInfoModel != null ? '${userInfoModel?.fName} ${userInfoModel?.lName}' : 'guest_user'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.heading.small.medium,
            ),
            const SizedBox(height: 2),

            restaurant != null ? Row(children: [
              Icon(Icons.star_rounded, color: context.primary, size: 12),

              Text(
                restaurant?.avgRating?.toStringAsFixed(1)??'',
                style: context.subHeading.extraSmall.regular,
              ),
              const SizedBox(width: Dimensions.padding2xSmall),

              Text('(${restaurant?.ratingCount})', style: context.body.extraSmall.medium.overrideWith(color: context.textBaseMedium)),
            ]) : const SizedBox(),
          ]))
        ]),
      ),
    );
  }
}