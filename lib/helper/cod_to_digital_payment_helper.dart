import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/cod_payment_failed_sheet.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class CodToDigitalPaymentHelper {

  static String? readStatus(String url) {
    String? status;
    for(final RegExpMatch match in RegExp(r'[?&]status=([a-zA-Z_-]*)').allMatches(url)) {
      final String? value = match.group(1);
      if(value != null && value.isNotEmpty) {
        status = value.toLowerCase();
      }
    }
    return status;
  }

  static bool? readOutcome(String url) {
    final String? status = readStatus(url);
    if(status != null) {
      return status == 'success';
    }
    if(url.startsWith('${AppConstants.baseUrl}/payment-success')) {
      return true;
    }
    if(url.startsWith(AppConstants.codToDigitalCallbackUrl) || url.startsWith('${AppConstants.baseUrl}/payment-fail')
        || url.startsWith('${AppConstants.baseUrl}/payment-cancel')) {
      return false;
    }
    return null;
  }

  static Future<void> handleOutcome({required bool isSuccess, required String orderId, String? contactNumber}) async {
    if(Get.currentRoute.contains(RouteHelper.payment)) {
      Get.back();
    }

    final bool isPaid = await _refreshOrder(orderId, contactNumber);

    if(isSuccess || isPaid) {
      showCustomSnackBar('payment_completed_successfully'.tr, isError: false);
      return;
    }

    final OrderModel? order = Get.find<OrderController>().trackModel;
    CodPaymentFailedSheet.open(
      order: order?.id.toString() == orderId ? order : null, contactNumber: contactNumber,
    );
  }

  static Future<bool> _refreshOrder(String orderId, String? contactNumber) async {
    final bool hasContactNumber = contactNumber != null && contactNumber.isNotEmpty && contactNumber != 'null';
    final String? number = hasContactNumber ? contactNumber : null;

    final OrderController orderController = Get.find<OrderController>();
    await orderController.timerTrackOrder(orderId, contactNumber: number);
    orderController.startTrackTimer(orderId: orderId, contactNumber: number, immediate: false);

    final OrderModel? order = orderController.trackModel;
    return order?.id.toString() == orderId && order?.paymentStatus == 'paid';
  }
}
