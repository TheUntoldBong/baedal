import 'dart:async';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/home/domain/models/banner_model.dart';
import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/features/home/domain/models/category_cuisine_model.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service_interface.dart';
import 'package:get/get.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<String?>? _bannerImageList;
  List<dynamic>? _bannerDataList;

  List<String?>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  CategoryCuisineModel? _categoryCuisineModel;
  CategoryCuisineModel? get categoryCuisineModel => _categoryCuisineModel;
  List<CategoryCuisineItem>? get categoryCuisineList => _categoryCuisineModel?.data;

  CategoryCuisineModel? _exploreCategoryCuisineModel;
  CategoryCuisineModel? get exploreCategoryCuisineModel => _exploreCategoryCuisineModel;
  List<CategoryCuisineItem>? get exploreCategoryCuisineList => _exploreCategoryCuisineModel?.data;

  bool _exploreCategoryCuisinePaginate = false;
  bool get exploreCategoryCuisinePaginate => _exploreCategoryCuisinePaginate;

  static const int _exploreCategoryCuisineLimit = 20;

  Future<void> getExploreCategoryCuisineList(bool reload) async {
    if(_exploreCategoryCuisineModel != null && !reload) {
      return;
    }
    _exploreCategoryCuisineModel = null;
    _exploreCategoryCuisineModel = await homeServiceInterface.getCategoryCuisineList(
      source: DataSourceEnum.client, limit: _exploreCategoryCuisineLimit, offset: 1,
    );
    update();
  }

  Future<void> loadMoreExploreCategoryCuisine() async {
    if(_exploreCategoryCuisinePaginate || _exploreCategoryCuisineModel?.data == null) {
      return;
    }
    int limit = _exploreCategoryCuisineModel!.limit ?? _exploreCategoryCuisineLimit;
    int totalPage = ((_exploreCategoryCuisineModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_exploreCategoryCuisineModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _exploreCategoryCuisinePaginate = true;
    update();

    CategoryCuisineModel? nextPage = await homeServiceInterface.getCategoryCuisineList(
      source: DataSourceEnum.client, limit: limit, offset: nextOffset,
    );
    if(nextPage != null) {
      _exploreCategoryCuisineModel!.data!.addAll(nextPage.data ?? []);
      _exploreCategoryCuisineModel!.offset = nextPage.offset;
      _exploreCategoryCuisineModel!.totalSize = nextPage.totalSize;
    }
    _exploreCategoryCuisinePaginate = false;
    update();
  }

  Future<void> getCategoryCuisineList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_categoryCuisineModel == null || reload || fromRecall) {
      if(!fromRecall) {
        _categoryCuisineModel = null;
      }
      if(dataSource == DataSourceEnum.local) {
        _categoryCuisineModel = await homeServiceInterface.getCategoryCuisineList(source: DataSourceEnum.local);
        update();
        getCategoryCuisineList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        _categoryCuisineModel = await homeServiceInterface.getCategoryCuisineList(source: DataSourceEnum.client);
        update();
      }
    }
  }

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(!fromRecall) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local){
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.local);
        _prepareBannerList(bannerModel);
        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBannerList(bannerModel);
      }
    }
  }

  void _prepareBannerList(BannerModel? bannerModel){
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        _bannerImageList!.add(campaign.imageFullUrl);
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_bannerImageList!.contains(banner.imageFullUrl)){
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        }else {
          _bannerImageList!.add(banner.imageFullUrl);
        }
        if(banner.food != null) {
          _bannerDataList!.add(banner.food);
        }else {
          _bannerDataList!.add(banner.restaurant);
        }
      }
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }


  Future<void> getCashBackOfferList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _cashBackOfferList = null;
    List<CashBackModel>? cashBackOfferList;

    if(dataSource == DataSourceEnum.local){
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.local);
      _prepareCashBackOfferList(cashBackOfferList);
      getCashBackOfferList(dataSource: DataSourceEnum.client);
    }else{
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.client);
      _prepareCashBackOfferList(cashBackOfferList);
    }
  }

  void _prepareCashBackOfferList(List<CashBackModel>? cashBackOfferList){
    if(cashBackOfferList != null) {
      _cashBackOfferList = [];
      _cashBackOfferList!.addAll(cashBackOfferList);
    }
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(amount);
    if(cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

  final List<String> _searchHintFoods = ['Burger', 'Pizza', 'Pasta', 'Sandwich', 'Biryani'];
  static const Duration _searchHintTypeSpeed = Duration(milliseconds: 100);
  static const Duration _searchHintEraseSpeed = Duration(milliseconds: 50);
  static const Duration _searchHintHoldDuration = Duration(milliseconds: 1200);
  int _searchHintIndex = 0;
  int _searchHintCharCount = 0;
  _SearchHintPhase _searchHintPhase = _SearchHintPhase.typing;
  Timer? _searchHintTimer;

  int get searchHintIndex => _searchHintIndex;
  String get currentSearchHint => _searchHintFoods[_searchHintIndex].substring(0, _searchHintCharCount);

  void startSearchHintTimer() {
    _searchHintTimer?.cancel();
    _searchHintCharCount = 0;
    _searchHintPhase = _SearchHintPhase.typing;
    _scheduleSearchHintTick();
  }

  void _scheduleSearchHintTick() {
    final Duration delay = switch (_searchHintPhase) {
      _SearchHintPhase.typing => _searchHintTypeSpeed,
      _SearchHintPhase.holding => _searchHintHoldDuration,
      _SearchHintPhase.erasing => _searchHintEraseSpeed,
    };
    _searchHintTimer = Timer(delay, _advanceSearchHint);
  }

  void _advanceSearchHint() {
    final String word = _searchHintFoods[_searchHintIndex];
    switch (_searchHintPhase) {
      case _SearchHintPhase.typing:
        _searchHintCharCount++;
        if (_searchHintCharCount >= word.length) {
          _searchHintPhase = _SearchHintPhase.holding;
        }
        break;
      case _SearchHintPhase.holding:
        _searchHintPhase = _SearchHintPhase.erasing;
        break;
      case _SearchHintPhase.erasing:
        _searchHintCharCount--;
        if (_searchHintCharCount <= 0) {
          _searchHintCharCount = 0;
          _searchHintIndex = (_searchHintIndex + 1) % _searchHintFoods.length;
          _searchHintPhase = _SearchHintPhase.typing;
        }
        break;
    }
    update(['search_hint']);
    _scheduleSearchHintTick();
  }

  void stopSearchHintTimer() {
    _searchHintTimer?.cancel();
    _searchHintTimer = null;
  }

}

enum _SearchHintPhase { typing, holding, erasing }