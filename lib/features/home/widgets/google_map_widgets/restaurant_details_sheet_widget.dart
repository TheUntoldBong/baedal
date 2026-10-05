import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RestaurantDetailsSheetWidget extends StatelessWidget {
  final Restaurant restaurant;
  final bool isActive;
  final bool fromOrder;
  const RestaurantDetailsSheetWidget({super.key, required this.restaurant, required this.isActive, this.fromOrder = false});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(fromOrder ? 0 : 15),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''),
            arguments: RestaurantScreen(restaurant: restaurant),
          );
        },
        child: Container(
          width: 380, height: fromOrder ? 160 : 150,
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
            border: isActive ? Border.all(color: context.primary, width: 1) : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImageWidget(
                      image: '${restaurant.logoFullUrl}',
                      height: 60, width: 60, fit: BoxFit.cover, isRestaurant: true,
                    )),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Flexible(
                    child: Text(
                      '${restaurant.name}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.heading.large.strong,
                    ),
                  ),
                  if(restaurant.verifiedSeller == true) ...[
                    const SizedBox(width: Dimensions.padding2xSmall),
                    const RestaurantVerifiedIconWidget(size: 16),
                  ],
                ]),
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(children: [
                  Icon(Icons.storefront, color: context.iconBaseMedium, size: 18),
                  const SizedBox(width: Dimensions.padding2xSmall),

                  Flexible(child: _RestaurantAddressText(restaurant: restaurant)),
                ]),
                const SizedBox(height: 2),

                restaurant.avgRating! > 0 ? Row(children: [
                  Icon(Icons.star_rounded, color: context.primary, size: 18),

                  Text(
                    (restaurant.avgRating ?? 0).toStringAsFixed(1),
                    style: context.heading.defaultSize.strong,
                  ),
                  const SizedBox(width: Dimensions.padding2xSmall),

                  Text('(${restaurant.ratingCount})', style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                ]) : SizedBox.shrink(),

              ])),
              const SizedBox(width: Dimensions.paddingSmall),

              Column(children: [

                GetBuilder<FavouriteController>(builder: (favouriteController) {
                  if(restaurant.id == null) {
                    return const SizedBox();
                  }
                  bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                  return CustomFavouriteWidget(
                    isWished: isWished,
                    isRestaurant: true,
                    id: restaurant.id!,
                  );
                }),
                const SizedBox(height: Dimensions.paddingSmall),

                InkWell(
                  onTap: () async {
                    String url ='https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude}'
                        ',${restaurant.longitude}&mode=d';
                    if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                    }else {
                    showCustomSnackBar('unable_to_launch_google_map'.tr);
                    }
                  },
                  child: const Icon(Icons.directions),
                ),

              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSmall),

            if(restaurant.distanceLabel?.isNotEmpty ?? false) Row( children: [
              Text(restaurant.distanceLabel!, style: context.heading.large.strong),
              Text(' ${'away'.tr}', style: context.heading.large.strong),
            ]),

          ]),

        ),
      ),
    );
  }
}

class _RestaurantAddressText extends StatefulWidget {
  final Restaurant restaurant;
  const _RestaurantAddressText({required this.restaurant});

  @override
  State<_RestaurantAddressText> createState() => _RestaurantAddressTextState();
}

class _RestaurantAddressTextState extends State<_RestaurantAddressText> {

  String get _listAddress => widget.restaurant.address?.trim() ?? '';

  @override
  void initState() {
    super.initState();

    if(_listAddress.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<RestaurantController>().fetchRestaurantAddress(widget.restaurant);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      final String address = _listAddress.isNotEmpty
          ? _listAddress : (restaurantController.cachedAddress(widget.restaurant.id) ?? '');

      return Text(
        address.isNotEmpty ? address : 'no_address_found'.tr, maxLines: 1,
        style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium), overflow: TextOverflow.ellipsis,
      );
    });
  }
}
