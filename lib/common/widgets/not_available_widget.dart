import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NotAvailableWidget extends StatelessWidget {
  final double fontSize;
  final bool isRestaurant;
  final double opacity;
  final Color color;
  final double? radius;
  const NotAvailableWidget({super.key, this.fontSize = 8, this.isRestaurant = false, this.opacity = 0.6, this.color = Colors.white, this.radius});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, bottom: 0, right: 0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius ?? Dimensions.radiusExtraSmall), color: Colors.black.withValues(alpha: opacity)),
        child: Text(
          isRestaurant ? 'closed_now'.tr : 'not_available_now_break'.tr, textAlign: TextAlign.center,
          style: context.subHeading.small.regular.overrideWith(color: color).copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}
