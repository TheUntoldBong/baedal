import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PortionWidget extends StatelessWidget {
  static const double _iconSize = 16;

  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Function()? onTap;
  final bool changeIconColor;
  const PortionWidget({super.key, required this.icon, required this.title, required this.route, this.hideDivider = false, this.suffix, this.onTap, this.changeIconColor = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      child: Column(children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            CustomAssetImageWidget(icon, height: _iconSize, width: _iconSize, color: changeIconColor ? context.iconBaseMedium : null),
            const SizedBox(width: Dimensions.paddingMedium),

            Expanded(child: Text(title, style: context.heading.defaultSize.medium)),

            if(suffix != null) ...[
              const SizedBox(width: Dimensions.paddingSmall),
              Container(
                decoration: BoxDecoration(
                  color: context.error,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall, horizontal: Dimensions.paddingSmall),
                child: Text(suffix!, style: context.heading.small.overrideWith(color: context.onSurfaceVariant)),
              ),
            ],
          ]),
        ),

        if(!hideDivider) const Divider(height: 1, thickness: 1, indent: _iconSize + Dimensions.paddingMedium),

      ]),
    );
  }
}
