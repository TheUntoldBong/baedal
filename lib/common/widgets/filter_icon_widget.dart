import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';

class FilterIconWidget extends StatelessWidget {
  final bool fromAppBar;
  final Color? iconColor;
  const FilterIconWidget({super.key, required this.fromAppBar, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: fromAppBar ? BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        color: context.surfaceContainer,
        border: Border.all(color: context.primary, width: 1.2),
      ) : BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: context.surfaceContainer,
        border: Border.all(color: iconColor ?? context.textBaseDefault, width: 0.5),
      ),
      padding: const EdgeInsets.all(Dimensions.padding2xSmall),
      child: Icon(Icons.tune_sharp, size: fromAppBar ? 18 : 24, color: iconColor ?? context.textBaseDefault),
    );
  }
}
