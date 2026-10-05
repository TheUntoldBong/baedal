import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/domain/services/address_service_interface.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/prediction_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';

class AddressController extends GetxController implements GetxService {
  final AddressServiceInterface addressServiceInterface;
  AddressController({required this.addressServiceInterface});

  List<AddressModel>? _addressList;
  late List<AddressModel> _allAddressList;
  List<AddressModel>? get addressList => _addressList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  final TextEditingController locationSearchController = TextEditingController();

  List<PredictionModel>? _locationSuggestions;
  List<PredictionModel>? get locationSuggestions => _locationSuggestions;

  List<AddressModel>? _recentSearchedAddressList;
  List<AddressModel>? get recentSearchedAddressList => _recentSearchedAddressList;

  Timer? _searchDebounce;

  void updateLocationSuggestions(List<PredictionModel>? suggestions, {bool notify = true}) {
    _locationSuggestions = suggestions;
    if (notify) {
      update();
    }
  }

  void searchLocationSuggestion(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateLocationSuggestions(null));
      return;
    }
    if (_locationSuggestions == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateLocationSuggestions([]));
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final List<PredictionModel> results = await Get.find<LocationController>().searchLocation(query);
      updateLocationSuggestions(results);
    });
  }

  Future<AddressModel> setLocationFromPlace(String? placeId, String? description) async {
    final position = await Get.find<LocationController>().setLocation(placeId ?? '', description, null);
    AddressModel address = AddressModel(
      address: description,
      addressType: 'others',
      latitude: position.latitude.toString(),
      longitude: position.longitude.toString(),
    );
    await addRecentSearchedAddress(address);
    return address;
  }


  List<AddressModel> _readRecentSearchedAddresses() {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    List<AddressModel> list = [];
    try {
      String? data = prefs.getString(AppConstants.recentSearchAddress);
      if (data != null && data.isNotEmpty) {
        jsonDecode(data).forEach((a) => list.add(AddressModel.fromJson(a)));
      }
    } catch (e) {
      list = [];
    }
    return list;
  }

  Future<void> getRecentSearchedAddresses() async {
    _recentSearchedAddressList = _readRecentSearchedAddresses();
    update();
  }

  Future<void> addRecentSearchedAddress(AddressModel address) async {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    List<AddressModel> list = _readRecentSearchedAddresses();
    list.removeWhere((a) => a.address == address.address);
    list.insert(0, address);
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }
    await prefs.setString(AppConstants.recentSearchAddress, jsonEncode(list.map((a) => a.toJson()).toList()));
    _recentSearchedAddressList = list;
    update();
  }

  Future<void> clearRecentSearchedAddresses() async {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    await prefs.remove(AppConstants.recentSearchAddress);
    _recentSearchedAddressList = [];
    update();
  }

  Future<ResponseModel> deleteAddress(int? id, int index) async {
    ResponseModel responseModel = await addressServiceInterface.delete(id!);
    if (responseModel.isSuccess) {
      _addressList!.removeAt(index);
    }
    update();
    return responseModel;
  }

  Future<void> getAddressList({bool canInsertAddress = false, DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _addressList = null;
    List<AddressModel>? addressList;

    if(dataSource == DataSourceEnum.local){
      addressList = await addressServiceInterface.getList(source: DataSourceEnum.local);
      _prepareAddressList(addressList, canInsertAddress: canInsertAddress);
      getAddressList(dataSource: DataSourceEnum.client);
    }else{
      addressList = await addressServiceInterface.getList(source: DataSourceEnum.client);
      _prepareAddressList(addressList, canInsertAddress: canInsertAddress);
    }
  }

  void _prepareAddressList(List<AddressModel>? addressList, {bool canInsertAddress = false}) {
    if (addressList != null) {
      _addressList = [];
      _allAddressList = [];
      _addressList?.addAll(addressList);
      _allAddressList.addAll(addressList);
      if (canInsertAddress && (_addressList != null && _addressList!.isNotEmpty)) {
        try{
          AddressModel? addressModel = _addressList!.firstWhere((address) => address.isDefault!);
          Get.find<CheckoutController>().insertAddresses(addressModel);
        } catch (e){
          Get.find<CheckoutController>().insertAddresses(_addressList!.first);
        }
      }
    }
    update();
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout, int? restaurantZoneId) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await addressServiceInterface.add(addressModel, fromCheckout, restaurantZoneId);
    _isLoading = false;
    update();
    return responseModel;
  }

  void filterAddresses(String queryText) {
    if (_addressList != null) {
      _addressList = addressServiceInterface.filterAddresses(_addressList!, queryText);
      update();
    }
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel, int? addressId) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await addressServiceInterface.update(addressModel.toJson(), addressId!);
    if (responseModel.isSuccess) {
      Get.find<AddressController>().getAddressList();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> markDefault(int id) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await addressServiceInterface.markDefault(id);
    if (responseModel.isSuccess) {
     await getAddressList();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

}
