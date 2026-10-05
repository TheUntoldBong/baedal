import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/product/domain/models/review_body_model.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/widgets/delivery_man_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/rating_input_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  const DeliveryManReviewWidget({super.key, required this.deliveryMan, required this.orderID});

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(ReviewController reviewController) {
    if(reviewController.deliveryManRating == 0) {
      showCustomSnackBar('give_a_rating'.tr);
      return;
    }
    if(_controller.text.isEmpty) {
      showCustomSnackBar('write_a_review'.tr);
      return;
    }

    FocusScope.of(context).unfocus();

    ReviewBodyModel reviewBodyModel = ReviewBodyModel(
      deliveryManId: widget.deliveryMan!.id.toString(),
      rating: reviewController.deliveryManRating.toString(),
      comment: _controller.text,
      orderId: widget.orderID,
    );
    reviewController.submitDeliveryManReview(reviewBodyModel).then((value) {
      if(value.isSuccess) {
        showCustomSnackBar(value.message, isError: false);
        _controller.text = '';
      } else {
        showCustomSnackBar(value.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          if(widget.deliveryMan != null) ...[
            DeliveryManWidget(deliveryMan: widget.deliveryMan),
            const SizedBox(height: Dimensions.paddingDefault),
          ],

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(
                'rate_his_service'.tr,
                style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              RatingInputWidget(
                rating: reviewController.deliveryManRating,
                onRated: reviewController.setDeliveryManRating,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              Text(
                'share_your_opinion'.tr,
                style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              CustomTextFieldWidget(
                controller: _controller,
                hintText: 'write_your_review_here'.tr,
                maxLines: 5,
                showLabelText: false,
                capitalization: TextCapitalization.sentences,
                inputAction: TextInputAction.done,
                fillColor: context.surface,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              CustomButtonWidget(
                buttonText: 'submit'.tr,
                radius: Dimensions.radiusDefault,
                isLoading: reviewController.isLoading,
                onPressed: () => _submit(reviewController),
              ),

            ]),
          ),

        ]))),
      );
    });
  }
}
