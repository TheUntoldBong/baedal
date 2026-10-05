import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SearchResultCountWidget extends StatelessWidget {
  final TabController tabController;
  const SearchResultCountWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search.SearchController>(builder: (searchController) {
      return AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          bool isNull;
          int length = 0;
          if(tabController.index == 0) {
            isNull = searchController.searchProductList == null || searchController.searchRestList == null;
            if(!isNull) {
              length = searchController.searchProductList!.length + searchController.searchRestList!.length;
            }
          } else if(tabController.index == 1) {
            isNull = searchController.searchProductList == null;
            if(!isNull) {
              length = searchController.searchProductList!.length;
            }
          } else {
            isNull = searchController.searchRestList == null;
            if(!isNull) {
              length = searchController.searchRestList!.length;
            }
          }

          return isNull ? const SizedBox() : Row(children: [
            Text(
              length.toString(),
              style: context.heading.large.medium.overrideWith(color: context.textBaseMedium,)
            ),
            const SizedBox(width: Dimensions.padding2xSmall),
            Text(
              'results'.tr, style: context.heading.large.medium.overrideWith(color: context.textBaseMedium,)
            ),
          ]);
        },
      );
    });
  }
}
