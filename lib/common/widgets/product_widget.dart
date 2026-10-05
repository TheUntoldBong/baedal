import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:flutter/material.dart';


class ProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool fromCartSuggestion;
  const ProductWidget({super.key, required this.product, required this.isRestaurant, required this.restaurant, required this.index,
    required this.length, this.inRestaurant = false, this.isCampaign = false, this.fromCartSuggestion = false});

  @override
  Widget build(BuildContext context) {
    return isRestaurant ? RestaurantCardWidget(
      restaurant: restaurant!,
    ) : HorizontalFoodCardWidget(
      product: product!, restaurant: restaurant, index: index, length: length,
      inRestaurant: inRestaurant, isCampaign: isCampaign, fromCartSuggestion: fromCartSuggestion,
    );
  }
}
