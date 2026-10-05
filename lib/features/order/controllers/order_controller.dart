import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/delivery_log_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_cancellation_body.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/pause_log_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/subscription_schedule_model.dart';
import 'package:stackfood_multivendor/features/order/domain/services/order_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;

  OrderController({required this.orderServiceInterface});

  static const Set<String> trackableStatuses = <String>{
    'confirmed', 'accepted', 'processing', 'handover', 'picked_up', 'out_for_delivery',
  };

  static const Set<String> _mapHiddenStatuses = <String>{
    'delivered', 'canceled', 'refunded', 'refund_requested',
  };

  bool showDeliveryMap(OrderModel? order) {
    if (order == null || order.orderType != 'delivery') return false;
    final String status = (order.orderStatus ?? '').toLowerCase();

    if (order.subscription != null) {
      return !_mapHiddenStatuses.contains(status);
    }

    return order.deliveryMan != null && trackableStatuses.contains(status);
  }

  bool showArrivalState(OrderModel? order) {
    if (order == null || order.orderType != 'delivery' || order.subscription == null) return false;
    final String status = (order.orderStatus ?? '').toLowerCase();
    return !_mapHiddenStatuses.contains(status) && order.deliveryMan == null;
  }

  List<OrderDetailsModel>? _orderDetails;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;

  Timer? _timer;
  String? _timerOrderId;

  String? _activeTrackOrderId;
  String? get activeTrackOrderId => _activeTrackOrderId;

  void setActiveTrackOrder(String? orderID) {
    _activeTrackOrderId = orderID;
  }

  bool _showCancelled = false;
  bool get showCancelled => _showCancelled;

  OrderModel? _trackModel;
  OrderModel? get trackModel => _trackModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _reorderingOrderId;
  int? get reorderingOrderId => _reorderingOrderId;

  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  List<SubscriptionScheduleModel>? _schedules;
  List<SubscriptionScheduleModel>? get schedules => _schedules;

  PaginatedDeliveryLogModel? _deliverLogs;
  PaginatedDeliveryLogModel? get deliveryLogs => _deliverLogs;

  PaginatedPauseLogModel? _pauseLogs;
  PaginatedPauseLogModel? get pauseLogs => _pauseLogs;

  bool _subscriveLoading = false;
  bool get subscriveLoading => _subscriveLoading;

  String? _cancelReason;
  String? get cancelReason => _cancelReason;

  bool _canReorder = true;
  String _reorderMessage = '';

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  int _selectedReasonIndex = 0;
  int get selectedReasonIndex => _selectedReasonIndex;

  List<String?>? _refundReasons;
  List<String?>? get refundReasons => _refundReasons;

  XFile? _refundImage;
  XFile? get refundImage => _refundImage;

  int? _cancellationIndex = 0;
  int? get cancellationIndex => _cancellationIndex;

  bool _showBottomSheet = true;
  bool get showBottomSheet => _showBottomSheet;

  static const double runningSheetPeek = 100;
  bool get runningSheetVisible => AuthHelper.isLoggedIn() && showBottomSheet && (runningOrders?.isNotEmpty ?? false);

  List<MyOrderModel>? get runningOrders => myOrderTab(MyOrderTabType.running).orders;

  bool _showOneOrder = true;
  bool get showOneOrder => _showOneOrder;

  bool _isCancelLoading = false;
  bool get isCancelLoading => _isCancelLoading;

  List<LatestOrderModel>? _restaurantLastOrders;
  List<LatestOrderModel>? get restaurantLastOrders => _restaurantLastOrders;

  List<int> _restaurantLastOrdersOffsetList = [];
  int _restaurantLastOrdersOffset = 1;
  int? _restaurantLastOrdersPageSize;
  int? get restaurantLastOrdersPageSize => _restaurantLastOrdersPageSize;
  bool _restaurantLastOrdersPaginating = false;
  bool get restaurantLastOrdersPaginating => _restaurantLastOrdersPaginating;

  List<LatestOrderModel>? _homeLastOrders;
  List<LatestOrderModel>? get homeLastOrders => _homeLastOrders;

  List<int> _homeLastOrdersOffsetList = [];
  int _homeLastOrdersOffset = 1;
  int? _homeLastOrdersPageSize;
  int? get homeLastOrdersPageSize => _homeLastOrdersPageSize;
  bool _homeLastOrdersPaginating = false;
  bool get homeLastOrdersPaginating => _homeLastOrdersPaginating;

  int get homeLastOrdersOffset => _homeLastOrdersOffset;
  int get restaurantLastOrdersOffset => _restaurantLastOrdersOffset;


  final Map<MyOrderTabType, MyOrderTabData> _myOrders = <MyOrderTabType, MyOrderTabData>{
    for (final MyOrderTabType tab in MyOrderTabType.values) tab: MyOrderTabData(),
  };

  MyOrderTabData myOrderTab(MyOrderTabType tab) => _myOrders[tab]!;

  Future<void> getMyOrders(MyOrderTabType tab, int offset, {bool notify = true, int limit = 10}) async {
    final MyOrderTabData data = _myOrders[tab]!;
    if (offset == 1) {
      data.loadedOffsets.clear();
      data.offset = 1;
      data.orders = null;
      if (notify) {
        update();
      }
    }
    if (data.loadedOffsets.contains(offset)) {
      if (data.paginating) {
        data.paginating = false;
        update();
      }
      return;
    }
    data.loadedOffsets.add(offset);
    final PaginatedMyOrderModel? paginatedMyOrderModel = await orderServiceInterface.getMyOrders(
      tab, offset, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), limit: limit,
    );
    if (paginatedMyOrderModel != null) {
      if (offset == 1) {
        data.orders = <MyOrderModel>[];
      }
      data.orders!.addAll(paginatedMyOrderModel.orders ?? <MyOrderModel>[]);
      data.totalSize = paginatedMyOrderModel.totalSize;
      data.paginating = false;
      update();
    } else {
      data.loadedOffsets.remove(offset);
      data.paginating = false;
      update();
    }
  }

  void setMyOrderOffset(MyOrderTabType tab, int offset) {
    _myOrders[tab]!.offset = offset;
  }

  void showMyOrderBottomLoader(MyOrderTabType tab) {
    _myOrders[tab]!.paginating = true;
    update();
  }

  void removeMyOrderFromList(int? id) {
    if (id == null) return;
    for (final MyOrderTabData data in _myOrders.values) {
      data.orders?.removeWhere((order) => order.id == id);
      if (data.totalSize != null && data.totalSize! > 0) {
        data.totalSize = data.totalSize! - 1;
      }
    }
    update();
  }


  Future<bool> deleteOrder(int? id) async {
    if(id == null) return false;
    return await orderServiceInterface.deleteOrder(id);
  }

  void callTrackOrderApi({required OrderModel orderModel, required String orderId, String? contactNumber}){
    if(orderModel.orderStatus != 'delivered' && orderModel.orderStatus != 'failed' && orderModel.orderStatus != 'canceled') {
      startTrackTimer(orderId: orderId.toString(), contactNumber: contactNumber);
    }else{
      cancelTimer();
      timerTrackOrder(orderId.toString(), contactNumber: contactNumber);
    }
  }

  void startTrackTimer({required String orderId, String? contactNumber, bool immediate = true, VoidCallback? onTick}) {
    _timer?.cancel();
    _timerOrderId = orderId;
    _activeTrackOrderId = orderId;

    if(immediate) {
      timerTrackOrder(orderId, contactNumber: contactNumber);
    }

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final bool onTrackableRoute = Get.currentRoute.contains(RouteHelper.orderDetails) || Get.currentRoute.contains(RouteHelper.orderTracking);
      if(_timerOrderId != orderId || !onTrackableRoute) {
        timer.cancel();
        return;
      }
      await timerTrackOrder(orderId, contactNumber: contactNumber);
      onTick?.call();
    });
  }

  Future<bool> timerTrackOrder(String orderID, {String? contactNumber}) async {
    _showCancelled = false;
    OrderModel? orderModel = await orderServiceInterface.trackOrder(orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), contactNumber: contactNumber);
    if(_activeTrackOrderId != null && _activeTrackOrderId != orderID) {
      return (_trackModel != null);
    }
    if(orderModel != null) {
      _trackModel = orderModel;
    }
    update();
    return (orderModel != null);
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerOrderId = null;
  }

  void clearStaleTrackModel(String? orderId) {
    if(_trackModel != null && _trackModel!.id.toString() != orderId) {
      _trackModel = null;
      _schedules = null;
    }
  }

  Future<ResponseModel> trackOrder(String? orderID, OrderModel? orderModel, bool fromTracking, {String? contactNumber, bool? fromGuestInput = false}) async {
    if(_trackModel != null && _trackModel!.id.toString() != orderID) {
      _trackModel = null;
    }
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    ResponseModel responseModel;
    if(orderModel == null) {
      _isLoading = true;

      OrderModel? responseOrderModel = await orderServiceInterface.trackOrder(orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), contactNumber: contactNumber);
      if (responseOrderModel != null) {
        _trackModel = responseOrderModel;
        responseModel = ResponseModel(true, 'Successful');
      } else {
        responseModel = ResponseModel(false, 'Failed');
      }
      _isLoading = false;
      update();
    }else {
      _trackModel = orderModel;
      responseModel = ResponseModel(true, 'Successful');
    }
    return responseModel;
  }

  Future<void> getDeliveryLogs(int? subscriptionID, int offset) async {
    if(offset == 1) {
      _deliverLogs = null;
    }
    PaginatedDeliveryLogModel? deliveryLogModel = await orderServiceInterface.getSubscriptionDeliveryLog(subscriptionID, offset);
    if (deliveryLogModel != null) {
      if (offset == 1) {
        _deliverLogs = deliveryLogModel;
      }else {
        _deliverLogs!.data!.addAll(deliveryLogModel.data!);
        _deliverLogs!.offset = deliveryLogModel.offset;
        _deliverLogs!.totalSize = deliveryLogModel.totalSize;
      }
      update();
    }
  }

  Future<void> getPauseLogs(int? subscriptionID, int offset) async {
    if(offset == 1) {
      _pauseLogs = null;
    }
    PaginatedPauseLogModel? pauseLogModel = await orderServiceInterface.getSubscriptionPauseLog(subscriptionID, offset);
    if (pauseLogModel != null) {
      if (offset == 1) {
        _pauseLogs = pauseLogModel;
      }else {
        _pauseLogs!.data!.addAll(pauseLogModel.data!);
        _pauseLogs!.offset = pauseLogModel.offset;
        _pauseLogs!.totalSize = pauseLogModel.totalSize;
      }
      update();
    }
  }

  void setCancelIndex(int? index) {
    _cancellationIndex = index;
    update();
  }

  Future<bool> updateSubscriptionStatus(int? subscriptionID, DateTime? startDate, DateTime? endDate, String status,
      String note, String? reason, String? orderId, String? contactNumber) async {
    _subscriveLoading = true;
    update();

    ResponseModel responseModel = await orderServiceInterface.updateSubscriptionStatus(
      subscriptionID, startDate != null ? DateConverter.dateToDateAndTime(startDate) : null,
      endDate != null ? DateConverter.dateToDateAndTime(endDate) : null, status, note, reason,
    );
    if (responseModel.isSuccess) {
      Get.back();
      timerTrackOrder(orderId.toString(), contactNumber: contactNumber);
      if(status == 'canceled' || startDate!.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        _trackModel!.subscription!.status = status;
      }
      showCustomSnackBar(
        status == 'paused' ? 'subscription_paused_successfully'.tr : 'subscription_cancelled_successfully'.tr, isError: false,
      );
    }
    _subscriveLoading = false;
    update();
    return responseModel.isSuccess;
  }

  Future<void> getOrderCancelReasons()async {
    List<CancellationData>? reasons = await orderServiceInterface.getCancelReasons();
    if (reasons != null) {
      _orderCancelReasons = [];
      _orderCancelReasons!.addAll(reasons);
    }
    update();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _isLoading = true;
    _showCancelled = false;

    Response response = await orderServiceInterface.getOrderDetails(orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if (response.statusCode == 200) {
      _orderDetails = orderServiceInterface.processOrderDetails(response);
      _schedules = orderServiceInterface.processSchedules(response);
    }
    _isLoading = false;
    update();
    return _orderDetails;
  }

  Future<DigitalPaymentStatusModel?> getDigitalPaymentStatus(int orderId) async {
    return await orderServiceInterface.getDigitalPaymentStatus(orderId);
  }

  Future<PayDigitallyResponseModel> payDigitally({required int orderId, required String paymentMethod, String? callback}) async {
    return await orderServiceInterface.payDigitally(orderId: orderId, paymentMethod: paymentMethod, callback: callback);
  }

  Future<bool> switchToCOD(String? orderID, String? contactNumber, {double? points}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await orderServiceInterface.switchToCOD(orderID);
    if (responseModel.isSuccess) {
      if(points != null) {
        Get.find<LoyaltyController>().saveEarningPoint(points.toStringAsFixed(0));
      }
      if(Get.find<AuthController>().isGuestLoggedIn()) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID!, 'success', 0, contactNumber));
      }else {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      }
      showCustomSnackBar(responseModel.message, isError: false);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void selectReason(int index,{bool isUpdate = true}){
    _selectedReasonIndex = index;
    if(isUpdate) {
      update();
    }
  }

  void setOrderCancelReason(String? reason){
    _cancelReason = reason;
    update();
  }

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  Future<void> getRefundReasons()async {
    _refundReasons = null;
    _refundReasons = await orderServiceInterface.getRefundReasons();
    update();
  }

  void pickRefundImage(bool isRemove) async {
    if(isRemove) {
      _refundImage = null;
    }else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  void showRunningOrders(){
    _showBottomSheet = !_showBottomSheet;
    update();
  }

  void showOrders(){
    _showOneOrder = !_showOneOrder;
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId)async {
    if(_selectedReasonIndex == 0){
      showCustomSnackBar('please_select_reason'.tr);
    }else{
      _isLoading = true;
      update();
      Map<String, String> body = orderServiceInterface.prepareReasonData(note, orderId, _refundReasons![selectedReasonIndex]!);

      ResponseModel responseModel = await orderServiceInterface.submitRefundRequest(body, _refundImage, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
      if (responseModel.isSuccess) {
        showCustomSnackBar(responseModel.message, isError: false);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
      _isLoading = false;
      update();
    }
  }

  Future<bool> cancelOrder(int? orderID, String? cancelReason, {String? comment}) async {
    _isCancelLoading = true;
    update();
    ResponseModel responseModel = await orderServiceInterface.cancelOrder(orderID.toString(), cancelReason, comment);
    _isCancelLoading = false;
    Get.back();
    if (responseModel.isSuccess) {
      myOrderTab(MyOrderTabType.running).orders?.removeWhere((order) => order.id == orderID);
      _showCancelled = true;
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message);
    }
    update();
    return responseModel.isSuccess;
  }

  Future<void> reorderFromLastOrder(int? orderId) async {
    if (orderId == null || _isLoading) return;

    _isLoading = true;
    _reorderingOrderId = orderId;
    update();
    List<OrderDetailsModel>? details = await getOrderDetails(orderId.toString());
    _isLoading = false;
    _reorderingOrderId = null;
    update();
    if (details != null && details.isNotEmpty) {
      await reOrder(details, details.first.zoneId);
    }
  }

  Future<void> reOrder(List<OrderDetailsModel> orderedFoods, int? restaurantZoneId) async {
    if(_isLoading) return;
    final pir = Get.find<CartController>().isExistInCart(orderedFoods.first.foodDetails?.id ?? -1, orderedFoods.first.foodDetails?.restaurantId ?? -1);
    if(pir.$1 != -1){
      bool flg = false;
      await showCustomDialog(
        child: ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: 'if_you_continue'.tr,
        onYesPressed: () async{
          flg = true;
          if(Get.isOverlaysOpen){
            Get.back();
          }
        }
      ),
        isDismissible: false,
      );
      if(flg){
        bool success = await Get.find<CartController>().removeCartBundle(orderedFoods.first.foodDetails?.restaurantId ?? -1);
        if(success){
          await _reOrder(orderedFoods, restaurantZoneId);
        }
        else{
          showCustomSnackBar('something want wrong!');
        }
      }
    }
    else{
      await _reOrder(orderedFoods,restaurantZoneId);
    }
  }

  Future<void> _reOrder(List<OrderDetailsModel> orderedFoods, int? restaurantZoneId) async {

    _isLoading = true;
    update();

    List<int?> foodIds = orderServiceInterface.prepareFoodIds(orderedFoods);
    List<Product>? responseFoods = await orderServiceInterface.getFoodsFromFoodIds(foodIds);
    final bool isUnavailable = responseFoods?.length != orderedFoods.length;
    if(isUnavailable){
      showCustomSnackBar('This order can\'t be reordered - One or more items are Unavailable.');
    }
    else{
      if (responseFoods != null && responseFoods.isNotEmpty) {
        _canReorder = true;
        List<Product> foods = responseFoods;

        List<OnlineCart> onlineCartList = orderServiceInterface.prepareOnlineCartList(restaurantZoneId, orderedFoods, foods);
        List<CartModel> offlineCartList = orderServiceInterface.prepareOfflineCartList(restaurantZoneId, orderedFoods, foods);

        _canReorder = AddressHelper.getAddressFromSharedPref()!.zoneIds!.contains(restaurantZoneId);
        _reorderMessage = !_canReorder ? 'you_are_not_in_the_order_zone' : '';

        if(_canReorder) {
          _canReorder = await orderServiceInterface.checkProductVariationHasChanged(offlineCartList);
          _reorderMessage = !_canReorder ? 'this_ordered_products_are_updated_so_can_not_reorder_this_order' : '';
        }

        if(_canReorder) {
          await Get.find<CartController>().reorderAddToCart(onlineCartList).then((statusCode) {
            if(statusCode == 200) {
              Get.toNamed(RouteHelper.getCartBundleListRoute());
            }
          });
        }else{
          showCustomSnackBar(_reorderMessage.tr);
        }
      }
      else{
        showCustomSnackBar('Current orders can not be reordered as some changes occurred to the items.');
      }
    }

    _isLoading = false;
    update();
  }

  Future<void> getRestaurantLastOrders(int restaurantId, {int offset = 1, int limit = 10, bool notify = true}) async {
    if (offset == 1) {
      _restaurantLastOrdersOffsetList = [];
      _restaurantLastOrdersOffset = 1;
      _restaurantLastOrders = null;
      if (notify) update();
    }
    if (!_restaurantLastOrdersOffsetList.contains(offset)) {
      _restaurantLastOrdersOffsetList.add(offset);
      PaginatedLatestOrderModel? result = await orderServiceInterface.getRestaurantLastOrders(restaurantId, offset: offset, limit: limit);
      if (result != null) {
        if (offset == 1) _restaurantLastOrders = [];
        _restaurantLastOrders!.addAll(result.orders!);
        _restaurantLastOrdersPageSize = result.totalSize;
        _restaurantLastOrdersPaginating = false;
        update();
      }
    } else {
      if (_restaurantLastOrdersPaginating) {
        _restaurantLastOrdersPaginating = false;
        update();
      }
    }
  }

  Future<void> getHomeLastOrders({int offset = 1, bool notify = true}) async {
    if (offset == 1) {
      _homeLastOrdersOffsetList = [];
      _homeLastOrdersOffset = 1;
      _homeLastOrders = null;
      if (notify) update();
    }
    if (!_homeLastOrdersOffsetList.contains(offset)) {
      _homeLastOrdersOffsetList.add(offset);
      PaginatedLatestOrderModel? result = await orderServiceInterface.getHomeLastOrders(offset: offset, limit: 10);
      if (result != null) {
        if (offset == 1) _homeLastOrders = [];
        _homeLastOrders!.addAll(result.orders!);
        _homeLastOrdersPageSize = result.totalSize;
        _homeLastOrdersPaginating = false;
        update();
      }
    } else {
      if (_homeLastOrdersPaginating) {
        _homeLastOrdersPaginating = false;
        update();
      }
    }
  }

  void showLastOrderLoader({required bool isHome}) {
    if (isHome) {
      _homeLastOrdersPaginating = true;
      _homeLastOrdersOffset++;
    } else {
      _restaurantLastOrdersPaginating = true;
      _restaurantLastOrdersOffset++;
    }
    update();
  }

  void clearLastOrders({bool notify = true}) {
    _homeLastOrders = null;
    _homeLastOrdersOffsetList = [];
    _homeLastOrdersOffset = 1;
    _homeLastOrdersPageSize = null;
    _homeLastOrdersPaginating = false;

    _restaurantLastOrders = null;
    _restaurantLastOrdersOffsetList = [];
    _restaurantLastOrdersOffset = 1;
    _restaurantLastOrdersPageSize = null;
    _restaurantLastOrdersPaginating = false;

    if (notify) update();
  }


}