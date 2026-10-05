import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionTypeButton extends StatelessWidget {
  final CheckoutController checkoutController;
  final String type;
  final int index;
  const SubscriptionTypeButton({super.key, required this.checkoutController, required this.type, required this.index});

  @override
  Widget build(BuildContext context) {
    bool isSelected = checkoutController.subscriptionTypeIndex == index;
    return InkWell(
      onTap: () => checkoutController.setSubscriptionType(type, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
          border: Border.all(color: isSelected ? context.primary : context.outline, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          RadioGroup<int>(
            groupValue: checkoutController.subscriptionTypeIndex,
            onChanged: (int? value) => checkoutController.setSubscriptionType(type, index),
            child: Radio<int>(
              value: index,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
                  ? context.primary : context.bgNeutralMedium),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            ),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),

          Flexible(child: Text(type.tr, style: context.subHeading.defaultSize.strong, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
