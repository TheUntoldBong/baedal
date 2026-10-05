import 'dart:convert';
import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:stackfood_multivendor/helper/filter_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;

  CategoryRepository({required this.apiClient});

  static String _cuisineQuery(List<int>? cuisines) => Uri.encodeComponent(jsonEncode(cuisines ?? []));

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
  Future<List<CategoryModel>?> getList({int? offset, DataSourceEnum? source, String? search}) async {
    List<CategoryModel>? categoryList;
    String cacheId = AppConstants.categoryUri;

    switch(source!){
      case DataSourceEnum.client:
        String uri = AppConstants.categoryUri;
        if (search != null && search.isNotEmpty) {
          uri += '?name=$search';
        }
        Response response = await apiClient.getData(uri);

        if(response.statusCode == 200){
          categoryList = [];
          response.body.forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((category) {
            categoryList!.add(CategoryModel.fromJson(category));
          });
        }
    }
    return categoryList;
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Response response = await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
    if (response.statusCode == 200) {
      subCategoryList= [];
      if(response.body != null && response.body.isNotEmpty) {
        subCategoryList.add(CategoryModel(id: int.parse(parentID!), name: 'all'.tr));
        response.body.forEach((category) => subCategoryList!.add(CategoryModel.fromJson(category)));
      }
    }
    return subCategoryList;
  }

  @override
  Future<ProductModel?> getCategoryProductList(String? categoryID, FilterDataModel? filterDataModel) async {
    ProductModel? productModel;
    Response response = await apiClient.getData(
        '${AppConstants.categoryProductUri}$categoryID?limit=10&offset=${filterDataModel?.offset ?? 1}'
        '&sort_by=${FilterHelper.getSortTypeFromIndex(filterDataModel?.sortIndex ?? -1, isRestaurant: false)}'
        '${'&min_price=${(filterDataModel?.minPrice??0) > 0 ? (filterDataModel?.minPrice??0.0) : "0.0"}&max_price=${(filterDataModel?.maxPrice??0) > 0 ? (filterDataModel?.maxPrice ?? 0.0) : ""}'}'
        '${(filterDataModel?.deliveryTypes?.contains(0) ?? false) ?  '&order_type[]=all' : "${(filterDataModel?.deliveryTypes?.contains(1) ?? false) ? '&order_type[]=delivery' : ''}${(filterDataModel?.deliveryTypes?.contains(2) ?? false) ? '&order_type[]=take_away' : ''}${(filterDataModel?.deliveryTypes?.contains(3) ?? false) ? '&order_type[]=dine_in' : ''}"}'
        '${(FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false) != '') ? '&filter_by[]=${FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false)}' : ''}'
        '&rating_1_plus=${filterDataModel?.rating == 1 ? '1' : '0'}'
        '&rating_2_plus=${filterDataModel?.rating == 2 ? '1' : '0'}'
        '&rating_3_plus=${filterDataModel?.rating == 3 ? '1' : '0'}'
        '&rating_4_plus=${filterDataModel?.rating == 4 ? '1' : '0'}'
        '&rating_5=${filterDataModel?.rating == 5 ? '1' : '0'}'
        '${(filterDataModel?.freeDelivery ?? false) ? '&filter_by[]=free_delivery' : ''}'
        '${(filterDataModel?.isAvailable ?? false) ? '&filter_by[]=currently_available' : ''}'
        '${(filterDataModel?.isNew ?? false) ? '&filter_by[]=new_arrivals' : ''}'
        '${(filterDataModel?.discounted ?? false)  ? '&filter_by[]=discounted' : ''}'
        '${(filterDataModel?.isPopular ?? false) ? '&filter_by[]=popular' : ''}'
        '&cuisine=${_cuisineQuery(filterDataModel?.selectedCuisines)}'
    );
    if (response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, FilterDataModel? filterDataModel) async {
    RestaurantModel? restaurantModel;

    Response response = await apiClient.getData(
        '${AppConstants.categoryRestaurantUri}$categoryID?limit=10&offset=${filterDataModel?.offset ?? 1}'
        '&sort_by=${FilterHelper.getSortTypeFromIndex(filterDataModel?.restaurantSortIndex ?? -1, isRestaurant: true)}'
        '${(filterDataModel?.restDeliveryTypes?.contains(0) ?? false) ?  '&order_type[]=all' : "${(filterDataModel?.restDeliveryTypes?.contains(1) ?? false) ? '&order_type[]=delivery' : ''}${(filterDataModel?.restDeliveryTypes?.contains(2) ?? false) ? '&order_type[]=take_away' : ''}${(filterDataModel?.restDeliveryTypes?.contains(3) ?? false) ? '&order_type[]=dine_in' : ''}"}'
        '${(FilterHelper.foodType(filterDataModel?.restVeg ?? false, filterDataModel?.restNonVeg ?? false) != '') ? '&filter_by[]=${(FilterHelper.foodType(filterDataModel?.restVeg ?? false, filterDataModel?.restNonVeg ?? false))}' : ''}'
        '&rating_1_plus=${filterDataModel?.restRating == 1 ? '1' : '0'}'
        '&rating_2_plus=${filterDataModel?.restRating == 2 ? '1' : '0'}'
        '&rating_3_plus=${filterDataModel?.restRating == 3 ? '1' : '0'}'
        '&rating_4_plus=${filterDataModel?.restRating == 4 ? '1' : '0'}'
        '&rating_5=${filterDataModel?.restRating == 5 ? '1' : '0'}'
        '${(filterDataModel?.restFreeDelivery ?? false) ? '&filter_by[]=free_delivery' : ''}'
        '${(filterDataModel?.restIsAvailable ?? false) ? '&filter_by[]=currently_available' : ''}'
        '${(filterDataModel?.restIsNew ?? false) ? '&filter_by[]=new_arrivals' : ''}'
        '${(filterDataModel?.restDiscounted ?? false)  ? '&filter_by[]=discounted' : ''}'
        '${(filterDataModel?.restIsPopular ?? false) ? '&filter_by[]=popular' : ''}'
        '&cuisine=${_cuisineQuery(filterDataModel?.restSelectedCuisines)}'
    );

    if (response.statusCode == 200) {
      restaurantModel = RestaurantModel.fromJson(response.body);
    }
    return restaurantModel;
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, FilterDataModel? filterDataModel) async {
    String productFilter = (
        '&sort_by=${FilterHelper.getSortTypeFromIndex(filterDataModel?.sortIndex ?? -1, isRestaurant: false)}'
        '${'&min_price=${(filterDataModel?.minPrice??0) > 0 ? (filterDataModel?.minPrice??0.0) : "0.0"}&max_price=${(filterDataModel?.maxPrice??0) > 0 ? (filterDataModel?.maxPrice ?? 0.0) : ""}'}'
        '${(filterDataModel?.deliveryTypes?.contains(0) ?? false) ?  '&order_type[]=all' : "${(filterDataModel?.deliveryTypes?.contains(1) ?? false) ? '&order_type[]=delivery' : ''}${(filterDataModel?.deliveryTypes?.contains(2) ?? false) ? '&order_type[]=take_away' : ''}${(filterDataModel?.deliveryTypes?.contains(3) ?? false) ? '&order_type[]=dine_in' : ''}"}'
        '${(FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false) != '') ? '&filter_by[]=${FilterHelper.foodType(filterDataModel?.veg ?? false, filterDataModel?.nonVeg ?? false)}' : ''}'
        '&rating_1_plus=${filterDataModel?.rating == 1 ? '1' : '0'}'
        '&rating_2_plus=${filterDataModel?.rating == 2 ? '1' : '0'}'
        '&rating_3_plus=${filterDataModel?.rating == 3 ? '1' : '0'}'
        '&rating_4_plus=${filterDataModel?.rating == 4 ? '1' : '0'}'
        '&rating_5=${filterDataModel?.rating == 5 ? '1' : '0'}'
        '${(filterDataModel?.freeDelivery ?? false) ? '&filter_by[]=free_delivery' : ''}'
        '${(filterDataModel?.isAvailable ?? false) ? '&filter_by[]=currently_available' : ''}'
        '${(filterDataModel?.isNew ?? false) ? '&filter_by[]=new_arrivals' : ''}'
        '${(filterDataModel?.discounted ?? false)  ? '&filter_by[]=discounted' : ''}'
        '${(filterDataModel?.isPopular ?? false) ? '&filter_by[]=popular' : ''}'
        '&cuisine=${_cuisineQuery(filterDataModel?.selectedCuisines)}'
    );

    String restaurantFilter = (
        '&sort_by=${FilterHelper.getSortTypeFromIndex(filterDataModel?.restaurantSortIndex ?? -1, isRestaurant: true)}'
        '${(filterDataModel?.restDeliveryTypes?.contains(0) ?? false) ?  '&order_type[]=all' : "${(filterDataModel?.restDeliveryTypes?.contains(1) ?? false) ? '&order_type[]=delivery' : ''}${(filterDataModel?.restDeliveryTypes?.contains(2) ?? false) ? '&order_type[]=take_away' : ''}${(filterDataModel?.restDeliveryTypes?.contains(3) ?? false) ? '&order_type[]=dine_in' : ''}"}'
        '${(FilterHelper.foodType(filterDataModel?.restVeg ?? false, filterDataModel?.restNonVeg ?? false) != '') ? '&filter_by[]=${(FilterHelper.foodType(filterDataModel?.restVeg ?? false, filterDataModel?.restNonVeg ?? false))}' : ''}'
        '&rating_1_plus=${filterDataModel?.restRating == 1 ? '1' : '0'}'
        '&rating_2_plus=${filterDataModel?.restRating == 2 ? '1' : '0'}'
        '&rating_3_plus=${filterDataModel?.restRating == 3 ? '1' : '0'}'
        '&rating_4_plus=${filterDataModel?.restRating == 4 ? '1' : '0'}'
        '&rating_5=${filterDataModel?.restRating == 5 ? '1' : '0'}'
        '${(filterDataModel?.restFreeDelivery ?? false) ? '&filter_by[]=free_delivery' : ''}'
        '${(filterDataModel?.restIsAvailable ?? false) ? '&filter_by[]=currently_available' : ''}'
        '${(filterDataModel?.restIsNew ?? false) ? '&filter_by[]=new_arrivals' : ''}'
        '${(filterDataModel?.restDiscounted ?? false)  ? '&filter_by[]=discounted' : ''}'
        '${(filterDataModel?.restIsPopular ?? false) ? '&filter_by[]=popular' : ''}'
        '&cuisine=${_cuisineQuery(filterDataModel?.restSelectedCuisines)}'
    );
      
    return await apiClient.getData(
      '${AppConstants.searchUri}${isRestaurant ? 'restaurants' : 'products'}/search?name=$query&category_id=$categoryID&offset=1&limit=50${isRestaurant ? restaurantFilter : productFilter}',
    );
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}