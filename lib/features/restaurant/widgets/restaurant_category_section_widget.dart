import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';


class RestaurantCategorySectionWidget extends StatelessWidget {
  final RestaurantCategoryItem category;
  final List<Product> products;

  const RestaurantCategorySectionWidget({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.paddingDefault,
            right: Dimensions.paddingDefault,
            top: Dimensions.paddingLarge,
            bottom: Dimensions.paddingSmall,
          ),
          child: Text(
            category.name ?? '',
            style: context.heading.defaultSize.strong,
          ),
        ),
        ProductViewWidget(
          isRestaurant: false,
          restaurants: null,
          products: products,
          inRestaurantPage: true,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
        ),
      ],
    );
  }
}
