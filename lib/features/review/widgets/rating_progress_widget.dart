import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/styles.dart';

class RatingProgressWidget extends StatelessWidget {
  final String ratingNumber;
  final double ratingPercent;
  final double progressValue;
  const RatingProgressWidget({super.key, required this.ratingNumber, required this.ratingPercent, required this.progressValue});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Row(children: [

      Text(ratingNumber, style: context.subHeading.small.medium),
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(
        child: LinearProgressIndicator(
          minHeight: isDesktop ? Dimensions.paddingSmall : Dimensions.padding2xSmall,
          value: progressValue,
          backgroundColor: context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          valueColor: AlwaysStoppedAnimation<Color>(context.primary),
        ),
      ),

      Container(
        alignment: Alignment.centerRight,
        width: 50,
        child: Text('${ratingPercent.toStringAsFixed(1)}%', style: context.body.small.medium.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.5))),
      ),

    ]);
  }
}