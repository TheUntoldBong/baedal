import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/offer/domain/repositories/offer_repository_interface.dart';
import 'package:stackfood_multivendor/features/offer/domain/services/offer_service_interface.dart';

class OfferService implements OfferServiceInterface {
  final OfferRepositoryInterface offerRepositoryInterface;
  OfferService({required this.offerRepositoryInterface});

  @override
  Future<ProductModel?> getOfferItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getOfferItems(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      offset: offset, limit: limit,
    );
  }

  @override
  Future<RestaurantModel?> getOfferRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int itemLimit = 5, int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getOfferRestaurants(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      itemLimit: itemLimit, offset: offset, limit: limit,
    );
  }

  @override
  Future<ProductModel?> getTopRatedItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getTopRatedItems(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      offset: offset, limit: limit,
    );
  }

  @override
  Future<RestaurantModel?> getTopRatedRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getTopRatedRestaurants(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      offset: offset, limit: limit,
    );
  }

  @override
  Future<ProductModel?> getFreeDeliveryItems({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getFreeDeliveryItems(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      offset: offset, limit: limit,
    );
  }

  @override
  Future<RestaurantModel?> getFreeDeliveryRestaurants({
    String? search, double? minPrice, double? maxPrice, bool halal = false,
    String? type, int? rating, Set<int>? categoryIds, Set<int>? cuisineIds,
    int offset = 1, int limit = 20,
  }) async {
    return await offerRepositoryInterface.getFreeDeliveryRestaurants(
      search: search, minPrice: minPrice, maxPrice: maxPrice, halal: halal,
      type: type, rating: rating, categoryIds: categoryIds, cuisineIds: cuisineIds,
      offset: offset, limit: limit,
    );
  }
}
