import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/helper/delivery_time_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SaverDeliveryTimeWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  final double deliveryCharge;
  final double originalDeliveryCharge;
  const SaverDeliveryTimeWidget({super.key, required this.checkoutController, required this.deliveryCharge, required this.originalDeliveryCharge});

  static bool canShow(CheckoutController checkoutController, double deliveryCharge, double originalDeliveryCharge) {
    final ZoneData? saverZoneData = checkoutController.saverZoneData;
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    final bool belowOriginalDeliveryCharge = saverZoneData?.minimumDeliveryCharge != null
        && originalDeliveryCharge >= 0
        && originalDeliveryCharge < saverZoneData!.minimumDeliveryCharge!;
    final bool belowCurrentDeliveryCharge = saverZoneData?.minimumDeliveryCharge != null
        && deliveryCharge >= 0
        && deliveryCharge < saverZoneData!.minimumDeliveryCharge!;
    final bool hasCurrentEligibleDeliveryCharge = deliveryCharge > 0 && !belowCurrentDeliveryCharge;
    final bool hadEligibleOriginalDeliveryCharge = originalDeliveryCharge > 0 && !belowOriginalDeliveryCharge;
    final bool disableSaverOptions = isFreeDeliveryCouponApplied && deliveryCharge == 0 && hadEligibleOriginalDeliveryCharge;

    final bool isProFullFreeDelivery = ProHelper.isFullFreeDelivery(Get.find<CartController>().subTotal);

    return checkoutController.orderType == 'delivery'
        && !checkoutController.subscriptionOrder
        && !isProFullFreeDelivery
        && saverZoneData != null
        && saverZoneData.deliveryOptions != null
        && saverZoneData.status == 1
        && saverZoneData.additionalDeliveryOptionStatus!
        && (hasCurrentEligibleDeliveryCharge || disableSaverOptions);
  }

  @override
  Widget build(BuildContext context) {
    final ZoneData? saverZoneData = checkoutController.saverZoneData;
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    final bool belowOriginalDeliveryCharge = saverZoneData?.minimumDeliveryCharge != null
        && originalDeliveryCharge >= 0
        && originalDeliveryCharge < saverZoneData!.minimumDeliveryCharge!;
    final bool hadEligibleOriginalDeliveryCharge = originalDeliveryCharge > 0 && !belowOriginalDeliveryCharge;
    final bool disableSaverOptions = isFreeDeliveryCouponApplied && deliveryCharge == 0 && hadEligibleOriginalDeliveryCharge;


    final bool canShowSection = canShow(checkoutController, deliveryCharge, originalDeliveryCharge);

    if(disableSaverOptions && checkoutController.saverDeliveryType != 'standard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(checkoutController.saverDeliveryType != 'standard') {
          checkoutController.setSaverDeliveryType('standard');
        }
      });
    }

    return canShowSection ? Column(
      children: [
        const SizedBox(height: Dimensions.paddingDefault),

        AbsorbPointer(
          absorbing: disableSaverOptions,
          child: Opacity(
            opacity: disableSaverOptions ? 0.55 : 1,
            child: RadioGroup<String>(
              groupValue: checkoutController.saverDeliveryType,
              onChanged: (String? value) {
                if(value != null && !disableSaverOptions) {
                  checkoutController.setSaverDeliveryType(value);
                }
              },
              child: ResponsiveHelper.isDesktop(context) ? SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: checkoutController.saverZoneData!.deliveryOptions!.length,
                    itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                    child: SizedBox(
                      width: 270,
                      child: saverCard(context, index),
                    ),
                  );
                }),
              ) : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkoutController.saverZoneData!.deliveryOptions!.length,
                separatorBuilder: (context, index) => SizedBox(height: Dimensions.paddingLarge),
                itemBuilder: (context, index) {
                  return saverCard(context, index);
                }
              ),
            ),
          ),
        ),
        if(disableSaverOptions) ...[
          const SizedBox(height: Dimensions.padding2xSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 18,),
              const SizedBox(width: Dimensions.padding2xSmall),
              Expanded(
                child: Text(
                  'free_delivery_applies_to_this_order_amount_so_delivery_type_charge_options_are_disabled'.tr,
                  style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: Dimensions.paddingSmall),
      ],
    ) : const SizedBox();
  }

  Widget saverCard(BuildContext context, int index) {
    DeliveryOptions deliveryOption = checkoutController.saverZoneData!.deliveryOptions![index];
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    bool select = checkoutController.saverDeliveryType == deliveryOption.deliveryType;
    String storeDeliveryTime = _finalizeDeliveryTime(checkoutController.restaurant?.deliveryTime??'', deliveryOption);
    double totalDeliveryCharge = checkoutController.getSaverDeliveryChargeAdjustment(
      deliveryOption: deliveryOption,
    ) + (isFreeDeliveryCouponApplied ? originalDeliveryCharge : deliveryCharge);
    totalDeliveryCharge = totalDeliveryCharge < 0 ? 0 : totalDeliveryCharge;
    String deliveryChargeText = PriceConverter.convertPrice(totalDeliveryCharge);

    return InkWell(
      onTap: deliveryOption.deliveryType == null ? null : () {
        checkoutController.setSaverDeliveryType(deliveryOption.deliveryType!);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Expanded(
            child: ResponsiveHelper.isDesktop(context) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${deliveryOption.deliveryType?.replaceAll('_', ' ').capitalize} ${'delivery'.tr}', maxLines: 1, style: select ? context.subHeading.defaultSize.strong : context.subHeading.defaultSize.medium),
              const SizedBox(height: Dimensions.paddingOverSmall),
      
              FittedBox(
                child: Text(
                  storeDeliveryTime,
                  style: context.body.defaultSize.regular,
                ),
              ),
      
              const SizedBox(height: Dimensions.paddingOverSmall),
      
              Text(
                '${'charge'.tr}: $deliveryChargeText',
                style: context.body.small.semiBold,
              ),
            ]) : Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text('${deliveryOption.deliveryType?.replaceAll('_', ' ').capitalize} ${'delivery'.tr}', style: select ? context.subHeading.defaultSize.strong : context.subHeading.defaultSize.medium),
                      const SizedBox(width: Dimensions.paddingOverSmall),
      
                      Text(
                        storeDeliveryTime,
                        style: context.body.defaultSize.regular,
                      ),
                  ],
                ),
              ),
            ]),
          ),
          SizedBox(width: Dimensions.paddingSmall,),
      
          if(deliveryOption.extraCharge != null || deliveryOption.reduceCharge != null)
            Container(
              margin: EdgeInsets.only(top: Dimensions.padding2xSmall-3),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
              child: Text(
                deliveryOption.extraCharge != null ? '+ ${PriceConverter.convertPrice(deliveryOption.extraCharge)}'
                    : deliveryOption.reduceCharge != null ? '- ${PriceConverter.convertPrice(deliveryOption.reduceCharge)}'
                    : '',
                style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseMedium),
              ),
            ),
      
          Radio<String>(
            value: deliveryOption.deliveryType ?? '',
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? context.primary : context.iconBaseDefault,
            ),
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),
        ],
      ),
    );
  }

  String _finalizeDeliveryTime(String storeDeliveryTime, DeliveryOptions deliveryOption) {
    String time = '';
    if(storeDeliveryTime.isNotEmpty) {
      try {
        final List<String> timeList = storeDeliveryTime.split('-');
        final String timeUnit = timeList.length >= 3 ? timeList[2] : 'min';

        final List<int> storeMinutes = DeliveryTimeHelper.parseStoreMinutes(storeDeliveryTime);
        int minTime = storeMinutes[0];
        int maxTime = storeMinutes[1];

        int saverMinTime = DeliveryTimeHelper.toMinutes(
          checkoutController.saverZoneData!.minimumDeliveryTime?.value ?? 0,
          checkoutController.saverZoneData!.minimumDeliveryTime?.unit ?? 'min',
        );

        if(minTime > saverMinTime) {
          minTime = saverMinTime;
        }

        if(maxTime < saverMinTime) {
          maxTime = saverMinTime;
        }

        if(deliveryOption.deliveryType == 'standard') {
          time = _formatDeliveryTime(minTime, maxTime);
        } else if(deliveryOption.deliveryType == 'express') {
          int reduceTime = DeliveryTimeHelper.toMinutes(deliveryOption.reduceDeliveryTime?.value ?? 0, deliveryOption.reduceDeliveryTime?.unit ?? timeUnit);
          time = _formatDeliveryTime(minTime, (maxTime - reduceTime).clamp(minTime, 9999999));
        } else if(deliveryOption.deliveryType == 'slightly_delay') {
          int addTime = DeliveryTimeHelper.toMinutes(deliveryOption.addDeliveryTime?.value ?? 0, deliveryOption.addDeliveryTime?.unit ?? timeUnit);
          time = _formatDeliveryTime(minTime, maxTime + addTime);
        }
      }catch(_) {}

    }

    return time;

  }

  String _formatDeliveryTime(int minTime, int maxTime,) {

    String left = getSlidTime(minTime);
    String right = getSlidTime(maxTime);

    bool isLeftContainMin = left.contains('min');
    bool isRightContainMin = right.contains('min');
    bool isLeftContainHour = left.contains('hr');
    bool isRightContainHour = right.contains('hr');

    if(isLeftContainMin && isRightContainMin && !isLeftContainHour && !isRightContainHour){
      left = left.replaceAll(' min', '');
      right = right.replaceAll(' min', '');
      if(left == right) {
        return '(${'upto'.tr} $left min)';
      }
      return '($left - $right) min';
    }
    if(!isLeftContainMin && !isRightContainMin && isLeftContainHour && isRightContainHour){
      left = left.replaceAll(' hr', '');
      right =  right.replaceAll(' hr', '');
      if(left == right) {
        return '(${'upto'.tr} $left hr)';
      }
      return '($left - $right) hr';
    }
    if(left == right) {
      return '(${'upto'.tr} $left)';
    }
    return '($left - $right)';
  }

  String getSlidTime(int value){
    if(value >=60){
      int h = value ~/ 60;
      int m = value % 60;
      if(m == 0){
        return '$h hr';
      }
      return '$h hr $m min';
    }
    return '$value min';
  }

}
