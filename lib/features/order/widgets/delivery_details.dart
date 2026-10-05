import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
class DeliveryDetails extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetails({super.key, this.from = true, this.address});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(from ? Icons.storefront_rounded : Icons.location_on, size: 28, color: from ? Colors.blue : context.primary),
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(from ? 'from_restaurant'.tr : 'To'.tr, style: context.subHeading.defaultSize.medium),
        const SizedBox(height: Dimensions.padding2xSmall),

        Text(
          address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
        )
      ])),
    ]);
  }
}
