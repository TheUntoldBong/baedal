import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/offer/domain/services/offer_service_interface.dart';
import 'package:get/get.dart';

class OfferController extends GetxController implements GetxService {
  final OfferServiceInterface offerServiceInterface;
  OfferController({required this.offerServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isTopRated = false;
  bool _isFreeDelivery = false;

  ProductModel? _foodModel;
  List<Product>? get foodList => _foodModel?.products;

  RestaurantModel? _restaurantModel;
  List<Restaurant>? get restaurantList => _restaurantModel?.restaurants;

  int get foodTotalSize => _foodModel?.totalSize ?? 0;
  int get restaurantTotalSize => _restaurantModel?.totalSize ?? 0;

  bool _foodPaginate = false;
  bool get foodPaginate => _foodPaginate;

  bool _restaurantPaginate = false;
  bool get restaurantPaginate => _restaurantPaginate;

  String _searchText = '';
  String get searchText => _searchText;

  double _minPrice = 0;
  double get minPrice => _minPrice;

  double _maxPrice = 1000;
  double get maxPrice => _maxPrice;

  bool _halal = false;
  bool get halal => _halal;

  bool _veg = false;
  bool get veg => _veg;

  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  int? _rating;
  int? get rating => _rating;

  final Set<int> _categoryIds = {};
  Set<int> get categoryIds => _categoryIds;

  final Set<int> _cuisineIds = {};
  Set<int> get cuisineIds => _cuisineIds;

  String get _type => (_veg && !_nonVeg) ? 'veg' : (_nonVeg && !_veg) ? 'non_veg' : '';

  void setSearchText(String text) {
    _searchText = text;
    getOffers(isTopRated: _isTopRated, isFreeDelivery: _isFreeDelivery);
  }

  void applyFilters({
    required double minPrice, required double maxPrice, required bool halal,
    required bool veg, required bool nonVeg, int? rating,
    required Set<int> categoryIds, required Set<int> cuisineIds,
  }) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _halal = halal;
    _veg = veg;
    _nonVeg = nonVeg;
    _rating = rating;
    _categoryIds..clear()..addAll(categoryIds);
    _cuisineIds..clear()..addAll(cuisineIds);
    getOffers(isTopRated: _isTopRated, isFreeDelivery: _isFreeDelivery);
  }

  void clearFilters({bool includeSearch = false}) {
    _minPrice = 0;
    _maxPrice = 1000;
    _halal = false;
    _veg = false;
    _nonVeg = false;
    _rating = null;
    _categoryIds.clear();
    _cuisineIds.clear();
    if(includeSearch) {
      _searchText = '';
    }
  }

  void resetFilters() {
    clearFilters();
    getOffers(isTopRated: _isTopRated, isFreeDelivery: _isFreeDelivery);
  }

  Future<ProductModel?> _fetchItems({int offset = 1, int limit = 20}) {
    if(_isTopRated) {
      return offerServiceInterface.getTopRatedItems(
        search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
        type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
        offset: offset, limit: limit,
      );
    }
    if(_isFreeDelivery) {
      return offerServiceInterface.getFreeDeliveryItems(
        search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
        type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
        offset: offset, limit: limit,
      );
    }
    return offerServiceInterface.getOfferItems(
      search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
      type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
      offset: offset, limit: limit,
    );
  }

  Future<RestaurantModel?> _fetchRestaurants({int offset = 1, int limit = 20}) {
    if(_isTopRated) {
      return offerServiceInterface.getTopRatedRestaurants(
        search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
        type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
        offset: offset, limit: limit,
      );
    }
    if(_isFreeDelivery) {
      return offerServiceInterface.getFreeDeliveryRestaurants(
        search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
        type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
        offset: offset, limit: limit,
      );
    }
    return offerServiceInterface.getOfferRestaurants(
      search: _searchText, minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal,
      type: _type, rating: _rating, categoryIds: _categoryIds, cuisineIds: _cuisineIds,
      offset: offset, limit: limit,
    );
  }

  Future<void> getOffers({bool isTopRated = false, bool isFreeDelivery = false}) async {
    _isTopRated = isTopRated;
    _isFreeDelivery = isFreeDelivery;
    _isLoading = true;
    update();

    List<dynamic> results = await Future.wait([
      _fetchItems(),
      _fetchRestaurants(),
    ]);

    _foodModel = (results[0] as ProductModel?) ?? ProductModel(totalSize: 0, products: []);
    _restaurantModel = (results[1] as RestaurantModel?) ?? RestaurantModel(totalSize: 0, restaurants: []);

    _isLoading = false;
    update();
  }

  Future<void> loadMoreFoodItems() async {
    if(_foodPaginate || _foodModel?.products == null) {
      return;
    }
    int limit = int.tryParse(_foodModel!.limit ?? '20') ?? 20;
    int totalPage = ((_foodModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_foodModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _foodPaginate = true;
    update();

    ProductModel? nextPage = await _fetchItems(offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _foodModel!.products!.addAll(nextPage.products ?? []);
      _foodModel!.offset = nextPage.offset;
      _foodModel!.totalSize = nextPage.totalSize;
    }
    _foodPaginate = false;
    update();
  }

  Future<void> loadMoreRestaurants() async {
    if(_restaurantPaginate || _restaurantModel?.restaurants == null) {
      return;
    }
    int limit = int.tryParse(_restaurantModel!.limit ?? '20') ?? 20;
    int totalPage = ((_restaurantModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_restaurantModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _restaurantPaginate = true;
    update();

    RestaurantModel? nextPage = await _fetchRestaurants(offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _restaurantModel!.restaurants!.addAll(nextPage.restaurants ?? []);
      _restaurantModel!.offset = nextPage.offset;
      _restaurantModel!.totalSize = nextPage.totalSize;
    }
    _restaurantPaginate = false;
    update();
  }
}
