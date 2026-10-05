import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class DeliverymanRegistrationController extends GetxController implements GetxService {
  final DeliverymanRegistrationServiceInterface deliverymanRegistrationServiceInterface;

  DeliverymanRegistrationController({required this.deliverymanRegistrationServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  String? _selectedIdentityType;
  String? get selectedIdentityType => _selectedIdentityType;

  List<VehicleModel>? _vehicles;
  List<VehicleModel>? get vehicles => _vehicles;

  List<ShiftModel>? _shifts;
  List<ShiftModel>? get shifts => _shifts;

  List<ShiftModel> _selectedShifts = [];
  List<ShiftModel> get selectedShifts => _selectedShifts;

  List<int?>? _vehicleIds;
  List<int?>? get vehicleIds => _vehicleIds;

  final List<String> _dmTypeList = ['freelancer', 'salary_based'];
  List<String> get dmTypeList => _dmTypeList;

  String? _selectedDmType;
  String? get selectedDmType => _selectedDmType;

  String? _selectedDmTypeId;
  String? get selectedDmTypeId => _selectedDmTypeId;

  List<int>? _zoneIds;
  List<int>? get zoneIds => _zoneIds;

  List<ZoneModel>? _zoneList;
  List<ZoneModel>? get zoneList => _zoneList;

  List<DataModel>? _dataList;
  List<DataModel>? get dataList => _dataList;

  List<dynamic>? _additionalList;
  List<dynamic>? get additionalList => _additionalList;

  LatLng? _restaurantLocation;
  LatLng? get restaurantLocation => _restaurantLocation;

  String? _restaurantAddress;
  String? get restaurantAddress => _restaurantAddress;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  String? _countryDialCode;
  String? get countryDialCode => _countryDialCode;

  String? _selectedDeliveryZoneId;
  String? get selectedDeliveryZoneId => _selectedDeliveryZoneId;

  String? _selectedVehicleId;
  String? get selectedVehicleId => _selectedVehicleId;

  void setSelectedDmType(String? dmType) {
    _selectedDmType = dmType;
    _selectedDmTypeId = _selectedDmType == 'freelancer' ? '1' : '0';
    update();
  }

  void setSelectedDeliveryZone({String? zoneId}) {
    _selectedDeliveryZoneId = zoneId;
    update();
  }

  void setSelectedVehicleType({String? vehicleId}) {
    _selectedVehicleId = vehicleId;
    update();
  }

  void setSelectedIdentityType(String? identityType) {
    _selectedIdentityType = identityType;
    update();
  }

  void setCountryDialCode(String? countryDialCode, {bool notify = true}) {
    _countryDialCode = countryDialCode;
    if(notify) {
      update();
    }
  }

  void setSelectedTabIndex(int index, {bool notify = true}) {
    _selectedTabIndex = index;
    if(notify) {
      update();
    }
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void showHidePassView({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  void pickDmImage(bool isImage, bool isRemove) async {
    if(isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    }else {
      if (isImage) {
        _pickedImage = await deliverymanRegistrationServiceInterface.picImageFromGallery();
      } else {
        XFile? xFile = await deliverymanRegistrationServiceInterface.picImageFromGallery();
        if(xFile != null) {
          _pickedIdentities.add(xFile);
        }
      }
      update();
    }
  }

  Future<void> getShiftList() async {
    _isLoading = true;
    update();
    List<ShiftModel>? shifts = await deliverymanRegistrationServiceInterface.getShiftList();
    if (shifts != null) {
      _shifts = shifts;
    }
    _isLoading = false;
    update();
  }

  void toggleShift(ShiftModel shift) {
    if (_selectedDmTypeId == 'salary_based') {return;}
    if (_selectedShifts.any((deliveryManShift) => deliveryManShift.id == shift.id)) {
      _selectedShifts.removeWhere((deliveryManShift) => deliveryManShift.id == shift.id);
    } else {
      _selectedShifts.add(shift);
    }
    update();
  }

  void removeShift(ShiftModel shift) {
    _selectedShifts.removeWhere((deliveryManShift) => deliveryManShift.id == shift.id);
    update();
  }

  bool isShiftSelected(ShiftModel shift) {
    return _selectedShifts.any((deliveryManShift) => deliveryManShift.id == shift.id);
  }

  void clearSelectedShifts() {
    _selectedShifts.clear();
    update();
  }

  void setDeliverymanType(String? typeId) {
    _selectedDmTypeId = typeId;
    if (typeId == 'salary_based' && _shifts != null) {
      ShiftModel? fullDayShift = _shifts!.firstWhereOrNull((shift) => shift.isFullDay == 1);
      if (fullDayShift != null) {
        _selectedShifts = [fullDayShift];
      }
    } else {
      _selectedShifts.clear();
    }
    update();
  }

  List<int> getSelectedShiftIds() {
    return _selectedShifts.map((shift) => shift.id!).toList();
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  Future<void> getVehicleList() async {
    _vehicles = await deliverymanRegistrationServiceInterface.getVehicleList();
    _vehicleIds = deliverymanRegistrationServiceInterface.setVehicleIdList(_vehicles);
    update();
  }

  Future<List<ZoneModel>?> getZoneList({bool forDeliveryRegistration = false}) async {
    _restaurantLocation = null;
    _zoneIds = null;
    _zoneList = await deliverymanRegistrationServiceInterface.getZoneList(forDeliveryRegistration);
    if (_zoneList != null && forDeliveryRegistration) {
      setLocation(LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ));
    }
    update();
    return _zoneList;
  }

  void setLocation(LatLng location) async {
    ZoneResponseModel response = await Get.find<LocationController>().getZone(
      location.latitude.toString(), location.longitude.toString(), false,
    );
    _restaurantAddress = await Get.find<LocationController>().getAddressFromGeocode(LatLng(location.latitude, location.longitude));
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
    }else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    update();
  }

  void setDeliverymanAdditionalJoinUsPageData({bool isUpdate = true}){
    _dataList = [];
    _additionalList = [];
    if(Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData != null) {
      for (var data in Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData!.data!) {
        int index = Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData!.data!.indexOf(data);
        _dataList!.add(data);
        if(data.fieldType == CustomInputFieldType.text || data.fieldType == CustomInputFieldType.number || data.fieldType == CustomInputFieldType.email || data.fieldType == CustomInputFieldType.phone){
          _additionalList!.add(TextEditingController());
        } else if(data.fieldType == CustomInputFieldType.date) {
          _additionalList!.add(null);
        } else if(data.fieldType == CustomInputFieldType.checkBox) {
          _additionalList!.add([]);
          if(data.checkData != null) {
            for (var element in data.checkData!) {
              debugPrint(element);
              _additionalList![index].add(0);
            }
          }
        } else if(data.fieldType == CustomInputFieldType.file) {
          _additionalList!.add([]);
        }
      }
    }

    if(isUpdate) {
      update();
    }
  }

  void removeAdditionalFile(int index, int subIndex) {
    _additionalList![index].removeAt(subIndex);
    update();
  }

  void removeDmImage(){
    _pickedImage = null;
    update();
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  void setAdditionalDate(int index, String date) {
    _additionalList![index] = date;
    update();
  }

  void setAdditionalCheckData(int index, int i, String date) {
    if(_additionalList![index][i] == date){
      _additionalList![index][i] = 0;
    } else {
      _additionalList![index][i] = date;
    }
    update();
  }

  Future<void> pickFile(int index, MediaData mediaData) async {
    FilePickerResult? result = await deliverymanRegistrationServiceInterface.picFile(mediaData);
    if(result != null) {
      _additionalList![index].add(result);
    }
    update();
  }

  Future<void> registerDeliveryMan(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = deliverymanRegistrationServiceInterface.prepareIdentityImage(_pickedImage, _pickedIdentities);
    List<MultipartDocument> multiPartsDocuments = deliverymanRegistrationServiceInterface.prepareMultipartDocuments(inputTypeList, additionalDocuments);
    await deliverymanRegistrationServiceInterface.registerDeliveryMan(data, multiParts, multiPartsDocuments);
    _isLoading = false;
    update();
  }

  String camelCaseToSentence(String text) {
    var result = text.replaceAll('_', " ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

  void resetDmRegistrationData(){
    _selectedTabIndex = 0;
    _pickedImage = null;
    _selectedIdentityType = null;
    _selectedDmType = null;
    _selectedDmTypeId = null;
    _selectedVehicleId = null;
    _selectedDeliveryZoneId = null;
    _pickedIdentities = [];
    _showPassView = false;
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;
    _selectedShifts = [];
  }

}