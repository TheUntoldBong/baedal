import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/product/domain/models/review_body_model.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/widgets/rating_input_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProductReviewWidget extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  const ProductReviewWidget({super.key, required this.orderDetailsList});

  @override
  State<ProductReviewWidget> createState() => _ProductReviewWidgetState();
}

class _ProductReviewWidgetState extends State<ProductReviewWidget> {

  void _submit(ReviewController reviewController, int index) {
    if(reviewController.submitList[index]) {
      return;
    }
    if(reviewController.ratingList[index] == 0) {
      showCustomSnackBar('give_a_rating'.tr);
      return;
    }

    FocusScope.of(context).unfocus();

    ReviewBodyModel reviewBody = ReviewBodyModel(
      productId: widget.orderDetailsList[index].foodDetails!.id.toString(),
      rating: reviewController.ratingList[index].toString(),
      comment: reviewController.reviewList[index],
      orderId: widget.orderDetailsList[index].orderId.toString(),
    );
    reviewController.submitReview(index, reviewBody).then((value) {
      if(value.isSuccess) {
        showCustomSnackBar(value.message, isError: false);
        reviewController.setReview(index, '');
      } else {
        showCustomSnackBar(value.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return Center(child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          itemCount: widget.orderDetailsList.length,
          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingDefault),
          itemBuilder: (context, index) {
            final OrderDetailsModel orderDetails = widget.orderDetailsList[index];
            final String? imageUrl = orderDetails.foodDetails!.imageFullUrl;

            return Container(
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  if(imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      child: CustomImageWidget(
                        height: 60, width: 60, fit: BoxFit.cover,
                        image: imageUrl, isFood: true,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingMedium),
                  ],

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text(
                      orderDetails.foodDetails!.name!,
                      style: context.heading.defaultSize.medium,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.padding2xSmall),

                    Row(children: [
                      Text(PriceConverter.convertPrice(orderDetails.foodDetails!.price), style: context.heading.defaultSize.strong),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Expanded(child: Text(
                        '${'quantity'.tr}: ${orderDetails.quantity}',
                        style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),

                  ])),

                ]),
                Divider(height: Dimensions.paddingExtraLarge, color: context.outline),

                Text(
                  'rate_the_food'.tr,
                  style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                ),
                const SizedBox(height: Dimensions.paddingSmall),

                RatingInputWidget(
                  rating: reviewController.ratingList[index],
                  isEnabled: !reviewController.submitList[index],
                  onRated: (rating) => reviewController.setRating(index, rating),
                ),
                const SizedBox(height: Dimensions.paddingLarge),

                Text(
                  'share_your_opinion'.tr,
                  style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                ),
                const SizedBox(height: Dimensions.paddingSmall),

                CustomTextFieldWidget(
                  hintText: 'write_your_review_here'.tr,
                  maxLines: 3,
                  showLabelText: false,
                  capitalization: TextCapitalization.sentences,
                  inputAction: TextInputAction.done,
                  isEnabled: !reviewController.submitList[index],
                  fillColor: context.surface,
                  onChanged: (text) => reviewController.setReview(index, text),
                ),
                const SizedBox(height: Dimensions.paddingLarge),

                CustomButtonWidget(
                  buttonText: reviewController.submitList[index] ? 'submitted'.tr : 'submit'.tr,
                  radius: Dimensions.radiusDefault,
                  isLoading: reviewController.loadingList[index],
                  onPressed: reviewController.submitList[index] ? null : () => _submit(reviewController, index),
                ),

              ]),
            );
          },
        ),
      ));
    });
  }
}
