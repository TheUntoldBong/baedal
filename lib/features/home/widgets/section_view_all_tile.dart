import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SectionViewAllTile extends StatelessWidget {
  final VoidCallback onTap;
  final double leftPadding;
  final double rightPadding;
  const SectionViewAllTile({super.key, required this.onTap, this.leftPadding = Dimensions.paddingLarge, this.rightPadding = Dimensions.paddingLarge});

  @override
  Widget build(BuildContext context) {
    final Color primary = context.primary;
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 56, width: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withValues(alpha: 0.1)),
            child: Icon(Icons.arrow_forward, color: primary, size: 26),
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          Text('view_all'.tr, style: context.subHeading.small.medium.overrideWith(color: primary)),
        ]),
      ),
    );
  }
}
