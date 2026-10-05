import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodScreen extends StatefulWidget {
  const PopularFoodScreen({super.key});

  @override
  State<PopularFoodScreen> createState() => _PopularFoodScreenState();
}

class _PopularFoodScreenState extends State<PopularFoodScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<ReviewController>().getReviewedProductList(true, Get.find<ReviewController>().reviewType, false);
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<ReviewController>(builder: (reviewController) {
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: 'item_you_will_love'.tr,
            showCart: true,
            type: reviewController.reviewType,
            onVegFilterTap:  (VegType type) {
              reviewController.getReviewedProductList(true, type, true);
            },
            actions: [],
          ),
          body: SingleChildScrollView(controller: scrollController, child: SizedBox(
            child: Column(children: [

              Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GetBuilder<RestaurantController>(
                  builder: (restaurantController) {

                    return ProductViewWidget(
                      isRestaurant: false, restaurants: null,
                      products: reviewController.reviewedProductList,
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    );
                  }
                ),
              )),
            ]),
          )),
        );
      });
    });
  }
}
