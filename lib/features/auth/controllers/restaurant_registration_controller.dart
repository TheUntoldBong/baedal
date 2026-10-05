import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/features/business/domain/models/package_model.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/restaurant_registration_service_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class RestaurantRegistrationController extends GetxController implements GetxService {
  final RestaurantRegistrationServiceInterface restaurantRegistrationServiceInterface;

  RestaurantRegistrationController({required this.restaurantRegistrationServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _zoneLoading = false;
  bool get zoneLoading => _zoneLoading;

  List<DataModel>? _dataList;
  List<DataModel>? get dataList => _dataList;

  List<dynamic>? _additionalList;
  List<dynamic>? get additionalList => _additionalList;

  double _storeStatus = 0.1;
  double get storeStatus => _storeStatus;

  LatLng? _restaurantLocation;
  LatLng? get restaurantLocation => _restaurantLocation;

  String? _restaurantAddress;
  String? get restaurantAddress => _restaurantAddress;

  List<ZoneModel>? _zoneList;
  List<ZoneModel>? get zoneList => _zoneList;

  String _storeMinTime = '--';
  String get storeMinTime => _storeMinTime;

  String _storeMaxTime = '--';
  String get storeMaxTime => _storeMaxTime;

  String _storeTimeUnit = 'minute';
  String get storeTimeUnit => _storeTimeUnit;

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  XFile? _pickedCover;
  XFile? get pickedCover => _pickedCover;

  int? _selectedZoneIndex = 0;
  int? get selectedZoneIndex => _selectedZoneIndex;

  List<int>? _zoneIds;
  List<int>? get zoneIds => _zoneIds;

  bool _inZone = false;
  bool get inZone => _inZone;

  int _businessIndex = 0;
  int get businessIndex => _businessIndex;

  int _activeSubscriptionIndex = 0;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  PackageModel? _packageModel;
  PackageModel? get packageModel => _packageModel;

  final List<FilePickerResult> _tinFiles = [];
  List<FilePickerResult>? get tinFiles => _tinFiles;

  String? _tinExpireDate;
  String? get tinExpireDate => _tinExpireDate;

  bool _showLogoValidation = false;
  bool get showLogoValidation => _showLogoValidation;

  bool _showCoverValidation = false;
  bool get showCoverValidation => _showCoverValidation;

  void setRestaurantAdditionalJoinUsPageData({bool isUpdate = true}){
    _dataList = [];
    _additionalList = [];
    if(Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData != null) {
      for (var data in Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData!.data!) {
        int index = Get.find<SplashController>().configModel!.restaurantAdditionalJoinUsPageData!.data!.indexOf(data);
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
    FilePickerResult? result = await restaurantRegistrationServiceInterface.picFile(mediaData);
    if(result != null) {
      _additionalList![index].add(result);
    }
    update();
  }

  void removeAdditionalFile(int index, int subIndex) {
    _additionalList![index].removeAt(subIndex);
    update();
  }

  void storeStatusChange(double value, {bool isUpdate = true}){
    _storeStatus = value;
    if(isUpdate) {
      update();
    }
  }

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _restaurantLocation = null;
    _zoneIds = null;
    _zoneList = await Get.find<DeliverymanRegistrationController>().getZoneList();
    if (_zoneList != null) {
      setLocation(LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ));
    }
    update();
  }

  void startZoneLoading() {
    if(!_zoneLoading) {
      _zoneLoading = true;
      update();
    }
  }

  Future<void> setLocation(LatLng location, {bool forRestaurantRegistration = false, int? zoneId}) async {
    _zoneLoading = true;
    update();
    ZoneResponseModel response = await Get.find<LocationController>().getZone(
      location.latitude.toString(), location.longitude.toString(), false,
    );
    int? selectedZoneId = zoneId ?? _selectedZone?.id;
    _inZone = selectedZoneId != null && await restaurantRegistrationServiceInterface.checkInZone(
      location.latitude.toString(), location.longitude.toString(), selectedZoneId,
    );
    _restaurantAddress = await Get.find<LocationController>().getAddressFromGeocode(LatLng(location.latitude, location.longitude));
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
      for(int index=0; index<_zoneList!.length; index++) {
        if(_zoneIds!.contains(_zoneList![index].id)) {
          if(!forRestaurantRegistration) {
            _selectedZoneIndex = 0;
          }
          break;
        }
      }
      if(!_inZone && forRestaurantRegistration) {
        await _selectZoneOfLocation(location);
      }
    }else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    _zoneLoading = false;
    update();
  }

  ZoneModel? get _selectedZone => (_zoneList != null && _selectedZoneIndex != null && _selectedZoneIndex! < _zoneList!.length)
      ? _zoneList![_selectedZoneIndex!] : null;

  Future<void> _selectZoneOfLocation(LatLng location) async {
    for(int index=0; index<_zoneList!.length; index++) {
      if(index == _selectedZoneIndex || !_zoneIds!.contains(_zoneList![index].id)) {
        continue;
      }
      bool inZone = await restaurantRegistrationServiceInterface.checkInZone(
        location.latitude.toString(), location.longitude.toString(), _zoneList![index].id!,
      );
      if(inZone) {
        _selectedZoneIndex = index;
        _inZone = true;
        break;
      }
    }
  }

  void setZoneIndex(int? index) {
    _selectedZoneIndex = index;
    update();
  }

  void minTimeChange(String time){
    _storeMinTime = time;
    update();
  }

  void maxTimeChange(String time){
    _storeMaxTime = time;
    update();
  }

  void timeUnitChange(String unit){
    _storeTimeUnit = unit;
    update();
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    }else {
      if (isLogo) {
        _pickedLogo = await restaurantRegistrationServiceInterface.picLogoFromGallery();
        _showLogoValidation = false;
      } else {
        _pickedCover = await restaurantRegistrationServiceInterface.picLogoFromGallery();
        _showCoverValidation = false;
      }
      update();
    }
  }

  void resetRestaurantRegistration() {
    _pickedLogo = null;
    _pickedCover = null;
    _storeMinTime = '--';
    _storeMaxTime = '--';
    _storeTimeUnit = 'minute';
    update();
  }

  void setImageValidation({bool? logo, bool? cover}) {
    if (logo != null) {
      _showLogoValidation = logo;
    }
    if (cover != null) {
      _showCoverValidation = cover;
    }
    update();
  }

  Future<void> registerRestaurant(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();

    List<FilePickerResult> tinFiles = [];

    for (FilePickerResult element in _tinFiles) {
      tinFiles.add(element);
    }

    List<MultipartDocument> multiPartsDocuments = [];
    multiPartsDocuments.addAll(restaurantRegistrationServiceInterface.prepareMultipartDocuments(inputTypeList, additionalDocuments));

    for (FilePickerResult result in tinFiles) {
      multiPartsDocuments.add(MultipartDocument('tin_certificate_image', result));
    }

    double size = 0;
    for(var element in multiPartsDocuments){
      size = size + element.file!.files.first.size;
    }
    debugPrint(' Total document size: $size');
    if(size > 1000000) {
      showCustomSnackBar('max_file_size_1_mb'.tr);
      _isLoading = false;
      update();
      return;
    }

    Response? response = await restaurantRegistrationServiceInterface.registerRestaurant(data, _pickedLogo, _pickedCover, multiPartsDocuments);

    if(response.statusCode == 200) {
      Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(true);
      int? restaurantId = response.body['restaurant_id'];
      int? packageId = response.body['package_id'];
      if(packageId == null) {
        Get.find<BusinessController>().submitBusinessPlan(restaurantId: restaurantId!, packageId: null);
      } else {
        if(!GetPlatform.isWeb) {
          Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(restaurantId: restaurantId, packageId: packageId));
        } else {
          Get.offNamed(RouteHelper.getSubscriptionPaymentRoute(restaurantId: restaurantId, packageId: packageId));
        }
      }
    }
    _isLoading = false;
    update();
  }

  void resetBusiness(){
    _businessIndex = Get.find<SplashController>().configModel!.commissionBusinessModel == 0 ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    _paymentIndex = Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus??false ? 1 : 0;
  }

  Future<void> getPackageList({bool isUpdate = true}) async {
    _packageModel = await restaurantRegistrationServiceInterface.getPackageList();
    if(isUpdate) {
      update();
    }
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }

  Future<void> pickFiles() async {

    FilePickerResult? result;

    if(GetPlatform.isWeb){
      result = await FilePicker.platform.pickFiles(
        withReadStream: false,
        allowMultiple: false,
      );
    }else{
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
    }

    if (result != null && result.files.isNotEmpty) {

      List<String> supportedFormat = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf', 'doc', 'docx'];
      if(!supportedFormat.contains(result.files.single.extension) && GetPlatform.isWeb) {
        showCustomSnackBar('please_select_valid_file'.tr);
        return;
      }

      for (var file in result.files) {
        if (file.size > 2000000) {
          showCustomSnackBar('max_file_size_2_mb'.tr);
        } else {
          _tinFiles.add(result);
        }
      }
      update();
    }
  }

  void removeFile(int index) {
    _tinFiles.removeAt(index);
    update();
  }

  Future<void> setTinExpireDate(DateTime dateTime) async {
    _tinExpireDate = DateConverter.dateTimeForCoupon(dateTime);
    update();
  }

  void resetData(){
    _tinExpireDate = null;
    _tinFiles.clear();
    _storeMinTime = '--';
    _storeMaxTime = '--';
    _storeTimeUnit = 'minute';
    _showLogoValidation = false;
    _showCoverValidation = false;
  }

  String camelCaseToSentence(String text) {
    var result = text.replaceAll('_', " ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

}