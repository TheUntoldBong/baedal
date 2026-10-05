import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NewOnStackFoodViewWidget extends StatelessWidget {
  const NewOnStackFoodViewWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
        final double cardWidth = (MediaQuery.of(context).size.width * 0.72).clamp(240.0, 300.0);
        final double cardHeight = (cardWidth / 2) + 64;

        return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox.shrink() : Container(
          width: Dimensions.webMaxWidth,
          color: context.primary.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingDefault),
                child: Text('${'new_on'.tr} ${AppConstants.appName}', style: context.heading.large.semiBold),
              ),


              restController.latestRestaurantList != null ? SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                  itemCount: restController.latestRestaurantList!.length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == restController.latestRestaurantList!.length) {
                        return SectionViewAllTile(
                          onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('latest')),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getRestaurantRoute(restController.latestRestaurantList![index].id, slug: restController.latestRestaurantList![index].slug ?? ''),
                              arguments: RestaurantScreen(restaurant: restController.latestRestaurantList![index]),
                            );
                          },
                          child: RestaurantCardWidget(
                            restaurant: restController.latestRestaurantList![index],
                            width: cardWidth,
                          ),
                        ),
                      );
                    },
                ),
              ) : SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                  itemCount: 3,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                    child: RestaurantCardShimmerWidget(width: cardWidth),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingDefault),
           ],
          ),

        );
      }
    );
  }
}
