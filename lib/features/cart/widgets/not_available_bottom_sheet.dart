import 'package:stackfood_multivendor/common/widgets/option_selection_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NotAvailableBottomSheet extends StatelessWidget {
  const NotAvailableBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    return OptionSelectionBottomSheetWidget(
      title: 'if_any_product_is_not_available'.tr,
      options: cartController.notAvailableList,
      initialIndex: cartController.notAvailableIndex,
      onApply: (index) => cartController.setAvailableIndex(index),
    );
  }
}
