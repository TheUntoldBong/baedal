import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class TotalRatingReviewViewWidget extends StatelessWidget {
  final bool isRating;
  final int totalNumber;
  const TotalRatingReviewViewWidget({super.key, required this.totalNumber, required this.isRating});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Dimensions.padding2xSmall),
        decoration: BoxDecoration(
          color: context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        ),
        child: Text('$totalNumber ${isRating ? 'ratings'.tr : 'reviews'.tr}', textAlign: TextAlign.center,
          style: context.body.extraSmall.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6)).copyWith(fontSize: 8),
        ),
      ),
    );
  }
}