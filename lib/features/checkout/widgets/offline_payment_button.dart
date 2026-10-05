import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class OfflinePaymentButton extends StatelessWidget {
  final bool isSelected;
  final List<OfflineMethodModel>? offlineMethodList;
  final bool isOfflinePaymentActive;
  final Function? onTap;
  final CheckoutController checkoutController;
  final JustTheController tooltipController;
  final bool? disablePayment;
  const OfflinePaymentButton({super.key, required this.isSelected, required this.offlineMethodList, required this.isOfflinePaymentActive, required this.onTap,
    required this.checkoutController, required this.tooltipController, this.disablePayment = false});

  @override
  Widget build(BuildContext context) {
    return (isOfflinePaymentActive && offlineMethodList != null && offlineMethodList!.isNotEmpty) ? InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        width: 550,
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          border: Border.all(color: context.outline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
        child: Column(children: [
          Row(children: [

            Expanded(
              child: Row(children: [

                Flexible(
                  child: Text(
                    'pay_offline'.tr,
                    style: context.subHeading.defaultSize.semiBold.overrideWith(color: disablePayment! ? context.textBaseMedium : context.textBaseDefault),
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),

                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: tooltipController,
                  preferredDirection: AxisDirection.up,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('note'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: const Color(0xff90D0FF))),
                          const SizedBox(height: Dimensions.paddingSmall),

                          OfflinePaymentTooltipNoteWidget(
                            note: 'offline_payment_note_line_one'.tr,
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),

                          OfflinePaymentTooltipNoteWidget(
                            note: 'offline_payment_note_line_two'.tr,
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),

                          OfflinePaymentTooltipNoteWidget(
                            note: 'offline_payment_note_line_three'.tr,
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => tooltipController.showTooltip(),
                    child: isSelected ? Icon(Icons.info_rounded, color: context.primary, size: 18) : const SizedBox(),
                  ),
                ),

              ]),
            ),


            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 24,
              color: isSelected ? context.primary : context.iconDisabledDefault,
            ),
          ]),
          SizedBox(height: isSelected ? Dimensions.paddingLarge : 0),

          isSelected ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: Dimensions.paddingDefault,
              mainAxisSpacing: Dimensions.paddingDefault,
              mainAxisExtent: 50,
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 3,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: offlineMethodList!.length,
            itemBuilder: (context, index) {
              bool isSelected = checkoutController.selectedOfflineBankIndex == index;
              return InkWell(
                onTap: () => checkoutController.selectOfflineBank(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? context.textBaseDefault.withValues(alpha: 0.8) : context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  child: Center(child: Text(offlineMethodList![index].methodName!,
                    style: context.subHeading.defaultSize.medium.overrideWith(color: isSelected ? context.surfaceContainer : context.textBaseDefault),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                ),
              );
            },
          ) : const SizedBox(),

        ]),
      ),
    ) : const SizedBox();
  }
}

class OfflinePaymentTooltipNoteWidget extends StatelessWidget {
  final String note;
  const OfflinePaymentTooltipNoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: Dimensions.paddingSmall),
        Expanded(
          flex: 0,
          child: Container(
            height: 5, width: 5,
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(child: Text(note, style: context.body.defaultSize.regular.overrideWith(color: context.surfaceContainer))),
      ],
    );
  }
}
