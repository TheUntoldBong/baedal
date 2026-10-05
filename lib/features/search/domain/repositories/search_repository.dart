import 'dart:convert';

import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/search/domain/repositories/search_repository_interface.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';
import 'package:stackfood_multivendor/features/search/domain/models/top_category_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepository implements SearchRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SearchRepository({required this.apiClient, required this.sharedPreferences});

  static String _cuisineQuery(List<int> cuisines) => Uri.encodeComponent(jsonEncode(cuisines));

  @override
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText) async {
    SearchSuggestionModel? searchSuggestionModel;
    Response response = await apiClient.getData('${AppConstants.searchSuggestionsUri}?name=$searchText');
    if(response.statusCode == 200) {
      searchSuggestionModel = SearchSuggestionModel.fromJson(response.body);
    }
    return searchSuggestionModel;
  }

  @override
  Future<List<Product>?> getSuggestedFoods() async {
    List<Product>? suggestedFoodList;
    Response response = await apiClient.getData(AppConstants.suggestedFoodUri);
    if(response.statusCode == 200) {
      suggestedFoodList = [];
      response.body.forEach((suggestedFood) => suggestedFoodList!.add(Product.fromJson(suggestedFood)));
    }
    return suggestedFoodList;
  }

  @override
  Future<List<String>?> getTrendingSearches() async {
    List<String>? trendingSearchList;
    Response response = await apiClient.getData('${AppConstants.trendingSearchUri}?cache=false', handleError: false);
    if(response.statusCode == 200) {
      trendingSearchList = [];
      response.body['trending_searches'].forEach((trendingSearch) => trendingSearchList!.add(trendingSearch['keyword']));
    }
    return trendingSearchList;
  }

  @override
  Future<TopCategoryModel?> getTopCategories({int offset = 1, int limit = 10}) async {
    TopCategoryModel? topCategoryModel;
    Response response = await apiClient.getData('${AppConstants.topCategoriesUri}?offset=$offset&limit=$limit', handleError: false);
    if(response.statusCode == 200) {
      topCategoryModel = TopCategoryModel.fromJson(response.body);
    }
    return topCategoryModel;
  }

  @override
  Future<RestaurantModel?> getFeaturedRestaurants({int offset = 1, int limit = 10}) async {
    RestaurantModel? restaurantModel;
    Response response = await apiClient.getData('${AppConstants.featuredRestaurantUri}?limit=$limit&offset=$offset', handleError: false);
    if(response.statusCode == 200) {
      restaurantModel = RestaurantModel.fromJson(response.body);
    }
    return restaurantModel;
  }

  @override
  Future<RestaurantModel?> getExclusiveDeals({int offset = 1, int limit = 10}) async {
    RestaurantModel? restaurantModel;
    Response response = await apiClient.getData('${AppConstants.exclusiveDealsUri}?limit=$limit&offset=$offset', handleError: false);
    if(response.statusCode == 200) {
      restaurantModel = RestaurantModel.fromJson(response.body);
    }
    return restaurantModel;
  }

  @override
  Future<Response> getSearchData({required String query, required bool isRestaurant, required int offset,
    String? type, int? isNew = 0, int? freeDelivery = 0, int? isAvailableFood =0, int? isPopular = 0, double? minPrice, double? maxPrice,
    int? isOneRatting = 0, int? isTwoRatting = 0, int? isThreeRatting = 0, int? isFourRatting = 0, int? isFiveRatting = 0,
    String? sortBy, int? discounted = 0, required List<int> selectedCuisines, required List<int> orderType, int? isOpenRestaurant, int? nearMe = 0}) async {

    return await apiClient.getData('${AppConstants.searchUri}${isRestaurant ? 'restaurants' : 'products'}/search?'
        '&offset=$offset&limit=10'
        '&name=$query'
        '&sort_by=$sortBy'
        '&near_me=${nearMe == 1 ? '1' : '0'}'
        '${!isRestaurant? '&min_price=${minPrice! > 0 ? minPrice : "0.0"}&max_price=${maxPrice! > 0 ? maxPrice : ""}' : ""}'
        '${orderType.contains(0) ? '&order_type[]=all' : "${orderType.contains(1) ? '&order_type[]=delivery' : ''}${orderType.contains(2) ? '&order_type[]=take_away' : ''}${orderType.contains(3) ? '&order_type[]=dine_in' : ''}"}'
        '${type == 'veg' ? '&filter_by[]=veg' : ''}'
        '${type == 'non_veg' ? '&filter_by[]=non_veg' : ''}'
        '&rating_1_plus=${isOneRatting ==1 ? '1' : '0'}'
        '&rating_2_plus=${isTwoRatting ==1 ? '1' : '0'}'
        '&rating_3_plus=${isThreeRatting ==1 ? '1' : '0'}'
        '&rating_4_plus=${isFourRatting == 1 ? '1' : '0'}'
        '&rating_5=${isFiveRatting == 1 ? '1' : '0'}'
        '${freeDelivery == 1 ? '&filter_by[]=free_delivery' : ''}'
        '${isAvailableFood == 1 || (isOpenRestaurant == 1 && isRestaurant) ? '&filter_by[]=currently_available' : ''}'
        '${isNew == 1 ? '&filter_by[]=new_arrivals' : ''}'
        '${discounted == 1 ? '&filter_by[]=discounted' : ''}'
        '${isPopular == 1 ? '&filter_by[]=popular' : ''}'
        '&cuisine=${_cuisineQuery(selectedCuisines)}'
    );
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.searchHistory, searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.searchHistory, []);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  
}