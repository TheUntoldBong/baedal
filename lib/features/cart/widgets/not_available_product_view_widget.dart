import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/not_available_bottom_sheet.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NotAvailableProductViewWidget extends StatelessWidget {
  final CartController cartController;
  const NotAvailableProductViewWidget({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            InkWell(
              onTap: (){
                showModalBottomSheet(
                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (con) => const NotAvailableBottomSheet(),
                );
              },
              child: Row(children: [
                Expanded(child: Text(
                  'if_any_product_is_not_available'.tr,
                  style: context.heading.large.strong,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                )),
                Icon(Icons.keyboard_arrow_right, size: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
              ]),
            ),

            cartController.notAvailableIndex != -1 ? Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
              child: Container(
                padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingSmall, top: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(children: [
                  Expanded(child: Text(
                    cartController.notAvailableList[cartController.notAvailableIndex].tr,
                    style: context.body.small.regular.overrideWith(color: context.textBaseDefault),
                  )),
                  const SizedBox(width: Dimensions.paddingSmall),

                  InkWell(
                    onTap: ()=> cartController.setAvailableIndex(-1),
                    child: Icon(Icons.close, size: 18, color: context.iconBaseMedium),
                  ),
                ]),
              ),
            ) : const SizedBox(),

          ]),
        ),

      ],
    );
  }
}
