import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/offer/domain/repositories/offer_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';

class OfferRepository implements OfferRepositoryInterface {
  final ApiClient apiClient;
  OfferRepository({required this.apiClient});


  static String _idList(Set<int> ids) => '[${ids.join(',')}]';

  static String _ratingQuery(int? rating) => ''
      '${rating == 5 ? '&rating_5=1' : ''}'
      '${rating == 4 ? '&rating_4_plus=1' : ''}'
      '${rating == 3 ? '&rating_3_plus=1' : ''}'
      '${rating == 2 ? '&rating_2_plus=1' : ''}';

  String _itemFilterQuery({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
  }) {
    return ''
        '${search != null && search.isNotEmpty ? '&search=$search' : ''}'
        '${minPrice != null ? '&min_price=$minPrice' : ''}'
        '${maxPrice != null ? '&max_price=$maxPrice' : ''}'
        '${halal ? '&halal=1' : ''}'
        '${type != null && type.isNotEmpty ? '&type=$type' : ''}'
        '${_ratingQuery(rating)}'
        '${categoryIds != null && categoryIds.isNotEmpty ? '&category_ids=${_idList(categoryIds)}' : ''}'
        '${cuisineIds != null && cuisineIds.isNotEmpty ? '&cuisine_id=${_idList(cuisineIds)}' : ''}';
  }


  String _restaurantFilterQuery({
    String? search, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
  }) {
    return ''
        '${search != null && search.isNotEmpty ? '&search=$search' : ''}'
        '${halal ? '&filter_by[]=halal' : ''}'
        '${type != null && type.isNotEmpty ? '&type=$type' : ''}'
        '${_ratingQuery(rating)}'
        '${categoryIds != null && categoryIds.isNotEmpty ? '&category_ids=${_idList(categoryIds)}' : ''}'
        '${cuisineIds != null && cuisineIds.isNotEmpty ? '&cuisine_id=${_idList(cuisineIds)}' : ''}';
  }

  @override
  Future<ProductModel?> getOfferItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    ProductModel? productModel;
    Response response = await apiClient.getData(
      '${AppConstants.offerItemsUri}?limit=$limit&offset=$offset'
      '${_itemFilterQuery(search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal, type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds)}',
      handleError: false,
    );
    if(response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future<RestaurantModel?> getOfferRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int itemLimit = 5, int offset = 1, int limit = 20,
  }) async {
    RestaurantModel? restaurantModel;
    Response response = await apiClient.getData(
      '${AppConstants.offerRestaurantsUri}?limit=$limit&offset=$offset&item_limit=$itemLimit'
      '${_restaurantFilterQuery(search: search, halal: halal, type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds)}',
      handleError: false,
    );
    if(response.statusCode == 200) {
      restaurantModel = RestaurantModel.fromJson(response.body);
    }
    return restaurantModel;
  }


  String _filteredListQuery({
    required String filterBy,
    bool isRestaurant = false,
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
  }) {
    return ''
        '&filter_by[]=$filterBy'
        '${halal ? '&filter_by[]=halal' : ''}'
        '${search != null && search.isNotEmpty ? '&name=$search' : ''}'
        '${!isRestaurant && minPrice != null ? '&min_price=$minPrice' : ''}'
        '${!isRestaurant && maxPrice != null ? '&max_price=$maxPrice' : ''}'
        '${type == null || type.isEmpty ? '' : isRestaurant ? '&filter_by[]=$type' : '&type=$type'}'
        '${_ratingQuery(rating)}'
        '${categoryIds != null && categoryIds.isNotEmpty ? '&category_ids=${_idList(categoryIds)}' : ''}'
        '${cuisineIds != null && cuisineIds.isNotEmpty ? '&cuisine_id=${_idList(cuisineIds)}' : ''}';
  }


  Future<ProductModel?> _getFilteredItems({
    required String filterBy,
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    final bool searching = search != null && search.isNotEmpty;
    final String baseUri = searching ? AppConstants.productSearchUri : AppConstants.restaurantProductUri;
    ProductModel? productModel;
    Response response = await apiClient.getData(
      '$baseUri?limit=$limit&offset=$offset'
      '${_filteredListQuery(filterBy: filterBy, search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal, type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds)}',
      handleError: false,
    );
    if(response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  Future<RestaurantModel?> _getFilteredRestaurants({
    required String filterBy,
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    RestaurantModel? restaurantModel;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantUri}/all?limit=$limit&offset=$offset'
      '${_filteredListQuery(filterBy: filterBy, isRestaurant: true, search: search, halal: halal, type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds)}',
      handleError: false,
    );
    if(response.statusCode == 200) {
      restaurantModel = RestaurantModel.fromJson(response.body);
    }
    return restaurantModel;
  }

  @override
  Future<ProductModel?> getTopRatedItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) {
    return _getFilteredItems(
      filterBy: 'top_rated', search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds, offset: offset, limit: limit,
    );
  }

  @override
  Future<RestaurantModel?> getTopRatedRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) {
    return _getFilteredRestaurants(
      filterBy: 'top_rated', search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds, offset: offset, limit: limit,
    );
  }

  @override
  Future<ProductModel?> getFreeDeliveryItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) {
    return _getFilteredItems(
      filterBy: 'free_delivery', search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds, offset: offset, limit: limit,
    );
  }

  @override
  Future<RestaurantModel?> getFreeDeliveryRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) {
    return _getFilteredRestaurants(
      filterBy: 'free_delivery', search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds, offset: offset, limit: limit,
    );
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
