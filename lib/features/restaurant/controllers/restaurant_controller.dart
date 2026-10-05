import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/cart_suggested_item_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_paginate_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/services/restaurant_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantServiceInterface restaurantServiceInterface;

  RestaurantController({required this.restaurantServiceInterface}){
    _filterDataModel = FilterDataModel(isRestaurant: true);
  }

  FilterDataModel? _filterDataModel;
  FilterDataModel? get getFilterDataModel => _filterDataModel;
  void setFilterDataModel(FilterDataModel filterDataModel){
    _filterDataModel = filterDataModel;
  }

  RestaurantModel? _restaurantModel;
  RestaurantModel? get restaurantModel => _restaurantModel;

  RestaurantModel? _nearbyRestaurantModel;
  RestaurantModel? get nearbyRestaurantModel => _nearbyRestaurantModel;

  List<Restaurant>? _restaurantList;
  List<Restaurant>? get restaurantList => _restaurantList;

  final Map<RestaurantPaginateType, RestaurantPaginateModel> _paginates = <RestaurantPaginateType, RestaurantPaginateModel>{
    for (final RestaurantPaginateType type in RestaurantPaginateType.values) type: RestaurantPaginateModel(),
  };

  RestaurantPaginateModel restaurantPaginate(RestaurantPaginateType type) => _paginates[type]!;

  List<Restaurant>? get recommendedRestaurantList => restaurantPaginate(RestaurantPaginateType.recommended).restaurants;
  List<Restaurant>? get topPickRestaurantList => restaurantPaginate(RestaurantPaginateType.topPick).restaurants;
  List<Restaurant>? get quickDeliveryRestaurantList => restaurantPaginate(RestaurantPaginateType.quickDelivery).restaurants;

  List<Restaurant>? _latestRestaurantList;
  List<Restaurant>? get latestRestaurantList => _latestRestaurantList;

  List<Restaurant>? _recentlyViewedRestaurantList;
  List<Restaurant>? get recentlyViewedRestaurantList => _recentlyViewedRestaurantList;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  List<Product>? _restaurantProducts;
  List<Product>? get restaurantProducts => _restaurantProducts;

  ProductModel? _restaurantProductModel;
  ProductModel? get restaurantProductModel => _restaurantProductModel;

  ProductModel? _restaurantSearchProductModel;
  ProductModel? get restaurantSearchProductModel => _restaurantSearchProductModel;

  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Set<String> _restaurantTypes = {'all'};
  Set<String> get restaurantTypes => _restaurantTypes;
  bool get isDefaultRestaurantType => _restaurantTypes.length == 1 && _restaurantTypes.single == 'all';

  bool _foodPaginate = false;
  bool get foodPaginate => _foodPaginate;

  int? _foodPageSize;
  int? get foodPageSize => _foodPageSize;

  List<int> _foodOffsetList = [];

  int _foodOffset = 1;
  int get foodOffset => _foodOffset;

  VegType _type = VegType.all;
  VegType get type => _type;

  VegType _searchType = VegType.all;
  VegType get searchType => _searchType;

  String _searchText = '';
  String get searchText => _searchText;

  String _restaurantSearchQuery = '';
  String get restaurantSearchQuery => _restaurantSearchQuery;

  RecommendedProductModel? _recommendedProductModel;
  RecommendedProductModel? get recommendedProductModel => _recommendedProductModel;

  CartSuggestItemModel? _cartSuggestItemModel;
  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  RestaurantCategoryFoodsModel? _restaurantCategoryFoodsModel;
  RestaurantCategoryFoodsModel? get restaurantCategoryFoodsModel => _restaurantCategoryFoodsModel;

  List<Product>? _suggestedItems;
  List<Product>? get suggestedItems => _suggestedItems;

  int? _foodPageOffset;
  int? get foodPageOffset => _foodPageOffset;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<Restaurant>? _orderAgainRestaurantList;
  List<Restaurant>? get orderAgainRestaurantList => _orderAgainRestaurantList;

  String _freeDeliverySearchQuery = '';

  RestaurantModel? _freeDeliveryRestaurantModel;
  RestaurantModel? get freeDeliveryRestaurantModel => _freeDeliveryRestaurantModel;
  List<Restaurant>? get freeDeliveryRestaurantList => _freeDeliveryRestaurantModel?.restaurants;

  int _topRated = 0;
  int get topRated => _topRated;

  int _discount = 0;
  int get discount => _discount;

  int _veg = 0;
  int get veg => _veg;

  int _nonVeg = 0;
  int get nonVeg => _nonVeg;

  int _newlyJoined = 0;
  int _popular = 0;

  String? _sortBy;
  String? get sortBy => _sortBy;

  int _nearestRestaurantIndex = -1;
  int get nearestRestaurantIndex => _nearestRestaurantIndex;


  void setNearestRestaurantIndex(int index, {bool notify = true}) {
    _nearestRestaurantIndex = index;
    if(notify) {
      update();
    }
  }

  void setVegType(VegType type, {bool notify = true}) {
    _type = type;
    if(notify) {
      update();
    }
  }

  void setRestaurantSearchQuery(String query, {bool notify = true}) {
    _restaurantSearchQuery = query;
    if(notify) {
      update();
    }
  }

  List<Restaurant>? _searched(List<Restaurant>? restaurants) {
    if(restaurants == null || _restaurantSearchQuery.isEmpty) {
      return restaurants;
    }
    final String query = _restaurantSearchQuery.toLowerCase();
    return restaurants.where((restaurant) => (restaurant.name ?? '').toLowerCase().contains(query)).toList();
  }

  List<Restaurant>? get searchedLatestRestaurantList => _searched(_latestRestaurantList);
  List<Restaurant>? get searchedRecentlyViewedRestaurantList => _searched(_recentlyViewedRestaurantList);
  List<Restaurant>? get searchedOrderAgainRestaurantList => _searched(_orderAgainRestaurantList);

  double getRestaurantDistance(LatLng restaurantLatLng){
    return restaurantServiceInterface.getRestaurantDistanceFromUser(restaurantLatLng);
  }

  String filteringUrl(String slug){
    return restaurantServiceInterface.filterRestaurantLinkUrl(slug, _restaurant?.id, _restaurant?.zoneId);
  }

  Future<void> getOrderAgainRestaurantList(bool reload, {VegType type = VegType.all, DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _type = type;
    if(reload) {
      _orderAgainRestaurantList = null;
      update();
    }
    List<Restaurant>? orderAgainRestaurantList;
    if(dataSource == DataSourceEnum.local) {
      orderAgainRestaurantList = await restaurantServiceInterface.getOrderAgainRestaurantList(type: type, source: DataSourceEnum.local);
      _prepareOrderAgainRestaurantList(orderAgainRestaurantList);
      getOrderAgainRestaurantList(false, type: type, dataSource: DataSourceEnum.client);
    } else {
      orderAgainRestaurantList = await restaurantServiceInterface.getOrderAgainRestaurantList(type: type, source: DataSourceEnum.client);
      _prepareOrderAgainRestaurantList(orderAgainRestaurantList);
    }
  }

  void _prepareOrderAgainRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _orderAgainRestaurantList = [];
      _orderAgainRestaurantList = restaurantList;
    }
    update();
  }

  Future<void> getFreeDeliveryRestaurantList(int offset, bool reload, {String name = '', DataSourceEnum source = DataSourceEnum.local}) async {
    if(offset == 1) {
      _freeDeliverySearchQuery = name;
    }
    final String searchQuery = _freeDeliverySearchQuery;
    if(reload) {
      _freeDeliveryRestaurantModel = null;
      update();
    }

    RestaurantModel? restaurantModel;
    if(source == DataSourceEnum.local && offset == 1 && searchQuery.isEmpty) {
      restaurantModel = await restaurantServiceInterface.getFreeDeliveryRestaurantList(offset: offset, source: DataSourceEnum.local);
      _prepareFreeDeliveryRestaurantList(restaurantModel, offset);
      getFreeDeliveryRestaurantList(1, false, name: searchQuery, source: DataSourceEnum.client);
    } else {
      restaurantModel = await restaurantServiceInterface.getFreeDeliveryRestaurantList(offset: offset, name: searchQuery, source: DataSourceEnum.client);
      _prepareFreeDeliveryRestaurantList(restaurantModel, offset);
    }
  }

  void _prepareFreeDeliveryRestaurantList(RestaurantModel? restaurantModel, int offset) {
    if (restaurantModel != null) {
      if (offset == 1) {
        _freeDeliveryRestaurantModel = restaurantModel;
      } else {
        _freeDeliveryRestaurantModel!.totalSize = restaurantModel.totalSize;
        _freeDeliveryRestaurantModel!.offset = restaurantModel.offset;
        _freeDeliveryRestaurantModel!.restaurants!.addAll(restaurantModel.restaurants!);
      }
      update();
    }
  }

  Future<void> getRecentlyViewedRestaurantList(bool reload, VegType type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _type = type;
    if(reload && !fromRecall){
      _recentlyViewedRestaurantList = null;
    }
    if(notify) {
      update();
    }
    List<Restaurant>? recentlyViewedRestaurantList;
    if(_recentlyViewedRestaurantList == null || reload || fromRecall) {
      if(dataSource == DataSourceEnum.local) {
        recentlyViewedRestaurantList = await restaurantServiceInterface.getRecentlyViewedRestaurantList(type, source: DataSourceEnum.local);
        _prepareRecentlyViewedRestaurantList(recentlyViewedRestaurantList);
        getRecentlyViewedRestaurantList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        recentlyViewedRestaurantList = await restaurantServiceInterface.getRecentlyViewedRestaurantList(type, source: DataSourceEnum.client);
        _prepareRecentlyViewedRestaurantList(recentlyViewedRestaurantList);
      }
    }
  }

  void _prepareRecentlyViewedRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _recentlyViewedRestaurantList = [];
      _recentlyViewedRestaurantList = restaurantList;
    }
    update();
  }

  Future<void> getRestaurantRecommendedItemList(int? restaurantId, bool reload) async {
    _recommendedProductModel = null;
    if(reload) {
      _restaurantModel = null;
      update();
    }
    _recommendedProductModel = await restaurantServiceInterface.getRestaurantRecommendedItemList(restaurantId);
    update();
  }

  RestaurantBogoOfferListModel? _bogoOfferListModel;
  List<RestaurantBogoOfferModel>? get bogoOfferList => _bogoOfferListModel?.offers;

  Future<void> getRestaurantBogoOffers(int? restaurantId) async {
    _bogoOfferListModel = null;
    _bogoOfferListModel = await restaurantServiceInterface.getRestaurantBogoOffers(restaurantId, restaurant: _restaurant);
    update();
  }
  int _restaurantFetchId = 0;

  Future<void> getNearbyRestaurantList({DataSourceEnum source = DataSourceEnum.local}) async {
    RestaurantModel? restaurantModel = await restaurantServiceInterface.getRestaurantList(
      1, const {'all'}, 0, 0, 0, 0,
      sortBy: 'distance', newlyJoined: 0, popular: 0, source: source, filterDataModel: _filterDataModel,
    );
    if(restaurantModel != null) {
      _nearbyRestaurantModel = restaurantModel;
      update();
    }
    if(source == DataSourceEnum.local) {
      await getNearbyRestaurantList(source: DataSourceEnum.client);
    }
  }

  Future<void> getRestaurantList(int offset, bool reload, {bool fromMap = false, DataSourceEnum source = DataSourceEnum.local, int? fetchId}) async {
    if(reload) {
      _restaurantModel = null;
      fetchId = ++_restaurantFetchId;
      update();
    }
    fetchId ??= _restaurantFetchId;

    Set<String> orderTypes = _restaurantTypes.isEmpty ? {'all'} : _restaurantTypes;

    RestaurantModel? restaurantModel;
    if(source == DataSourceEnum.local && offset == 1) {
      restaurantModel = await restaurantServiceInterface.getRestaurantList(offset, orderTypes, _topRated, _discount, _veg, _nonVeg, sortBy: _sortBy, newlyJoined: _newlyJoined, popular: _popular, fromMap: fromMap, source: DataSourceEnum.local, filterDataModel: _filterDataModel);
      _prepareRestaurantList(restaurantModel, offset, fetchId);
      getRestaurantList(1, false, fromMap: fromMap, source: DataSourceEnum.client, fetchId: fetchId);
    } else {
      restaurantModel = await restaurantServiceInterface.getRestaurantList(offset, orderTypes, _topRated, _discount, _veg, _nonVeg, sortBy: _sortBy, newlyJoined: _newlyJoined, popular: _popular, fromMap: fromMap, source: DataSourceEnum.client, filterDataModel: _filterDataModel);
      _prepareRestaurantList(restaurantModel, offset, fetchId);
    }
  }

  void _prepareRestaurantList(RestaurantModel? restaurantModel, int offset, [int? fetchId]) {
    if (restaurantModel != null) {
      if(fetchId != null && fetchId != _restaurantFetchId) return;
      if (offset == 1) {
        _restaurantModel = restaurantModel;
      }else {
        _restaurantModel!.totalSize = restaurantModel.totalSize;
        _restaurantModel!.offset = restaurantModel.offset;
        _restaurantModel!.restaurants!.addAll(restaurantModel.restaurants!);
      }
      update();
    }
  }

  void applyFilters({required Set<String> types, required int discount, required int veg, required int nonVeg}) {
    _restaurantTypes = types.isEmpty ? {'all'} : types;
    _discount = discount;
    _veg = veg;
    _nonVeg = nonVeg;
    getRestaurantList(1, true);
  }

  void resetFilters() {
    _restaurantTypes = {'all'};
    _discount = 0;
    _veg = 0;
    _nonVeg = 0;
    getRestaurantList(1, true);
  }

  static const Set<String> _orderTypeFilterValues = {'delivery', 'take_away', 'dine_in'};

  void setExploreTab(String tab, {bool loadRestaurants = true}) {
    _restaurantTypes = {'all'};
    _sortBy = tab == 'near_by_restaurants' ? 'distance' : null;
    _topRated = tab == 'top_rated' ? 1 : 0;
    _newlyJoined = tab == 'latest' ? 1 : 0;
    _popular = tab == 'popular' ? 1 : 0;
    _discount = 0;
    _veg = 0;
    _nonVeg = 0;
    if(loadRestaurants) {
      getRestaurantList(1, true);
    } else {
      update();
    }
  }

  String get activeExploreTab {
    if(_topRated == 1) return 'top_rated';
    if(_newlyJoined == 1) return 'latest';
    if(_popular == 1) return 'popular';
    if(_sortBy == 'distance') return 'near_by_restaurants';
    return 'all';
  }

  bool get hasOrderTypeFilter => _restaurantTypes.any(_orderTypeFilterValues.contains);

  Future<void> getQuickDeliveryRestaurantList(bool reload, bool notify, {int offset = 1, int limit = 10, VegType vegType = VegType.all, String searchQuery = ''}) {
    return _getRestaurantPaginateList(RestaurantPaginateType.quickDelivery, reload, notify, offset: offset, limit: limit, vegType: vegType, searchQuery: searchQuery);
  }

  Future<void> getTopPickRestaurantList(bool reload, bool notify, {int offset = 1, int limit = 10, VegType vegType = VegType.all, String searchQuery = ''}) {
    return _getRestaurantPaginateList(RestaurantPaginateType.topPick, reload, notify, offset: offset, limit: limit, vegType: vegType, searchQuery: searchQuery);
  }

  Future<void> getRecommendedRestaurantList(bool reload, bool notify, {int offset = 1, int limit = 10, VegType vegType = VegType.all, String searchQuery = ''}) {
    return _getRestaurantPaginateList(RestaurantPaginateType.recommended, reload, notify, offset: offset, limit: limit, vegType: vegType, searchQuery: searchQuery);
  }

  Future<void> _getRestaurantPaginateList(RestaurantPaginateType type, bool reload, bool notify, {required int offset, required int limit, VegType vegType = VegType.all, String searchQuery = ''}) async {
    final RestaurantPaginateModel data = _paginates[type]!;

    final VegType requestType = offset == 1 ? vegType : data.type;
    final String requestQuery = offset == 1 ? searchQuery : data.searchQuery;
    final bool refresh = reload || (offset == 1 && (data.type != vegType || data.searchQuery != searchQuery));

    if(offset == 1 && !refresh && data.restaurants != null) return;

    if(offset == 1) {
      data.loadedOffsets.clear();
      data.offset = 1;
      data.type = vegType;
      data.searchQuery = searchQuery;
      _type = vegType;
      if(refresh) {
        data.restaurants = null;
      }
      if(notify) {
        update();
      }
    }
    if(data.loadedOffsets.contains(offset)) {
      if(data.paginating) {
        data.paginating = false;
        update();
      }
      return;
    }
    data.loadedOffsets.add(offset);

    if(offset == 1 && requestQuery.isEmpty) {
      final RestaurantModel? cached = await _fetchRestaurantPaginate(type, offset: offset, limit: limit, vegType: requestType, searchQuery: requestQuery, source: DataSourceEnum.local);
      if(cached != null) {
        data.restaurants = cached.restaurants ?? [];
        data.totalSize = cached.totalSize;
        update();
      }
    }

    final RestaurantModel? result = await _fetchRestaurantPaginate(type, offset: offset, limit: limit, vegType: requestType, searchQuery: requestQuery, source: DataSourceEnum.client);
    if(result != null) {
      if(offset == 1) {
        data.restaurants = result.restaurants ?? [];
      } else {
        (data.restaurants ??= []).addAll(result.restaurants ?? []);
      }
      data.totalSize = result.totalSize;
      data.offset = offset;
    } else {
      data.loadedOffsets.remove(offset);
    }
    data.paginating = false;
    update();
  }

  Future<RestaurantModel?> _fetchRestaurantPaginate(RestaurantPaginateType type, {required int offset, required int limit, required VegType vegType, required String searchQuery, required DataSourceEnum source}) {
    return switch (type) {
      RestaurantPaginateType.recommended => restaurantServiceInterface.getRecommendedRestaurantList(offset: offset, limit: limit, type: vegType, name: searchQuery, source: source),
      RestaurantPaginateType.topPick => restaurantServiceInterface.getTopPickRestaurantList(offset: offset, limit: limit, type: vegType, name: searchQuery, source: source),
      RestaurantPaginateType.quickDelivery => restaurantServiceInterface.getQuickDeliveryRestaurantList(offset: offset, limit: limit, type: vegType, name: searchQuery, source: source),
    };
  }

  void showRestaurantPaginateBottomLoader(RestaurantPaginateType type) {
    _paginates[type]!.paginating = true;
    update();
  }

  Future<void> getLatestRestaurantList(bool reload, VegType type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    _type = type;
    if(reload){
      _latestRestaurantList = null;
    }
    if(notify) {
      update();
    }

    List<Restaurant>? latestRestaurantList;
    if(_latestRestaurantList == null || reload || fromRecall) {

      if(dataSource == DataSourceEnum.local) {
        latestRestaurantList = await restaurantServiceInterface.getLatestRestaurantList(type, source: DataSourceEnum.local);
        _prepareLatestRestaurantList(latestRestaurantList);
        getLatestRestaurantList(false, type, false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        latestRestaurantList = await restaurantServiceInterface.getLatestRestaurantList(type, source: DataSourceEnum.client);
        _prepareLatestRestaurantList(latestRestaurantList);
      }
    }
  }

  void _prepareLatestRestaurantList(List<Restaurant>? restaurantList) {
    if (restaurantList != null) {
      _latestRestaurantList = [];
      _latestRestaurantList = restaurantList;
    }
    update();
  }

  void setCategoryList() {
    if(Get.find<CategoryController>().categoryList != null && _restaurant != null) {
      _categoryList = restaurantServiceInterface.setCategories(Get.find<CategoryController>().categoryList!, _restaurant!);
    }
  }


  final Map<int, String> _addressCache = {};
  final Set<int> _addressRequests = {};

  String? cachedAddress(int? restaurantId) => restaurantId == null ? null : _addressCache[restaurantId];

  Future<void> fetchRestaurantAddress(Restaurant restaurant) async {
    final int? id = restaurant.id;
    if(id == null || _addressCache.containsKey(id) || !_addressRequests.add(id)) {
      return;
    }

    final Restaurant? details = await restaurantServiceInterface.getRestaurantDetails(
      id.toString(), restaurant.slug ?? '', Get.find<LocalizationController>().locale.languageCode,
    );
    final String address = details?.address?.trim() ?? '';
    if(address.isNotEmpty) {
      _addressCache[id] = address;
      update();
    }
  }

  Future<Restaurant?> getRestaurantDetails(Restaurant restaurant, {bool setNullBeforeLoad = false, String slug = ''}) async {
    _categoryIndex = 0;
    if(restaurant.name != null) {
      _restaurant = restaurant;
    }else {
      _isLoading = true;
      if(setNullBeforeLoad){
        _restaurant = null;
      }
      _restaurant = await restaurantServiceInterface.getRestaurantDetails(restaurant.id.toString(), slug, Get.find<LocalizationController>().locale.languageCode);
      if(_restaurant != null && _restaurant!.latitude != null){
        await _setRequiredDataAfterRestaurantGet(slug);
      }
      Get.find<CheckoutController>().setOrderType(
        (_restaurant != null && _restaurant!.delivery != null) ? _restaurant!.delivery! ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );

      _isLoading = false;
      update();
    }
    return _restaurant;
  }

  Future<void> _setRequiredDataAfterRestaurantGet(String slug) async {
    Get.find<CheckoutController>().initializeTimeSlot(_restaurant!);
    if(slug.isNotEmpty){
      await _setStoreAddressToUserAddress(LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)));
    }
  }

  Future<void> _setStoreAddressToUserAddress(LatLng restaurantAddress) async {
    Position storePosition = Position(
      latitude: restaurantAddress.latitude, longitude: restaurantAddress.longitude,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
    );
    String addressFromGeocode = await Get.find<LocationController>().getAddressFromGeocode(LatLng(restaurantAddress.latitude, restaurantAddress.longitude));
    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(storePosition.latitude.toString(), storePosition.longitude.toString(), true);
    AddressModel addressModel = restaurantServiceInterface.prepareAddressModel(storePosition, responseModel, addressFromGeocode);
    await AddressHelper.saveAddressInSharedPref(addressModel);
  }

  void makeEmptyRestaurant({bool willUpdate = true}) {
    _restaurant = null;
    if(willUpdate) {
      update();
    }
  }

  void makeEmptySuggestedItems({bool willUpdate = true}) {
    _suggestedItems = null;
    if(willUpdate) {
      update();
    }
  }

  Future<void> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    _suggestedItems = await restaurantServiceInterface.getCartRestaurantSuggestedItemList(restaurantID);
    update();
  }

  Future<void> getRestaurantProductList(int? restaurantID, int offset, VegType type, bool notify) async {
    _foodOffset = offset;
    if(offset == 1 || _restaurantProducts == null) {
      _type = type;
      _foodOffsetList = [];
      _restaurantProducts = null;
      _foodOffset = 1;
      if(notify) {
        update();
      }
    }
    if (!_foodOffsetList.contains(offset)) {
      _foodOffsetList.add(offset);
      ProductModel? productModel = await restaurantServiceInterface.getRestaurantProductList(restaurantID, offset,
          (_restaurant != null && _restaurant!.categoryIds!.isNotEmpty && _categoryIndex != 0)
          ? _categoryList![_categoryIndex].id : 0, type);

      if (productModel != null) {
        if (offset == 1) {
          _restaurantProducts = [];
        }
        _restaurantProducts!.addAll(productModel.products!);
        _foodPageSize = productModel.totalSize;
        _foodPageOffset = productModel.offset;
        _foodPaginate = false;
        update();
      }
    } else {
      if(_foodPaginate) {
        _foodPaginate = false;
        update();
      }
    }
  }

  void showFoodBottomLoader() {
    _foodPaginate = true;
    update();
  }

  void setFoodOffset(int offset) {
    _foodOffset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getRestaurantSearchProductList(String searchText, String? restaurantId, int offset, VegType type) async {
    if(searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    }else {
      _isSearching = true;
      _searchText = searchText;
      if(offset == 1 || _restaurantSearchProductModel == null) {
        _searchType = type;
        _restaurantSearchProductModel = null;
        update();
      }
      ProductModel? productModel = await restaurantServiceInterface.getRestaurantSearchProductList(searchText, restaurantId, offset, type);
      if (productModel != null) {
        if (offset == 1) {
          _restaurantSearchProductModel = productModel;
        }else {
          _restaurantSearchProductModel!.products!.addAll(productModel.products!);
          _restaurantSearchProductModel!.totalSize = productModel.totalSize;
          _restaurantSearchProductModel!.offset = productModel.offset;
        }
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if(isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _restaurantSearchProductModel = ProductModel(products: []);
    _searchText = '';
    _searchType = VegType.all;
  }

  void setCategoryIndex(int index) {
    _categoryIndex = index;
    _restaurantProducts = null;
    getRestaurantProductList(_restaurant!.id, 1, Get.find<RestaurantController>().type, false);
    update();
  }

  Future<void> getRestaurantCategoryFoods(int restaurantId, VegType type) async {
    _type = type;
    _categoryIndex = 0;
    _restaurantCategoryFoodsModel = null;
    update();
    _restaurantCategoryFoodsModel = await restaurantServiceInterface.getRestaurantCategoryFoods(restaurantId, type);
    update();
  }


  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules, {int? customDateDuration}) {
    return restaurantServiceInterface.isRestaurantClosed(dateTime, active, schedules);
  }

  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules) {
    return restaurantServiceInterface.isRestaurantOpenNow(active, schedules);
  }

  bool isOpenNow(Restaurant restaurant) => restaurant.open == 1 && restaurant.active!;

  double? getDiscount(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discount : 0;

  String? getDiscountType(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discountType : 'percent';


}