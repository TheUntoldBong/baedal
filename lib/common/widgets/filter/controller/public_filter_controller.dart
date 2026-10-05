import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';
import 'package:get/get.dart';

class PublicFilterController extends GetxController implements GetxService {


  List<Product>? _searchProductList;
  List<Product>? get searchProductList => _searchProductList;

  List<Product>? _suggestedFoodList;
  List<Product>? get suggestedFoodList => _suggestedFoodList;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<Restaurant>? _searchRestList;
  List<Restaurant>? get searchRestList => _searchRestList;

  String _searchText = '';
  String get searchText => _searchText;

  double _lowerValue = 0;
  double get lowerValue => _lowerValue;

  double _upperValue = 0;
  double get upperValue => _upperValue;

  double _lowerLimit = 0;
  double get lowerLimit => _lowerLimit;

  double _upperLimit = 0;
  double get upperLimit => _upperLimit;

  final List<String> _historyList = [];
  List<String> get historyList => _historyList;

  final bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;

  final List<String> _orderTypeList = ['all'.tr, 'home_delivery'.tr, 'take_away'.tr, 'dine_in'.tr];
  List<String> get getOrderTypeList => _orderTypeList;

  final List<String> _sortList = ['default'.tr, 'ascending'.tr, 'descending'.tr, 'low_to_high'.tr, 'high_to_low'.tr];
  List<String> get sortList => _sortList;

  final List<String> _restaurantSortList = ['default'.tr, 'ascending'.tr, 'descending'.tr, "distance".tr, "fast_delivery".tr];
  List<String> get restaurantSortList => _restaurantSortList;

  int _sortIndex = 0;
  int get sortIndex => _sortIndex;

  int _restaurantSortIndex = 0;
  int get restaurantSortIndex => _restaurantSortIndex;

  int _rating = -1;
  int get rating => _rating;

  int _restaurantRating = -1;
  int get restaurantRating => _restaurantRating;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  bool _isAvailableFoods = false;
  bool get isAvailableFoods => _isAvailableFoods;


  bool _isNewArrivalsFoods = false;
  bool get isNewArrivalsFoods => _isNewArrivalsFoods;

  bool _freeDeliveryProduct = false;
  bool get isFreeDelivery => _freeDeliveryProduct;

  bool _freeDeliveryRestaurant = false;
  bool get isFreeDeliveryRestaurant => _freeDeliveryRestaurant;

  bool _isNewArrivalsRestaurant = false;
  bool get isNewArrivalsRestaurant => _isNewArrivalsRestaurant;

  bool _isPopularFood = false;
  bool get isPopularFood => _isPopularFood;

  bool _isPopularRestaurant = false;
  bool get isPopularRestaurant => _isPopularRestaurant;

  bool _isDiscountedFoods = false;
  bool get isDiscountedFoods => _isDiscountedFoods;

  bool _isDiscountedRestaurant = false;
  bool get isDiscountedRestaurant => _isDiscountedRestaurant;

  bool _productVeg = false;
  bool get productVeg => _productVeg;

  bool _restaurantVeg = false;
  bool get restaurantVeg => _restaurantVeg;

  bool _productNonVeg = false;
  bool get productNonVeg => _productNonVeg;

  bool _restaurantNonVeg = false;
  bool get restaurantNonVeg => _restaurantNonVeg;

  int? totalSize;
  int? pageOffset;
  final bool _paginate = false;
  bool get paginate => _paginate;

  List<int> _selectedCuisinesProduct = [];
  List<int> get selectedCuisinesProduct =>  _selectedCuisinesProduct;

  List<int> _selectedCuisinesRestaurant = [];
  List<int> get selectedCuisinesRestaurant => _selectedCuisinesRestaurant;

  List<int> _selectedOrderTypeRest = [];
  List<int> get getSelectedOrderTypeRest => _selectedOrderTypeRest;

  List<int> _selectedOrderType = [];
  List<int> get getSelectedOrderType => _selectedOrderType;

  bool _isOpenRestaurant = false;
  bool get isOpenRestaurant => _isOpenRestaurant;


  void selectCuisineProduct(int cuisineId) {
    if(_selectedCuisinesProduct.contains(cuisineId)) {
      _selectedCuisinesProduct.removeAt(_selectedCuisinesProduct.indexOf(cuisineId));
    } else {
      _selectedCuisinesProduct.add(cuisineId);
    }
    update();
  }

  void selectCuisineRestaurant(int cuisineId) {
    if(_selectedCuisinesRestaurant.contains(cuisineId)) {
      _selectedCuisinesRestaurant.removeAt(_selectedCuisinesRestaurant.indexOf(cuisineId));
    } else {
      _selectedCuisinesRestaurant.add(cuisineId);
    }
    update();
  }

  void setSelectedOrderTypeRest(int index) {
    if (index == 0) {
      if (_selectedOrderTypeRest.contains(0)) {
        _selectedOrderTypeRest.clear();
      } else {
        _selectedOrderTypeRest.clear();
        _selectedOrderTypeRest.addAll([0, 1, 2, 3]);
      }
    } else {
      _selectedOrderTypeRest.remove(0);
      if (_selectedOrderTypeRest.contains(index)) {
        _selectedOrderTypeRest.remove(index);
      } else {
        _selectedOrderTypeRest.add(index);
      }
    }
    update();
  }

  void setSelectedOrderType(int index) {
    if (index == 0) {
      if (_selectedOrderType.contains(0)) {
        _selectedOrderType.clear();
      } else {
        _selectedOrderType.clear();
        _selectedOrderType.addAll([0, 1, 2, 3]);
      }
    } else {
      _selectedOrderType.remove(0);
      if (_selectedOrderType.contains(index)) {
        _selectedOrderType.remove(index);
      } else {
        _selectedOrderType.add(index);
      }
    }
    update();
  }

  void toggleVeg() {
    _productVeg = !_productVeg;
    if(_productVeg) {
      _productNonVeg = false;
    }
    update();
  }

  void toggleResVeg() {
    _restaurantVeg = !_restaurantVeg;
    if(_restaurantVeg) {
      _restaurantNonVeg = false;
    }
    update();
  }

  void toggleNonVeg() {
    _productNonVeg = !_productNonVeg;
    if(_productNonVeg) {
      _productVeg = false;
    }
    update();
  }

  void toggleResNonVeg() {
    _restaurantNonVeg = !_restaurantNonVeg;
    if(_restaurantNonVeg) {
      _restaurantVeg = false;
    }
    update();
  }

  void toggleAvailableFoods() {
    _isAvailableFoods = !_isAvailableFoods;
    update();
  }

  void toggleNewArrivalFoods() {
    _isNewArrivalsFoods = !_isNewArrivalsFoods;
    update();
  }

  void toggleFreeDeliveryProduct() {
    _freeDeliveryProduct = !_freeDeliveryProduct;
    update();
  }

  void toggleFreeDeliveryRestaurant() {
    _freeDeliveryRestaurant = !_freeDeliveryRestaurant;
    update();
  }

  void toggleNewArrivalRestaurant() {
    _isNewArrivalsRestaurant = !_isNewArrivalsRestaurant;
    update();
  }

  void togglePopularFoods() {
    _isPopularFood = !_isPopularFood;
    update();
  }

  void togglePopularRestaurant() {
    _isPopularRestaurant = !_isPopularRestaurant;
    update();
  }

  void toggleOpenRestaurant() {
    _isOpenRestaurant = !_isOpenRestaurant;
    update();
  }

  void toggleDiscountedFoods() {
    _isDiscountedFoods = !_isDiscountedFoods;
    update();
  }

  void toggleDiscountedRestaurant() {
    _isDiscountedRestaurant = !_isDiscountedRestaurant;
    update();
  }

  void setRestaurant(bool isRestaurant, {bool willUpdate = true}) {
    _isRestaurant = isRestaurant;
    if(willUpdate) {
      update();
    }
  }

  void setSearchMode({bool canUpdate = true, FilterDataModel? filterDataModel} ) {

    _isRestaurant= filterDataModel?.isRestaurant ?? false;
    _restaurantSortIndex = filterDataModel?.restaurantSortIndex ?? 0;
    _sortIndex =filterDataModel?.sortIndex ?? 0;
    _lowerValue = filterDataModel?.minPrice ?? 0;
    _upperValue = filterDataModel?.maxPrice ?? 0;
    _lowerLimit = filterDataModel?.minLimit ?? 0;
    _upperLimit = filterDataModel?.maxLimit ?? 99999;
    _selectedOrderTypeRest = filterDataModel?.restDeliveryTypes ??[];
    _selectedOrderType = filterDataModel?.deliveryTypes ?? [];
    _restaurantVeg = filterDataModel?.restVeg ?? false;
    _productVeg = filterDataModel?.veg ?? false;
    _restaurantNonVeg = filterDataModel?.restNonVeg ?? false;
    _productNonVeg= filterDataModel?.nonVeg ?? false;
    _restaurantRating = filterDataModel?.restRating ?? -1;
    _rating = filterDataModel?.rating ?? -1;
    _freeDeliveryRestaurant= filterDataModel?.restFreeDelivery ?? false;
    _freeDeliveryProduct = filterDataModel?.freeDelivery ?? false;
    _isOpenRestaurant = filterDataModel?.restIsAvailable ?? false;
    _isAvailableFoods = filterDataModel?.isAvailable ?? false;
    _isNewArrivalsRestaurant = filterDataModel?.restIsNew ?? false;
    _isNewArrivalsFoods = filterDataModel?.isNew ?? false;
    _isDiscountedRestaurant = filterDataModel?.restDiscounted ?? false;
    _isDiscountedFoods = filterDataModel?.discounted ?? false;
    _isPopularRestaurant = filterDataModel?.restIsPopular ?? false;
    _isPopularFood = filterDataModel?.isPopular ?? false;
    _selectedCuisinesRestaurant = filterDataModel?.restSelectedCuisines ?? [];
    _selectedCuisinesProduct = filterDataModel?.selectedCuisines ?? [];

    if(canUpdate) {
      update();
    }
  }


  FilterDataModel getFilterDataModel(){
    return FilterDataModel(
      name : null,
      offset : null,
      limit : null,
      isRestaurant: _isRestaurant,
      restaurantSortIndex : _restaurantSortIndex,
      sortIndex : _sortIndex,
      minPrice : _lowerValue,
      maxPrice : _upperValue,
      minLimit : _lowerLimit,
      maxLimit : _upperLimit,
      restDeliveryTypes: _selectedOrderTypeRest,
      deliveryTypes : _selectedOrderType,
      restVeg: _restaurantVeg,
      veg : _productVeg,
      restNonVeg: _restaurantNonVeg,
      nonVeg: _productNonVeg,
      restRating : _restaurantRating,
      rating : _rating,
      restFreeDelivery: _freeDeliveryRestaurant,
      freeDelivery : _freeDeliveryProduct,
      restIsAvailable : _isOpenRestaurant,
      isAvailable : _isAvailableFoods,
      restIsNew : _isNewArrivalsRestaurant,
      isNew : _isNewArrivalsFoods,
      restDiscounted : _isDiscountedRestaurant,
      discounted : _isDiscountedFoods,
      restIsPopular : _isPopularRestaurant,
      isPopular : _isPopularFood,
      restSelectedCuisines : _selectedCuisinesRestaurant,
      selectedCuisines : _selectedCuisinesProduct,
    );
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void setLowerAndUpperLimit(double lower, double upper) {
    _lowerLimit = lower;
    _upperLimit = upper;
    update();
  }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setRestaurantRating(int rate) {
    _restaurantRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  void setRestSortIndex(int index) {
    _restaurantSortIndex = index;
    update();
  }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _lowerLimit = 0;
    _upperLimit = 999999;
    _isAvailableFoods = false;
    _isDiscountedFoods = false;
    _selectedOrderTypeRest.clear();
    _productVeg = false;
    _productNonVeg = false;
    _sortIndex = 0;
    _isNewArrivalsFoods = false;
    _freeDeliveryProduct = false;
    _isPopularFood = false;
    _isPopularRestaurant = false;
    _selectedCuisinesProduct.clear();
    update();
  }

  void resetRestaurantFilter() {
    _restaurantRating = -1;
    _isOpenRestaurant = false;
    _isDiscountedRestaurant = false;
    _selectedOrderType.clear();
    _restaurantVeg = false;
    _restaurantNonVeg = false;
    _restaurantSortIndex = 0;
    _isNewArrivalsRestaurant = false;
    _freeDeliveryRestaurant = false;
    _isPopularRestaurant = false;
    _selectedCuisinesRestaurant.clear();
    update();
  }
}