import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/celebration_particles.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int status;
  final double? totalAmount;
  final String? contactPersonNumber;
  final bool isDeliveryOrder;
  final double? proDiscount;

  const OrderSuccessfulScreen({
    super.key,
    required this.orderID,
    required this.status,
    required this.totalAmount,
    this.contactPersonNumber,
    this.isDeliveryOrder = false,
    this.proDiscount,
  });

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> with TickerProviderStateMixin {
  String? orderId;
  final ScrollController scrollController = ScrollController();
  bool _isCopied = false;

  late AnimationController _celebrationController;
  late AnimationController _pulseController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID;
    if (widget.orderID != null && widget.orderID!.contains('?')) {
      var parts = widget.orderID!.split('?');
      orderId = parts[0].trim();
    }
    Get.find<OrderController>().trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber);

    // Setup celebration animations
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _checkScaleAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    );

    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _pulseController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<OrderController>(builder: (orderController) {
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
                  orderID: orderId,
                  orderAmount: widget.totalAmount,
                  maxCodOrderAmount: maximumCodOrderAmount,
                  contactPersonNumber: widget.contactPersonNumber,
                ),
                barrierDismissible: false,
              );
            });
          }
        }

        return orderController.trackModel != null
            ? SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: FooterViewWidget(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Celebratory Confetti Particle Burst
                          if (success)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: CelebrationParticles(
                                animation: _celebrationController,
                                size: const Size(double.infinity, 420),
                              ),
                            ),

                          // Main Content Container
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                // Animated Hero Icon with Radiant Glow
                                _buildAnimatedHeroIcon(success),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // Title
                                Text(
                                  success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge + 3,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),

                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Text(
                                    success
                                        ? widget.isDeliveryOrder
                                            ? 'your_order_is_placed_successfully'.tr
                                            : 'your_order_is_placed_successfully_dine_in_and_takeaway'.tr
                                        : 'your_order_is_failed_to_place_because'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall + 1,
                                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // Order ID & Live Placed Time Pill Row
                                if (orderId != null && orderId!.isNotEmpty) ...[
                                  _buildOrderIdAndTimestampRow(orderId!, orderController),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                ],

                                // Smooth Content Section (Fade + Slide)
                                FadeTransition(
                                  opacity: _contentFadeAnimation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(_contentFadeAnimation),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 550),
                                      child: Column(
                                        children: [
                                          // 1. Live Order 4-Stage Stepper
                                          if (success) ...[
                                            _buildLiveOrderJourneyStepper(orderController),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                          ],

                                          // 2. Estimated Delivery & Route Hero Card
                                          if (success) ...[
                                            _buildDeliveryEstimateCard(orderController),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                          ],

                                          // 3. Order Details & Receipt Card
                                          _buildOrderSummaryCard(orderController),
                                          const SizedBox(height: Dimensions.paddingSizeDefault),

                                          // 4. Loyalty Points Earned Card
                                          if (Get.find<AuthController>().isLoggedIn() &&
                                              success &&
                                              (Get.find<SplashController>().configModel?.loyaltyPointStatus ?? false) &&
                                              total.floor() > 0) ...[
                                            _buildLoyaltyPointsCard(total),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                          ],

                                          const SizedBox(height: Dimensions.paddingSizeSmall),

                                          // 5. Action Buttons (Track Order Live & Back to Home)
                                          _buildActionButtons(success),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
                ),
              );
      }),
    );
  }

  Widget _buildAnimatedHeroIcon(bool success) {
    return SizedBox(
      width: 148,
      height: 148,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final t1 = _pulseController.value;
          final t2 = (_pulseController.value + 0.5) % 1.0;
          final baseColor = success ? const Color(0xFF10B981) : const Color(0xFFEF4444);

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer radiant ripple ring
              Container(
                width: 96 + (t1 * 46),
                height: 96 + (t1 * 46),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withValues(alpha: (1.0 - t1) * 0.35),
                    width: 2.5,
                  ),
                ),
              ),
              // Inner radiant ripple ring
              Container(
                width: 86 + (t2 * 32),
                height: 86 + (t2 * 32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withValues(alpha: (1.0 - t2) * 0.45),
                    width: 2.0,
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: ScaleTransition(
          scale: _checkScaleAnimation,
          child: Container(
            width: 92,
            height: 92,
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
                  color: (success ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.38),
                  blurRadius: 28,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                success ? Icons.check_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderIdAndTimestampRow(String orderId, OrderController orderController) {
    String orderTime = 'just_now'.tr;
    if (orderController.trackModel?.createdAt != null) {
      try {
        orderTime = DateConverter.dateTimeStringToFormattedTime(orderController.trackModel!.createdAt!);
      } catch (_) {
        orderTime = 'just_now'.tr;
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        // Copyable Order ID Pill
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: orderId));
            setState(() => _isCopied = true);
            showCustomSnackBar('${'order_id'.tr} #$orderId ${'copied'.tr}', isError: false);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isCopied = false);
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag_rounded, size: 15, color: Theme.of(context).primaryColor),
                const SizedBox(width: 4),
                Text(
                  '${'order_id'.tr}: #$orderId',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                    key: ValueKey<bool>(_isCopied),
                    size: 15,
                    color: _isCopied ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Placed Timestamp Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.75),
              ),
              const SizedBox(width: 5),
              Text(
                orderTime,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Visual 4-Stage Live Progression Stepper
  Widget _buildLiveOrderJourneyStepper(OrderController orderController) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.18 : 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withValues(alpha: 0.4 + (_pulseController.value * 0.6)),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFF10B981), blurRadius: 4),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Order Status',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'CONFIRMED',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // 4-Step Stepper Line
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepItem(
                stepIndex: 1,
                title: 'Order Placed',
                icon: Icons.check_rounded,
                isCompleted: true,
                isActive: false,
              ),
              _buildStepConnector(isPassed: true),
              _buildStepItem(
                stepIndex: 2,
                title: 'Preparing',
                icon: Icons.restaurant_rounded,
                isCompleted: false,
                isActive: true,
              ),
              _buildStepConnector(isPassed: false),
              _buildStepItem(
                stepIndex: 3,
                title: 'On The Way',
                icon: Icons.moped_rounded,
                isCompleted: false,
                isActive: false,
              ),
              _buildStepConnector(isPassed: false),
              _buildStepItem(
                stepIndex: 4,
                title: 'Delivered',
                icon: Icons.home_rounded,
                isCompleted: false,
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepIndex,
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryTextColor = (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.70);
    final color = isCompleted
        ? const Color(0xFF10B981)
        : isActive
            ? primaryColor
            : secondaryTextColor.withValues(alpha: 0.35);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : isActive
                      ? primaryColor.withValues(alpha: 0.15)
                      : Theme.of(context).cardColor,
              border: Border.all(
                color: color,
                width: isActive ? 2.0 : 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 16,
                color: isCompleted
                    ? Colors.white
                    : isActive
                        ? primaryColor
                        : secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: (isActive ? robotoBold : robotoMedium).copyWith(
              fontSize: 10.5,
              color: isActive
                  ? primaryColor
                  : isCompleted
                      ? const Color(0xFF10B981)
                      : secondaryTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isPassed}) {
    return Container(
      width: 20,
      margin: const EdgeInsets.only(top: 15),
      height: 2,
      color: isPassed
          ? const Color(0xFF10B981)
          : (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.18),
    );
  }

  Widget _buildDeliveryEstimateCard(OrderController orderController) {
    final restaurant = orderController.trackModel?.restaurant;
    final deliveryAddress = orderController.trackModel?.deliveryAddress?.address;
    final rawDeliveryTime = (restaurant?.deliveryTime != null && restaurant!.deliveryTime!.trim().isNotEmpty)
        ? restaurant.deliveryTime!
        : '25 - 35';
    final cleanDeliveryTime = rawDeliveryTime
        .replaceAll(RegExp(r'mins?', caseSensitive: false), '')
        .replaceAll('-', ' - ')
        .trim();
    final restaurantName = (restaurant?.name ?? '').replaceAll(r"\'", "'");
    final secondaryTextColor = (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.moped_rounded, color: Color(0xFF10B981), size: 28),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.isDeliveryOrder ? 'estimated_delivery_time'.tr : 'estimated_pickup_time'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ON TIME',
                            style: robotoBold.copyWith(fontSize: 9, color: const Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$cleanDeliveryTime ${'mins'.tr}',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge + 1,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Mini route visual row
          if (restaurantName.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront_rounded, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      restaurantName,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Text('• • 🛵 • •', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                  Icon(Icons.home_rounded, size: 16, color: const Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      deliveryAddress ?? 'home'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderController orderController) {
    final trackModel = orderController.trackModel!;
    final restaurant = trackModel.restaurant;
    final deliveryAddress = trackModel.deliveryAddress?.address;
    final paymentMethod = trackModel.paymentMethod != null
        ? trackModel.paymentMethod!.replaceAll('_', ' ').capitalizeFirst ?? ''
        : 'Digital Payment';
    final summaryRestName = (restaurant?.name ?? '').replaceAll(r"\'", "'");
    final summarySecondaryColor = (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF5A626A)).withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.18 : 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'order_summary'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault + 1,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trackModel.orderType == 'dine_in'
                      ? Colors.purple.withValues(alpha: 0.14)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trackModel.orderType == 'take_away'
                      ? 'take_away'.tr
                      : trackModel.orderType == 'dine_in'
                          ? 'dine_in'.tr
                          : 'delivery'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: trackModel.orderType == 'dine_in'
                        ? Colors.purple[700]
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Restaurant info
          if (restaurant != null) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    image: '${restaurant.logoFullUrl}',
                    height: 46,
                    width: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summaryRestName,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (deliveryAddress != null && deliveryAddress.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13, color: Theme.of(context).hintColor),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                deliveryAddress,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: summarySecondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else if (restaurant.address != null)
                        Text(
                          restaurant.address!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: summarySecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],

          // Payment method row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'payment_method'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
                ),
              ),
              Row(
                children: [
                  Text(
                    paymentMethod,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (trackModel.paymentStatus == 'paid' || trackModel.paymentMethod == 'cash_on_delivery')
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (trackModel.paymentStatus == 'paid')
                          ? 'paid'.tr
                          : (trackModel.paymentMethod == 'cash_on_delivery' ? 'COD' : 'pending'.tr),
                      style: robotoMedium.copyWith(
                        fontSize: 10,
                        color: (trackModel.paymentStatus == 'paid' || trackModel.paymentMethod == 'cash_on_delivery')
                            ? const Color(0xFF10B981)
                            : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Pro Discount Row if applicable
          if (widget.proDiscount != null && widget.proDiscount! > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 15, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'pro_discount'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '- ${PriceConverter.convertPrice(widget.proDiscount)}',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: Dimensions.paddingSizeSmall),
          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Total amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault + 1,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                PriceConverter.convertPrice(trackModel.orderAmount ?? widget.totalAmount),
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyPointsCard(double points) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.12),
            Theme.of(context).primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox,
            width: 44,
            height: 44,
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'congratulations'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${'you_have_earned'.tr} ${points.floor().toString()} ${'points_it_will_add_to'.tr}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool success) {
    final isGuest = !Get.find<AuthController>().isLoggedIn();

    return Column(
      children: [
        if (success) ...[
          // Primary Glow Live Track Order CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.offNamed(RouteHelper.getOrderDetailsRoute(
                  int.parse(orderId.toString()),
                  contactNumber: widget.contactPersonNumber,
                  fromGuestTrack: isGuest,
                ));
              },
              icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
              label: Text(
                'track_order'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault + 1,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 3,
                shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Secondary Back to Home Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
              icon: Icon(Icons.home_outlined, color: Theme.of(context).primaryColor, size: 20),
              label: Text(
                'back_to_home'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ] else ...[
          // For failed order, primary Back to Home
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
              label: Text(
                'back_to_home'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
