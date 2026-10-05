import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProPaymentBottomSheetWidget extends StatefulWidget {
  final PlanItem plan;
  final bool isRenew;
  const ProPaymentBottomSheetWidget({super.key, required this.plan, required this.isRenew});

  @override
  State<ProPaymentBottomSheetWidget> createState() => _ProPaymentBottomSheetWidgetState();
}

class _ProPaymentBottomSheetWidgetState extends State<ProPaymentBottomSheetWidget> {
  int _selectedDigitalIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.plan.price ?? 0;
    final double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
    final bool canPayWallet = walletBalance >= totalPrice;
    final bool hasWallet = Get.find<SplashController>().configModel!.customerWalletStatus!;
    final bool hasDigital = Get.find<SplashController>().configModel!.digitalPayment! && Get.find<SplashController>().configModel!.activePaymentMethodList!.isNotEmpty;
    final paymentMethods = Get.find<SplashController>().configModel!.activePaymentMethodList!;

    return SizedBox(
      width: 550,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.vertical(top: const Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0)),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 30, width: 30,
                    decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(50)),
                    child: Icon(Icons.clear, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          Text('choose_payment_method'.tr, style: context.heading.defaultSize.strong),
          const SizedBox(height: Dimensions.padding2xSmall),
          Text('total_bill'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
          Text(PriceConverter.convertPrice(totalPrice), style: context.heading.extraOverLarge.strong.overrideWith(color: context.primary)),
          const SizedBox(height: Dimensions.paddingLarge),

          Flexible(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if(!hasWallet && !hasDigital) Text('no_payment_method_is_enabled'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),

                if(hasWallet) Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    border: Border.all(color: context.outline),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('wallet_balance'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                      Text(PriceConverter.convertPrice(walletBalance), style: context.heading.extraLarge.strong),
                    ])),
                    OutlinedButton(
                      onPressed: () {
                        if(!canPayWallet) {
                          showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
                          return;
                        }
                        Get.back();
                        Get.find<ProController>().subscribePlan(widget.plan, 'wallet', 'wallet',  widget.isRenew);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.primary),
                        foregroundColor: context.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                      ),
                      child: Text('apply'.tr, style: context.heading.defaultSize.medium.overrideWith(color: context.primary)),
                    ),
                  ]),
                ),

                if(hasDigital) ...[
                  SizedBox(height: Dimensions.paddingLarge,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      border: Border.all(color: context.outline),
                    ),
                    padding: EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.paddingDefault),
                        Text('pay_via_online'.tr, style: context.subHeading.defaultSize.semiBold),
                        const SizedBox(height: Dimensions.paddingSmall),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final paymentMethod = paymentMethods[index];
                            final bool isSelected = _selectedDigitalIndex == index;
                            return InkWell(
                              onTap: () => setState(() => _selectedDigitalIndex = index),
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                                padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                child: Row(children: [
                                  CustomImageWidget(height: 20, width: 40, fit: BoxFit.contain, image: paymentMethod.getWayImageFullUrl ?? ''),
                                  const SizedBox(width: Dimensions.paddingSmall),
                                  Expanded(child: Text(paymentMethod.getWayTitle ?? '', style: context.subHeading.defaultSize.medium)),
                                  Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? context.primary : Colors.transparent,
                                      border: Border.all(color: isSelected ? context.primary : context.outlineVariant, width: 1.5),
                                    ),
                                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                      ])
                  )
                ]
              ]),
            ),
          ),

          if(hasDigital) ...[
            const SizedBox(height: Dimensions.paddingDefault),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDigitalIndex == -1 ? null : () {
                  final paymentMethod = paymentMethods[_selectedDigitalIndex];
                  Get.back();
                  Get.find<ProController>().subscribePlan(widget.plan, 'digital_payment', paymentMethod.getWay ?? '', widget.isRenew);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  disabledBackgroundColor: context.primary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  elevation: 0,
                ),
                child: Text('proceed'.tr, style: context.heading.defaultSize.strong.overrideWith(color: context.onPrimary)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
