import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_restaurants_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/services/cuisine_service_interface.dart';
import 'package:get/get.dart';

class CuisineController extends GetxController implements GetxService {
  final CuisineServiceInterface cuisineServiceInterface;
  CuisineController({required this.cuisineServiceInterface});

  FilterDataModel? _filterDataModel;
  FilterDataModel? get getFilterDataModel => _filterDataModel;
  void setFilterDataModel(FilterDataModel filterDataModel){
    _filterDataModel = filterDataModel;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CuisineModel? _cuisineModel;
  CuisineModel? get cuisineModel => _cuisineModel;

  CuisineRestaurantModel? _cuisineRestaurantsModel;
  CuisineRestaurantModel?  get cuisineRestaurantsModel => _cuisineRestaurantsModel;

  List<int>? _selectedCuisines;
  List<int>? get selectedCuisines => _selectedCuisines;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  String _filterType = '';
  String get filterType => _filterType;

  String _searchText = '';
  String get searchText => _searchText;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<String> _historyList = [];
  List<String> get historyList => _historyList;


  CuisineRestaurantModel? _searchCuisineRestaurantsModel;
  CuisineRestaurantModel?  get searchCuisineRestaurantsModel => _searchCuisineRestaurantsModel;

  void setFilterType(String type) {
    if(_filterType == type) {
      _filterType = '';
    } else {
      _filterType = type;
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void initialize(){
    _cuisineRestaurantsModel = null;
    _filterDataModel = FilterDataModel();
  }

  void initSearchData() {
    _searchText = '';
    _filterType = '';
    _historyList = [];
    _historyList.addAll(cuisineServiceInterface.getSearchHistory());
    if(_searchCuisineRestaurantsModel != null) {
      _searchCuisineRestaurantsModel?.restaurants = [];
    }
  }

  Future<void> getCuisineList({DataSourceEnum dataSource = DataSourceEnum.local, String? search}) async {
    _selectedCuisines = [];
    CuisineModel? cuisineModel;
    if(dataSource == DataSourceEnum.local) {
      cuisineModel = await cuisineServiceInterface.getCuisineList(source: DataSourceEnum.local, search: search);
      _prepareCuisineList(cuisineModel);
      getCuisineList(dataSource: DataSourceEnum.client, search: search);
    } else {
      cuisineModel = await cuisineServiceInterface.getCuisineList(source: DataSourceEnum.client, search: search);
      _prepareCuisineList(cuisineModel);
    }
  }

  void _prepareCuisineList(CuisineModel? cuisineModel) {
    if (cuisineModel != null) {
      _cuisineModel = cuisineModel;
      cuisineServiceInterface.generateCuisineIds(_cuisineModel);
    }
    update();
  }

  Future<void> getCuisineRestaurantList(int cuisineId, int offset, bool reload, {String? name}) async {
   _filterDataModel ??= FilterDataModel();
    if(reload) {
      _isLoading = true;
      _cuisineRestaurantsModel = null;
      update();
    }
   _filterDataModel?.offset = offset;
   CuisineRestaurantModel? restaurantModel = await cuisineServiceInterface.getRestaurantList(cuisineId, name: name, filterDataModel: _filterDataModel);
    if (restaurantModel != null) {
      if (offset == 1) {
        _cuisineRestaurantsModel = restaurantModel;
      }else {
        _cuisineRestaurantsModel!.totalSize = restaurantModel.totalSize;
        _cuisineRestaurantsModel!.offset = restaurantModel.offset;
        _cuisineRestaurantsModel!.restaurants!.addAll(restaurantModel.restaurants!);
      }
    }
    _isLoading = false;
    update();
  }

  Future<void> searchCuisineRestaurantList(int cuisineId, int offset, bool reload, {required String name, String? query}) async {
    _filterDataModel ??= FilterDataModel();
    if(name.isEmpty) {
      showCustomSnackBar('write_restaurant_name'.tr);
      return;
    }
    _isLoading = true;
    _isSearching = true;
    _searchText = name;
    _searchCuisineRestaurantsModel = null;
    update();

    _filterDataModel?.offset = offset;
    CuisineRestaurantModel? restaurantModel = await cuisineServiceInterface.getRestaurantList(cuisineId, name: name, filterDataModel: _filterDataModel);
    if (restaurantModel != null) {
      if (offset == 1) {
        _searchCuisineRestaurantsModel = restaurantModel;
      }else {
        _searchCuisineRestaurantsModel!.totalSize = restaurantModel.totalSize;
        _searchCuisineRestaurantsModel!.offset = restaurantModel.offset;
        _searchCuisineRestaurantsModel!.restaurants!.addAll(restaurantModel.restaurants!);
      }
    }
    _isLoading = false;
    update();
  }

  void setSelectedCuisineIndex(int index, bool notify) {
    if(!_selectedCuisines!.contains(index)) {
      _selectedCuisines!.add(index);
      if(notify) {
        update();
      }
    }
  }

  void removeCuisine(int index) {
    _selectedCuisines!.removeAt(index);
    update();
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if(isUpdate) {
      update();
    }
  }

  void saveSearchHistory(String query) {
    if (!_historyList.contains(query)) {
      _historyList.insert(0, query);
    }
    cuisineServiceInterface.saveSearchHistory(_historyList);
  }

  void removeHistory(int index) {
    _historyList.removeAt(index);
    cuisineServiceInterface.saveSearchHistory(_historyList);
    update();
  }

  void clearSearchAddress() async {
    cuisineServiceInterface.clearSearchHistory();
    _historyList = [];
    update();
  }

}