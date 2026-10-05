import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/tips_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final CheckoutController checkoutController;
  final double totalPrice;
  final Function(double x) onTotalChange;
  const DeliveryManTipsSection({super.key, required this.takeAway, required this.tooltipController3, required this.checkoutController, required this.totalPrice, required this.onTotalChange});

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    bool isDineIn = (widget.checkoutController.orderType == 'dine_in');
    final List<int> tipsDisplayOrder = [
      0,
      AppConstants.tips.length - 1,
      for (int i = 1; i < AppConstants.tips.length - 1; i++) i,
    ];

    return Column(
      children: [
        (!widget.checkoutController.subscriptionOrder && !widget.takeAway && !isDineIn && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: context.surfaceContainer,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('delivery_tips'.tr, style: context.subHeading.extraLarge.strong),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  'add_a_tip_to_show_your_appreciation_for_your_delivery_partner'.tr,
                  style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                ),
              ])),
              const SizedBox(width: Dimensions.paddingDefault),

              (widget.checkoutController.selectedTips == AppConstants.tips.length-1) ? const SizedBox() : InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                onTap: () => widget.checkoutController.toggleDmTipSave(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('save_for_later'.tr, style: context.heading.small.regular),
                    const SizedBox(width: Dimensions.paddingSmall),

                    SizedBox(
                      height: 12, width: 12,
                      child: Checkbox(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: context.primary,
                        value: widget.checkoutController.isDmTipSave,
                        onChanged: (bool? isChecked) => widget.checkoutController.toggleDmTipSave(),
                        side: BorderSide(width: 1, color: context.outlineVariant),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          SizedBox(height: Dimensions.paddingDefault),

          (widget.checkoutController.selectedTips == AppConstants.tips.length-1) && widget.checkoutController.canShowTipsField
          ? const SizedBox() : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tipsDisplayOrder.map((index) {
                return TipsWidget(
                  index: index,
                  title: AppConstants.tips[index] == '0' ? 'not_now'.tr : (index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
                  isSelected: widget.checkoutController.selectedTips == index,
                  isSuggested: index != 0 && AppConstants.tips[index] == widget.checkoutController.mostDmTipAmount.toString(),
                  onTap: () {
                    total = total - widget.checkoutController.tips;
                    widget.checkoutController.updateTips(index);
                    if(widget.checkoutController.selectedTips != AppConstants.tips.length-1) {
                      widget.checkoutController.addTips(double.parse(AppConstants.tips[index]));
                    }
                    if(widget.checkoutController.selectedTips == AppConstants.tips.length-1) {
                      widget.checkoutController.showTipsField();
                    }
                    widget.checkoutController.tipController.text = widget.checkoutController.tips.toString();
                    if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                      widget.checkoutController.checkBalanceStatus(total, extraCharge: widget.checkoutController.tips);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: (widget.checkoutController.selectedTips == AppConstants.tips.length-1) && widget.checkoutController.canShowTipsField ? Dimensions.padding2xSmall : 0),

          widget.checkoutController.selectedTips == AppConstants.tips.length-1 ? Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Row(children: [
              Expanded(
                child: CustomTextFieldWidget(
                  titleText: 'enter_amount'.tr,
                  controller: widget.checkoutController.tipController,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.number,
                  onSubmit: (value) async {
                    if(value.isNotEmpty){
                      try{
                        if(double.parse(value) >= 0){
                          if(Get.find<AuthController>().isLoggedIn()) {
                            total = total - widget.checkoutController.tips;
                            await widget.checkoutController.addTips(double.parse(value));
                            total = total + widget.checkoutController.tips;
                            widget.onTotalChange(total);
                            if(Get.find<ProfileController>().userInfoModel!.walletBalance! < total && widget.checkoutController.paymentMethodIndex == 1){
                              widget.checkoutController.checkBalanceStatus(total);
                              canCheckSmall = true;
                            } else if(Get.find<ProfileController>().userInfoModel!.walletBalance! > total && canCheckSmall && widget.checkoutController.isPartialPay){
                              widget.checkoutController.checkBalanceStatus(total);
                            }
                          } else {
                            widget.checkoutController.addTips(double.parse(value));
                          }
            
                        }else{
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        }
                      } catch(e) {
                        showCustomSnackBar('invalid_input'.tr);
                        widget.checkoutController.addTips(0.0);
                        widget.checkoutController.tipController.text = widget.checkoutController.tipController.text.substring(0, widget.checkoutController.tipController.text.length-1);
                        widget.checkoutController.tipController.selection = TextSelection.collapsed(offset: widget.checkoutController.tipController.text.length);
                      }
                    }else{
                      widget.checkoutController.addTips(0.0);
                    }
                  },
            
                  onChanged: (String value) async {
                    if(value.isNotEmpty){
                      try{
                        if(double.parse(value) >= 0){
                          if(Get.find<AuthController>().isLoggedIn()) {
                            total = total - widget.checkoutController.tips;
                            await widget.checkoutController.addTips(double.parse(value));
                            total = total + widget.checkoutController.tips;
                            widget.onTotalChange(total);
                            if(Get.find<ProfileController>().userInfoModel!.walletBalance! < total && widget.checkoutController.paymentMethodIndex == 1){
                              widget.checkoutController.checkBalanceStatus(total);
                              canCheckSmall = true;
                            } else if(Get.find<ProfileController>().userInfoModel!.walletBalance! > total && canCheckSmall && widget.checkoutController.isPartialPay){
                              widget.checkoutController.checkBalanceStatus(total);
                            }
                          } else {
                            widget.checkoutController.addTips(double.parse(value));
                          }
            
                        }else{
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        }
                      } catch(e){
                        showCustomSnackBar('invalid_input'.tr);
                        widget.checkoutController.addTips(0.0);
                        widget.checkoutController.tipController.text = widget.checkoutController.tipController.text.substring(0, widget.checkoutController.tipController.text.length-1);
                        widget.checkoutController.tipController.selection = TextSelection.collapsed(offset: widget.checkoutController.tipController.text.length);
                      }
                    }else{
                      widget.checkoutController.addTips(0.0);
                    }
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),
            
              InkWell(
                onTap: () {
                  widget.checkoutController.updateTips(0);
                  widget.checkoutController.showTipsField();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  child: const Icon(Icons.clear),
                ),
              ),
            
            ]),
          ) : const SizedBox(),

        ]) : const SizedBox.shrink(),

        SizedBox(height: (!widget.takeAway && !isDineIn && Get.find<SplashController>().configModel!.dmTipsStatus == 1)
            ? Dimensions.paddingSmall : 0),
      ],
    );
  }
}
