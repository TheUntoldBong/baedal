import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class CustomCardWidget extends StatelessWidget {
  final Widget child;
  const CustomCardWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          gradient: LinearGradient(
            colors: [
              context.surfaceContainer,
              context.surfaceContainer,
              context.primary.withValues(alpha: 0.2),
              context.primary.withValues(alpha: 0.5),
              context.primary,
            ],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        child: child,
      ),
    );
  }
}
