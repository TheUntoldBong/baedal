import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/delivery_coverage_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/distance_duration_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/timeslote_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class CheckoutServiceInterface {
  Future<int?> getDmTipMostTapped();
  Future<List<OfflineMethodModel>> getOfflineMethodList();
  Future<double> getExtraCharge(double? distance);
  Future<DeliveryCoverageModel?> getDeliveryCoverageList({int? restaurantId});
  List<TextEditingController> generateTextControllerList(List<MethodInformations>? methodInformation);
  List<FocusNode> generateFocusList(List<MethodInformations>? methodInformation);
  Future<List<TimeSlotModel>?> initializeTimeSlot(Restaurant restaurant, int? scheduleOrderSlotDuration);
  List<TimeSlotModel>? validateTimeSlot(List<TimeSlotModel> slots, DateTime date);
  List<int>? validateSlotIndexes(List<TimeSlotModel> slots, DateTime date);
  Future<bool> saveOfflineInfo(String data, String? guestId);
  int selectInstruction(int index, int selected);
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody);
  Future<Response> sendNotificationRequest(String orderId, String? guestId);
  String setPreferenceTimeForView(String time, bool instanceOrder);
  int selectTimeSlot(bool instanceOrder);
  double updateTips(int index, int selectedTips);
  Future<DistanceDurationModel> getDistanceAndDuration(LatLng originLatLng, LatLng destinationLatLng);
  Future<bool> updateOfflineInfo(String data, String? guestId);
  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data, String? guestId});
  Future<Response> getCheckoutSummary(CheckoutSummaryBodyModel summaryBody, {String? guestId});
  void saveDmTipIndex(String i);
  String getDmTipIndex();
}