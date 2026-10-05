import 'dart:async';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';
import 'package:stackfood_multivendor/features/search/domain/models/top_category_model.dart';
import 'package:stackfood_multivendor/features/search/domain/services/search_service_interface.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';


class SearchController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;

  SearchController({required this.searchServiceInterface}) {
    _speech = stt.SpeechToText();
  }

  List<Product>? _searchProductList;
  List<Product>? get searchProductList => _searchProductList;

  List<Product>? _suggestedFoodList;
  List<Product>? get suggestedFoodList => _suggestedFoodList;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<String>? _trendingSearchList;
  List<String>? get trendingSearchList => _trendingSearchList;

  TopCategoryModel? _topCategoryModel;
  TopCategoryModel? get topCategoryModel => _topCategoryModel;

  bool _topCategoryPaginate = false;
  bool get topCategoryPaginate => _topCategoryPaginate;

  RestaurantModel? _featuredRestaurantModel;
  RestaurantModel? get featuredRestaurantModel => _featuredRestaurantModel;

  bool _featuredRestaurantPaginate = false;
  bool get featuredRestaurantPaginate => _featuredRestaurantPaginate;

  RestaurantModel? _exclusiveDealsModel;
  RestaurantModel? get exclusiveDealsModel => _exclusiveDealsModel;

  bool _exclusiveDealsPaginate = false;
  bool get exclusiveDealsPaginate => _exclusiveDealsPaginate;

  List<Map<String, dynamic>> _suggestionsList = [];
  List<Map<String, dynamic>> get suggestionsList => _suggestionsList;

  List<Restaurant>? _searchRestList;
  List<Restaurant>? get searchRestList => _searchRestList;

  List<Restaurant>? _allRestList;

  String _searchText = '';
  String get searchText => _searchText;

  double _lowerValue = 0;
  double get lowerValue => _lowerValue;

  double _upperValue = 0;
  double get upperValue => _upperValue;

  List<Map<String, dynamic>> _historyList = [];
  List<Map<String, dynamic>> get historyList => _historyList;

  List<Map<String, dynamic>> get curatedHistoryList {
    List<Map<String, dynamic>> groupOf(String type) => _historyList.where((item) => (item['type'] ?? 'history') == type).take(2).toList();

    List<Map<String, dynamic>> curatedHead = [...groupOf('history'), ...groupOf('food'), ...groupOf('restaurant')];
    List<Map<String, dynamic>> remainder = _historyList.where((item) => !curatedHead.contains(item)).toList();

    return [...curatedHead, ...remainder];
  }

  bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;

  final List<String> _sortList = ['default'.tr, 'ascending'.tr, 'descending'.tr, 'low_to_high'.tr, 'high_to_low'.tr];
  List<String> get sortList => _sortList;

  final List<String> _orderTypeList = ['all'.tr, 'home_delivery'.tr, 'take_away'.tr, 'dine_in'.tr];
  List<String> get getOrderTypeList => _orderTypeList;

  final List<String> _restaurantSortList = ['default'.tr, 'ascending'.tr, 'descending'.tr, "distance".tr, "fast_delivery".tr];
  List<String> get restaurantSortList => _restaurantSortList;

  int _sortIndex = 0;
  int get sortIndex => _sortIndex;

  int _restaurantSortIndex = 0;
  int get restaurantSortIndex => _restaurantSortIndex;

  int _rating = -1;
  int get rating => _rating;

  int _restaurantRating = -1;
  int get restaurantRating => _restaurantRating;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  bool _isAvailableFoods = false;
  bool get isAvailableFoods => _isAvailableFoods;


  bool _isNewArrivalsFoods = false;
  bool get isNewArrivalsFoods => _isNewArrivalsFoods;

  bool _freeDeliveryProduct = false;
  bool get isFreeDelivery => _freeDeliveryProduct;

  bool _freeDeliveryRestaurant = false;
  bool get isFreeDeliveryRestaurant => _freeDeliveryRestaurant;

  bool _isNewArrivalsRestaurant = false;
  bool get isNewArrivalsRestaurant => _isNewArrivalsRestaurant;

  bool _isPopularFood = false;
  bool get isPopularFood => _isPopularFood;

  bool _isPopularRestaurant = false;
  bool get isPopularRestaurant => _isPopularRestaurant;

  bool _isDiscountedFoods = false;
  bool get isDiscountedFoods => _isDiscountedFoods;

  bool _isDiscountedRestaurant = false;
  bool get isDiscountedRestaurant => _isDiscountedRestaurant;

  bool _productVeg = false;
  bool get productVeg => _productVeg;

  bool _restaurantVeg = false;
  bool get restaurantVeg => _restaurantVeg;

  bool _productNonVeg = false;
  bool get productNonVeg => _productNonVeg;

  bool _restaurantNonVeg = false;
  bool get restaurantNonVeg => _restaurantNonVeg;

  int? totalSize;
  int? pageOffset;
  bool _paginate = false;
  bool get paginate => _paginate;

  int? _allFoodTotalSize;
  int _allFoodOffset = 1;
  int _allFoodLimit = 10;
  bool _allFoodPaginate = false;
  bool get allFoodPaginate => _allFoodPaginate;

  final List<int> _selectedCuisinesProduct = [];
  List<int> get selectedCuisinesProduct =>  _selectedCuisinesProduct;

  final List<int> _selectedCuisinesRestaurant = [];
  List<int> get selectedCuisinesRestaurant => _selectedCuisinesRestaurant;

  final List<int> _selectedOrderType = [];
  List<int> get getSelectedOrderType => _selectedOrderType;

  bool _isOpenRestaurant = false;
  bool get isOpenRestaurant => _isOpenRestaurant;

  bool _isNearMe = false;
  bool get isNearMe => _isNearMe;

  void setNearMe(bool value, {bool willUpdate = true}) {
    _isNearMe = value;
    if(willUpdate) {
      update();
    }
  }


  void selectCuisineProduct(int cuisineId) {
    if(_selectedCuisinesProduct.contains(cuisineId)) {
      _selectedCuisinesProduct.removeAt(_selectedCuisinesProduct.indexOf(cuisineId));
    } else {
      _selectedCuisinesProduct.add(cuisineId);
    }
    update();
  }

  void selectCuisineRestaurant(int cuisineId) {
    if(_selectedCuisinesRestaurant.contains(cuisineId)) {
      _selectedCuisinesRestaurant.removeAt(_selectedCuisinesRestaurant.indexOf(cuisineId));
    } else {
      _selectedCuisinesRestaurant.add(cuisineId);
    }
    update();
  }

  void setSelectedOrderType(int index) {
    if (index == 0) {
      if (_selectedOrderType.contains(0)) {
        _selectedOrderType.clear();
      } else {
        _selectedOrderType.clear();
        _selectedOrderType.addAll([0, 1, 2, 3]);
      }
    } else {
      _selectedOrderType.remove(0);
      if (_selectedOrderType.contains(index)) {
        _selectedOrderType.remove(index);
      } else {
        _selectedOrderType.add(index);
      }
    }
    update();
  }

  void toggleVeg() {
    _productVeg = !_productVeg;
    if(_productVeg) {
      _productNonVeg = false;
    }
    update();
  }

  void toggleResVeg() {
    _restaurantVeg = !_restaurantVeg;
    if(_restaurantVeg) {
      _restaurantNonVeg = false;
    }
    update();
  }

  void toggleNonVeg() {
    _productNonVeg = !_productNonVeg;
    if(_productNonVeg) {
      _productVeg = false;
    }
    update();
  }

  void toggleResNonVeg() {
    _restaurantNonVeg = !_restaurantNonVeg;
    if(_restaurantNonVeg) {
      _restaurantVeg = false;
    }
    update();
  }

  void toggleAvailableFoods() {
    _isAvailableFoods = !_isAvailableFoods;
    update();
  }

  void toggleNewArrivalFoods() {
    _isNewArrivalsFoods = !_isNewArrivalsFoods;
    update();
  }

  void toggleFreeDeliveryProduct() {
    _freeDeliveryProduct = !_freeDeliveryProduct;
    update();
  }

  void toggleFreeDeliveryRestaurant() {
    _freeDeliveryRestaurant = !_freeDeliveryRestaurant;
    update();
  }

  void toggleNewArrivalRestaurant() {
    _isNewArrivalsRestaurant = !_isNewArrivalsRestaurant;
    update();
  }

  void togglePopularFoods() {
    _isPopularFood = !_isPopularFood;
    update();
  }

  void togglePopularRestaurant() {
    _isPopularRestaurant = !_isPopularRestaurant;
    update();
  }

  void toggleOpenRestaurant() {
    _isOpenRestaurant = !_isOpenRestaurant;
    update();
  }

  void toggleDiscountedFoods() {
    _isDiscountedFoods = !_isDiscountedFoods;
    update();
  }

  void toggleDiscountedRestaurant() {
    _isDiscountedRestaurant = !_isDiscountedRestaurant;
    update();
  }

  void setRestaurant(bool isRestaurant, {bool willUpdate = true}) {
    _isRestaurant = isRestaurant;
    if(willUpdate) {
      update();
    }
  }

  void setSearchMode(bool isSearchMode, {bool canUpdate = true}) {
    _isSearchMode = isSearchMode;
    if(isSearchMode) {
      _searchText = '';
      _allRestList = null;
      _searchProductList = null;
      _searchRestList = null;
      _sortIndex = 0;
      _restaurantSortIndex = 0;
      _isDiscountedFoods = false;
      _isDiscountedRestaurant = false;
      _isAvailableFoods = false;
      _isOpenRestaurant = false;
      _productVeg = false;
      _restaurantVeg = false;
      _productNonVeg = false;
      _restaurantNonVeg = false;
      _rating = -1;
      _restaurantRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
      _freeDeliveryProduct = false;
      _freeDeliveryRestaurant = false;
      _isPopularFood = false;
      _isPopularRestaurant = false;
      _selectedOrderType.clear();
      _selectedCuisinesProduct.clear();
      _selectedCuisinesRestaurant.clear();
      _isNearMe = false;
    }
    if (_isRestaurant){
      _isRestaurant = !_isRestaurant;
    }
    if(canUpdate) {
      update();
    }
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void getSuggestedFoods() async {
    _suggestedFoodList = null;
    _suggestedFoodList = await searchServiceInterface.getSuggestedFoods();
    update();
  }

  void getTrendingSearches() async {
    _trendingSearchList = await searchServiceInterface.getTrendingSearches() ?? [];
    update();
  }

  void getTopCategories() async {
    _topCategoryModel = await searchServiceInterface.getTopCategories() ?? TopCategoryModel(totalSize: 0, categories: []);
    update();
  }

  void loadMoreTopCategories() async {
    if(_topCategoryPaginate || _topCategoryModel?.categories == null) {
      return;
    }
    int limit = _topCategoryModel!.limit ?? 10;
    int totalPage = ((_topCategoryModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_topCategoryModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _topCategoryPaginate = true;
    update();

    TopCategoryModel? nextPage = await searchServiceInterface.getTopCategories(offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _topCategoryModel!.categories!.addAll(nextPage.categories ?? []);
      _topCategoryModel!.offset = nextPage.offset;
      _topCategoryModel!.totalSize = nextPage.totalSize;
    }
    _topCategoryPaginate = false;
    update();
  }

  void getFeaturedRestaurants() async {
    _featuredRestaurantModel = await searchServiceInterface.getFeaturedRestaurants() ?? RestaurantModel(totalSize: 0, restaurants: []);
    update();
  }

  void loadMoreFeaturedRestaurants() async {
    if(_featuredRestaurantPaginate || _featuredRestaurantModel?.restaurants == null) {
      return;
    }
    int limit = int.tryParse(_featuredRestaurantModel!.limit ?? '10') ?? 10;
    int totalPage = ((_featuredRestaurantModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_featuredRestaurantModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _featuredRestaurantPaginate = true;
    update();

    RestaurantModel? nextPage = await searchServiceInterface.getFeaturedRestaurants(offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _featuredRestaurantModel!.restaurants!.addAll(nextPage.restaurants ?? []);
      _featuredRestaurantModel!.offset = nextPage.offset;
      _featuredRestaurantModel!.totalSize = nextPage.totalSize;
    }
    _featuredRestaurantPaginate = false;
    update();
  }

  void getExclusiveDeals() async {
    _exclusiveDealsModel = await searchServiceInterface.getExclusiveDeals() ?? RestaurantModel(totalSize: 0, restaurants: []);
    update();
  }

  void loadMoreExclusiveDeals() async {
    if(_exclusiveDealsPaginate || _exclusiveDealsModel?.restaurants == null) {
      return;
    }
    int limit = int.tryParse(_exclusiveDealsModel!.limit ?? '10') ?? 10;
    int totalPage = ((_exclusiveDealsModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_exclusiveDealsModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _exclusiveDealsPaginate = true;
    update();

    RestaurantModel? nextPage = await searchServiceInterface.getExclusiveDeals(offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _exclusiveDealsModel!.restaurants!.addAll(nextPage.restaurants ?? []);
      _exclusiveDealsModel!.offset = nextPage.offset;
      _exclusiveDealsModel!.totalSize = nextPage.totalSize;
    }
    _exclusiveDealsPaginate = false;
    update();
  }

  Future<List<Map<String, dynamic>>> getSearchSuggestions(String searchText) async {
    _suggestionsList = [];
    _searchSuggestionModel = await searchServiceInterface.getSearchSuggestions(searchText);
    if(_searchSuggestionModel != null) {
      for (var food in _searchSuggestionModel!.foods!) {
        _suggestionsList.add({
          'name': food.name!,
          'isRestaurant': false,
        });
      }
      for (var restaurant in _searchSuggestionModel!.restaurants!) {
        _suggestionsList.add({
          'name': restaurant.name!,
          'isRestaurant': true,
        });
      }
      _suggestionsList.shuffle();
    }
    return _suggestionsList;
  }

  Future<void> searchData(String query, int offset, {bool willUpdate = true, bool? nearMe}) async {
    if(nearMe != null) {
      _isNearMe = nearMe;
    }

    int rating = searchServiceInterface.findRatings(_isRestaurant ? _restaurantRating : _rating);
    bool isNewActive = _isRestaurant ? _isNewArrivalsRestaurant : _isNewArrivalsFoods;
    bool isPopular = _isRestaurant ? _isPopularRestaurant : _isPopularFood;
    String type = searchServiceInterface.processType(_isRestaurant, _restaurantVeg, _restaurantNonVeg, _productVeg, _productNonVeg);
    bool discounted = _isRestaurant ? _isDiscountedRestaurant : _isDiscountedFoods;
    String sortBy = searchServiceInterface.getSortBy(_isRestaurant, _restaurantSortIndex, _sortIndex);

      _searchText = query;
      if(offset == 1) {
        if (_isRestaurant) {
          _searchRestList = null;
          _allRestList = null;
        } else {
          _searchProductList = null;
        }
      } else {
        _paginate = true;
      }
      bool exists = _historyList.any((item) => item['query'] == query);
      if (!exists) {
        _historyList.insert(0, {
          'query': query,
          'type': 'history',
        });
      }
      List<String> historyStrings = _historyList.map((item) => '${item['query']}|${item['type']}').toList();
      searchServiceInterface.saveSearchHistory(historyStrings);
      _isSearchMode = false;
      if(willUpdate) {
        update();
      }

      Response response = await searchServiceInterface.getSearchData(
        query: query,
        isRestaurant: _isRestaurant,
        offset: offset,
        type: type,
        isNew: isNewActive ? 1 : 0,
        freeDelivery:  _isRestaurant?
            ( _freeDeliveryRestaurant ? 1 : 0)
            : (_freeDeliveryProduct ? 1 : 0),
        isAvailableFood: _isAvailableFoods? 1 : 0,
        isPopular: isPopular ? 1 : 0,
        isOneRatting: rating == 1 ? 1 : 0,
        isTwoRatting: rating == 2 ? 1 : 0,
        isThreeRatting: rating == 3 ? 1 : 0,
        isFourRatting: rating == 4 ? 1 : 0,
        isFiveRatting: rating == 5 ? 1 : 0,
        sortBy: sortBy,
        discounted: discounted ? 1 : 0,
        minPrice: _lowerValue, maxPrice: _upperValue,
        selectedCuisines:_isRestaurant ? _selectedCuisinesRestaurant : _selectedCuisinesProduct,
        orderType: _selectedOrderType,
        isOpenRestaurant: _isOpenRestaurant ? 1 : 0,
        nearMe: _isNearMe ? 1 : 0,
      );

      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestList = [];
          } else {
            _searchProductList = [];
          }
        } else {

          if (_isRestaurant) {
            if(offset == 1) {
              _searchRestList = [];
              _allRestList = [];
            }
            _searchRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
            _allRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
            totalSize = RestaurantModel.fromJson(response.body).totalSize;
            pageOffset = RestaurantModel.fromJson(response.body).offset;
          } else {
            if(offset == 1) {
              _searchProductList = [];
            }
            _searchProductList!.addAll(ProductModel.fromJson(response.body).products!);
            totalSize = ProductModel.fromJson(response.body).totalSize;
            pageOffset = ProductModel.fromJson(response.body).offset;
            if(_lowerValue == 0 || _upperValue == 0) {
              _lowerValue = ProductModel.fromJson(response.body).minPrice ?? 0;
              _upperValue = ProductModel.fromJson(response.body).maxPrice ?? 0;
            }
          }
        }
      }
    _paginate = false;
    update();
  }

  Future<void> searchAllData(String query, {bool willUpdate = true, bool? nearMe, String historyType = 'history'}) async {
    if(nearMe != null) {
      _isNearMe = nearMe;
    }
    _searchText = query;
    _searchProductList = null;
    _searchRestList = null;
    _allRestList = null;

    bool exists = _historyList.any((item) => item['query'] == query);
    if (!exists) {
      _historyList.insert(0, {
        'query': query,
        'type': historyType,
      });
    }
    List<String> historyStrings = _historyList.map((item) => '${item['query']}|${item['type']}').toList();
    searchServiceInterface.saveSearchHistory(historyStrings);
    _isSearchMode = false;
    if(willUpdate) {
      update();
    }

    int restaurantRating = searchServiceInterface.findRatings(_restaurantRating);
    String restaurantType = searchServiceInterface.processType(true, _restaurantVeg, _restaurantNonVeg, _productVeg, _productNonVeg);
    String restaurantSortBy = searchServiceInterface.getSortBy(true, _restaurantSortIndex, _sortIndex);

    List<Response> responses = await Future.wait([
      _getSearchedFoods(query, 1),
      searchServiceInterface.getSearchData(
        query: query, isRestaurant: true, offset: 1, type: restaurantType,
        isNew: _isNewArrivalsRestaurant ? 1 : 0, freeDelivery: _freeDeliveryRestaurant ? 1 : 0,
        isAvailableFood: 0, isPopular: _isPopularRestaurant ? 1 : 0,
        isOneRatting: restaurantRating == 1 ? 1 : 0, isTwoRatting: restaurantRating == 2 ? 1 : 0, isThreeRatting: restaurantRating == 3 ? 1 : 0,
        isFourRatting: restaurantRating == 4 ? 1 : 0, isFiveRatting: restaurantRating == 5 ? 1 : 0,
        sortBy: restaurantSortBy, discounted: _isDiscountedRestaurant ? 1 : 0,
        minPrice: 0, maxPrice: 0,
        selectedCuisines: _selectedCuisinesRestaurant, orderType: _selectedOrderType, isOpenRestaurant: _isOpenRestaurant ? 1 : 0,
        nearMe: _isNearMe ? 1 : 0,
      ),
    ]);

    _allFoodTotalSize = null;
    _allFoodOffset = 1;
    try {
      if(responses[0].statusCode == 200 && query.isNotEmpty) {
        ProductModel productModel = ProductModel.fromJson(responses[0].body);
        _searchProductList = productModel.products ?? [];
        _allFoodTotalSize = productModel.totalSize;
        _allFoodOffset = productModel.offset ?? 1;
        _allFoodLimit = int.tryParse(productModel.limit ?? '') ?? _allFoodLimit;
      } else {
        _searchProductList = [];
      }
    } catch (_) {
      _searchProductList = [];
    }

    try {
      if(responses[1].statusCode == 200 && query.isNotEmpty) {
        _searchRestList = RestaurantModel.fromJson(responses[1].body).restaurants ?? [];
        _allRestList = _searchRestList;
      } else {
        _searchRestList = [];
        _allRestList = [];
      }
    } catch (_) {
      _searchRestList = [];
      _allRestList = [];
    }

    update();
  }

  Future<Response> _getSearchedFoods(String query, int offset) {
    int rating = searchServiceInterface.findRatings(_rating);
    return searchServiceInterface.getSearchData(
      query: query, isRestaurant: false, offset: offset,
      type: searchServiceInterface.processType(false, _restaurantVeg, _restaurantNonVeg, _productVeg, _productNonVeg),
      isNew: _isNewArrivalsFoods ? 1 : 0, freeDelivery: _freeDeliveryProduct ? 1 : 0,
      isAvailableFood: _isAvailableFoods ? 1 : 0, isPopular: _isPopularFood ? 1 : 0,
      isOneRatting: rating == 1 ? 1 : 0, isTwoRatting: rating == 2 ? 1 : 0, isThreeRatting: rating == 3 ? 1 : 0,
      isFourRatting: rating == 4 ? 1 : 0, isFiveRatting: rating == 5 ? 1 : 0,
      sortBy: searchServiceInterface.getSortBy(false, _restaurantSortIndex, _sortIndex),
      discounted: _isDiscountedFoods ? 1 : 0,
      minPrice: _lowerValue, maxPrice: _upperValue,
      selectedCuisines: _selectedCuisinesProduct, orderType: _selectedOrderType, isOpenRestaurant: 0,
      nearMe: _isNearMe ? 1 : 0,
    );
  }

  Future<void> loadMoreSearchedFoods() async {
    if(_allFoodPaginate || _searchProductList == null || _allFoodTotalSize == null || _searchText.isEmpty) {
      return;
    }
    int totalPage = (_allFoodTotalSize! / (_allFoodLimit > 0 ? _allFoodLimit : 10)).ceil();
    int nextOffset = _allFoodOffset + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _allFoodPaginate = true;
    update();

    try {
      Response response = await _getSearchedFoods(_searchText, nextOffset);
      if(response.statusCode == 200) {
        ProductModel productModel = ProductModel.fromJson(response.body);
        _searchProductList!.addAll(productModel.products ?? []);
        _allFoodTotalSize = productModel.totalSize ?? _allFoodTotalSize;
        _allFoodOffset = productModel.offset ?? nextOffset;
      }
    } catch (_) {
    }

    _allFoodPaginate = false;
    update();
  }

  void getHistoryList() {
    _searchText = '';
    _historyList = [];
    _searchProductList = [];
    _allRestList = [];
    _searchRestList = [];
    List<String> storedHistory = searchServiceInterface.getSearchHistory();
    const validTypes = {'food', 'restaurant', 'history'};
    for (String item in storedHistory) {
      List<String> parts = item.split('|');
      if (parts.length == 2 && parts[0].trim().isNotEmpty) {
        _historyList.add({
          'query': parts[0],
          'type': validTypes.contains(parts[1]) ? parts[1] : 'history',
        });
      }
    }
  }

  void removeHistory(Map<String, dynamic> item) {
    _historyList.remove(item);
    List<String> historyStrings = _historyList.map((item) => '${item['query']}|${item['type']}').toList();
    searchServiceInterface.saveSearchHistory(historyStrings);
    update();
  }

  void clearSearchAddress() async {
    searchServiceInterface.clearSearchHistory();
    _historyList = [];
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setRestaurantRating(int rate) {
    _restaurantRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  void setRestSortIndex(int index) {
    _restaurantSortIndex = index;
    update();
  }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _isAvailableFoods = false;
    _isDiscountedFoods = false;
    _selectedOrderType.clear();
    _productVeg = false;
    _productNonVeg = false;
    _sortIndex = 0;
    _isNewArrivalsFoods = false;
    _freeDeliveryProduct = false;
    _isPopularFood = false;
    _selectedCuisinesProduct.clear();

    update();
  }

  void resetRestaurantFilter() {
    _restaurantRating = -1;
    _isOpenRestaurant = false;
    _isDiscountedRestaurant = false;
    _selectedOrderType.clear();
    _restaurantVeg = false;
    _restaurantNonVeg = false;
    _restaurantSortIndex = 0;
    _isNewArrivalsRestaurant = false;
    _freeDeliveryRestaurant = false;
    _isPopularRestaurant = false;
    _selectedCuisinesRestaurant.clear();
    update();
  }

  void applySharedFiltersToRestaurant() {
    _restaurantSortIndex = _sortIndex <= 2 ? _sortIndex : 0;
    _restaurantVeg = _productVeg;
    _restaurantNonVeg = _productNonVeg;
    _restaurantRating = _rating;
    _freeDeliveryRestaurant = _freeDeliveryProduct;
    _isNewArrivalsRestaurant = _isNewArrivalsFoods;
    _isDiscountedRestaurant = _isDiscountedFoods;
    _isPopularRestaurant = _isPopularFood;
    _selectedCuisinesRestaurant.clear();
    _selectedCuisinesRestaurant.addAll(_selectedCuisinesProduct);
  }

  void saveSearchHistory(String query) {
    if(query.trim().isEmpty) {
      return;
    }
    bool exists = _historyList.any((item) => item['query'] == query);
    if (!exists) {
      _historyList.insert(0, {
        'query': query,
        'type': 'history',
      });
    }
    List<String> historyStrings = _historyList.map((item) => '${item['query']}|${item['type']}').toList();
    searchServiceInterface.saveSearchHistory(historyStrings);
  }


  bool voiceIsListening = false;
  String voiceText = '';
  double voiceSoundLevel = 0.0;
  bool voiceAvailable = false;
  Timer? _voiceAutoSubmitTimer;

  late stt.SpeechToText _speech;

  Future<void> initVoice({bool isUpdate = true}) async {
    try {
      final available = await _speech.initialize(onStatus: _onStatus, onError: _onError);
      voiceAvailable = available;
    } catch (e) {
      voiceAvailable = false;
    }
    if(isUpdate) update();
  }

  void _onStatus(String status) {
    if (status == stt.SpeechToText.listeningStatus) {
      setVoiceListening(true);
      cancelVoiceAutoSubmit();
    } else if (status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus || status == 'not listening') {
      setVoiceListening(false);
      scheduleVoiceAutoSubmit(const Duration(seconds: 2));
    }
  }

  void _onError(dynamic error) {
    setVoiceListening(false);
  }

  Future<void> startVoiceListening({TextEditingController? externalController}) async {
    cancelVoiceAutoSubmit();

    try {
      if (_speech.isListening) await _speech.stop();
      await _speech.cancel();
    } catch (_) {}

    if (!voiceAvailable) {
      await initVoice();
      if (!voiceAvailable) return;
    }

    setVoiceText('');
    setVoiceSoundLevel(0.0);

    try {
      await _speech.listen(
        onResult: (result) {
          final recognized = result.recognizedWords;
          setVoiceText(recognized);
          if (externalController != null) {
            externalController.text = recognized;
            externalController.selection = TextSelection.fromPosition(TextPosition(offset: externalController.text.length));
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        onSoundLevelChange: (level) {
          final normalized = (level / 50).clamp(0.0, 1.0);
          setVoiceSoundLevel(normalized);
        },
        localeId: Get.deviceLocale?.languageCode,
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true, listenMode: stt.ListenMode.search),
      );
      if (_speech.isListening) {
        setVoiceListening(true);
      } else {
        setVoiceListening(false);
      }
    } catch (e) {
      setVoiceListening(false);
    }
  }

  Future<void> stopVoiceListening({bool submit = false}) async {
    cancelVoiceAutoSubmit();
    try {
      await _speech.stop();
    } catch (e) {
      try {
        await _speech.cancel();
      } catch (_) {}
    }
    setVoiceListening(false);
    if (submit) await submitVoiceNow();
  }

  void setVoiceListening(bool value, {bool isUpdate = true}) {
    voiceIsListening = value;
    if(isUpdate) update();
  }

  void setVoiceText(String text, {bool isUpdate = true}) {
    voiceText = text;
    if(isUpdate) update();
  }

  void setVoiceSoundLevel(double level, {bool isUpdate = true}) {
    voiceSoundLevel = level;
    if(isUpdate) update();
  }

  void scheduleVoiceAutoSubmit(Duration duration) {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = Timer(duration, () async {
      await submitVoiceNow();
    });
  }

  void cancelVoiceAutoSubmit() {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = null;
  }

  Future<void> submitVoiceNow() async {
    cancelVoiceAutoSubmit();
    final text = voiceText.trim();
    if (text.isNotEmpty) {
      try {
        if ((Get.isBottomSheetOpen ?? false) || (Get.isDialogOpen ?? false)) {
          Get.back();
        }
      } catch (_) {}
      await searchData(text, 1);
    }
  }

  @override
  void onClose() {
    _voiceAutoSubmitTimer?.cancel();
    super.onClose();
  }

}