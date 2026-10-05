import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/readmore_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/rating_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProductReviewBottomSheet extends StatelessWidget {
  final Product product;
  const ProductReviewBottomSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 550 : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
          bottomLeft: Radius.circular(ResponsiveHelper.isDesktop(context) ? 20 : 0), bottomRight: Radius.circular(ResponsiveHelper.isDesktop(context) ? 20 : 0),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SizedBox(width: 20),

          Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: context.bgNeutralLight,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSmall, top: Dimensions.paddingSmall),
            child: InkWell(
              onTap: () {
                Get.back();
                ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                  FoodBottomSheetWidget(product: product, isCampaign: false, fromReview: true),
                  backgroundColor: Colors.transparent, isScrollControlled: true,
                ) : Get.dialog(
                  Dialog(child: FoodBottomSheetWidget(product: product, isCampaign: false, fromReview: true)),
                );
              },
              child: Icon(Icons.close, color: context.iconDisabledDefault, size: 22),
            ),
          ),
        ]),

        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.padding2xSmall),
              child: Column(children: [

                Text(product.name ?? '', style: context.heading.large.semiBold),
                SizedBox(height: Dimensions.padding2xSmall),

                Text('${product.reviewCount} ${'reviews'.tr}', style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                SizedBox(height: Dimensions.paddingLarge),

                RatingWidget(averageRating: product.avgRating ?? 0, ratingCount: product.ratingCount ?? 0, reviewCommentCount: product.reviewCount ?? 0, ratings: product.ratings),
                const SizedBox(height: Dimensions.paddingLarge),

                ListView.builder(
                  itemCount: product.reviews!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(product.reviews?[index].userName ?? '', style: context.heading.defaultSize.semiBold),
                        SizedBox(height: Dimensions.padding2xSmall),

                        RatingBarWidget(rating: product.avgRating, size: 15, ratingCount: null, reviewCount: null),
                        SizedBox(height: Dimensions.padding2xSmall),

                        Text(DateConverter.stringDateTimeToDate(product.reviews![index].createdAt!), style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                        SizedBox(height: Dimensions.padding2xSmall),

                        ReadMoreText(
                          product.reviews?[index].comment ?? '',
                          style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.7)),
                          trimMode: TrimMode.Line,
                          trimLines: 3,
                          colorClickableText: context.primary,
                          lessStyle: context.heading.defaultSize.strong.overrideWith(color: context.primary),
                          trimCollapsedText: 'show_more'.tr,
                          trimExpandedText: ' ${'show_less'.tr}',
                          moreStyle: context.heading.defaultSize.strong.overrideWith(color: context.primary),
                        ),

                      ]),
                    );
                  },
                ),

              ]),
            ),
          ),
        ),

      ]),

    );
  }
}
