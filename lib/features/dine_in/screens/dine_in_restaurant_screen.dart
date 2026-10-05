import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_filter_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class DineInRestaurantScreen extends StatefulWidget {
  const DineInRestaurantScreen({super.key});

  @override
  State<DineInRestaurantScreen> createState() => _DineInRestaurantScreenState();
}

class _DineInRestaurantScreenState extends State<DineInRestaurantScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<DineInController>().initSetup(willUpdate: false);
    Get.find<DineInController>().getDineInRestaurantList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'restaurant_list'.tr,
        actions: [
          IconButton(
            onPressed: () {
              showCustomBottomSheet(child: const DineRestaurantFilterBottomSheet());
            },
            icon: Icon(Icons.filter_list_outlined, color: context.primary),
          ),
        ],
      ),
      floatingActionButton: ResponsiveHelper.isDesktop(context) ? null : Align(
        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.bottomRight : Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () {
              Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true));
            },
            label: Row(children: [

              CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
              SizedBox(width: Dimensions.paddingSmall),

              Text('view_from_map'.tr, style: context.body.large.medium.overrideWith(color: Colors.white)),

            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(height: Dimensions.paddingSmall),

                  ResponsiveHelper.isDesktop(context) ? Container(
                    height: 64, color: context.primary.withValues(alpha: 0.10),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                    child: Row(children: [
                      Text(
                        'restaurant_list'.tr,
                        style: context.subHeading.large.semiBold,
                      ),

                      Spacer(),

                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true)),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                            CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
                            SizedBox(width: Dimensions.paddingSmall),

                            Text('view_from_map'.tr, style: context.body.small.medium.overrideWith(color: Colors.white)),

                          ]),
                        ),
                      ),

                      SizedBox(width: Dimensions.paddingSmall),

                      InkWell(
                        onTap: () {
                          showCustomDialog(child: const DineRestaurantFilterBottomSheet());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: context.primary),
                            color: context.surfaceContainer,
                          ),
                          padding: EdgeInsets.all(Dimensions.padding2xSmall),
                          child: Icon(Icons.filter_list_outlined, color: context.primary),
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : 0),

                  GetBuilder<DineInController>(builder: (dineInController) {
                    return dineInController.dineInModel != null ? dineInController.dineInModel!.restaurants!.isNotEmpty ?
                    PaginatedListViewWidget(
                      scrollController: _scrollController,
                      totalSize: dineInController.dineInModel!.totalSize,
                      offset: dineInController.dineInModel!.offset,
                      onPaginate: (int? offset) async => await dineInController.getDineInRestaurantList(offset!, false),
                      productView: dineInRestaurant(dineInController.dineInModel!.restaurants!),
                    ) : Center(child: Padding(
                      padding: EdgeInsets.only(top: context.height * 0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                          const SizedBox(height: Dimensions.padding2xSmall),
                          Text('there_is_no_restaurant'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                        ],
                      ),
                    )) : DineInRestaurantShimmerWidget();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dineInRestaurant(List<Restaurant> restaurants) {
    final int crossAxisCount = ResponsiveHelper.isMobile(context) ? 1 : 3;
    final EdgeInsets padding = ResponsiveHelper.isDesktop(context)
        ? EdgeInsets.zero
        : const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault, bottom: 100);

    return LayoutBuilder(builder: (context, constraints) {
      final double cellWidth = (constraints.maxWidth - padding.horizontal
          - Dimensions.paddingLarge * (crossAxisCount - 1)) / crossAxisCount;

      return GridView.builder(
        shrinkWrap: true,
        itemCount: restaurants.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: Dimensions.paddingLarge,
          crossAxisSpacing: Dimensions.paddingLarge,
          mainAxisExtent: (cellWidth / 2) + 90,
        ),
        padding: padding,
        itemBuilder: (context, index) {
          final Restaurant restaurant = restaurants[index];

          return RestaurantCardWidget.detailed(
            restaurant: restaurant,
            onTap: () {
              if(restaurant.restaurantStatus == 1){
                Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? '', fromDinIn: true),
                  arguments: RestaurantScreen(restaurant: restaurant, fromDineIn: true),
                );
              }else if(restaurant.restaurantStatus == 0){
                showCustomSnackBar('restaurant_is_not_available'.tr);
              }
            },
          );
        },
      );
    });
  }
}
