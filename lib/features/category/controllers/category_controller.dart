import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface}){
    _filterDataModel = FilterDataModel(isRestaurant: true);
  }

  FilterDataModel? _filterDataModel;
  FilterDataModel? get getFilterDataModel => _filterDataModel;
  void setFilterDataModel(FilterDataModel filterDataModel){
    _filterDataModel = filterDataModel;
  }

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Product>? _categoryProductList;
  List<Product>? get categoryProductList => _categoryProductList;

  List<Restaurant>? _categoryRestaurantList;
  List<Restaurant>? get categoryRestaurantList => _categoryRestaurantList;

  List<Product>? _searchProductList;
  List<Product>? get searchProductList => _searchProductList;

  List<Restaurant>? _searchRestaurantList;
  List<Restaurant>? get searchRestaurantList => _searchRestaurantList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restaurantPageSize;
  int? get restaurantPageSize => _restaurantPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;


  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  String _searchText = '';
  String get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  void setOffset(int value){
    _offset = value;
  }

  Future<void> getCategoryList(bool reload, {String? search, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_categoryList == null || reload || fromRecall) {
      if(!fromRecall) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if(dataSource == DataSourceEnum.local) {
        categoryList = await categoryServiceInterface.getCategoryList(source: DataSourceEnum.local, search: search);
        _prepareCategoryList(categoryList);
        getCategoryList(false, dataSource: DataSourceEnum.client, fromRecall: true, search: search);
      }else {
        categoryList = await categoryServiceInterface.getCategoryList(source: DataSourceEnum.client, search: search);
        _prepareCategoryList(categoryList);
      }
    }
  }

  void _prepareCategoryList(List<CategoryModel>? categoryList) {
    if(categoryList != null) {
      _categoryList = [];
      _categoryList!.addAll(categoryList);
    }
    update();
  }

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _filterDataModel = FilterDataModel();
    _subCategoryList = null;
    _categoryProductList = null;
    _categoryRestaurantList = null;
    _isRestaurant = false;
    _subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    update();
    getCategoryProductList(categoryID, 1, false);
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if(_isRestaurant) {
      getCategoryRestaurantList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, true);
    }else {
      getCategoryProductList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, true);
    }
  }

  void getCategoryProductList(String? categoryID, int offset,  bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(notify) {
        update();
      }
      _categoryProductList = null;
    }

    _filterDataModel ??= FilterDataModel();
    _filterDataModel?.offset = offset;
    ProductModel? productModel = await categoryServiceInterface.getCategoryProductList(categoryID, _filterDataModel);
    if(productModel != null) {
      if (offset == 1) {
        _categoryProductList = [];
      }
      _categoryProductList!.addAll(productModel.products!);
      _pageSize = productModel.totalSize;
      _filterDataModel ??= FilterDataModel();
      _filterDataModel?.minLimit = productModel.minPrice;
      _filterDataModel?.maxLimit = productModel.maxPrice;
      _isLoading = false;
    }
    update();
  }

  void getCategoryRestaurantList(String? categoryID, int offset,  bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(notify) {
        update();
      }
      _categoryRestaurantList = null;
    }

    _filterDataModel ??= FilterDataModel();
    _filterDataModel?.offset = offset;
    RestaurantModel? restaurantModel = await categoryServiceInterface.getCategoryRestaurantList(categoryID, _filterDataModel);
    if(restaurantModel != null) {
      if (offset == 1) {
        _categoryRestaurantList = [];
      }
      _categoryRestaurantList!.addAll(restaurantModel.restaurants!);
      _restaurantPageSize = restaurantModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID) async {
    if((_isRestaurant && query!.isNotEmpty) || (!_isRestaurant && query!.isNotEmpty)) {
      _searchText = query;
      if (_isRestaurant) {
        _searchRestaurantList = null;
      } else {
        _searchProductList = null;
      }
      _isSearching = true;
      update();

      _filterDataModel ??= FilterDataModel();
      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isRestaurant,  _filterDataModel);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestaurantList = [];
          } else {
            _searchProductList = [];
          }
        } else {
          if (_isRestaurant) {
            _searchRestaurantList = [];
            _searchRestaurantList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
          } else {
            _searchProductList = [];
            ProductModel productModel = ProductModel.fromJson(response.body);
            _searchProductList!.addAll(productModel.products!);
            _filterDataModel ??= FilterDataModel();
            _filterDataModel?.minLimit = productModel.minPrice;
            _filterDataModel?.maxLimit = productModel.maxPrice;
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _searchText = '';
    _isSearching = !_isSearching;
    _searchProductList = null;
    _searchRestaurantList = null;
    if(_isSearching) {
      _searchProductList ??= [];
      _searchRestaurantList ??= [];
      _searchProductList!.addAll(_categoryProductList ?? []);
      _searchRestaurantList!.addAll(_categoryRestaurantList ?? []);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isRestaurant = isRestaurant;
    update();
  }

  void getCategoryProductListSilently(String? categoryID,) async {
    _isRestaurant = false;
    update();
    _filterDataModel?.offset = 1;
    ProductModel? productModel = await categoryServiceInterface.getCategoryProductList(categoryID, _filterDataModel);
    if (productModel != null) {
      _categoryProductList = [];
      _categoryProductList!.addAll(productModel.products!);
      _pageSize = productModel.totalSize;
      _offset = 1;
      _isLoading = false;
      _filterDataModel ??= FilterDataModel();
      _filterDataModel?.minLimit = productModel.minPrice;
      _filterDataModel?.maxLimit = productModel.maxPrice;
    }
    update();
  }

  void getCategoryRestaurantListSilently(String? categoryID) async {
    _isRestaurant = true;
    update();
    _filterDataModel?.offset = 1;
    RestaurantModel? restaurantModel = await categoryServiceInterface.getCategoryRestaurantList(categoryID, _filterDataModel);
    if (restaurantModel != null) {
      _categoryRestaurantList = [];
      _categoryRestaurantList!.addAll(restaurantModel.restaurants!);
      _restaurantPageSize = restaurantModel.totalSize;
      _offset = 1;
      _isLoading = false;
    }
    update();
  }

  void clearSearch({bool isUpdate = true}) {
    getCategoryList(isUpdate, search: '');
    if(isUpdate) {
      update();
    }
  }

}
