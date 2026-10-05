
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class RestaurantServiceInterface {
  double getRestaurantDistanceFromUser(LatLng restaurantLatLng);
  String filterRestaurantLinkUrl(String slug, int? restaurantId, int? restaurantZoneId);
  Future<RestaurantModel?> getRestaurantList(int offset, Set<String> orderTypes, int topRated, int discount, int veg, int nonVeg, {String? sortBy, int newlyJoined = 0, int popular = 0, bool fromMap = false, DataSourceEnum? source, FilterDataModel? filterDataModel});
  Future<List<Restaurant>?> getOrderAgainRestaurantList({VegType type, DataSourceEnum? source});
  Future<RestaurantModel?> getFreeDeliveryRestaurantList({required int offset, int limit = 25, String name, DataSourceEnum? source});
  Future<List<Restaurant>?> getRecentlyViewedRestaurantList(VegType type, {DataSourceEnum? source});
  Future<RestaurantModel?> getRecommendedRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<RestaurantModel?> getTopPickRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<RestaurantModel?> getQuickDeliveryRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<List<Restaurant>?> getLatestRestaurantList(VegType type, {DataSourceEnum? source});
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId);
  Future<RestaurantBogoOfferListModel?> getRestaurantBogoOffers(int? restaurantId, {int offset = 1, int limit = 10, Restaurant? restaurant});
  List<CategoryModel>? setCategories(List<CategoryModel> categoryList, Restaurant restaurant);
  Future<Restaurant?> getRestaurantDetails(String restaurantID, String slug, String? languageCode);
  AddressModel prepareAddressModel(Position storePosition, ZoneResponseModel responseModel, String addressFromGeocode);
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID);
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, VegType type);
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? restaurantId, int offset, VegType type);
  Future<RestaurantCategoryFoodsModel?> getRestaurantCategoryFoods(int restaurantId, VegType type);
  bool isRestaurantClosed(DateTime dateTime, bool active, List<Schedules>? schedules);
  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules);
}