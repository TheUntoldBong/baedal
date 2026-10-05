import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_paginate_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_search_bar_widget.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class AllRestaurantScreen extends StatefulWidget {
  final bool isRecentlyViewed;
  final bool isOrderAgain;
  final bool isRecommended;
  final bool isTopPick;
  final bool isQuickDelivery;
  final bool isFreeDelivery;
  const AllRestaurantScreen({super.key, required this.isRecentlyViewed, required this.isOrderAgain, this.isRecommended = false, this.isTopPick = false, this.isQuickDelivery = false, this.isFreeDelivery = false});


  @override
  State<AllRestaurantScreen> createState() => _AllRestaurantScreenState();
}

class _AllRestaurantScreenState extends State<AllRestaurantScreen> {
  static const int _pageLimit = 10;
  static const Duration _searchDebounce = Duration(milliseconds: 500);

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<bool> _searchBarShowing = ValueNotifier<bool>(true);
  Timer? _debounce;

  RestaurantPaginateType? get _paginateType => widget.isRecommended
      ? RestaurantPaginateType.recommended : widget.isTopPick
      ? RestaurantPaginateType.topPick : widget.isQuickDelivery
      ? RestaurantPaginateType.quickDelivery : null;

  bool get _searchesOnServer => _paginateType != null || widget.isFreeDelivery;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);
    final RestaurantController restController = Get.find<RestaurantController>();
    restController.setVegType(VegType.all, notify: false);
    restController.setRestaurantSearchQuery('', notify: false);
    _loadFirstPage(reload: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _searchBarShowing.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _restoreSharedLists();
    super.dispose();
  }

  void _restoreSharedLists() {
    final RestaurantController restController = Get.find<RestaurantController>();
    final bool wasFiltered = restController.type != VegType.all;
    if(!wasFiltered && restController.restaurantSearchQuery.isEmpty) return;

    restController.setVegType(VegType.all, notify: false);
    restController.setRestaurantSearchQuery('', notify: false);

    Future.microtask(() => wasFiltered || _searchesOnServer
        ? _loadFirstPage(reload: true) : restController.update());
  }

  Future<void> _loadFirstPage({required bool reload}) {
    final RestaurantController restController = Get.find<RestaurantController>();
    final RestaurantPaginateType? type = _paginateType;
    final VegType vegType = restController.type;
    final String searchQuery = restController.restaurantSearchQuery;
    if (type != null) {
      return _fetchPage(type, 1, reload: reload, notify: reload, vegType: vegType, searchQuery: searchQuery);
    }
    if (widget.isFreeDelivery) {
      return restController.getFreeDeliveryRestaurantList(1, reload, name: searchQuery);
    }
    if (widget.isRecentlyViewed) {
      return restController.getRecentlyViewedRestaurantList(reload, vegType, reload);
    }
    if (widget.isOrderAgain) {
      return restController.getOrderAgainRestaurantList(reload, type: vegType);
    }
    return restController.getLatestRestaurantList(reload, vegType, reload);
  }

  Future<void> _fetchPage(RestaurantPaginateType type, int offset, {bool reload = false, bool notify = false, VegType vegType = VegType.all, String searchQuery = ''}) {
    final RestaurantController restController = Get.find<RestaurantController>();
    return switch (type) {
      RestaurantPaginateType.recommended => restController.getRecommendedRestaurantList(reload, notify, offset: offset, limit: _pageLimit, vegType: vegType, searchQuery: searchQuery),
      RestaurantPaginateType.topPick => restController.getTopPickRestaurantList(reload, notify, offset: offset, limit: _pageLimit, vegType: vegType, searchQuery: searchQuery),
      RestaurantPaginateType.quickDelivery => restController.getQuickDeliveryRestaurantList(reload, notify, offset: offset, limit: _pageLimit, vegType: vegType, searchQuery: searchQuery),
    };
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    _trackSearchBarVisibility();

    final RestaurantPaginateType? type = _paginateType;
    if (type == null) return;
    if (scrollController.position.pixels < scrollController.position.maxScrollExtent - 200) return;

    final RestaurantController restController = Get.find<RestaurantController>();
    final RestaurantPaginateModel data = restController.restaurantPaginate(type);
    if (data.paginating || !data.hasMore(_pageLimit)) return;

    restController.showRestaurantPaginateBottomLoader(type);
    _fetchPage(type, data.offset + 1);
  }

  void _trackSearchBarVisibility() {
    final ScrollPosition position = scrollController.position;
    if (position.pixels <= 0) {
      _searchBarShowing.value = true;
      return;
    }
    switch (position.userScrollDirection) {
      case ScrollDirection.forward: _searchBarShowing.value = true;
      case ScrollDirection.reverse: _searchBarShowing.value = false;
      case ScrollDirection.idle: break;
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () => _applySearch(value));
  }

  void _applySearch(String value) {
    _debounce?.cancel();
    final RestaurantController restController = Get.find<RestaurantController>();
    final String query = value.trim();
    if (restController.restaurantSearchQuery == query) return;

    restController.setRestaurantSearchQuery(query, notify: !_searchesOnServer);
    if (_searchesOnServer) {
      _loadFirstPage(reload: true);
    }
  }

  void _onVegFilterTap(VegType vegType) {
    final RestaurantController restController = Get.find<RestaurantController>();
    restController.setVegType(vegType, notify: false);
    _loadFirstPage(reload: true);
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<RestaurantController>(
      builder: (restController) {
        final RestaurantPaginateType? type = _paginateType;
        final RestaurantPaginateModel? paginateData = type != null ? restController.restaurantPaginate(type) : null;

        final String title = widget.isRecommended
            ? 'recommended_for_you'.tr : widget.isTopPick
            ? 'top_pick_near_you'.tr : widget.isQuickDelivery
            ? '${'quick'.tr} ${'delivery'.tr}' : widget.isRecentlyViewed
            ? 'recently_viewed_restaurants'.tr : widget.isOrderAgain ? 'recently_ordered'.tr
            : widget.isFreeDelivery ? 'free_delivery'.tr : '${'new_on'.tr} ${AppConstants.appName}';

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: CustomAppBarWidget.sizeOf(context),
            child: ValueListenableBuilder<bool>(
              valueListenable: _searchBarShowing,
              builder: (context, showing, _) => CustomAppBarWidget(
                title: title,
                type: restController.type,
                onVegFilterTap: widget.isFreeDelivery ? null : _onVegFilterTap,
                elevation: showing ? 0 : 1,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadFirstPage(reload: true),
            child: CustomScrollView(controller: scrollController, physics: const AlwaysScrollableScrollPhysics(), slivers: [

              SliverAppBar(
                floating: true, snap: true, pinned: false, primary: false,
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                backgroundColor: context.surfaceContainer,
                surfaceTintColor: context.surfaceContainer,
                elevation: 0, scrolledUnderElevation: 0,
                titleSpacing: 0,
                title: Center(child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingSmall, Dimensions.paddingLarge, Dimensions.paddingSmall),
                    child: RestaurantSearchBarWidget(
                      controller: searchController,
                      hintText: 'search_restaurants'.tr,
                      onChanged: _onSearchChanged,
                      onSubmitted: _applySearch,
                      onClear: () {
                        searchController.clear();
                        _applySearch('');
                      },
                    ),
                  ),
                )),
              ),

              SliverToBoxAdapter(child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingDefault, Dimensions.paddingLarge, Dimensions.paddingLarge),
                  child: widget.isFreeDelivery ? PaginatedListViewWidget(
                    scrollController: scrollController,
                    totalSize: restController.freeDeliveryRestaurantModel?.totalSize,
                    offset: restController.freeDeliveryRestaurantModel?.offset,
                    onPaginate: (int? offset) async => await Get.find<RestaurantController>().getFreeDeliveryRestaurantList(offset!, false),
                    productView: RestaurantsViewWidget(restaurants: restController.freeDeliveryRestaurantList),
                  ) : RestaurantsViewWidget(
                    restaurants: widget.isRecommended
                        ? restController.recommendedRestaurantList : widget.isTopPick
                        ? restController.topPickRestaurantList : widget.isQuickDelivery
                        ? restController.quickDeliveryRestaurantList : widget.isRecentlyViewed
                        ? restController.searchedRecentlyViewedRestaurantList : widget.isOrderAgain
                        ? restController.searchedOrderAgainRestaurantList : restController.searchedLatestRestaurantList,
                  ),
                ),
              ))),

              if(paginateData?.paginating ?? false) SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
                  child: Center(child: SizedBox(
                    height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: context.primary),
                  )),
                ),
              ),

            ]),
          ),
        );
      }
    );
  }

}
