import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/delivery_log_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_cancellation_body.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/pause_log_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

abstract class OrderRepositoryInterface extends RepositoryInterface {
  Future<PaginatedMyOrderModel?> getMyOrderList({required int offset, int limit, String? status, String? type, String? guestId});
  @override
  Future<Response> get(String? id, {String? guestId});
  Future<OrderModel?> trackOrder(String? orderID, String? guestId, {String? contactNumber});
  Future<List<CancellationData>?> getCancelReasons();
  Future<ResponseModel> switchToCOD(String? orderID);
  Future<DigitalPaymentStatusModel?> getDigitalPaymentStatus(int orderId);
  Future<Response> payDigitally({required int orderId, required String paymentMethod, String? callback});
  Future<List<Product>?> getFoodsFromFoodIds(List<int?> ids);
  Future<List<String?>?> getRefundReasons();
  Future<ResponseModel> submitRefundRequest(Map<String, String> body, XFile? data, String? guestId);
  Future<bool> deleteOrder(int orderId);
  Future<ResponseModel> cancelOrder(String orderID, String? reason, String? comment);
  Future<PaginatedDeliveryLogModel?> getSubscriptionDeliveryLog(int? subscriptionID, int offset);
  Future<PaginatedPauseLogModel?> getSubscriptionPauseLog(int? subscriptionID, int offset);
  Future<ResponseModel> updateSubscriptionStatus(int? subscriptionID, String? startDate, String? endDate, String status, String note, String? reason);
  Future<PaginatedLatestOrderModel?> getRestaurantLastOrders(int restaurantId, {int offset, int limit});
  Future<PaginatedLatestOrderModel?> getHomeLastOrders({int offset, int limit});
}