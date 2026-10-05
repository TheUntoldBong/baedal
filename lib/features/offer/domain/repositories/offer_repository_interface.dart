import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class OfferRepositoryInterface extends RepositoryInterface {
  Future<ProductModel?> getOfferItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  });
  Future<RestaurantModel?> getOfferRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int itemLimit = 5, int offset = 1, int limit = 20,
  });
  Future<ProductModel?> getTopRatedItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  });
  Future<RestaurantModel?> getTopRatedRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  });
  Future<ProductModel?> getFreeDeliveryItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  });
  Future<RestaurantModel?> getFreeDeliveryRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  });
}
