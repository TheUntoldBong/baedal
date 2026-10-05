import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class SeeAllCardWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback onTap;
  const SeeAllCardWidget({super.key, this.width, this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Column(children: [
        Container(
          width: width, height: height,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.arrow_forward, color: context.primary),
        ),
        const SizedBox(height: 4),
        Text('see_all'.tr, style: context.subHeading.defaultSize.strong.overrideWith(color: context.primary)),
      ]),
    );
  }
}
