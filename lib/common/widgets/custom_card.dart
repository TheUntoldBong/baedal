import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isBorder;
  final Color? borderColor;
  final bool showShadow;
  const CustomCard({super.key, this.child, this.width, this.height, this.borderRadius, this.margin, this.padding, this.isBorder = false, this.borderColor, this.showShadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity, height: height,
      margin: margin, padding: padding,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusLarge+1),
        border: isBorder ? Border.all(color: context.outline, width: 1) : null,
        boxShadow: [
        ],
      ),
      child: child,
    );
  }
}
