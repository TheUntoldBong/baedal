import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class FavouriteController extends GetxController implements GetxService {
  final FavouriteServiceInterface favouriteServiceInterface;
  FavouriteController({required this.favouriteServiceInterface});

  List<Product?>? _wishProductList;
  List<Product?>? get wishProductList => _wishProductList;

  List<Restaurant?>? _wishRestList;
  List<Restaurant?>? get wishRestList => _wishRestList;

  List<int?> _wishProductIdList = [];
  List<int?> get wishProductIdList => _wishProductIdList;

  List<int?> _wishRestIdList = [];
  List<int?> get wishRestIdList => _wishRestIdList;

  bool _isDisable = false;
  bool get isDisable => _isDisable;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void addToFavouriteList(int? id, bool isRestaurant) async {
    _isDisable = true;
    update();
    Response response = await favouriteServiceInterface.addFavouriteList(id, isRestaurant);
    if (response.statusCode == 200) {
      if(isRestaurant) {
        _wishRestIdList.add(id);
      }else {
        _wishProductIdList.add(id);
      }
      showCustomSnackBar(response.body['message'], isError: false);
    }
    _isDisable = false;
    update();
  }

  void removeFromFavouriteList(int? id, bool isRestaurant) async {
    _isDisable = true;
    update();
    Response response = await favouriteServiceInterface.removeFavouriteList(id, isRestaurant);
    if (response.statusCode == 200) {
      if(isRestaurant) {
        _wishRestIdList.remove(id);
        _wishRestList?.removeWhere((restaurant) => restaurant?.id == id);
      }else {
        _wishProductIdList.remove(id);
        _wishProductList?.removeWhere((product) => product?.id == id);
      }
      showCustomSnackBar(response.body['message'], isError: true);
    }
    _isDisable = false;
    update();
  }

  Future<void> getFavouriteList({bool fromFavScreen = false}) async {
    if(fromFavScreen){
      _wishProductList = null;
      _wishProductIdList = [];
      _wishRestList = null;
      _wishRestIdList = [];
    }else {
      _wishProductList = [];
      _wishProductIdList = [];
      _wishRestList = [];
      _wishRestIdList = [];
    }
    Response response = await favouriteServiceInterface.getFavouriteList();
    if (response.statusCode == 200) {
      if(fromFavScreen){
        _wishProductList = [];
        _wishProductIdList = [];
        _wishRestList = [];
        _wishRestIdList = [];
      }
      update();
      response.body['food'].forEach((food) async {
        Product product = Product.fromJson(food);
        (_wishProductList ?? []).add(product);
        _wishProductIdList.add(product.id);
      });

      response.body['restaurant'].forEach((res) async {
        Restaurant? restaurant;
        try{
          restaurant = Restaurant.fromJson(res);
        }catch(e){
          debugPrint('exception create in restaurant list create : $e');
        }
        (_wishRestList ?? []).add(restaurant);
        _wishRestIdList.add(restaurant!.id);
      });
    }
    update();
  }

  void removeFavourites() {
    _wishProductIdList = [];
    _wishRestIdList = [];
  }

  Future<void> clearAll({required bool isFood}) async {
    _isLoading = true;
    update();

    Response response = await favouriteServiceInterface.clearAll(isFood: isFood);
    if (response.statusCode == 200) {
      _wishProductList = [];
      _wishProductIdList = [];

      _wishRestList = [];
      _wishRestIdList = [];
      getFavouriteList(fromFavScreen: true);
      Get.back();
      showCustomSnackBar(response.body['message'], isError: false);
    }
    _isLoading = false;
    update();
  }
}
