import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OfferBadgeWidget extends StatelessWidget {
  final String text;
  final String? icon;
  final bool freeDelivery;

  const OfferBadgeWidget({super.key, required this.text, this.icon, this.freeDelivery = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: Dimensions.paddingOverSmall),
      decoration: BoxDecoration(
        color: context.bgErrorLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            CustomAssetImageWidget(icon!, height: 11, color: context.iconDangerLight),
            const SizedBox(width: Dimensions.paddingOverSmall),
          ],
          if (freeDelivery) ...[
            Icon(Icons.pedal_bike_outlined, size: 11, color: context.iconDangerLight),
            const SizedBox(width: Dimensions.paddingOverSmall),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.subHeading.small.semiBold.overrideWith(color: context.textDangerLight),
            ),
          ),
        ],
      ),
    );
  }
}
