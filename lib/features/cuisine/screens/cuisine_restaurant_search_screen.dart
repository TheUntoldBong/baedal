import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CuisineRestaurantSearchScreen extends StatefulWidget {
  final int cuisineId;
  const CuisineRestaurantSearchScreen({super.key, required this.cuisineId});

  @override
  State<CuisineRestaurantSearchScreen> createState() => _CuisineRestaurantSearchScreenState();
}

class _CuisineRestaurantSearchScreenState extends State<CuisineRestaurantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().initSearchData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CuisineController>(builder: (cuisineController) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if(cuisineController.isSearching && !didPop){
            _searchController.text = '';
            cuisineController.changeSearchStatus();
            cuisineController.initSearchData();
          }else if(_searchController.text.isNotEmpty){
            _searchController.text = '';
            setState(() {});
          }else if(!didPop){
            Future.delayed(const Duration(milliseconds: 0), () => Get.back());
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(Dimensions.webMaxWidth, 80),
            child: Container(
              height: 80 + context.mediaQueryPadding.top, width: Dimensions.webMaxWidth,
              padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
              color: context.surfaceContainer,
              alignment: Alignment.center,
              child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                child: Row(children: [

                  IconButton(
                    onPressed: () {
                      if(cuisineController.isSearching){
                        _searchController.text = '';
                        cuisineController.changeSearchStatus();
                        cuisineController.initSearchData();
                      }else if(_searchController.text.isNotEmpty){
                        _searchController.text = '';
                        setState(() {});
                      }else {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  Expanded(child: TextField(
                      controller: _searchController,
                      style: context.body.large.regular,
                      textInputAction: TextInputAction.search,
                      cursorColor: context.primary,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'search_restaurants_in_cuisine'.tr,
                        hintStyle: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(Dimensions.paddingSmall),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: context.primary.withValues(alpha: 0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: context.primary.withValues(alpha: 0.3), width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(cuisineController.isSearching ? Icons.clear : CupertinoIcons.search, size: 25),
                          onPressed: () {
                            if(cuisineController.isSearching) {
                              _searchController.text = '';
                              cuisineController.changeSearchStatus();
                              cuisineController.initSearchData();

                            } else {
                              cuisineController.saveSearchHistory(_searchController.text.trim());
                              cuisineController.searchCuisineRestaurantList(widget.cuisineId, 1, true, name: _searchController.text.trim());
                            }

                          },
                        ),
                      ),
                      onSubmitted: (text) {
                        cuisineController.saveSearchHistory(_searchController.text.trim());
                        cuisineController.searchCuisineRestaurantList(widget.cuisineId, 1, true, name: _searchController.text.trim());
                      }
                  )),
                  const SizedBox(width: Dimensions.padding2xSmall),


                ]),
              )),
            ),
          ),

          body: SingleChildScrollView(
            controller: _scrollController,
            padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSmall),
            child: Center(
              child: SizedBox(width: Dimensions.webMaxWidth, child: !cuisineController.isSearching ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: Dimensions.padding2xSmall),
                    cuisineController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('recent_search'.tr, style: context.subHeading.large.medium),

                      InkWell(
                        onTap: () => cuisineController.clearSearchAddress(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: 4),
                          child: Text('clear_all'.tr, style: context.body.small.regular.overrideWith(color: context.error)),
                        ),
                      ),
                    ]) : const SizedBox(),

                    SizedBox(height: cuisineController.historyList.isNotEmpty ? Dimensions.padding2xSmall : 0),
                    Wrap(
                      children: cuisineController.historyList.map((historyData) {
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                            decoration: BoxDecoration(
                              color: context.bgNeutralLight,
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              border: Border.all(color: context.outline),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(
                                onTap: () {
                                  _searchController.text = historyData;
                                  cuisineController.saveSearchHistory(historyData);
                                  cuisineController.searchCuisineRestaurantList(widget.cuisineId, 1, true, name: _searchController.text.trim());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                                  child: Text(
                                    historyData,
                                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.5)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),

                              InkWell(
                                onTap: () => cuisineController.removeHistory(cuisineController.historyList.indexOf(historyData)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                                  child: Icon(Icons.close, color: context.iconBaseMedium, size: 20),
                                ),
                              )
                            ]),
                          ),
                        );
                      }).toList(),
                    ),

                  ]) : PaginatedListViewWidget(
                  scrollController: _scrollController,
                  totalSize: cuisineController.searchCuisineRestaurantsModel?.totalSize,
                  offset: cuisineController.searchCuisineRestaurantsModel != null ? int.parse(cuisineController.searchCuisineRestaurantsModel!.offset!) : null,
                  onPaginate: (int? offset) async {
                    await cuisineController.searchCuisineRestaurantList(widget.cuisineId, offset!, false, name: cuisineController.searchText);
                  },
                  productView: ProductViewWidget(
                      isRestaurant: true,
                      products: null,
                      restaurants: cuisineController.searchCuisineRestaurantsModel?.restaurants,
                      padding: EdgeInsets.only(
                        left: ResponsiveHelper.isDesktop(context) ? Dimensions.padding2xSmall : Dimensions.paddingSmall,
                        right: ResponsiveHelper.isDesktop(context) ? Dimensions.padding2xSmall : Dimensions.paddingSmall,
                        top: ResponsiveHelper.isDesktop(context) ? Dimensions.padding2xSmall : Dimensions.paddingDefault,
                        bottom: ResponsiveHelper.isDesktop(context) ? Dimensions.padding2xSmall : 0,
                      ),
                  ),
              ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

