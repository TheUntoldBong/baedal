import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class RazorpayHelper {
  static Razorpay? _razorpay;
  static String? _orderId;
  static double? _amount;
  static String? _contactNumber;
  static String? _email;
  static String? _customerName;
  static bool _isDeliveryOrder = true;
  static double _proDiscount = 0;
  static double? _maxCodOrderAmount;

  // Pre-payment flow state
  static bool _isPrePaymentFlow = false;
  static PlaceOrderBodyModel? _placeOrderBody;
  static CheckoutController? _checkoutController;
  static int? _zoneId;
  static bool _fromCart = true;
  static bool _isCashOnDeliveryActive = false;

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

  /// Initiates payment BEFORE creating an order in the database.
  /// If customer cancels or presses back, no order is placed and cart is untouched.
  /// Only when payment succeeds, the order is created and confirmed.
  static Future<void> initiateAndCheckout({
    required PlaceOrderBodyModel placeOrderBody,
    required CheckoutController checkoutController,
    required double amount,
    required int? zoneId,
    required double? maxCodOrderAmount,
    required bool fromCart,
    required bool isCashOnDeliveryActive,
    required String contactNumber,
    required String email,
    required String customerName,
    bool isDeliveryOrder = true,
    double proDiscount = 0,
  }) async {
    init();

    _isPrePaymentFlow = true;
    _placeOrderBody = placeOrderBody;
    _checkoutController = checkoutController;
    _zoneId = zoneId;
    _amount = amount;
    _maxCodOrderAmount = maxCodOrderAmount;
    _fromCart = fromCart;
    _isCashOnDeliveryActive = isCashOnDeliveryActive;
    _contactNumber = contactNumber;
    _email = email;
    _customerName = customerName;
    _isDeliveryOrder = isDeliveryOrder;
    _proDiscount = proDiscount;
    _orderId = null;

    // Show loading spinner while preparing Razorpay order
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    String? razorpayOrderId;
    String? key;
    double finalAmount = amount;

    try {
      final response = await Get.find<ApiClient>().postData(AppConstants.razorpayInitiateUri, {
        'order_amount': amount,
      });

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200 && response.body != null && response.body['status'] == true) {
        razorpayOrderId = response.body['razorpay_order_id'];
        key = response.body['api_key'];
        if (response.body['amount'] != null) {
          finalAmount = double.tryParse('${response.body['amount']}') ?? amount;
        }
      } else {
        debugPrint('Failed to initiate Razorpay order: ${response.statusCode} - ${response.statusText}');
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      debugPrint('Exception while initiating Razorpay order: $e');
    }

    if (key == null || key.isEmpty) {
      var activeList = Get.find<SplashController>().configModel?.activePaymentMethodList;
      if (activeList != null) {
        for (var method in activeList) {
          if ((method.getWay == 'razor_pay' || method.getWay == 'razorpay') && method.publicKey != null && method.publicKey!.isNotEmpty) {
            key = method.publicKey;
            break;
          }
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

    if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
      showCustomSnackBar('Could not initiate online payment. You can retry or switch to Cash on Delivery.');
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

    var options = <String, dynamic>{
      'key': key,
      'amount': (finalAmount * 100).round(),
      'currency': 'INR',
      'name': Get.find<SplashController>().configModel?.businessName ?? AppConstants.appName,
      'description': 'Order Payment',
      'timeout': 120,
      'prefill': prefill,
      'theme': {
        'color': '#20A7DB',
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'external': {
        'wallets': ['paytm']
      },
      'order_id': razorpayOrderId,
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      showCustomSnackBar('Could not launch Razorpay: $e');
    }
  }

  /// Legacy checkout when order was already created in DB
  static Future<void> openCheckout({
    required String orderId,
    required double amount,
    required String contactNumber,
    required String email,
    required String customerName,
    bool isDeliveryOrder = true,
    double proDiscount = 0,
    double? maxCodOrderAmount,
  }) async {
    init();

    _isPrePaymentFlow = false;
    _orderId = orderId;
    _amount = amount;
    _contactNumber = contactNumber;
    _email = email;
    _customerName = customerName;
    _isDeliveryOrder = isDeliveryOrder;
    _proDiscount = proDiscount;
    _maxCodOrderAmount = maxCodOrderAmount;

    // Show loading spinner while preparing Razorpay order
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    String? razorpayOrderId;
    String? key;
    double finalAmount = amount;

    try {
      final response = await Get.find<ApiClient>().postData(AppConstants.razorpayCreateOrderUri, {
        'order_id': orderId,
      });

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200 && response.body != null && response.body['status'] == true) {
        razorpayOrderId = response.body['razorpay_order_id'];
        key = response.body['api_key'];
        if (response.body['amount'] != null) {
          finalAmount = double.tryParse('${response.body['amount']}') ?? amount;
        }
      } else {
        debugPrint('Failed to create Razorpay server order: ${response.statusCode} - ${response.statusText}');
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      debugPrint('Exception while creating Razorpay order: $e');
    }

    if (key == null || key.isEmpty) {
      var activeList = Get.find<SplashController>().configModel?.activePaymentMethodList;
      if (activeList != null) {
        for (var method in activeList) {
          if ((method.getWay == 'razor_pay' || method.getWay == 'razorpay') && method.publicKey != null && method.publicKey!.isNotEmpty) {
            key = method.publicKey;
            break;
          }
        }
      }
    }
    if (key == null || key.isEmpty) {
      key = AppConstants.razorpayKey;
    }

    if (key.isEmpty) {
      showCustomSnackBar('Razorpay payment gateway is not configured.');
      _handlePaymentError(PaymentFailureResponse(3, 'Razorpay not configured', null));
      return;
    }

    if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
      showCustomSnackBar('Could not initiate online payment. You can retry or switch to Cash on Delivery.');
      _handlePaymentError(PaymentFailureResponse(3, 'Failed to create Razorpay server order', null));
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

    var options = <String, dynamic>{
      'key': key,
      'amount': (finalAmount * 100).round(),
      'currency': 'INR',
      'name': Get.find<SplashController>().configModel?.businessName ?? AppConstants.appName,
      'description': 'Order #$orderId',
      'timeout': 120,
      'prefill': prefill,
      'theme': {
        'color': '#20A7DB',
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'external': {
        'wallets': ['paytm']
      },
      'order_id': razorpayOrderId,
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      showCustomSnackBar('Could not launch Razorpay: $e');
      _handlePaymentError(PaymentFailureResponse(3, e.toString(), null));
    }
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}');

    // If pre-payment flow, place the order now with verified payment details
    if (_isPrePaymentFlow && _placeOrderBody != null && _checkoutController != null) {
      _placeOrderBody!.paymentId = response.paymentId;
      _placeOrderBody!.razorpayOrderId = response.orderId;
      _placeOrderBody!.signature = response.signature;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        await _checkoutController!.placeOrder(
          _placeOrderBody!,
          _zoneId,
          _placeOrderBody!.orderAmount ?? (_amount ?? 0),
          _maxCodOrderAmount,
          _fromCart,
          _isCashOnDeliveryActive,
          proDiscount: _proDiscount,
        );
      } catch (e) {
        debugPrint('Error placing order after payment: $e');
        showCustomSnackBar('Payment was received (ID: ${response.paymentId}), but order creation encountered an error: $e. Please contact support.');
      } finally {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }
      return;
    }

    // Legacy fallback (post-placement verification)
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      if (_orderId != null && response.paymentId != null) {
        final verification = await Get.find<ApiClient>().postData(AppConstants.razorpayVerifyUri, {
          'order_id': _orderId,
          'payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'signature': response.signature,
        });

        if (Get.isDialogOpen == true) {
          Get.back();
        }

        if (verification.statusCode != 200) {
          debugPrint('Razorpay verification rejected: ${verification.statusCode} - ${verification.statusText}');
          showCustomSnackBar('Payment was received but could not be verified. Please contact support before trying again.');
          return;
        }
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        showCustomSnackBar('Payment could not be verified. Please contact support before trying again.');
        return;
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      debugPrint('Error verifying razorpay payment: $e');
      showCustomSnackBar('Payment was received but could not be verified. Please contact support before trying again.');
      return;
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

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (_isPrePaymentFlow) {
      // Pre-payment flow: NO order created in DB, cart remains 100% intact!
      // Code 2 or PAYMENT_CANCELLED means customer pressed back button or cancelled.
      if (response.code == Razorpay.PAYMENT_CANCELLED || response.code == 2) {
        showCustomSnackBar('Payment cancelled. You can select Cash on Delivery or try paying again.', isError: false);
      } else {
        showCustomSnackBar('Payment was not completed. You can choose Cash on Delivery or try again.');
      }
      return;
    }

    // Legacy fallback
    if (_orderId != null && Get.context != null) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: PaymentFailedDialog(
            orderID: _orderId,
            orderAmount: _amount,
            maxCodOrderAmount: _maxCodOrderAmount,
            contactPersonNumber: _contactNumber,
            onRetry: () {
              openCheckout(
                orderId: _orderId!,
                amount: _amount ?? 0,
                contactNumber: _contactNumber ?? '',
                email: _email ?? '',
                customerName: _customerName ?? '',
                isDeliveryOrder: _isDeliveryOrder,
                proDiscount: _proDiscount,
                maxCodOrderAmount: _maxCodOrderAmount,
              );
            },
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      showCustomSnackBar('Payment cancelled or failed. You can switch to COD or try again.');
    }
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay External Wallet: ${response.walletName}');
  }
}
