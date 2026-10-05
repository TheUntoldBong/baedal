import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/coupon_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/info_view_widget.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

class RestaurantInfoSectionWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final bool hasCoupon;
  const RestaurantInfoSectionWidget({super.key, required this.restaurant, required this.restController, required this.hasCoupon});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double xyz = MediaQuery.of(context).size.width-1170;
    final double realSpaceNeeded = xyz/2;

    return SliverAppBar(
      expandedHeight: isDesktop ? 350 : hasCoupon ? 400 : 300,
      toolbarHeight: isDesktop ? 150 : 90,
      pinned: true, floating: false, elevation: 0.5,
      backgroundColor: context.surfaceContainer,
      leading: !isDesktop ? IconButton(
        icon: Container(
          height: 50, width: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.primary),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: Dimensions.padding2xSmall),
          child: Icon(Icons.chevron_left, color: context.surfaceContainer, size: 28),
        ),
        onPressed: () => Get.back(),
      ) : const SizedBox(),

      flexibleSpace: GetBuilder<CouponController>(
        builder: (couponController) {
          bool hasCoupons = couponController.couponList != null && couponController.couponList!.isNotEmpty;
          return Container(
            margin: isDesktop ? EdgeInsets.symmetric(horizontal: realSpaceNeeded) : EdgeInsets.zero,
            child: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              centerTitle: true,
              expandedTitleScale: isDesktop ? 1 : 1.1,
              title: CustomizableSpaceBarWidget(
                builder: (context, scrollingRate) {
                  return !isDesktop ? Container(
                    color: context.surfaceContainer.withValues(alpha: scrollingRate),
                    padding: EdgeInsets.only(
                      bottom: 0,
                      left: Get.find<LocalizationController>().isLtr ? 40 * scrollingRate : 0,
                      right: Get.find<LocalizationController>().isLtr ? 0 : 40 * scrollingRate,
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: (hasCoupon ? 260 : 160) - (scrollingRate * 25),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)]
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                        padding: EdgeInsets.only(
                          left: Get.find<LocalizationController>().isLtr ? 20 : 0,
                          right: Get.find<LocalizationController>().isLtr ? 0 : 20,
                          top: scrollingRate * (context.height * 0.035)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSmall - (scrollingRate * Dimensions.paddingSmall)),
                          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [

                            InfoViewWidget(restaurant: restaurant, restController: restController, scrollingRate: scrollingRate),
                            SizedBox(height: Dimensions.paddingLarge - (scrollingRate * (isDesktop ? 2 : Dimensions.paddingLarge))),

                            scrollingRate < 0.8 ? CouponViewWidget(scrollingRate: scrollingRate) : const SizedBox(),

                          ]),
                        ),
                      ),
                    ),
                  ) : Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: restaurant.announcementActive! ? 200 : 160,
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: hasCoupons ? Dimensions.paddingDefault : 200, vertical: Dimensions.paddingSmall),
                      child: Column(
                        children: [
                          restaurant.announcementActive != null && restaurant.announcementActive! && restaurant.announcementMessage != null ? Container(
                            height: 40 - (scrollingRate * 40),
                            padding: EdgeInsets.only(
                              left: Get.find<LocalizationController>().isLtr ? 250 : 20,
                              right: Get.find<LocalizationController>().isLtr ? 20 : 250,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              CustomAssetImageWidget(Images.announcement, height: 26, width: 26),
                              const SizedBox(width: Dimensions.paddingSmall),

                              Flexible(
                                child: Marquee(
                                  text: restaurant.announcementMessage!,
                                  style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                                  blankSpace: 20.0,
                                  velocity: 100.0,
                                  accelerationDuration: const Duration(seconds: 5),
                                  decelerationDuration: const Duration(milliseconds: 500),
                                  accelerationCurve: Curves.linear,
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                            ]),
                          ) : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Row(children: [

                                  SizedBox(width: 250  - (scrollingRate * 90)),

                                  Expanded(child: InfoViewWidget(restaurant: restaurant, restController: restController, scrollingRate: scrollingRate)),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  hasCoupons ? Expanded(child: CouponViewWidget(scrollingRate: scrollingRate)) : const SizedBox(),

                                ]),

                                Positioned(left: Get.find<LocalizationController>().isLtr ? 30 : null, right: Get.find<LocalizationController>().isLtr ? null : 30, top: - 80 + (scrollingRate * 77), child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.surfaceContainer,
                                    border: Border.all(color: context.primary, width: 0.2),
                                    boxShadow: [BoxShadow(color: context.primary.withValues(alpha: 0.3), blurRadius: 10)]
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(500),
                                    child: Stack(children: [
                                      CustomImageWidget(
                                        image: '${restaurant.logoFullUrl}',
                                        height: 200 - (scrollingRate * 90), width: 200 - (scrollingRate * 90), fit: BoxFit.cover,
                                        isRestaurant: true,
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
                                ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              background: Container(
                margin: EdgeInsets.only(bottom: isDesktop ? 100 : (hasCoupon ? 200 : 100)),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusLarge)),
                  child: CustomImageWidget(
                    height: 100,
                    fit: BoxFit.cover, placeholder: Images.restaurantCover,
                    image: '${restaurant.coverPhotoFullUrl}',
                    isRestaurant: true,
                  ),
                ),
              ),
            ),
          );
        }
      ),
      actions: const [SizedBox()],
    );
  }
}