import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/option_selection_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class DeliveryInstructionBottomSheet extends StatelessWidget {
  const DeliveryInstructionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController = Get.find<CheckoutController>();
    return OptionSelectionBottomSheetWidget(
      title: 'add_more_delivery_instruction'.tr,
      options: AppConstants.deliveryInstructionList,
      initialIndex: checkoutController.selectedInstruction,
      onApply: (index) => checkoutController.setInstruction(index),
    );
  }
}
