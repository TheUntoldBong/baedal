import 'dart:convert';

import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/repositories/restaurant_repository_interface.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantRepository implements RestaurantRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RestaurantRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId) async {
    RecommendedProductModel? recommendedProductModel;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantRecommendedItemUri}?restaurant_id=$restaurantId',
    );
    if (response.statusCode == 200 && response.body != null) {
      if (response.body is Map<String, dynamic>) {
        recommendedProductModel = RecommendedProductModel.fromJson(response.body);
      } else if (response.body is List) {
        recommendedProductModel = RecommendedProductModel.fromList(response.body);
      }
    }

    if (recommendedProductModel == null || (recommendedProductModel.products?.isEmpty ?? true)) {
      Response fallbackResponse = await apiClient.getData(
        '${AppConstants.cartRestaurantSuggestedItemsUri}?restaurant_id=$restaurantId',
      );
      if (fallbackResponse.statusCode == 200 && fallbackResponse.body != null) {
        if (fallbackResponse.body is List) {
          final List<Product> items = [];
          for (var item in fallbackResponse.body) {
            if (item is Map<String, dynamic>) {
              items.add(Product.fromJson(item));
            }
          }
          if (items.isNotEmpty) {
            recommendedProductModel = RecommendedProductModel(
              totalSize: items.length,
              products: items,
            );
          }
        }
      }
    }

    return recommendedProductModel;
  }

  String get _guestQuery {
    final String guestId = AuthHelper.isLoggedIn() ? '' : AuthHelper.getGuestId();
    return guestId.isNotEmpty ? '&guest_id=$guestId' : '';
  }

  @override
  Future<RestaurantBogoOfferListModel?> getRestaurantBogoOffers(int? restaurantId, {int offset = 1, int limit = 10, Restaurant? restaurant}) async {
    Response response = await apiClient.getData(
      '${AppConstants.restaurantBogoOffersUri}?restaurant_id=$restaurantId&limit=$limit&offset=$offset$_guestQuery', handleError: false,
    );
    if (response.statusCode == 200) {
      return RestaurantBogoOfferListModel.fromJson(response.body, restaurant: restaurant);
    }
    return null;
  }

  @override
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    List<Product>? suggestedItems;
    Response response = await apiClient.getData('${AppConstants.cartRestaurantSuggestedItemsUri}?restaurant_id=$restaurantID');
    if (response.statusCode == 200) {
      suggestedItems =  [];
      response.body.forEach((product) {
        suggestedItems!.add(Product.fromJson(product));
      });
    }
    return suggestedItems;
  }

  @override
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, VegType type) async {
    ProductModel? productModel;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantProductUri}?restaurant_id=$restaurantID&category_id=$categoryID&offset=$offset&limit=12&type=${type.value}',
    );
    if (response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? restaurantId, int offset, VegType type) async {
    ProductModel? restaurantSearchProductModel;
    Response response = await apiClient.getData(
      '${AppConstants.searchUri}products/search?restaurant_id=$restaurantId&name=$searchText&offset=$offset&limit=10&type=${type.value}',
    );
    if (response.statusCode == 200) {
      restaurantSearchProductModel = ProductModel.fromJson(response.body);
    }
    return restaurantSearchProductModel;
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
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode}) async {
    return await _getRestaurantDetails(id, slug, languageCode);
  }

  Future<Restaurant?> _getRestaurantDetails(String? restaurantID, String slug, String? languageCode) async {
    Restaurant? restaurant;
    Map<String, String>? header;
    if(slug.isNotEmpty){
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), [],
        languageCode, '', '', setHeader: false,
      );
    }
    Response response = await apiClient.getData('${AppConstants.restaurantDetailsUri}${slug.isNotEmpty ? slug : restaurantID ?? ''}', headers: header);
    if (response.statusCode == 200) {
      restaurant = Restaurant.fromJson(response.body);
    }
    return restaurant;
  }

  @override
  Future<RestaurantModel?> getList({int? offset, Set<String>? orderTypes, String? sortBy, int? topRated, int? discount, int? veg, int? nonVeg, int? newlyJoined, int? popular, bool fromMap = false, DataSourceEnum? source, FilterDataModel? filterDataModel}) async {
    RestaurantModel? restaurantModel;

    final String orderTypeQuery = (orderTypes ?? const <String>{})
        .where((orderType) => orderType != 'all').map((orderType) => '&order_type[]=$orderType').join();

    final String filterByQuery = ''
        '${(newlyJoined ?? 0) == 1 ? '&filter_by[]=new_arrivals' : ''}'
        '${(popular ?? 0) == 1 ? '&filter_by[]=popular' : ''}'
        '${(topRated ?? 0) == 1 ? '&filter_by[]=top_rated' : ''}'
        '${(discount ?? 0) == 1 ? '&filter_by[]=discounted' : ''}'
        '${(veg ?? 0) == 1 ? '&filter_by[]=veg' : ''}'
        '${(nonVeg ?? 0) == 1 ? '&filter_by[]=non_veg' : ''}';

    String sortByQuery = (sortBy == null || sortBy.isEmpty) ? '' : '&sort_by=$sortBy';

    String cacheId = '${AppConstants.restaurantUri}/all?limit=${fromMap ? 20 : 25}&offset=$offset&type=all$orderTypeQuery$sortByQuery$filterByQuery';

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(cacheId);
        if(response.statusCode == 200){
          restaurantModel = RestaurantModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return restaurantModel;
  }

  @override
  Future<List<Restaurant>?> getRestaurantList({VegType? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source, FilterDataModel? filterDataModel}) async {
    if(isRecentlyViewed) {
      return _getRecentlyViewedRestaurantList(type ?? VegType.all, source: source);
    } else if(isOrderAgain) {
      return _getOrderAgainRestaurantList(type ?? VegType.all, source: source);
    } else if(isLatest) {
      return _getLatestRestaurantList(type ?? VegType.all, source: source);
    }
    return null;
  }

  @override
  Future<RestaurantModel?> getRecommendedRestaurantList({int offset = 1, int limit = 10, VegType type = VegType.all, String name = '', DataSourceEnum? source}) {
    return _getPaginatedRestaurantList(
      '${AppConstants.recommendedRestaurantUri}?offset=$offset&limit=$limit&type=${type.value}${_nameQuery(name)}',
      cache: name.isEmpty, source: source,
    );
  }

  @override
  Future<RestaurantModel?> getTopPickRestaurantList({int offset = 1, int limit = 10, VegType type = VegType.all, String name = '', DataSourceEnum? source}) {
    return _getPaginatedRestaurantList(
      '${AppConstants.restaurantUri}/all?filter_data=near_by_restaurants&filter_by%5B%5D=popular&offset=$offset&limit=$limit&type=${type.value}${_nameQuery(name)}',
      cache: name.isEmpty, source: source,
    );
  }

  @override
  Future<RestaurantModel?> getQuickDeliveryRestaurantList({int offset = 1, int limit = 10, VegType type = VegType.all, String name = '', DataSourceEnum? source}) {
    return _getPaginatedRestaurantList(
      '${AppConstants.quickDeliveryRestaurantUri}?offset=$offset&limit=$limit&type=${type.value}${_nameQuery(name)}',
      cache: name.isEmpty, source: source,
    );
  }

  static String _nameQuery(String name) => name.isEmpty ? '' : '&name=${Uri.encodeQueryComponent(name)}';

  Future<RestaurantModel?> _getPaginatedRestaurantList(String uri, {bool cache = true, DataSourceEnum? source}) async {
    RestaurantModel? restaurantModel;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if(response.statusCode == 200){
          restaurantModel = RestaurantModel.fromJson(response.body);
          if(cache) {
            LocalClient.organize(DataSourceEnum.client, uri, jsonEncode(response.body), apiClient.getHeader());
          }
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, uri, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return restaurantModel;
  }


  Future<List<Restaurant>?> _getLatestRestaurantList(VegType type, {DataSourceEnum? source}) async {
    List<Restaurant>? latestRestaurantList;
    String cacheId = AppConstants.latestRestaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.latestRestaurantUri}?type=${type.value}');
        if(response.statusCode == 200){
          latestRestaurantList = [];
          response.body.forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          latestRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return latestRestaurantList;
  }


  Future<List<Restaurant>?> _getRecentlyViewedRestaurantList(VegType type, {DataSourceEnum? source}) async {
    List<Restaurant>? recentlyViewedRestaurantList;
    String cacheId = '${AppConstants.recentlyViewedRestaurantUri}?type=${type.value}';

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(cacheId);
        if(response.statusCode == 200){
          recentlyViewedRestaurantList = [];
          response.body.forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          recentlyViewedRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return recentlyViewedRestaurantList;
  }

  Future<List<Restaurant>?> _getOrderAgainRestaurantList(VegType type, {DataSourceEnum? source}) async {
    List<Restaurant>? orderAgainRestaurantList;
    String cacheId = '${AppConstants.orderAgainUri}?type=${type.value}';

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(cacheId);
        if(response.statusCode == 200){
          orderAgainRestaurantList = [];
          response.body.forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          orderAgainRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return orderAgainRestaurantList;
  }

  @override
  Future<RestaurantModel?> getFreeDeliveryRestaurantList({required int offset, int limit = 25, String name = '', DataSourceEnum? source}) async {
    RestaurantModel? restaurantModel;
    String cacheId = '${AppConstants.restaurantUri}/free-delivery';

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.restaurantUri}/all?filter_by[]=free_delivery&limit=$limit&offset=$offset${_nameQuery(name)}');
        if(response.statusCode == 200){
          restaurantModel = RestaurantModel.fromJson(response.body);
          if(name.isEmpty) {
            LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
          }
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return restaurantModel;
  }

  @override
  Future<RestaurantCategoryFoodsModel?> getRestaurantCategoryFoods(int restaurantId, VegType type) async {
    RestaurantCategoryFoodsModel? model;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantCategoriesItem}?restaurant_id=$restaurantId&type=${type.value}',
    );
    if (response.statusCode == 200) {
      model = RestaurantCategoryFoodsModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }


}