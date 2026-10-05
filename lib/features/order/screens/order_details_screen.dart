import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/offline_success_dialog.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/model/billing_value.dart';
import 'package:stackfood_multivendor/features/order/widgets/bottom_view_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/log_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/billing_summery_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/deliveryman_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/item_info_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/note_collapsible_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/payment_method_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/repeat_order_card.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/restaurant_address_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_status_card.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/cod_to_digital_payment_helper.dart';
import 'package:stackfood_multivendor/helper/map_camera_helper.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:stackfood_multivendor/theme/system_ui_style.dart';

part '../widgets/order_details_info.dart';
part '../widgets/order_details_status.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromOfflinePayment;
  final String? contactNumber;
  final bool fromGuestTrack;
  final bool fromNotification;
  final bool fromDineIn;
  final String? codToDigitalPaymentStatus;
  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.contactNumber, this.fromOfflinePayment = false, this.fromGuestTrack = false, this.fromNotification = false, this.fromDineIn = false, this.codToDigitalPaymentStatus});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();

  GoogleMapController? _mapController;
  Set<Marker> _markers = HashSet<Marker>();
  bool _mapLoading = true;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<bool> _showMapAppBar = ValueNotifier<bool>(false);
  bool _autoCollapseScheduled = false;
  bool _userMovedSheet = false;
  static const double _baseInitialExtent = 0.45;
  static const double _minCollapsedExtent = 0.20;
  static const double _maxCollapsedExtent = 0.55;
  static const double _peekBottomGap = Dimensions.paddingExtraLarge;

  double _collapsedExtent = _minCollapsedExtent;
  double get _initialExtent => math.min(math.max(_baseInitialExtent, _collapsedExtent + 0.12), 0.85);
  double get _appBarRevealExtent => math.max(0.60, _initialExtent + 0.05);

  List<double>? _cachedSnapSizes;
  List<double> get _snapSizes => _cachedSnapSizes ??= <double>[_collapsedExtent, _initialExtent, 0.92];
  bool _peekMeasured = false;
  int _peekMeasureAttempts = 0;
  final GlobalKey _sheetTopKey = GlobalKey();
  final GlobalKey _deliveryManKey = GlobalKey();

  static const double _arrivalMapHeight = 300;
  final ValueNotifier<bool> _showArrivalAppBar = ValueNotifier<bool>(false);

  void _onArrivalScroll() {
    if (!scrollController.hasClients) return;
    _showArrivalAppBar.value = scrollController.offset > _arrivalMapHeight - kToolbarHeight;
  }

  void _onSheetExtent() {
    if (!_sheetController.isAttached) return;
    if (!_userMovedSheet && (_sheetController.size - _initialExtent).abs() > 0.02) {
      _userMovedSheet = true;
    }
    _showMapAppBar.value = _sheetController.size > _appBarRevealExtent;
  }

  void _measurePeekExtent(double maxHeight) {
    if (_peekMeasured || maxHeight <= 0) return;
    final RenderObject? topObject = _sheetTopKey.currentContext?.findRenderObject();
    final RenderObject? peekObject = _deliveryManKey.currentContext?.findRenderObject();
    if (topObject is! RenderBox || peekObject is! RenderBox || !topObject.hasSize || !peekObject.hasSize) {
      if (++_peekMeasureAttempts < 10 && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measurePeekExtent(maxHeight));
      }
      return;
    }

    final double top = topObject.localToGlobal(Offset.zero).dy;
    final double bottom = peekObject.localToGlobal(Offset(0, peekObject.size.height)).dy;
    final double extent = ((bottom - top) + _peekBottomGap) / maxHeight;

    _peekMeasured = true;
    final double clamped = extent.clamp(_minCollapsedExtent, _maxCollapsedExtent);
    if (mounted && (clamped - _collapsedExtent).abs() > 0.005) {
      setState(() {
        _collapsedExtent = clamped;
        _cachedSnapSizes = null;
      });
    }
  }

  void _maybeScheduleAutoCollapse() {
    if (_autoCollapseScheduled) return;
    _autoCollapseScheduled = true;
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted && !_userMovedSheet && _sheetController.isAttached && _sheetController.size > _collapsedExtent) {
        _sheetController.animateTo(_collapsedExtent, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });
  }

  void _loadData() async {
    final OrderController orderController = Get.find<OrderController>();
    orderController.setActiveTrackOrder(widget.orderId.toString());
    await orderController.trackOrder(widget.orderId.toString(), widget.orderModel, false, contactNumber: widget.contactNumber).then((value) {
      if (widget.fromOfflinePayment) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      } else if (widget.fromDineIn) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId, isDineIn: true)));
      }
    });
    orderController.getOrderCancelReasons();
    if (widget.orderModel != null || orderController.trackModel == null) {
      orderController.timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber);
    }
    orderController.getOrderDetails(widget.orderId.toString());
  }

  void _startApiCall({bool immediate = false}) {
    Get.find<OrderController>().startTrackTimer(
      orderId: widget.orderId.toString(), contactNumber: widget.contactNumber, immediate: immediate,
    );
  }

  Future<void> _handleTrackOrder(OrderModel order) async {
    Get.find<OrderController>().cancelTimer();
    await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, widget.contactNumber))?.whenComplete(() => _startApiCall(immediate: true));
  }

  Future<void> _openInExternalMaps(LatLng position) async {
    final String url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=${position.latitude},${position.longitude}&travelmode=driving';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('unable_to_launch_google_map'.tr);
    }
  }

  Future<void> _setMarkers(OrderModel order) async {
    try {
      final results = await Future.wait([
        MarkerHelper.getRestaurantMarker(size: 48),
        MarkerHelper.getDeliveryManMarker(size: 48),
        MarkerHelper.getUserMarker(size: 48),
      ]);
      final BitmapDescriptor storeIcon = results[0];
      final BitmapDescriptor dmIcon = results[1];
      final BitmapDescriptor userIcon = results[2];

      final LatLng? storeLatLng = MapCameraHelper.toLatLng(order.restaurant?.latitude, order.restaurant?.longitude);
      final LatLng? destinationLatLng = MapCameraHelper.toLatLng(order.deliveryAddress?.latitude, order.deliveryAddress?.longitude);
      final LatLng? deliveryManLatLng = MapCameraHelper.toLatLng(order.deliveryMan?.lat, order.deliveryMan?.lng);

      final Set<Marker> markers = HashSet<Marker>();

      if (storeLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('store'),
          position: storeLatLng,
          zIndexInt: 1,
          anchor: const Offset(0.5, 0.5),
          icon: storeIcon,
          infoWindow: InfoWindow(
            title: order.restaurant!.name ?? '',
            onTap: () => _openInExternalMaps(storeLatLng),
          ),
        ));
      }

      if (destinationLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          zIndexInt: 2,
          anchor: const Offset(0.5, 0.5),
          icon: userIcon,
          infoWindow: InfoWindow(
            title: 'your_location'.tr,
            onTap: () => _openInExternalMaps(destinationLatLng),
          ),
        ));
      }

      if (deliveryManLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: deliveryManLatLng,
          zIndexInt: 3,
          anchor: const Offset(0.5, 0.5),
          icon: dmIcon,
          infoWindow: InfoWindow(
            title: 'delivery_man'.tr,
            onTap: () => _openInExternalMaps(deliveryManLatLng),
          ),
        ));
      }

      if (mounted) setState(() { _markers = markers; _mapLoading = false; });

      await MapCameraHelper.fitPoints(
        _mapController,
        [destinationLatLng, deliveryManLatLng, storeLatLng].whereType<LatLng>().toList(),
        padding: 80,
        maxSpanMeters: 40000,
        animate: false,
      );
    } catch (_) {
      if (mounted) setState(() { _mapLoading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCall();
    _sheetController.addListener(_onSheetExtent);
    scrollController.addListener(_onArrivalScroll);
    _showCodToDigitalPaymentResult();
  }

  void _showCodToDigitalPaymentResult() {
    final String? status = widget.codToDigitalPaymentStatus;
    if (status == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CodToDigitalPaymentHelper.handleOutcome(
        isSuccess: status.toLowerCase() == 'success',
        orderId: widget.orderId.toString(), contactNumber: widget.contactNumber,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startApiCall(immediate: true);
    } else if (state == AppLifecycleState.paused) {
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    final orderController = Get.find<OrderController>();
    orderController.cancelTimer();
    if (orderController.activeTrackOrderId == widget.orderId.toString()) {
      orderController.setActiveTrackOrder(null);
    }
    _mapController?.dispose();
    _sheetController.removeListener(_onSheetExtent);
    _sheetController.dispose();
    scrollController.removeListener(_onArrivalScroll);
    scrollController.dispose();
    _showMapAppBar.dispose();
    _showArrivalAppBar.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAppLayout(context);
  }

  void _openLogSheet({required bool isDeliveryLog, required OrderModel order, required double total}) {
    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Theme.of(Get.context!).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: LogBottomSheetWidget(
          isDeliveryLog: isDeliveryLog,
          subscriptionID: order.subscriptionId,
          totalAmount: isDeliveryLog ? total : null,
          orderQuantity: isDeliveryLog ? order.subscription?.quantity : null,
        ),
      ),
    );
  }

  List<Widget> _orderAppBarActions(OrderModel? order, double total) {
    final bool subscription = order?.subscription != null;
    return [
      IconButton(
        onPressed: () => Get.toNamed(RouteHelper.getSupportRoute()),
        icon: CustomAssetImageWidget(Images.support, width: 22, height: 22),
      ),
      if (subscription) ...[
        IconButton(
          onPressed: () => _openLogSheet(isDeliveryLog: false, order: order!, total: total),
          icon: Icon(Icons.pause_rounded, size: 30, color: context.iconBaseDefault),
        ),
        IconButton(
          onPressed: () => _openLogSheet(isDeliveryLog: true, order: order!, total: total),
          icon: Icon(Icons.history_rounded, size: 30, color: context.iconBaseDefault),
        ),
      ],
      const SizedBox(width: Dimensions.paddingSmall),
    ];
  }

  List<Widget> _orderMapActions(OrderModel? order, double total) {
    final bool subscription = order?.subscription != null;
    return [
      _FloatingMapButton(
        image: Images.support,
        onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
      ),
      if (subscription) ...[
        const SizedBox(width: Dimensions.paddingMedium),
        _FloatingMapButton(icon: Icons.pause_rounded, onTap: () => _openLogSheet(isDeliveryLog: false, order: order!, total: total)),
        const SizedBox(width: Dimensions.paddingMedium),
        _FloatingMapButton(icon: Icons.history_rounded, onTap: () => _openLogSheet(isDeliveryLog: true, order: order!, total: total)),
      ],
    ];
  }

  Widget _buildArrivalState(BuildContext context, OrderController orderController, OrderModel order, double total, bool ongoing, BillingValues billing) {
    return Stack(children: [
      Column(children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  height: _arrivalMapHeight,
                  child: Stack(children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.tryParse(order.deliveryAddress?.latitude ?? '') ?? 0.0,
                              double.tryParse(order.deliveryAddress?.longitude ?? '') ?? 0.0,
                            ),
                            zoom: 15,
                          ),
                          markers: _markers,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          zoomGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _setMarkers(order);
                          },
                          style: Get.find<ThemeController>().darkTheme ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                        ),
                      ),
                    ),

                    if (_mapLoading) const Center(child: CircularProgressIndicator()),

                    Positioned(
                      right: Dimensions.paddingDefault,
                      bottom: Dimensions.paddingDefault,
                      child: _FloatingMapButton(
                        icon: Icons.crop_free,
                        onTap: () => _handleTrackOrder(order),
                      ),
                    ),
                  ]),
                ),

                _OrderDetailsStatus(order: order, ongoing: ongoing, total: total, arrivalState: true),
                _OrderDetailsInfo(
                  order: order,
                  total: total,
                  orderDetails: orderController.orderDetails ?? const [],
                  billing: billing,
                ),
              ]),
            ),
          ),
        ),

        _BottomView(
          orderController: orderController, order: order, total: total,
          orderId: widget.orderId, contactNumber: widget.contactNumber,
          showTrackButton: false,
        ),
      ]),

      Positioned.fill(child: _TopOverlay(
        showAppBar: _showArrivalAppBar,
        mapActions: _orderMapActions(order, total),
        appBarActions: _orderAppBarActions(order, total),
      )),
    ]);
  }

  Widget _buildAppLayout(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification || widget.fromOfflinePayment) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        double deliveryCharge = 0;
        double itemsPrice = 0;
        double discount = 0;
        double couponDiscount = 0;
        double tax = 0;
        double addOns = 0;
        double dmTips = 0;
        double additionalCharge = 0;
        double extraPackagingCharge = 0;
        double referrerBonusAmount = 0;
        double deliveryTypeCharge = 0;
        OrderModel? order = orderController.trackModel;
        bool taxIncluded = false;
        bool ongoing = false;

        if (orderController.orderDetails != null && order != null) {
          if (order.orderType == 'delivery') {
            deliveryCharge = order.deliveryCharge ?? 0;
            dmTips = order.dmTips ?? 0;
          }
          couponDiscount = order.couponDiscountAmount ?? 0;
          discount = order.restaurantDiscountAmount ?? 0;
          tax = order.totalTaxAmount ?? 0;
          taxIncluded = order.taxStatus ?? false;
          additionalCharge = order.additionalCharge ?? 0;
          extraPackagingCharge = order.extraPackagingAmount ?? 0;
          referrerBonusAmount = order.referrerBonusAmount ?? 0;
          if ((order.deliveryType == 'slightly_delay' || order.deliveryType == 'express') && order.deliveryTypeCharge != null) {
            deliveryTypeCharge = order.deliveryType == 'slightly_delay' ? -order.deliveryTypeCharge! : order.deliveryTypeCharge!;
          }
          for (OrderDetailsModel orderDetails in orderController.orderDetails!) {
            if (orderDetails.isBogoBundle) {
              itemsPrice = itemsPrice + (orderDetails.bogoDetails?.totalPrice ?? 0);
              continue;
            }
            for (AddOn addOn in orderDetails.addOns!) { addOns = addOns + (addOn.price! * addOn.quantity!); }
            itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
          }

          ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested'
              && order.orderStatus != 'refunded' && order.orderStatus != 'refund_request_canceled');
        }

        final double subTotal = itemsPrice + addOns;
        final double proDiscount = (order?.benefitType == ProBenefitType.discount ? order?.proDiscount ?? 0 : 0).toDouble();
        final double finalDeliveryCharge = order?.benefitType == ProBenefitType.deliveryFee
            ? (deliveryCharge + (order?.deliveryFeeReductionAmount ?? 0))
            : deliveryCharge;
        final double total = itemsPrice + addOns - discount + (taxIncluded ? 0 : tax) + finalDeliveryCharge + deliveryTypeCharge - couponDiscount + dmTips + additionalCharge + extraPackagingCharge - referrerBonusAmount - proDiscount - (order?.benefitType == ProBenefitType.deliveryFee ? (order?.deliveryFeeReductionAmount ?? 0) : 0);

        final bool isReady = orderController.orderDetails != null && order != null && orderController.trackModel != null;

        final billing = BillingValues(
          itemsPrice: itemsPrice, addOns: addOns, subTotal: subTotal, discount: discount, couponDiscount: couponDiscount,
          referrerBonusAmount: referrerBonusAmount, additionalCharge: additionalCharge, tax: tax, taxIncluded: taxIncluded,
          dmTips: dmTips, extraPackagingCharge: extraPackagingCharge, deliveryCharge: deliveryCharge, deliveryTypeCharge: deliveryTypeCharge, total: total,
        );

        final bool showArrivalState = orderController.showArrivalState(order);
        final bool showMap = orderController.showDeliveryMap(order) && !showArrivalState;

        return Scaffold(
          backgroundColor: context.surface,
          appBar: (showMap || showArrivalState) ? null : CustomAppBarWidget(
            centerTitle: false,
            title: 'order_details'.tr,
            actions: _orderAppBarActions(order, total),
          ),

          body: SafeArea(
            top: !showMap && !showArrivalState,
            child: !isReady
                ? const Center(child: CircularProgressIndicator())
                : showArrivalState ? _buildArrivalState(context, orderController, order, total, ongoing, billing)
                : showMap ? Builder(builder: (context) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: systemUiOverlayStyleOf(context, statusBarColor: Colors.transparent),
                child: LayoutBuilder(builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _measurePeekExtent(constraints.maxHeight);
                    _maybeScheduleAutoCollapse();
                  });
                  return Stack(children: [
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            double.tryParse(order.deliveryAddress?.latitude ?? '') ?? 0.0,
                            double.tryParse(order.deliveryAddress?.longitude ?? '') ?? 0.0,
                          ),
                          zoom: 15,
                        ),
                        markers: _markers,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _setMarkers(order);
                        },
                        style: Get.find<ThemeController>().darkTheme
                            ? Get.find<ThemeController>().darkMap
                            : Get.find<ThemeController>().lightMap,
                      ),
                    ),

                    if (_mapLoading) const Center(child: CircularProgressIndicator()),

                    Positioned(
                      right: Dimensions.paddingDefault,
                      bottom: _collapsedExtent * constraints.maxHeight + Dimensions.paddingSmall,
                      child: _FloatingMapButton(
                        icon: Icons.crop_free,
                        onTap: () => _handleTrackOrder(order),
                      ),
                    ),

                    Positioned.fill(child: DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: _initialExtent,
                      minChildSize: _collapsedExtent,
                      maxChildSize: 1,
                      snap: true,
                      snapSizes: _snapSizes,
                      builder: (ctx, sheetScrollController) => CustomScrollView(
                        controller: sheetScrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: KeyedSubtree(
                            key: _sheetTopKey,
                            child: _OrderDetailsStatus(order: order, ongoing: ongoing, floating: true, total: total),
                          )),
                          const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSmall)),
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: Dimensions.paddingSmall, bottom: Dimensions.padding2xSmall),
                                    width: 40, height: 4,
                                    decoration: BoxDecoration(
                                      color: context.bgNeutralMedium,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  _OrderDetailsInfo(
                                    order: order,
                                    total: total,
                                    orderDetails: orderController.orderDetails ?? const [],
                                    billing: billing,
                                    isDragable: true,
                                    deliveryManKey: _deliveryManKey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _BottomView(
                              orderController: orderController, order: order, total: total,
                              orderId: widget.orderId, contactNumber: widget.contactNumber,
                              showTrackButton: false,
                            ),
                          ),
                        ],
                      ),
                    )),

                    Positioned.fill(child: _TopOverlay(
                      showAppBar: _showMapAppBar,
                      mapActions: _orderMapActions(order, total),
                      appBarActions: _orderAppBarActions(order, total),
                    )),
                  ]);
                }),
              );
            }) : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).canvasColor.withValues(alpha: 3), context.surfaceContainer],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            Container(height: 2, color: context.surface),
                            _OrderDetailsStatus(order: order, ongoing: ongoing, total: total),
                            _OrderDetailsInfo(
                              order: order,
                              total: total,
                              orderDetails: orderController.orderDetails ?? const [],
                              billing: billing,
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
                _BottomView(
                  orderController: orderController, order: order, total: total,
                  orderId: widget.orderId, contactNumber: widget.contactNumber,
                  showTrackButton: false,
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  final ValueListenable<bool> showAppBar;
  final List<Widget> mapActions;
  final List<Widget> appBarActions;

  const _TopOverlay({required this.showAppBar, required this.mapActions, required this.appBarActions});

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder<bool>(
      valueListenable: showAppBar,
      builder: (context, show, _) => Stack(children: [

        Positioned(
          top: topInset + Dimensions.paddingSmall,
          left: Dimensions.paddingDefault,
          right: Dimensions.paddingDefault,
          child: IgnorePointer(
            ignoring: show,
            child: AnimatedOpacity(
              opacity: show ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _FloatingMapButton(
                  icon: Get.find<LocalizationController>().isLtr ? Icons.arrow_back : Icons.arrow_forward,
                  onTap: () => Get.back(),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: mapActions),
              ]),
            ),
          ),
        ),

        Positioned(
          top: 0, left: 0, right: 0,
          child: IgnorePointer(
            ignoring: !show,
            child: AnimatedSlide(
              offset: show ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: SizedBox(
                  height: topInset + kToolbarHeight,
                  child: CustomAppBarWidget(
                    centerTitle: false,
                    title: 'order_details'.tr,
                    actions: appBarActions,
                  ),
                ),
              ),
            ),
          ),
        ),

      ]),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final VoidCallback? onTap;

  const _FloatingMapButton({this.icon, this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Dimensions.radiusMedium);
    return Material(
      color: context.surfaceContainer,
      borderRadius: radius,
      elevation: 3,
      shadowColor: context.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: 36, height: 36,
          child: image != null
              ? Padding(padding: const EdgeInsets.all(11), child: CustomAssetImageWidget(image!))
              : Icon(icon, size: 22, color: context.iconBaseDefault),
        ),
      ),
    );
  }
}
