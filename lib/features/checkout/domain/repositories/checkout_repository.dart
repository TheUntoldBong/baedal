import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/delivery_coverage_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckoutRepository implements CheckoutRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CheckoutRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<int?> getDmTipMostTapped() async {
    int mostDmTipAmount = 0;
    Response response = await apiClient.getData(AppConstants.mostTipsUri);
    if(response.statusCode == 200){
      mostDmTipAmount = response.body['most_tips_amount'];
    }
    return mostDmTipAmount;
  }

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    List<OfflineMethodModel> offlineMethodList = [];
    Response response = await apiClient.getData(AppConstants.offlineMethodListUri);
    if (response.statusCode == 200) {
      response.body.forEach((method) => offlineMethodList.add(OfflineMethodModel.fromJson(method)));
    }
    return offlineMethodList;
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    double? extraCharge;
    Response response = await apiClient.getData('${AppConstants.vehicleChargeUri}?distance=$distance');
    if (response.statusCode == 200) {
      extraCharge = double.parse(response.body.toString());
    } else {
      extraCharge = 0;
    }
    return extraCharge;
  }

  @override
  Future<DeliveryCoverageModel?> getDeliveryCoverageList({int? restaurantId}) async {
    DeliveryCoverageModel? coverageModel;
    Response response = await apiClient.getData(
      '${AppConstants.deliveryChargeCoverageUri}${restaurantId != null ? '?restaurant_id=$restaurantId' : ''}', handleError: false,
    );
    if (response.statusCode == 200 && response.body is Map) {
      coverageModel = DeliveryCoverageModel.fromJson(response.body);
    }
    return coverageModel;
  }

  @override
  Future<bool> saveOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.offlinePaymentSaveInfoUri}/${guestId != null ? '?guest_id=$guestId' : ''}', jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody) async {
    return await apiClient.postData(AppConstants.placeOrderUri, orderBody.toJson());
  }

  @override
  Future<Response> sendNotificationRequest(String orderId, String? guestId) async {
    return await apiClient.getData('${AppConstants.sendCheckoutNotificationUri}/$orderId${guestId != null ? '?guest_id=$guestId' : ''}');
  }

  @override
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {

    final response = await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
        '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=TWO_WHEELER',
    );

    return response;
  }

  @override
  Future<bool> updateOfflineInfo(String data, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.offlinePaymentUpdateInfoUri}${guestId != null ? '?guest_id=$guestId' : ''}', jsonDecode(data));
    return (response.statusCode == 200);
  }

  @override
  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data, String? guestId}) async {
    Response response = await apiClient.postData('${AppConstants.checkRestaurantValidation}${guestId != null ? '?guest_id=$guestId' : ''}', data, handleError: false);
    return (response.statusCode == 200);
  }

  @override
  Future<Response> getCheckoutSummary(CheckoutSummaryBodyModel summaryBody, {String? guestId}) async {
    return await apiClient.postData(
      '${AppConstants.checkoutSummaryUri}${guestId != null ? '?guest_id=$guestId' : ''}',
      summaryBody.toJson(), handleError: false,
    );
  }

  @override
  Future<bool> saveDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
  
}