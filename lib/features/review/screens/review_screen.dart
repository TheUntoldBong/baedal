import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/widgets/rating_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/review_list_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ReviewScreen extends StatefulWidget {
  final String? restaurantName;
  final String? restaurantID;
  final Restaurant? restaurant;
  const ReviewScreen({super.key, required this.restaurantID, this.restaurantName, this.restaurant});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<ReviewController>().getRestaurantReviewList(widget.restaurantID);
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.restaurantName ?? 'restaurant_reviews'.tr),
      body: GetBuilder<ReviewController>(builder: (reviewController) {
        return reviewController.restaurantReviewList != null ? reviewController.restaurantReviewList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await reviewController.getRestaurantReviewList(widget.restaurantID);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              child: Column(children: [

                Center(child: SizedBox(width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    child: isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Expanded(flex: 4, child: RatingWidget(averageRating: widget.restaurant?.avgRating ?? 0, ratingCount: widget.restaurant?.ratingCount ?? 0, reviewCommentCount: widget.restaurant?.reviewsCommentsCount ?? 0, ratings: widget.restaurant?.ratings)),
                      const SizedBox(width: Dimensions.paddingLarge),

                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          height: 600,
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                            boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                          ),
                          child: ReviewListWidget(reviewController: reviewController, restaurantName: widget.restaurantName),
                        ),
                      ),

                    ]) : Column(children: [

                      RatingWidget(averageRating: widget.restaurant?.avgRating ?? 0, ratingCount: widget.restaurant?.ratingCount ?? 0, reviewCommentCount: widget.restaurant?.reviewsCommentsCount ?? 0, ratings: widget.restaurant?.ratings),
                      const SizedBox(height: Dimensions.paddingLarge),

                      ReviewListWidget(reviewController: reviewController, restaurantName: widget.restaurantName),

                    ]),
                  ),

                )),

              ]),
            ),
          ),
        ) : Center(child: NoDataScreen(title: 'no_review_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
