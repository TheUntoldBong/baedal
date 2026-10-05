import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_status_card.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/order/widgets/address_details_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/helper/map_camera_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackDetailsView extends StatelessWidget {
  final OrderModel track;
  final Function callback;
  const TrackDetailsView({super.key, required this.track, required this.callback});

  @override
  Widget build(BuildContext context) {
    double distance = 0;
    bool takeAway = track.orderType == 'take_away';
    final bool ongoing = track.orderStatus != 'delivered' && track.orderStatus != 'failed' && track.orderStatus != 'canceled'
        && track.orderStatus != 'refund_requested' && track.orderStatus != 'refunded' && track.orderStatus != 'refund_request_canceled';
    final LatLng? deliveryAddressLatLng = MapCameraHelper.toLatLng(track.deliveryAddress?.latitude, track.deliveryAddress?.longitude);
    final LatLng? deliveryManLatLng = MapCameraHelper.toLatLng(track.deliveryMan?.lat, track.deliveryMan?.lng);
    if(deliveryAddressLatLng != null && deliveryManLatLng != null) {
      distance = Geolocator.distanceBetween(
        deliveryAddressLatLng.latitude, deliveryAddressLatLng.longitude,
        deliveryManLatLng.latitude, deliveryManLatLng.longitude,
      ) / 1000;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge, horizontal: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: context.surfaceContainer,
      ),
      alignment: Alignment.center,
      child: Column(children: [

        Container(
          height: 5, width: 80,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSmall),

        OrderStatusCard(order: track, ongoing: ongoing, total: track.orderAmount ?? 0),
        const SizedBox(height: Dimensions.paddingDefault),

        takeAway ? InkWell(
          onTap: () async {
            final LatLng? restaurantLatLng = MapCameraHelper.toLatLng(track.restaurant?.latitude, track.restaurant?.longitude);
            if(restaurantLatLng == null) {
              showCustomSnackBar('unable_to_launch_google_map'.tr);
              return;
            }
            String url = 'https://www.google.com/maps/dir/?api=1'
                '&destination=${restaurantLatLng.latitude},${restaurantLatLng.longitude}&travelmode=driving';
            if (await canLaunchUrlString(url)) {
              Get.find<OrderController>().cancelTimer();
              await launchUrlString(url, mode: LaunchMode.externalApplication);
              Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: track.id.toString());
            }else {
              showCustomSnackBar('unable_to_launch_google_map'.tr);
            }
          },
          child: Column(children: [
            Icon(Icons.directions, size: 25, color: context.primary),
            Text(
              'direction'.tr,
              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
            ),
            const SizedBox(height: Dimensions.paddingSmall),
          ]),
        ) : Column(children: [
          CustomAssetImageWidget(Images.route, height: 20, width: 20, color: context.primary),
          Text(
            '${distance.toStringAsFixed(2)} ${'km'.tr}',
            style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
          ),
          const SizedBox(height: Dimensions.paddingSmall),
        ]),

        Row(children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            decoration: BoxDecoration(
              color: context.surface,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),

          Flexible(
            child: Text(
              takeAway ? track.deliveryAddress!.address! : track.deliveryMan!.location??'no_address_found'.tr,
              style: context.body.defaultSize.medium.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.7)),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

        ]),

        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 3),
            color: context.bgNeutralMedium,
            height: 20, width: 3,
          ),
        ),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),

          Flexible(
            child: takeAway ? Text(track.restaurant != null ? track.restaurant!.address! : '',
              style: context.body.defaultSize.medium.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.7)),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ) : AddressDetailsWidget(addressDetails: track.deliveryAddress),
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSmall),

        Container(
          width: context.width,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              takeAway ? 'restaurant_details'.tr : 'delivery_man_details'.tr,
              style: context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseMedium),
            ),
            const SizedBox(height: Dimensions.paddingSmall),

            Row(children: [

              ClipOval(child: CustomImageWidget(
                image: '${takeAway ? track.restaurant != null ? track.restaurant!.logoFullUrl : '' : track.deliveryMan!.imageFullUrl}',
                height: 45, width: 45, fit: BoxFit.cover,
              )),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(
                      takeAway ? track.restaurant != null ? track.restaurant!.name! : 'no_restaurant_data_found'.tr : '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.heading.small.strong,
                    ),
                  ),
                  if(takeAway && track.restaurant?.verifiedSeller == true) ...[
                    const SizedBox(width: Dimensions.padding2xSmall),
                    const RestaurantVerifiedIconWidget(),
                  ],
                ]),

                RatingBarWidget(
                  rating: takeAway ? track.restaurant != null ? track.restaurant!.avgRating : 0 : track.deliveryMan!.avgRating, size: 15,
                  ratingCount: takeAway ? track.restaurant != null ? track.restaurant!.ratingCount : 0 : track.deliveryMan!.ratingCount,
                ),
              ])),

              Get.find<AuthController>().isLoggedIn() ? InkWell(
                onTap: callback as void Function()?,
                child: CustomAssetImageWidget(Images.chatImageOrderDetails, height: 25, width: 25),
              ) : const SizedBox(),
              const SizedBox(width: Dimensions.paddingLarge),

              InkWell(
                onTap: () async {
                  if(await canLaunchUrlString('tel:${takeAway ? track.restaurant != null ? track.restaurant!.phone : '' : track.deliveryMan!.phone}')) {
                    launchUrlString('tel:${takeAway ? track.restaurant != null ? track.restaurant!.phone : '' : track.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                  }else {
                    showCustomSnackBar('${'can_not_launch'.tr} ${takeAway ? track.restaurant != null ? track.restaurant!.phone : '' : track.deliveryMan!.phone}');
                  }

                },
                child: CustomAssetImageWidget(Images.callImageOrderDetails, height: 25, width: 25),
              ),

            ]),

          ]),
        ),

      ]),
    );
  }
}
