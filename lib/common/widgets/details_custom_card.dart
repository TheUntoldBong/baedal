import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';

class DetailsCustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isBorder;
  const DetailsCustomCard({super.key, this.child, this.width, this.height, this.borderRadius, this.margin, this.padding, this.isBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity, height: height,
      margin: margin, padding: padding,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusDefault),
        border: isBorder ? Border.all(color: context.outline, width: 1.5) : null,
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }
}
