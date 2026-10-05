import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryInstructionSection extends StatelessWidget {
  const DeliveryInstructionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: 'delivery_instruction'.tr,
                style: context.subHeading.defaultSize.medium,
                children: [
                  TextSpan(
                    text: ' (${'optional'.tr})',
                    style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingMedium),

        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            itemCount: AppConstants.deliveryInstructionList.length,
            itemBuilder: (context, index) {
              bool isSelected = checkoutController.selectedInstruction == index;
              return Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  onTap: () => checkoutController.setInstruction(isSelected ? -1 : index),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: isSelected ? context.outlineVariant : context.outline,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      AppConstants.deliveryInstructionList[index].tr,
                      style: (isSelected ? context.subHeading.defaultSize.strong : context.subHeading.defaultSize.regular).copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]);
    });
  }
}
