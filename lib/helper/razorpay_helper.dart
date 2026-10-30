import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class RazorpayHelper {
  static Razorpay? _razorpay;
  static String? _orderId;
  static double? _amount;
  static String? _contactNumber;
  static bool _isDeliveryOrder = true;
  static double _proDiscount = 0;

  static void init() {
    _razorpay ??= Razorpay();
    _razorpay!.clear();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  static void openCheckout({
    required String orderId,
    required double amount,
    required String contactNumber,
    required String email,
    required String customerName,
    bool isDeliveryOrder = true,
    double proDiscount = 0,
  }) {
    init();

    _orderId = orderId;
    _amount = amount;
    _contactNumber = contactNumber;
    _isDeliveryOrder = isDeliveryOrder;
    _proDiscount = proDiscount;

    String? key;
    var activeList = Get.find<SplashController>().configModel?.activePaymentMethodList;
    if (activeList != null) {
      for (var method in activeList) {
        if ((method.getWay == 'razor_pay' || method.getWay == 'razorpay') && method.publicKey != null && method.publicKey!.isNotEmpty) {
          key = method.publicKey;
          break;
        }
      }
    }
    if (key == null || key.isEmpty) {
      key = AppConstants.razorpayKey;
    }

    if (key.isEmpty) {
      showCustomSnackBar('Razorpay payment gateway is not configured.');
      return;
    }

    Map<String, dynamic> prefill = {};
    if (contactNumber.trim().isNotEmpty) {
      prefill['contact'] = contactNumber.trim();
    }
    if (email.trim().isNotEmpty) {
      prefill['email'] = email.trim();
    }
    if (customerName.trim().isNotEmpty) {
      prefill['name'] = customerName.trim();
    }

    var options = {
      'key': key,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': Get.find<SplashController>().configModel?.businessName ?? AppConstants.appName,
      'description': 'Order #$orderId',
      'timeout': 120,
      'prefill': prefill,
      'theme': {
        'color': '#20A7DB',
      },
      'notes': {
        'order_id': orderId,
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      showCustomSnackBar('Could not launch Razorpay: $e');
    }
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}');

    try {
      if (_orderId != null && response.paymentId != null) {
        await Get.find<ApiClient>().postData(AppConstants.razorpayVerifyUri, {
          'order_id': _orderId,
          'payment_id': response.paymentId,
        });
      }
    } catch (e) {
      debugPrint('Error verifying razorpay payment: $e');
    }

    if (_amount != null && Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint != null) {
      double total = ((_amount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
    }

    if (_orderId != null) {
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
        _orderId!, 'success', _amount, _contactNumber,
        isDeliveryOrder: _isDeliveryOrder, proDiscount: _proDiscount,
      ));
    }
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay Payment Failure: ${response.code} - ${response.message}');
    showCustomSnackBar('Payment cancelled or failed. You can switch to COD or try again.');
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay External Wallet: ${response.walletName}');
  }
}
