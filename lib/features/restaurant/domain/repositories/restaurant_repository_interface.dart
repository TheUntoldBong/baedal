import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class RestaurantRepositoryInterface extends RepositoryInterface {
  @override
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode});
  @override
  Future<RestaurantModel?> getList({int? offset, Set<String>? orderTypes, String? sortBy, int? topRated, int? discount, int? veg, int? nonVeg, int? newlyJoined, int? popular, bool fromMap = false, DataSourceEnum? source, FilterDataModel? filterDataModel});
  Future<List<Restaurant>?> getRestaurantList({VegType? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source, FilterDataModel? filterDataModel});
  Future<RestaurantModel?> getRecommendedRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<RestaurantModel?> getTopPickRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<RestaurantModel?> getQuickDeliveryRestaurantList({int offset, int limit, VegType type, String name, DataSourceEnum? source});
  Future<RestaurantModel?> getFreeDeliveryRestaurantList({required int offset, int limit = 25, String name, DataSourceEnum? source});
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId);
  Future<RestaurantBogoOfferListModel?> getRestaurantBogoOffers(int? restaurantId, {int offset = 1, int limit = 10, Restaurant? restaurant});
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID);
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, VegType type);
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? restaurantId, int offset, VegType type);
  Future<RestaurantCategoryFoodsModel?> getRestaurantCategoryFoods(int restaurantId, VegType type);
}