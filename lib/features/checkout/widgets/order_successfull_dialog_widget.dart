import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderSuccessfulDialogWidget extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  final bool isDeliveryOrder;
  final double? proDiscount;

  const OrderSuccessfulDialogWidget({
    super.key,
    required this.orderID,
    this.contactNumber,
    this.isDeliveryOrder = false,
    this.proDiscount,
  });

  @override
  State<OrderSuccessfulDialogWidget> createState() => _OrderSuccessfulDialogWidgetState();
}

class _OrderSuccessfulDialogWidgetState extends State<OrderSuccessfulDialogWidget> with TickerProviderStateMixin {
  bool _isCopied = false;
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().trackOrder(widget.orderID.toString(), null, false, contactNumber: widget.contactNumber);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        double total = 0;
        bool success = true;
        double? maximumCodOrderAmount;

        if (orderController.trackModel != null) {
          final address = AddressHelper.getAddressFromSharedPref();
          if (address?.zoneData != null && address!.zoneId != null) {
            final matchingZones = address.zoneData!.where((data) => data.id == address.zoneId).toList();
            if (matchingZones.isNotEmpty) {
              maximumCodOrderAmount = matchingZones.first.maxCodOrderAmount;
            }
          }

          final loyaltyPoints = Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0;
          total = ((orderController.trackModel!.orderAmount ?? 0) / 100) * loyaltyPoints;
          success = orderController.trackModel!.paymentStatus == 'paid' ||
              orderController.trackModel!.paymentMethod == 'cash_on_delivery' ||
              orderController.trackModel!.paymentMethod == 'partial_payment';

          if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
            Future.delayed(const Duration(seconds: 1), () {
              Get.dialog(
                PaymentFailedDialog(
                  orderID: widget.orderID,
                  orderAmount: total,
                  maxCodOrderAmount: maximumCodOrderAmount,
                  contactPersonNumber: widget.contactNumber,
                ),
                barrierDismissible: false,
              );
            });
          }
        }

        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 480,
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault + 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault + 4),
                child: orderController.trackModel != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header close button
                          if (ResponsiveHelper.isDesktop(context))
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8, right: 8),
                                child: IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.close, size: 20),
                                  splashRadius: 18,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                          // Scrollable body
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Animated Checkmark / Ripple
                                  _buildAnimatedIcon(success),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  // Heading
                                  Text(
                                    success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  // Copyable Order ID Pill
                                  if (widget.orderID != null) ...[
                                    _buildOrderIdPill(widget.orderID!),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                  ],

                                  // Subtitle description
                                  Text(
                                    success
                                        ? widget.isDeliveryOrder
                                            ? 'your_order_is_placed_successfully'.tr
                                            : 'your_order_is_placed_successfully_dine_in_and_takeaway'.tr
                                        : 'your_order_is_failed_to_place_because'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  // Order Details Quick Strip
                                  if (success && orderController.trackModel != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'total_amount'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions.fontSizeExtraSmall,
                                                  color: Theme.of(context).hintColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                PriceConverter.convertPrice(orderController.trackModel!.orderAmount),
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (orderController.trackModel?.restaurant?.deliveryTime != null)
                                            Row(
                                              children: [
                                                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF10B981)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${orderController.trackModel!.restaurant!.deliveryTime} ${'mins'.tr}',
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions.fontSizeSmall,
                                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  // Dual Action Buttons
                                  Row(
                                    children: [
                                      if (success) ...[
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Get.back();
                                                Get.toNamed(RouteHelper.getOrderDetailsRoute(
                                                  int.parse(widget.orderID.toString()),
                                                  contactNumber: widget.contactNumber,
                                                  fromGuestTrack: !Get.find<AuthController>().isLoggedIn(),
                                                ));
                                              },
                                              icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 16),
                                              label: Text(
                                                'track_order'.tr,
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                      ],
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: OutlinedButton.icon(
                                            onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                                            icon: Icon(Icons.home_outlined, color: Theme.of(context).primaryColor, size: 16),
                                            label: Text(
                                              'back_to_home'.tr,
                                              style: robotoBold.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeLarge),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedIcon(bool success) {
    final baseColor = success ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 68 + (t * 24),
              height: 68 + (t * 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: baseColor.withValues(alpha: (1.0 - t) * 0.35),
                  width: 2,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: success
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            success ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderIdPill(String orderId) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: orderId));
        setState(() => _isCopied = true);
        showCustomSnackBar('${'order_id'.tr} #$orderId ${'copied'.tr}', isError: false);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isCopied = false);
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag_rounded, size: 14, color: Theme.of(context).primaryColor),
            const SizedBox(width: 3),
            Text(
              '${'order_id'.tr}: $orderId',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
              size: 14,
              color: _isCopied ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
