import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/controller/public_filter_controller.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/search/widgets/custom_check_box_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';


class PublicFilterWidget extends StatefulWidget {
  final bool isRestaurant;
  final FilterAdditionalDataModel? filterAdditionalDataModel;
  final FilterDataModel? filterDataModel;
  final bool startFullScreen;
  const PublicFilterWidget({super.key, required this.isRestaurant, this.filterAdditionalDataModel, this.filterDataModel, this.startFullScreen = false});

  @override
  State<PublicFilterWidget> createState() => _PublicFilterWidgetState();
}

class _PublicFilterWidgetState extends State<PublicFilterWidget> {
  bool showAllCuisine = false;
  List<String> ratings = ['5_rating', '4_rating', '3_rating', '2_rating', '1_rating'];
  final Set<String> _collapsedSections = {};

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

    PublicFilterController? publicFilterController;
    publicFilterController = Get.find<PublicFilterController>();


    if(Get.find<CuisineController>().cuisineModel?.cuisines?.isEmpty ?? true) {
      Get.find<CuisineController>().getCuisineList();
    }

    publicFilterController.setSearchMode(filterDataModel: widget.filterDataModel, canUpdate: false);
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
              child: GetBuilder<PublicFilterController>(builder: (publicFilterController) {
                return Column(children: [
                  _buildHeader(context, topInset),
                  Divider(color: context.outlineVariant, height: 1),

                  Expanded(
                    child: CustomScrollView(controller: scrollController, slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                          child: _buildFilterSections(context, publicFilterController),
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
                    child: SafeArea(top: false, child: _buildBottomButtons(context, publicFilterController)),
                  ),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }
  Widget _buildHeader(BuildContext context, double topInset) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if(_isFullScreen) SizedBox(height: topInset),
      AnimatedSize(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.bottomCenter,
        child: _isFullScreen ? const SizedBox(width: double.infinity) : Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: Dimensions.paddingSmall),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.bgNeutralMedium,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
        ]),
      ),
      SizedBox(height: Dimensions.paddingSmall),
      Row(children: [
        IconButton(onPressed: _closeSheet, icon:  Icon(Icons.close, color: context.theme.textTheme.bodyLarge?.color, size: 22)),
        Text('filter_data'.tr, style: context.heading.extraLarge.strong),
      ]),
    ]);
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    final bool isExpanded = !_collapsedSections.contains(title);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() {
            if(isExpanded) {
              _collapsedSections.add(title);
            } else {
              _collapsedSections.remove(title);
            }
          }),
          child: Row(children: [
            Expanded(child: Text(title, style: context.heading.large.strong, maxLines: 1, overflow: TextOverflow.ellipsis)),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(Icons.keyboard_arrow_down, color: context.iconBaseMedium),
            ),
          ]),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !isExpanded ? const SizedBox(width: double.infinity) : Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                color: context.surfaceContainer,
              ),
              child: child,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildFilterSections(BuildContext context, PublicFilterController publicFilterController) {
    List<String> sortListData = widget.isRestaurant ? publicFilterController.restaurantSortList : publicFilterController.sortList;

    final List<Widget> sections = [

      _buildSection(context,
        title: 'sorting'.tr,
        child:  Wrap(
          runSpacing: Dimensions.paddingSmall,
          children: sortListData.map((sort) {
            int index = sortListData.indexOf(sort);
            bool isSelected = widget.isRestaurant ? (index == publicFilterController.restaurantSortIndex) : (index == publicFilterController.sortIndex);
            return CustomCheckBoxWidget( title: sort, value: isSelected, isRadioButton: true,
              onClick: () {
                if(widget.isRestaurant) {
                  publicFilterController.setRestSortIndex(index);
                } else {
                  publicFilterController.setSortIndex(index);
                }
              },
            );
          }).toList(),
        ),
      ),

      if(!widget.isRestaurant) _buildSection(context,
        title: '${'price'.tr} ${'(${PriceConverter.convertPrice(publicFilterController.lowerValue)} - ${PriceConverter.convertPrice(publicFilterController.upperValue)})'}'.tr,
        child: RangeSlider(
          values: RangeValues(
            publicFilterController.lowerValue.clamp(publicFilterController.lowerLimit, publicFilterController.upperLimit),
            publicFilterController.upperValue.clamp(publicFilterController.lowerLimit, publicFilterController.upperLimit),
          ),
          max: publicFilterController.upperLimit,
          min: publicFilterController.lowerLimit,
          divisions: ((publicFilterController.upperLimit) + 100).toInt(),
          activeColor: context.primary,
          inactiveColor: context.bgNeutralMedium,
          labels: RangeLabels(publicFilterController.lowerValue.toInt().toString(), publicFilterController.upperValue.toInt().toString()),
          onChanged: (RangeValues rangeValues) {
            publicFilterController.setLowerAndUpperValue(rangeValues.start.floor().toDouble(), rangeValues.end.ceil().toDouble());
          },

        ),
      ),

      _buildSection(context,
        title: 'food_type'.tr,
        child: Row(
          children: [
            Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
              child: CustomCheckBoxWidget(
                checkBoxAlignRight: false,
                title: 'veg'.tr,
                value: widget.isRestaurant ? publicFilterController.restaurantVeg : publicFilterController.productVeg,
                onClick: () {
                  if(widget.isRestaurant) {
                    publicFilterController.toggleResVeg();
                  } else {
                    publicFilterController.toggleVeg();
                  }
                },
              ),
            ) : const SizedBox(),

            Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Expanded(
              child: CustomCheckBoxWidget(
                checkBoxAlignRight: false,
                title: 'non_veg'.tr,
                value: widget.isRestaurant ? publicFilterController.restaurantNonVeg : publicFilterController.productNonVeg,
                onClick: () {
                  if(widget.isRestaurant) {
                    publicFilterController.toggleResNonVeg();
                  } else {
                    publicFilterController.toggleNonVeg();
                  }
                },
              ),
            ) : const SizedBox(),
          ],
        ),
      ),

      _buildSection(context,
        title: 'order_type'.tr,
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: publicFilterController.getOrderTypeList.length,
            itemBuilder: (context, index){
              return CustomCheckBoxWidget(
                title: publicFilterController.getOrderTypeList[index],
                value: widget.isRestaurant ? publicFilterController.getSelectedOrderTypeRest.contains(index) : publicFilterController.getSelectedOrderType.contains(index),
                onClick: () {
                  widget.isRestaurant ? publicFilterController.setSelectedOrderTypeRest(index): publicFilterController.setSelectedOrderType(index);
                },
              );
            }
        ),
      ),

      _buildSection(context,
        title: 'rating'.tr,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: ratings.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            bool isSelected = false;
            if(widget.isRestaurant) {
              isSelected = publicFilterController.restaurantRating == (5 - index);
            } else {
              isSelected = publicFilterController.rating == (5 - index);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: CustomCheckBoxWidget(
                title: ratings[index].tr,
                value: isSelected,
                isRadioButton: true,
                ratingList: ratings,
                onClick: () {
                  if(widget.isRestaurant) {
                    publicFilterController.setRestaurantRating(5 - index);
                  } else {
                    publicFilterController.setRating(5 - index);
                  }
                },
              ),
            );
          },
        ),
      ),

      _buildSection(context,
        title: 'filter_by'.tr,
        child: Column(
          children: [

            CustomCheckBoxWidget(
              title: 'free_delivery'.tr,
              value: widget.isRestaurant ? publicFilterController.isFreeDeliveryRestaurant : publicFilterController.isFreeDelivery,
              onClick: () {
                if(widget.isRestaurant){
                  publicFilterController.toggleFreeDeliveryRestaurant();
                }
                else{
                  publicFilterController.toggleFreeDeliveryProduct();
                }
              },
            ),

            if(!widget.isRestaurant)CustomCheckBoxWidget(
              title: 'currently_available_foods'.tr,
              value: publicFilterController.isAvailableFoods,
              onClick: () {
                publicFilterController.toggleAvailableFoods();
              },
            ),

            widget.isRestaurant ? CustomCheckBoxWidget(
              title: 'open_restaurants'.tr,
              value: publicFilterController.isOpenRestaurant,
              onClick: () {
                publicFilterController.toggleOpenRestaurant();
              },
            ) : const SizedBox(),

            CustomCheckBoxWidget(
              title: 'new_arrivals'.tr,
              value: widget.isRestaurant ? publicFilterController.isNewArrivalsRestaurant : publicFilterController.isNewArrivalsFoods,
              onClick: () {
                if(widget.isRestaurant) {
                  publicFilterController.toggleNewArrivalRestaurant();
                } else {
                  publicFilterController.toggleNewArrivalFoods();
                }
              },
            ),

            CustomCheckBoxWidget(
              title: 'discounted'.tr,
              value: widget.isRestaurant ? publicFilterController.isDiscountedRestaurant : publicFilterController.isDiscountedFoods,
              onClick: () {
                if(widget.isRestaurant) {
                  publicFilterController.toggleDiscountedRestaurant();
                } else {
                  publicFilterController.toggleDiscountedFoods();
                }
              },
            ),

            if(widget.filterAdditionalDataModel?.fromPopularRestaurant != true)
            CustomCheckBoxWidget(
              title: 'popular'.tr,
              value: widget.isRestaurant ? publicFilterController.isPopularRestaurant : publicFilterController.isPopularFood,
              onClick: () {
                if(widget.isRestaurant) {
                  publicFilterController.togglePopularRestaurant();
                } else {
                  publicFilterController.togglePopularFoods();
                }
              },
            ),

          ],
        ),
      ),

      if(widget.filterAdditionalDataModel?.showCuisines != false && widget.isRestaurant)
      GetBuilder<CuisineController>(
          builder: (cuisineController) {
            const int snapCount = 3;
            return cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isNotEmpty ?
            _buildSection(context,
              title: '${'cuisines'.tr} ',
              child:  ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: showAllCuisine ? cuisineController.cuisineModel!.cuisines!.length
                    : cuisineController.cuisineModel!.cuisines!.length > (snapCount+1) ? (snapCount+1) : cuisineController.cuisineModel!.cuisines!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool isSelected = widget.isRestaurant ? publicFilterController.selectedCuisinesRestaurant.contains(cuisineController.cuisineModel!.cuisines![index].id!) : publicFilterController.selectedCuisinesProduct.contains(cuisineController.cuisineModel!.cuisines![index].id!);
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
                      onClick: () => widget.isRestaurant ? publicFilterController.selectCuisineRestaurant(cuisineController.cuisineModel!.cuisines![index].id!) : publicFilterController.selectCuisineProduct(cuisineController.cuisineModel!.cuisines![index].id!),
                    );
                  }
                },
              ),
            ) :
            const SizedBox();
          }
      ),

    ];

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      for(int i = 0; i < sections.length; i++) ...[
        sections[i],
        if(i != sections.length - 1) Divider(color: context.outline, height: Dimensions.paddingDefault),
      ],
    ]);
  }

  Widget _buildBottomButtons(BuildContext context, PublicFilterController publicFilterController) {
    return Row(children: [
      Expanded(
        child: CustomButtonWidget(
          color: context.bgNeutralMedium,
          textColor: Theme.of(context).textTheme.bodyLarge!.color,
          onPressed: () {
            publicFilterController.resetRestaurantFilter();
            publicFilterController.resetFilter();

            _closeSheet();
            widget.filterAdditionalDataModel?.callback?.call(publicFilterController.getFilterDataModel());
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
            widget.filterAdditionalDataModel?.callback?.call(publicFilterController.getFilterDataModel());
          },
        ),
      ),
    ]);
  }
}

void showFilterBottomSheetOrDialog(BuildContext context, bool isRestaurant, {double? maxValue, double? minValue, FilterAdditionalDataModel? filterAdditionalDataModel, FilterDataModel? filterDataModel}) {
  Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 1),
      child: PublicFilterWidget(
        isRestaurant: isRestaurant,
        filterAdditionalDataModel: filterAdditionalDataModel,
        filterDataModel: filterDataModel,
        startFullScreen: true,
      ),
    ),
    isScrollControlled: true,
    backgroundColor: context.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
    ),
  );
}
