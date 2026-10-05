import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/pickup_warning_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryOptionButton extends StatelessWidget {
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
  const DeliveryOptionButton({super.key, required this.value, required this.title, required this.charge, required this.isFree, required this.total,
    this.chargeForView, this.deliveryFeeTooltipController, required this.badWeatherCharge, required this.extraChargeForToolTip,
    this.guestNameTextEditingController, this.guestNumberTextEditingController, this.guestEmailController});


  Future<void> _selectOrderType(BuildContext context, CheckoutController checkoutController) async {
    if(checkoutController.orderType == 'delivery' && (value == 'take_away' || value == 'dine_in')) {
      Widget sheet = PickupWarningBottomSheet(orderType: value);
      bool? confirmed = ResponsiveHelper.isDesktop(context)
          ? await Get.dialog<bool>(Dialog(backgroundColor: Colors.transparent, child: sheet))
          : await Get.bottomSheet<bool>(sheet, backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true);
      if(confirmed != true) {
        return;
      }
    }

    checkoutController.setOrderType(value);
    checkoutController.setInstruction(-1);

    if(checkoutController.orderType == 'take_away') {
      checkoutController.addTips(0);
      if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
        double tips = 0;
        try{
          tips = double.parse(checkoutController.tipController.text);
        } catch(_) {}
        checkoutController.checkBalanceStatus(total, discount: charge! + tips);
      }
    }else if(checkoutController.orderType == 'dine_in') {
      checkoutController.addTips(0);
      if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
        double tips = 0;
        try{
          tips = double.parse(checkoutController.tipController.text);
        } catch(_) {}
        checkoutController.checkBalanceStatus(total, discount: charge! + tips);
      }

      if(AuthHelper.isLoggedIn()) {
        String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          guestNameTextEditingController?.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.lName ?? ''}';
          guestNumberTextEditingController?.text = phone;
          guestEmailController?.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
        });
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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == value;
        return InkWell(
          onTap: () => _selectOrderType(context, checkoutController),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
              border: Border.all(color: select ? context.primary : context.outline, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
            child: Row(
              children: [
                RadioGroup(
                  groupValue: checkoutController.orderType,
                  onChanged: (String? value) => _selectOrderType(context, checkoutController),
                  child: Radio(
                    value: value,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
                        ? context.primary : context.iconBaseLight),
                    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                  ),
                ),
                const SizedBox(width: Dimensions.padding2xSmall),

                Text(title, style: context.subHeading.defaultSize.strong),

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
