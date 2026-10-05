import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CouponCardWidget extends StatelessWidget {
  final List<Coupon>? couponList;
  final List<JustTheController>? toolTipController;
  final int index;
  final Function()? onCopyClick;
  final bool unavailable;
  const CouponCardWidget({super.key, required this.index, this.couponList, this.toolTipController, this.onCopyClick, this.unavailable = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        boxShadow: unavailable ? null : [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Stack(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Transform.rotate(
            angle: Get.find<LocalizationController>().isLtr ? 0 : pi,
            child: CustomAssetImageWidget(
              Get.find<ThemeController>().darkTheme ? Images.couponBgDark : Images.couponBgLight,
              height: ResponsiveHelper.isMobilePhone() ? 160 : 150, width: size.width,
              fit: ResponsiveHelper.isMobilePhone() ? BoxFit.cover : BoxFit.contain,
              color: unavailable ? context.surfaceContainer : null,
            ),
          ),
        ),

        Container(
          alignment: Alignment.center,
          child: Row(children: [

            Container(
              alignment: Alignment.center,

              width: ResponsiveHelper.isDesktop(context) ? 150 : size.width * 0.3,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CustomAssetImageWidget(
                  couponList![index].discountType == 'percent' ? Images.percentCouponOffer : couponList![index].couponType
                      == 'free_delivery' ? Images.freeDelivery : Images.money,
                  height: 25, width: 25,
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  '${couponList![index].couponType == 'free_delivery' ? '' : couponList![index].discount}${couponList![index].discountType == 'percent' ? '%'
                      : couponList![index].couponType == 'free_delivery' ?  'free_delivery'.tr
                      : Get.find<SplashController>().configModel!.currencySymbol} ${couponList![index].couponType == 'free_delivery' ? '' : 'off'.tr}',
                  style: context.heading.large.strong.overrideWith(color: unavailable ? context.textBaseMedium : null),
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                couponList![index].restaurant == null ?  Flexible(child: Text(
                  couponList![index].couponType == 'restaurant_wise' ?
                  '${'on'.tr} ${couponList![index].data}' : 'on_all_store'.tr,
                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                  maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                )) : Flexible(child: Text(
                  couponList![index].couponType == 'default' ?
                  '${couponList![index].restaurant!.name}' : couponList![index].couponType == 'restaurant_wise' ? '${couponList![index].restaurant!.name}' : '',
                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
              ]),
            ),
            SizedBox(width: ResponsiveHelper.isDesktop(context) ? 10 : 20),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [

                JustTheTooltip(
                  backgroundColor: Get.find<ThemeController>().darkTheme ? context.surfaceContainer : Colors.black87,
                  controller: toolTipController![index],
                  preferredDirection: AxisDirection.up,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  triggerMode: TooltipTriggerMode.manual,
                  content: unavailable ? SizedBox() : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${'code_copied'.tr} !',style: context.body.defaultSize.regular.overrideWith(color: context.surfaceContainer)),
                  ),
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: unavailable ? context.primary.withValues(alpha: 0.5) : context.primary,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [5, 5],
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
                      radius: const Radius.circular(50),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [

                      Text(
                        '${couponList![index].code}',
                        style: context.subHeading.small.medium.overrideWith(color: unavailable ? context.textBaseMedium : null),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Icon(Icons.copy_rounded, color: unavailable ? context.primary.withValues(alpha: 0.5) : context.primary, size: 20),

                    ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSmall),

                Text(
                  '${DateConverter.stringDateTimeToDate(couponList![index].startDate!)} ${'to'.tr} ${DateConverter.stringDateTimeToDate(couponList![index].expireDate!)}',
                  style: context.body.small.medium.overrideWith(color: unavailable ? context.textBaseMedium : context.textBaseDefault),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text('*', style: context.body.small.regular.overrideWith(color: unavailable ? context.textBaseMedium : context.error)),

                  Text(
                    '${'min_purchase'.tr} ',
                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    PriceConverter.convertPrice(couponList![index].minPurchase),
                    style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                    maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                  ),

                ]),

              ]),
            ),

          ]),
        ),

        if(couponList![index].couponType == 'pro_customer') Positioned.directional(
          textDirection: Directionality.of(context),
          top: Dimensions.paddingSmall,
          start: Dimensions.paddingSmall,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: unavailable ? context.iconBaseMedium : const Color(0xFFB57BEE),
              shape: BoxShape.circle,
            ),
            child: CustomAssetImageWidget(Images.proPlanCrown, height: 14, width: 14, color: Colors.white),
          ),
        ),

      ]),
    );
  }
}
