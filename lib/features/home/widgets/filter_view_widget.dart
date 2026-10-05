import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurant_filter_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class FilterViewWidget extends StatelessWidget {
  const FilterViewWidget({super.key});

  void _openFilterSheet(BuildContext context) {
    if(ResponsiveHelper.isDesktop(context)) {
      Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: RestaurantFilterBottomSheetWidget()));
    } else {
      showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (context) => const RestaurantFilterBottomSheetWidget(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurant) {
      bool hasActiveFilter = restaurant.hasOrderTypeFilter
          || restaurant.discount == 1 || restaurant.veg == 1 || restaurant.nonVeg == 1;

      return Center(child: InkWell(
        onTap: () => _openFilterSheet(context),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hasActiveFilter ? context.primary.withValues(alpha: 0.1) : context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(color: hasActiveFilter ? context.primary : context.outline),
            ),
            child: Icon(Icons.tune, color: context.primary, size: 22),
          ),

          if(hasActiveFilter) Positioned(
            right: -2, top: -2,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: context.surfaceContainer, width: 1.5),
              ),
            ),
          ),
        ]),
      ));
    });
  }
}