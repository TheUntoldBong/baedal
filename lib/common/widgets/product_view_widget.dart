import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_shimmer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final List<Restaurant?>? restaurants;
  final bool isRestaurant;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inRestaurantPage;
  final bool? fromFavorite;
  final bool? fromSearch;
  const ProductViewWidget({super.key, required this.restaurants, required this.products, required this.isRestaurant, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingLarge), this.noDataText,
    this.isCampaign = false, this.inRestaurantPage = false, this.fromFavorite = false, this.fromSearch = false});

  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(isRestaurant) {
      isNull = restaurants == null;
      if(!isNull) {
        length = restaurants!.length;
      }
    }else {
      isNull = products == null;
      if(!isNull) {
        length = products!.length;
      }
    }

    return Column(children: [

      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context)  ? Dimensions.paddingLarge : 0.01,
          mainAxisExtent: ResponsiveHelper.isDesktop(context)  ? 142 : isRestaurant ? 250 : 140,
          crossAxisCount: ResponsiveHelper.isMobile(context)  ? 1 :  3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          return ProductWidget(
            isRestaurant: isRestaurant, product: isRestaurant ? null : products![index],
            restaurant: isRestaurant ? restaurants![index] : null, index: index, length: length, isCampaign: isCampaign,
            inRestaurant: inRestaurantPage,
          );
        },
      ) : NoDataScreen(
        isEmptyRestaurant: isRestaurant ? true : false,
        isEmptyWishlist: fromFavorite! ? true : false,
        isEmptySearchFood: fromSearch! ? true : false,
        title: noDataText ?? (isRestaurant ? 'there_is_no_restaurant'.tr : 'there_is_no_food'.tr),
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : 0.01,
          mainAxisExtent: 150,
          crossAxisCount: ResponsiveHelper.isMobile(context)  ? 1 : 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return ProductShimmer(isEnabled: isNull, isRestaurant: isRestaurant, hasDivider: index != shimmerLength-1);
        },
      ),

    ]);
  }
}
