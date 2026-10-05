import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NoDataScreen extends StatelessWidget {
  final String? title;
  final bool fromAddress;
  final bool isEmptyAddress;
  final bool isEmptyCart;
  final bool isEmptyChat;
  final bool isEmptyOrder;
  final bool isEmptyCoupon;
  final bool isEmptyFood;
  final bool isEmptyNotification;
  final bool isEmptyRestaurant;
  final bool isEmptySearchFood;
  final bool isEmptyTransaction;
  final bool isEmptyWishlist;
  const NoDataScreen({super.key, required this.title,  this.fromAddress = false,
    this.isEmptyAddress = false, this.isEmptyCart = false, this.isEmptyChat = false, this.isEmptyOrder = false, this.isEmptyCoupon = false,
    this.isEmptyFood = false, this.isEmptyNotification = false, this.isEmptyRestaurant = false, this.isEmptySearchFood = false, this.isEmptyTransaction = false,
    this.isEmptyWishlist = false});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      child: Column(mainAxisAlignment: fromAddress ? MainAxisAlignment.start : MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

        fromAddress ? SizedBox(height : isDesktop ? height * 0.1 : height * 0.25) : SizedBox(
          height: isEmptyTransaction || isEmptyCoupon ? height * 0.15  : isDesktop ? height * 0.2 : height * 0.3,
        ),

        Center(
          child: CustomAssetImageWidget(
            isEmptyAddress ? Images.emptyAddress : isEmptyCart ? Images.emptyCart : isEmptyChat ? Images.emptyChat : isEmptyOrder ? Images.emptyOrder
            : isEmptyCoupon ? Images.emptyCoupon : isEmptyFood ? Images.emptyFood : isEmptyNotification ? Images.emptyNotification
            : isEmptyRestaurant ? Images.emptyRestaurant : isEmptySearchFood ? Images.emptySearchFood : isEmptyTransaction ? Images.emptyTransaction
            : isEmptyWishlist ? Images.emptyWishlist : Images.emptyFood,
            width: isDesktop ? 130 : 80, height: isDesktop ? 130 : 80,
          ),
        ),
        SizedBox(height: fromAddress ? 10 : 10),

        Text(
          title ?? '',
          style: context.heading.defaultSize.medium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: fromAddress ? 10 : MediaQuery.of(context).size.height * 0.03),

        fromAddress ? Text(
          'please_add_your_address_for_your_better_experience'.tr,
          style: context.subHeading.defaultSize.regular.copyWith(color: context.textBaseMedium),
          textAlign: TextAlign.center,
        ) : const SizedBox(),
        SizedBox(height: isEmptyAddress ? 30 : MediaQuery.of(context).size.height * 0.05),

        fromAddress ? InkWell(
          onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: context.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault, horizontal: Dimensions.paddingSizeExtraOverLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline_sharp, size: 18.0, color: context.surfaceContainer),
                const SizedBox(width: Dimensions.paddingSmall),

                Text('add_address'.tr, style: context.heading.defaultSize.strong.overrideWith(color: Theme.of(context).colorScheme.onPrimary)),
              ],
            ),
          ),
        ) : const SizedBox(),

      ]),
    );
  }
}
