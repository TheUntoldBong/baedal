import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_restaurants_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/repositories/cuisine_repository_interface.dart';
import 'package:stackfood_multivendor/helper/filter_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class CuisineRepository implements CuisineRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CuisineRepository({required this.apiClient, required this.sharedPreferences});

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
  Future<CuisineModel?> getList({int? offset, DataSourceEnum? source, String? search}) async {
    CuisineModel? cuisineModel;
    String cacheId = AppConstants.cuisineUri;

    switch(source!){
      case DataSourceEnum.client:
        String uri = AppConstants.cuisineUri;
        if (search != null && search.isNotEmpty) {
          uri += '?name=$search';
        }

        Response response = await apiClient.getData(uri);
        if(response.statusCode == 200){
          cuisineModel = CuisineModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          cuisineModel = CuisineModel.fromJson(jsonDecode(cacheResponseData));
        }
    }

    return cuisineModel;
  }

  @override
  Future<CuisineRestaurantModel?> getRestaurantList(int cuisineId, {String? name, FilterDataModel? filterDataModel}) async {
    CuisineRestaurantModel? cuisineRestaurantsModel;
    StringBuffer mainUrl = StringBuffer();

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
    );

    mainUrl.write('${AppConstants.cuisineRestaurantUri}?cuisine=$cuisineId&offset=${filterDataModel?.offset ?? 1}&limit=${(name == null || name.isEmpty) ? 10 : 30}');

     if (name != null && name.isNotEmpty) mainUrl.write('&name=$name');
     if (filterDataModel != null) mainUrl.write(restaurantFilter);

     Response response = await apiClient.getData(mainUrl.toString());

    if(response.statusCode == 200) {
      cuisineRestaurantsModel = CuisineRestaurantModel.fromJson(response.body);
    }
    return cuisineRestaurantsModel;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.searchCuisineHistory, searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.searchCuisineHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.searchCuisineHistory, []);
  }

}