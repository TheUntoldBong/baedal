import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/review_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/readmore_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel review;
  final bool hasDivider;
  final String? restaurantName;
  const ReviewWidget({super.key, required this.review, required this.hasDivider, this.restaurantName});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
            Text(review.customerName ?? '', style: context.heading.defaultSize.medium),
            const SizedBox(height: Dimensions.padding2xSmall),

            RatingBarWidget(rating: review.rating!.toDouble(), ratingCount: null, size: 18),
            const SizedBox(height: Dimensions.padding2xSmall),

            isDesktop ? Text(DateConverter.stringDateTimeToDate(review.createdAt!), style: context.body.small.regular.overrideWith(color: context.textBaseMedium)) : const SizedBox(),
            SizedBox(height: isDesktop ?  Dimensions.padding2xSmall : 0),

            isDesktop ? ReadMoreText(
              review.comment ?? '',
              style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7)),
              trimMode: TrimMode.Line,
              trimLines: 3,
              colorClickableText: context.primary,
              lessStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
              trimCollapsedText: 'show_more'.tr,
              trimExpandedText: ' ${'show_less'.tr}',
              moreStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
            ) : Text(DateConverter.stringDateTimeToDate(review.createdAt!), style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
          
          ]),
        ),
        SizedBox(width: isDesktop ? Dimensions.paddingLarge : 0),

        _ReviewFoodChip(review: review),

      ]),
      const SizedBox(height: Dimensions.paddingDefault),

      isDesktop ? const SizedBox() : ReadMoreText(
        review.comment ?? '',
        style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7)),
        trimMode: TrimMode.Line,
        trimLines: 3,
        colorClickableText: context.primary,
        lessStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
        trimCollapsedText: 'show_more'.tr,
        trimExpandedText: ' ${'show_less'.tr}',
        moreStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
      ),
      SizedBox(height: isDesktop ? 0 : Dimensions.paddingSmall),

      review.reply != null ? Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault, horizontal: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: context.textBaseLight,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text(restaurantName ?? '', style: context.heading.defaultSize.medium),

            Text(DateConverter.stringDateTimeToDate(review.updatedAt!), style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),

          ]),
          const SizedBox(height: Dimensions.paddingDefault),

          ReadMoreText(
            review.reply ?? '',
            style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.7)),
            trimMode: TrimMode.Line,
            trimLines: 3,
            colorClickableText: context.primary,
            lessStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
            trimCollapsedText: 'show_more'.tr,
            trimExpandedText: ' ${'show_less'.tr}',
            moreStyle: context.body.defaultSize.strong.overrideWith(color: context.primary),
          ),

        ]),
      ) : const SizedBox(),

      hasDivider ? Divider(
        height: 40, thickness: 1,
        color: context.outlineVariant,
      ) : const SizedBox(),

    ]);
  }
}

class _ReviewFoodChip extends StatefulWidget {
  final ReviewModel review;
  const _ReviewFoodChip({required this.review});

  @override
  State<_ReviewFoodChip> createState() => _ReviewFoodChipState();
}

class _ReviewFoodChipState extends State<_ReviewFoodChip> {
  bool _isOpening = false;

  Future<void> _openFoodSheet() async {
    if(_isOpening) {
      return;
    }
    setState(() => _isOpening = true);

    try {
      Product? product = await Get.find<ProductController>().getProductDetails(widget.review.foodId!, null);
      if(!mounted) {
        return;
      }

      if(product == null) {
        showCustomSnackBar('product_is_not_available'.tr);
        return;
      }
      await Get.bottomSheet(
        FoodBottomSheetWidget(product: product, fromReview: true),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      );
    } finally {
      if(mounted) {
        setState(() => _isOpening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openFoodSheet,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.padding2xSmall),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          border: Border.all(color: context.outline),
        ),
        child: Row(children: [

          const SizedBox(width: Dimensions.padding2xSmall),
          SizedBox(
            width: 70,
            child: Text(widget.review.foodName ?? '', style: context.subHeading.small.medium, overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            child: CustomImageWidget(
              image: widget.review.foodImageFullUrl ?? '',
              height: 45, width: 45, fit: BoxFit.cover,
            ),
          ),

        ]),
      ),
    );
  }
}
