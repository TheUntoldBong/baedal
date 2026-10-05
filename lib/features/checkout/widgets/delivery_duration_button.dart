import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DeliveryDurationButton extends StatelessWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final double total;
  final String? chargeForView;
  final JustTheController? deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final TextEditingController? guestNameTextEditingController;
  final TextEditingController? guestNumberTextEditingController;
  final TextEditingController? guestEmailController;
  const DeliveryDurationButton({super.key, required this.value, required this.title, required this.charge, required this.isFree, required this.total,
    this.chargeForView, this.deliveryFeeTooltipController, required this.badWeatherCharge, required this.extraChargeForToolTip,
    this.guestNameTextEditingController, this.guestNumberTextEditingController, this.guestEmailController});

  double? _convertToString(String? value) {
    if(value == null) {
      return null;
    }
    String cleanedValue = value.replaceAll('', Get.find<SplashController>().configModel!.currencySymbol!).trim();
    double? convertedValue = double.tryParse(cleanedValue);
    return convertedValue;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        double? convertedFromStringCharge = chargeForView != null ? _convertToString(chargeForView) : null;
        bool select = checkoutController.orderType == value;
        return InkWell(
          onTap: () async {
            checkoutController.setOrderType(value);
            checkoutController.setInstruction(-1);

            if(checkoutController.orderType == 'take_away') {
              checkoutController.addTips(0);
              if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try{
                  tips = double.parse(checkoutController.tipController.text);
                } catch(_) {}
                checkoutController.checkBalanceStatus(total, discount: (charge! < 0 ? 0 : charge!) + tips);
              }
            }else if(checkoutController.orderType == 'dine_in') {
              checkoutController.addTips(0);
              if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try{
                  tips = double.parse(checkoutController.tipController.text);
                } catch(_) {}
                checkoutController.checkBalanceStatus(total, discount: (charge! < 0 ? 0 : charge!) + tips);
              }

              if(AuthHelper.isLoggedIn()) {
                String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');

                guestNameTextEditingController?.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''}';
                guestNumberTextEditingController?.text = phone;
                guestEmailController?.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
              }

            }else{
              checkoutController.updateTips(
                checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 0, notify: false,
              );

              if(checkoutController.isPartialPay){
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select ? context.surfaceContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              border: Border.all(color: select ? context.primary : context.outline, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
            child: Row(
              children: [
                RadioGroup(
                  groupValue: checkoutController.orderType,
                  onChanged: (String? value) {
                    checkoutController.setOrderType(value!);
                  },
                  child: Radio(
                    value: value,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: context.primary,
                    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                  ),
                ),
                const SizedBox(width: Dimensions.padding2xSmall),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseDefault)),

                  Row(children: [
                    Text(
                      value == 'delivery'
                        ? (convertedFromStringCharge != null && convertedFromStringCharge == 0 ? 'free'.tr : '${'charge'.tr}: +$chargeForView')
                        : 'free'.tr,
                      style: context.body.small.regular.overrideWith(color: context.textBaseDefault),
                    ),
                    const SizedBox(width: Dimensions.padding2xSmall),

                    value == 'delivery' && (chargeForView! != '0') && (extraChargeForToolTip > 0 || badWeatherCharge > 0) ? CustomToolTip(
                      message: extraChargeForToolTip > 0
                        ? '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(extraChargeForToolTip)} ${badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(badWeatherCharge)}' : ''}'
                        : '${'this_charge_include_bad_weather_charge'.tr} ${PriceConverter.convertPrice(badWeatherCharge)}',
                      tooltipController: deliveryFeeTooltipController,
                      preferredDirection: AxisDirection.right,
                      child: const Icon(Icons.info, color: Colors.blue, size: 14),
                    ) : const SizedBox(),
                  ]),

                ]),
                const SizedBox(width: Dimensions.paddingSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode = '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }
}
