import 'package:stackfood_multivendor/common/models/review_model.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';


class ReviewDialogWidget extends StatelessWidget {
  final ReviewModel review;
  final bool fromOrderDetails;
  const ReviewDialogWidget({super.key, required this.review, this.fromOrderDetails = false});

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: SizedBox(width: 500, child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: !fromOrderDetails ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipOval(
            child: CustomImageWidget(
              image: review.foodImageFullUrl ?? '',
              height: 60, width: 60, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              review.foodName!, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.heading.small.strong,
            ),

            RatingBarWidget(rating: review.rating!.toDouble(), ratingCount: null, size: 15),

            Text(
              review.customerName ?? '',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.subHeading.extraSmall.medium,
            ),

            Text(
              review.comment!,
              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
            ),

          ])),

        ]) : Text(
          review.comment!,
          style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      )));
  }
}
