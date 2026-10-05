import 'dart:convert';

import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/order/domain/models/delivery_log_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_cancellation_body.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/pause_log_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/refund_model.dart';
import 'package:stackfood_multivendor/features/order/domain/repositories/order_repository_interface.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:image_picker/image_picker.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  OrderRepository({required this.apiClient});

  @override
  Future<OrderModel?> trackOrder(String? orderID, String? guestId, {String? contactNumber}) async {
    OrderModel? trackModel;

    String formatPhoneNumber(String contactNumber) {
      final number = contactNumber.trim().replaceAll(' ', '');
      return number.startsWith('+') ? number : '+$number';
    }

    Response response = await apiClient.getData(
      '${AppConstants.trackUri}$orderID${guestId != null ? '&guest_id=$guestId' : ''}'
          '${contactNumber != null ? '&contact_number=${formatPhoneNumber(contactNumber)}' : ''}',
    );
    if (response.statusCode == 200) {
      trackModel = OrderModel.fromJson(response.body);
    }
    return trackModel;
  }

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  @override
  Future<ResponseModel> switchToCOD(String? orderID) async {
    Map<String, String> data = {'_method': 'put', 'order_id': orderID!};
    if(AuthHelper.isGuestLoggedIn()) {
      data.addAll({'guest_id': AuthHelper.getGuestId()});
    }
    Response response = await apiClient.postData(AppConstants.codSwitchUri, data);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<DigitalPaymentStatusModel?> getDigitalPaymentStatus(int orderId) async {
    DigitalPaymentStatusModel? statusModel;
    final String guestId = AuthHelper.isGuestLoggedIn() ? AuthHelper.getGuestId() : '';
    Response response = await apiClient.getData(
      '${AppConstants.orderDigitalPaymentStatusUri}?order_id=$orderId${guestId.isNotEmpty ? '&guest_id=$guestId' : ''}',
      handleError: false,
    );
    if(response.statusCode == 200 && response.body is Map) {
      statusModel = DigitalPaymentStatusModel.fromJson(response.body);
    }
    return statusModel;
  }

  @override
  Future<Response> payDigitally({required int orderId, required String paymentMethod, String? callback}) async {
    Map<String, String> data = {'order_id': orderId.toString(), 'payment_method': paymentMethod};
    if(callback != null && callback.isNotEmpty) {
      data.addAll({'callback': callback});
    }
    if(AuthHelper.isGuestLoggedIn()) {
      data.addAll({'guest_id': AuthHelper.getGuestId()});
    }
    return await apiClient.postData(AppConstants.orderPayDigitallyUri, data, handleError: false);
  }

  @override
  Future<List<Product>?> getFoodsFromFoodIds(List<int?> ids) async {
    List<Product>? foods;
    Response response = await apiClient.postData(AppConstants.productListWithIdsUri, {'food_id': jsonEncode(ids)});
    if (response.statusCode == 200) {
      foods = [];
      response.body.forEach((food) => foods!.add(Product.fromJson(food)));
    }
    return foods;
  }

  @override
  Future<List<String?>?> getRefundReasons() async {
    List<String?>? refundReasons;
    Response response = await apiClient.getData(AppConstants.refundReasonsUri);
    if (response.statusCode == 200) {
      RefundModel refundModel = RefundModel.fromJson(response.body);
      refundReasons = [];
      refundReasons.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons!) {
        refundReasons.add(element.reason);
      }
    }
    return refundReasons;
  }

  @override
  Future<ResponseModel> submitRefundRequest(Map<String, String> body, XFile? data, String? guestId) async {
    Response response = await apiClient.postMultipartData('${AppConstants.refundRequestUri}${guestId != null ? '?guest_id=$guestId' : ''}', body,  [MultipartBody('image[]', data)], []);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<bool> deleteOrder(int orderId) async {
    final String guestId = AuthHelper.isGuestLoggedIn() ? AuthHelper.getGuestId() : '';
    final Response response = await apiClient.deleteData('${AppConstants.orderDeleteUri}?order_id=$orderId${guestId.isNotEmpty ? '&guest_id=$guestId' : ''}', handleError: false);
    return response.statusCode == 200;
  }

  @override
  Future<ResponseModel> cancelOrder(String orderID, String? reason, String? comment) async {
    Map<String, String> data = {'_method': 'put', 'order_id': orderID, 'reason': reason ?? '', 'note': comment ?? ''};
    if(AuthHelper.isGuestLoggedIn()){
      data.addAll({'guest_id': AuthHelper.getGuestId()});
    }
    Response response = await apiClient.postData(AppConstants.orderCancelUri, data);
    if(response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<PaginatedDeliveryLogModel?> getSubscriptionDeliveryLog(int? subscriptionID, int offset) async {
    PaginatedDeliveryLogModel? deliverLogs;
    Response response = await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/delivery-log?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      deliverLogs = PaginatedDeliveryLogModel.fromJson(response.body);
    }
    return deliverLogs;
  }

  @override
  Future<PaginatedPauseLogModel?> getSubscriptionPauseLog(int? subscriptionID, int offset) async {
    PaginatedPauseLogModel? pauseLogs;
    Response response = await apiClient.getData('${AppConstants.subscriptionListUri}/$subscriptionID/pause-log?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      pauseLogs = PaginatedPauseLogModel.fromJson(response.body);
    }
    return pauseLogs;
  }

  @override
  Future<ResponseModel> updateSubscriptionStatus(int? subscriptionID, String? startDate, String? endDate, String status, String note, String? reason) async {
    Response response = await apiClient.postData(
      '${AppConstants.subscriptionListUri}/update/$subscriptionID',
      {'_method': 'put', 'status': status, 'note': note, 'cancellation_reason': reason, 'start_date': startDate, 'end_date': endDate},
    );
    if(response.statusCode == 200) {
      return ResponseModel(true, response.statusText);
    } else {
      return ResponseModel(false, response.statusText);
    }
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
  Future<Response> get(String? id, {String? guestId}) async {
    return await apiClient.getData('${AppConstants.orderDetailsUri}$id${guestId != null ? '&guest_id=$guestId' : ''}');
  }



  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedMyOrderModel?> getMyOrderList({required int offset, int limit = 10, String? status, String? type, String? guestId}) async {
    PaginatedMyOrderModel? paginatedMyOrderModel;
    Response response = await apiClient.getData(
      '${AppConstants.orderListUri}?offset=$offset&limit=$limit'
          '${status != null ? '&status=$status' : ''}'
          '${type != null ? '&type=$type' : ''}'
          '${guestId != null ? '&guest_id=$guestId' : ''}',
    );
    if (response.statusCode == 200) {
      paginatedMyOrderModel = PaginatedMyOrderModel.fromJson(response.body);
    }
    return paginatedMyOrderModel;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedLatestOrderModel?> getRestaurantLastOrders(int restaurantId, {int offset = 1, int limit = 5}) async {
    PaginatedLatestOrderModel? paginatedLatestOrderModel;
    Response response = await apiClient.getData('${AppConstants.getLastOrderUri}?offset=$offset&limit=$limit&restaurant_id=$restaurantId');
    if (response.statusCode == 200) {
      paginatedLatestOrderModel = PaginatedLatestOrderModel.fromJson(response.body);
    }
    return paginatedLatestOrderModel;
  }

  @override
  Future<PaginatedLatestOrderModel?> getHomeLastOrders({int offset = 1, int limit = 5}) async {
    PaginatedLatestOrderModel? paginatedLatestOrderModel;
    Response response = await apiClient.getData('${AppConstants.getLastOrderUri}?offset=$offset&limit=$limit',);
    if (response.statusCode == 200) {
      paginatedLatestOrderModel = PaginatedLatestOrderModel.fromJson(response.body);
    }
    return paginatedLatestOrderModel;
  }

}