import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/public_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter_icon_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CuisineRestaurantScreen extends StatefulWidget {
  final int cuisineId;
  final String? name;
  const CuisineRestaurantScreen({super.key, required this.cuisineId, required this.name});

  @override
  State<CuisineRestaurantScreen> createState() => _CuisineRestaurantScreenState();
}

class _CuisineRestaurantScreenState extends State<CuisineRestaurantScreen> {
  final ScrollController _scrollController = ScrollController();
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().initialize();
    Get.find<CuisineController>().getCuisineRestaurantList(widget.cuisineId, 1, false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      appBar: CustomAppBarWidget(
        title: '${widget.name!} ${'cuisine'.tr}',
        actions: [
          IconButton(
            onPressed: (){
              Get.toNamed(RouteHelper.getSearchCuisineRestaurantsRoute(widget.cuisineId));
              },
            icon: Icon(CupertinoIcons.search, color: context.primary),
          ),

          InkWell(
            onTap: () =>Get.toNamed(RouteHelper.getCartBundleListRoute()),
            child: CartWidget(color: context.primary, size: 20, imageIcon: Images.cartIcon),
          ),
          SizedBox(width: Dimensions.paddingDefault),

          InkWell(
            onTap: (){
              showFilterBottomSheetOrDialog(
                context, true, filterAdditionalDataModel:  FilterAdditionalDataModel(
                showPriceWidget: false,
                showCuisines: false,
                callback: (data){
                  Get.find<CuisineController>().setFilterDataModel(data);
                  Get.find<CuisineController>().getCuisineRestaurantList(
                    widget.cuisineId,
                    1,
                    true,
                    name: Get.find<CuisineController>().searchText,
                  );
                }),
                filterDataModel: Get.find<CuisineController>().getFilterDataModel?..isRestaurant = true,
              );
            },
            child: FilterIconWidget(fromAppBar: true, iconColor: context.primary,),
          ),
          SizedBox(width: Dimensions.paddingDefault),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          if(!ResponsiveHelper.isDesktop(context)) Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingMedium),
            child: Text('restaurant_list'.tr, style: context.heading.large.strong),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<CuisineController>(builder: (cuisineController) {
                      final restaurants = cuisineController.cuisineRestaurantsModel?.restaurants;

                      if (cuisineController.isLoading) {
                        return Center(child: Padding(padding: EdgeInsets.all(Dimensions.paddingExtraLarge), child: CircularProgressIndicator()));
                      }

                      if (cuisineController.cuisineRestaurantsModel != null && (restaurants == null || restaurants.isEmpty)) {
                        return Padding(
                          padding: EdgeInsets.all(Dimensions.paddingLarge),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                            const SizedBox(height: 150),
                            const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                            const SizedBox(height: Dimensions.padding2xSmall),
                            Text('there_is_no_restaurant'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                          ]),
                        );
                      }

                      return PaginatedListViewWidget(
                        scrollController: _scrollController,
                        totalSize: cuisineController.cuisineRestaurantsModel?.totalSize,
                        offset: cuisineController.cuisineRestaurantsModel != null ? int.parse(cuisineController.cuisineRestaurantsModel!.offset!) : null,
                        onPaginate: (int? offset) async {
                          await cuisineController.getCuisineRestaurantList(widget.cuisineId, offset!, false);
                        },
                        productView: ProductViewWidget(
                          isRestaurant: true,
                          products: null,
                          restaurants: restaurants,
                          padding: EdgeInsets.only(
                            left: Dimensions.paddingLarge,
                            right: Dimensions.paddingLarge,
                            top: 0,
                            bottom: 0,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
