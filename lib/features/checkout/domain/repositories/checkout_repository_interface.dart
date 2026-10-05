import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/delivery_coverage_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class CheckoutRepositoryInterface extends RepositoryInterface {
  Future<int?> getDmTipMostTapped();
  Future<List<OfflineMethodModel>> getOfflineMethodList();
  Future<double> getExtraCharge(double? distance);
  Future<DeliveryCoverageModel?> getDeliveryCoverageList({int? restaurantId});
  Future<bool> saveOfflineInfo(String data, String? guestId);
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody);
  Future<Response> sendNotificationRequest(String orderId, String? guestId);
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng);
  Future<bool> updateOfflineInfo(String data, String? guestId);
  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data, String? guestId});
  Future<Response> getCheckoutSummary(CheckoutSummaryBodyModel summaryBody, {String? guestId});
  Future<bool> saveDmTipIndex(String index);
  String getDmTipIndex();
}