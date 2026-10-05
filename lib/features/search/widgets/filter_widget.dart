import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/custom_check_box_widget.dart';
import 'package:stackfood_multivendor/features/search/widgets/filter_section_wrapper.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

enum SearchFilterTarget { food, restaurant, both }

class FilterWidget extends StatefulWidget {
  final double? maxValue;
  final double? minValue;
  final SearchFilterTarget target;
  final bool startFullScreen;
  const FilterWidget({super.key, required this.maxValue, required this.minValue, required this.target, this.startFullScreen = false});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool showAllCuisine = false;
  List<String> ratings = ['5_rating', '4_rating', '3_rating', '2_rating', '1_rating'];

  bool get _isRestaurant => widget.target == SearchFilterTarget.restaurant;
  bool get _isBoth => widget.target == SearchFilterTarget.both;
  bool get _showFoodOnlySections => widget.target != SearchFilterTarget.restaurant;
  bool get _showRestaurantOnlySections => widget.target != SearchFilterTarget.food;

  static const double _minExtent = 0.55;
  static const double _collapsedInitialExtent = 0.75;
  static const double _maxExtent = 1.0;
  static const double _fullScreenThreshold = 0.98;

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  late double _initialExtent;
  late double _sheetExtent;
  bool get _isFullScreen => _sheetExtent >= _fullScreenThreshold;

  @override
  void initState() {
    super.initState();
    _initialExtent = widget.startFullScreen ? _maxExtent : _collapsedInitialExtent;
    _sheetExtent = _initialExtent;

    if(Get.find<CuisineController>().cuisineModel?.cuisines?.isEmpty ?? true) {
      Get.find<CuisineController>().getCuisineList();
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => FocusManager.instance.primaryFocus?.unfocus(),
      child: _buildDraggableSheet(context),
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    final double topInset = MediaQueryData.fromView(View.of(context)).padding.top;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if((notification.extent - _sheetExtent).abs() > 0.001) {
          setState(() => _sheetExtent = notification.extent);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _initialExtent,
        minChildSize: _minExtent,
        maxChildSize: _maxExtent,
        expand: false,
        builder: (context, scrollController) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: _isFullScreen ? BorderRadius.zero : const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge),
              ),
            ),
            child: ClipRRect(
              borderRadius: _isFullScreen ? BorderRadius.zero : const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge),
              ),
              child: GetBuilder<search.SearchController>(builder: (searchController) {
                return Column(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _isFullScreen
                        ? Padding(
                          key: const ValueKey('expanded'),
                          padding: EdgeInsets.only(top: topInset),
                          child: CustomAppBarWidget(title: 'filter_data'.tr, onBackPressed: _closeSheet , leadingIcon: Icons.close,),
                        )
                        : _buildDragHandleHeader(context, key: const ValueKey('collapsed')),
                  ),
                  Divider(color: context.outlineVariant, height: 1),

                  Expanded(
                    child: CustomScrollView(controller: scrollController, slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                          child: _buildFilterSections(context, searchController),
                        ),
                      ),
                    ]),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      boxShadow: [BoxShadow(color: context.shadow, offset: Offset(0, -3), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
                    child: SafeArea(top: false, child: _buildBottomButtons(context, searchController)),
                  ),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandleHeader(BuildContext context, {Key? key}) {
    return Column(key: key, mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: Dimensions.paddingSmall),
      Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: context.bgNeutralMedium,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
      ),
      SizedBox(height: Dimensions.paddingSmall),
      Row(children: [
        IconButton(onPressed: _closeSheet, icon: Icon(Icons.close)),
        Text("filter_data".tr, style: context.heading.extraLarge.strong),
      ]),
    ]);
  }

  Widget _buildFilterSections(BuildContext context, search.SearchController searchController) {
    List<String> sortListData = _isRestaurant ? searchController.restaurantSortList : searchController.sortList;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      SectionWrapper(
        title: 'sorting'.tr,
        child: Wrap(
          runSpacing: Dimensions.paddingSmall,
          children: sortListData.map((sort) {
            int index = sortListData.indexOf(sort);
            bool isSelected = _isRestaurant ? (index == searchController.restaurantSortIndex) : (index == searchController.sortIndex);
            return CustomCheckBoxWidget( title: sort, value: isSelected, isRadioButton: true,
              onClick: () {
                if(_isRestaurant) {
                  searchController.setRestSortIndex(index);
                } else {
                  searchController.setSortIndex(index);
                }
              },
            );
          }).toList(),
        ),
      ),

      if(_showFoodOnlySections) SectionWrapper(
        title: '${'price'.tr} ${'(${PriceConverter.convertPrice(searchController.lowerValue)} - ${PriceConverter.convertPrice(searchController.upperValue)})'}'.tr,
        child: RangeSlider(
          values: RangeValues(
            searchController.lowerValue.clamp(0, ((widget.maxValue ?? 0) + 100).toInt().toDouble()),
            searchController.upperValue.clamp(0, ((widget.maxValue ?? 0) + 100).toInt().toDouble()),
          ),
          max: ((widget.maxValue ?? 0) + 100).toInt().toDouble(),
          min: 0,
          divisions: ((widget.maxValue ?? 0) + 100).toInt(),
          activeColor: context.primary,
          inactiveColor: context.bgNeutralMedium,
          labels: RangeLabels(searchController.lowerValue.toInt().toString(), searchController.upperValue.toInt().toString()),
          onChanged: (RangeValues rangeValues) {
            searchController.setLowerAndUpperValue(rangeValues.start.floor().toDouble(), rangeValues.end.ceil().toDouble());
          },

        ),
      ),

      SectionWrapper(
        title: 'food_type'.tr,
        child: Row(
          children: [
            Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
              child: CustomCheckBoxWidget(
                checkBoxAlignRight: false,
                title: 'veg'.tr,
                value: _isRestaurant ? searchController.restaurantVeg : searchController.productVeg,
                onClick: () {
                  if(_isRestaurant) {
                    searchController.toggleResVeg();
                  } else {
                    searchController.toggleVeg();
                  }
                },
              ),
            ) : const SizedBox(),

            Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
              child: CustomCheckBoxWidget(
                checkBoxAlignRight: false,
                title: 'non_veg'.tr,
                value: _isRestaurant ? searchController.restaurantNonVeg : searchController.productNonVeg,
                onClick: () {
                  if(_isRestaurant) {
                    searchController.toggleResNonVeg();
                  } else {
                    searchController.toggleNonVeg();
                  }
                },
              ),
            ) : const SizedBox(),
          ],
        ),
      ),

      SectionWrapper(
        title: 'order_type'.tr,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: searchController.getOrderTypeList.length,
          itemBuilder: (context, index){
            return CustomCheckBoxWidget(
              title: searchController.getOrderTypeList[index],
              value: searchController.getSelectedOrderType.contains(index),
              onClick: () {
                searchController.setSelectedOrderType(index);
              },
            );
          }
        ),
      ),

      SectionWrapper(
        title: 'rating'.tr,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: ratings.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            bool isSelected = false;
            if(_isRestaurant) {
              isSelected = searchController.restaurantRating == (5 - index);
            } else {
              isSelected = searchController.rating == (5 - index);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: CustomCheckBoxWidget(
                title: ratings[index].tr,
                value: isSelected,
                isRadioButton: true,
                ratingList: ratings,
                onClick: () {
                  if(_isRestaurant) {
                    searchController.setRestaurantRating(5 - index);
                  } else {
                    searchController.setRating(5 - index);
                  }
                },
              ),
            );
          },
        ),
      ),

      SectionWrapper(
        title: 'filter_by'.tr,
        child: Column(
          children: [

            CustomCheckBoxWidget(
              title: 'free_delivery'.tr,
              value: _isRestaurant ? searchController.isFreeDeliveryRestaurant : searchController.isFreeDelivery,
              onClick: () {
                if(_isRestaurant){
                  searchController.toggleFreeDeliveryRestaurant();
                }
                else{
                  searchController.toggleFreeDeliveryProduct();
                }
              },
            ),

            if(_showFoodOnlySections) CustomCheckBoxWidget(
              title: 'currently_available_foods'.tr,
              value: searchController.isAvailableFoods,
              onClick: () {
                searchController.toggleAvailableFoods();
              },
            ),

            if(_showRestaurantOnlySections) CustomCheckBoxWidget(
              title: 'open_restaurants'.tr,
              value: searchController.isOpenRestaurant,
              onClick: () {
                searchController.toggleOpenRestaurant();
              },
            ),

            CustomCheckBoxWidget(
              title: 'new_arrivals'.tr,
              value: _isRestaurant ? searchController.isNewArrivalsRestaurant : searchController.isNewArrivalsFoods,
              onClick: () {
                if(_isRestaurant) {
                  searchController.toggleNewArrivalRestaurant();
                } else {
                  searchController.toggleNewArrivalFoods();
                }
              },
            ),

            CustomCheckBoxWidget(
              title: 'discounted'.tr,
              value: _isRestaurant ? searchController.isDiscountedRestaurant : searchController.isDiscountedFoods,
              onClick: () {
                if(_isRestaurant) {
                  searchController.toggleDiscountedRestaurant();
                } else {
                  searchController.toggleDiscountedFoods();
                }
              },
            ),

            CustomCheckBoxWidget(
              title: 'popular'.tr,
              value: _isRestaurant ? searchController.isPopularRestaurant : searchController.isPopularFood,
              onClick: () {
                if(_isRestaurant) {
                  searchController.togglePopularRestaurant();
                } else {
                  searchController.togglePopularFoods();
                }
              },
            ),

          ],
        ),
      ),

      if(_showRestaurantOnlySections) GetBuilder<CuisineController>(
        builder: (cuisineController) {
          const int snapCount = 3;
          return cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isNotEmpty ?
          SectionWrapper(
            title: '${'cuisines'.tr} ',
            child:  ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: showAllCuisine ? cuisineController.cuisineModel!.cuisines!.length
                  : cuisineController.cuisineModel!.cuisines!.length > (snapCount+1) ? (snapCount+1) : cuisineController.cuisineModel!.cuisines!.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool isSelected = _isRestaurant ? searchController.selectedCuisinesRestaurant.contains(cuisineController.cuisineModel!.cuisines![index].id!) : searchController.selectedCuisinesProduct.contains(cuisineController.cuisineModel!.cuisines![index].id!);
                if(!showAllCuisine && index == snapCount && cuisineController.cuisineModel!.cuisines!.length > (snapCount+1)) {
                  return InkWell(
                    onTap: (){
                      setState(() {
                        showAllCuisine = !showAllCuisine;
                      });
                    },
                    child: Center(child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${'see_more'.tr} (${cuisineController.cuisineModel!.cuisines!.length - snapCount})", style: context.subHeading.defaultSize.medium.overrideWith(color: Theme.of(context).colorScheme.tertiary)),
                      ],
                    )),
                  );
                } else {
                  return CustomCheckBoxWidget(
                    title: cuisineController.cuisineModel!.cuisines![index].name ?? '',
                    value: isSelected,
                    onClick: () => _isRestaurant ? searchController.selectCuisineRestaurant(cuisineController.cuisineModel!.cuisines![index].id!) : searchController.selectCuisineProduct(cuisineController.cuisineModel!.cuisines![index].id!),
                  );
                }
              },
            ),
          ) :
          const SizedBox();
        }
      ),

    ]);
  }

  void _runSearch(search.SearchController searchController) {
    if(_isBoth) {
      searchController.applySharedFiltersToRestaurant();
      searchController.searchAllData(searchController.searchText);
    } else {
      searchController.searchData(searchController.searchText, 1);
    }
  }

  Widget _buildBottomButtons(BuildContext context, search.SearchController searchController) {
    return Row(children: [
      Expanded(
        child: CustomButtonWidget(
          color: context.bgNeutralMedium,
          textColor: Theme.of(context).textTheme.bodyLarge!.color,
          onPressed: () {
            if(_showFoodOnlySections) {
              searchController.resetFilter();
            }
            if(_showRestaurantOnlySections) {
              searchController.resetRestaurantFilter();
            }
            _closeSheet();
            _runSearch(searchController);
          },
          buttonText: 'clear_filter'.tr,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(
        child: CustomButtonWidget(
          buttonText: 'filter'.tr,
          onPressed: () async {
            _closeSheet();
            _runSearch(searchController);
          },
        ),
      ),
    ]);
  }
}
