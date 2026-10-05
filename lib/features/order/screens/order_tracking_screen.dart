import 'dart:collection';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/dine_in_restaurants_card_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/map_action_button_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_status_card.dart';
import 'package:stackfood_multivendor/features/order/widgets/track_details_view.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/map_camera_helper.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/road_routing_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  Set<Circle> _circles = HashSet<Circle>();

  BitmapDescriptor? _restaurantIcon;
  BitmapDescriptor? _deliveryManIcon;
  BitmapDescriptor? _destinationIcon;

  bool _followMarkers = true;
  bool _programmaticMove = false;
  DateTime _lastProgrammaticMove = DateTime.fromMillisecondsSinceEpoch(0);

  // Live Tracking Animation State
  AnimationController? _movementController;
  AnimationController? _routePulseController;
  AnimationController? _breathingController;

  LatLng? _prevRiderLatLng;
  LatLng? _currentRiderLatLng;
  LatLng? _targetRiderLatLng;
  double _prevBearing = 0.0;
  double _currentBearing = 0.0;
  double _targetBearing = 0.0;
  bool _isStationary = true;
  int _lastPulseTickMs = 0;

  // Road Route State
  List<LatLng> _fullRoadPoints = [];
  String? _currentRouteKey;
  bool _isFetchingRoute = false;
  OrderModel? _lastTrackModel;

  static const Color _baedalBlue = Color(0xFF29A9E8);
  static const Color _baedalGlow = Color(0x3829A9E8);
  static const Color _baedalPulse = Color(0xFFEAF7FF);

  static const double _sheetHeight = 170;
  static const double _markerEdgeGap = 50;
  static const double _maxFitSpanMeters = 40000;
  static const Duration _programmaticMoveGrace = Duration(milliseconds: 1200);

  void _loadData() async {
    try {
      await Future.wait([
        Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
          double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
          double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
        )),
        Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber),
      ]);
    } catch (_) {
    }
    if(!mounted) return;
    _refreshMarkers();
    _timerTrackOrder(immediate: Get.find<OrderController>().trackModel == null);
  }

  AddressModel? _destinationAddress(OrderModel? track) {
    if(track?.orderType != 'take_away' || Get.find<LocationController>().position.latitude == 0) {
      return track?.deliveryAddress;
    }
    return AddressModel(
      latitude: Get.find<LocationController>().position.latitude.toString(),
      longitude: Get.find<LocationController>().position.longitude.toString(),
      address: Get.find<LocationController>().address,
    );
  }

  void _refreshMarkers() {
    final OrderModel? track = Get.find<OrderController>().trackModel;
    if(!mounted || track == null) return;
    drawMarkers(track, fitCamera: _followMarkers);
  }

  void _timerTrackOrder({bool immediate = true}){
    final OrderController orderController = Get.find<OrderController>();
    if(orderController.trackModel?.orderStatus != 'delivered' && orderController.trackModel?.orderStatus != 'failed' && orderController.trackModel?.orderStatus != 'canceled') {
      orderController.startTrackTimer(
        orderId: widget.orderID.toString(), contactNumber: widget.contactNumber, immediate: immediate,
        onTick: _refreshMarkers,
      );
    }else{
      orderController.cancelTimer();
      orderController.timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _movementController!.addListener(_onMovementTick);
    _movementController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isStationary = true;
      }
    });

    _routePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _routePulseController!.addListener(_onRoutePulseTick);
    _routePulseController!.repeat();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _breathingController!.addListener(_onBreathingTick);
    _breathingController!.repeat(reverse: true);

    Get.find<OrderController>().clearStaleTrackModel(widget.orderID);
    _loadData();
  }

  void _onMovementTick() {
    if (_prevRiderLatLng != null && _targetRiderLatLng != null) {
      final double t = CurvedAnimation(parent: _movementController!, curve: Curves.easeInOut).value;
      _currentRiderLatLng = RoadRoutingHelper.interpolate(_prevRiderLatLng!, _targetRiderLatLng!, t);
      _currentBearing = RoadRoutingHelper.interpolateAngle(_prevBearing, _targetBearing, t);

      _updateRiderMarkerAndRoute();
    }
  }

  void _onRoutePulseTick() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPulseTickMs < 35) return; // ~30 fps cadence for polyline channel efficiency
    _lastPulseTickMs = now;
    if (mounted && _fullRoadPoints.isNotEmpty) {
      _updateRoadPolylines();
      setState(() {});
    }
  }

  void _onBreathingTick() {
    if (!mounted) return;
    if (_isStationary && _currentRiderLatLng != null) {
      final double breath = _breathingController?.value ?? 0.0;
      final Set<Circle> newCircles = {
        Circle(
          circleId: const CircleId('rider_stationary_aura'),
          center: _currentRiderLatLng!,
          radius: 12.0 + (breath * 10.0),
          fillColor: Color.fromRGBO(41, 169, 232, 0.08 + (breath * 0.10)),
          strokeColor: const Color.fromRGBO(41, 169, 232, 0.28),
          strokeWidth: 1,
          zIndex: 1,
        ),
      };
      setState(() {
        _circles = newCircles;
      });
    } else if (!_isStationary && _circles.isNotEmpty) {
      setState(() {
        _circles = HashSet<Circle>();
      });
    }
  }

  void _updateRiderMarkerAndRoute() {
    if (!mounted || _lastTrackModel == null || _currentRiderLatLng == null) return;

    final DeliveryMan? deliveryMan = _lastTrackModel!.deliveryMan;
    if (deliveryMan == null || _deliveryManIcon == null) return;

    // Update rider marker with animated position and rotation
    final Set<Marker> updatedMarkers = Set<Marker>.from(_markers);
    updatedMarkers.removeWhere((m) => m.markerId.value == 'delivery_boy');

    updatedMarkers.add(Marker(
      markerId: const MarkerId('delivery_boy'),
      position: _currentRiderLatLng!,
      zIndexInt: 5,
      rotation: _currentBearing,
      anchor: const Offset(0.5, 0.5), // Center anchor for proper top-view vehicle rotation
      flat: true,
      infoWindow: InfoWindow(
        title: 'delivery_man'.tr,
        snippet: deliveryMan.location,
        onTap: () => _openInExternalMaps(_currentRiderLatLng!),
      ),
      icon: _deliveryManIcon!,
    ));

    // Update remaining road polyline
    _updateRoadPolylines();

    setState(() {
      _markers = updatedMarkers;
    });
  }

  void _updateRoadPolylines() {
    if (_fullRoadPoints.isEmpty) {
      _polylines = HashSet<Polyline>();
      return;
    }

    // 1. Ambient outer Baedal blue glow along entire road route
    final Set<Polyline> newPolylines = {
      Polyline(
        polylineId: const PolylineId('road_route_glow'),
        points: _fullRoadPoints,
        color: _baedalGlow,
        width: 11,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 1,
      ),
      // 2. Smooth continuous solid Baedal blue route
      Polyline(
        polylineId: const PolylineId('road_route_core'),
        points: _fullRoadPoints,
        color: _baedalBlue,
        width: 6,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        zIndex: 2,
      ),
    };

    // 3. Subtle traveling pulse moving along remaining route from rider to destination
    final List<LatLng> activePoints = _currentRiderLatLng != null
        ? RoadRoutingHelper.trimRemainingRoute(_fullRoadPoints, _currentRiderLatLng!)
        : _fullRoadPoints;

    if (activePoints.length >= 2) {
      final double progress = _routePulseController?.value ?? 0.0;
      final List<LatLng> pulseSegment = RoadRoutingHelper.getPulseSegment(
        activePoints,
        progress,
        pulseLengthMeters: 75.0,
      );

      if (pulseSegment.length >= 2) {
        newPolylines.add(Polyline(
          polylineId: const PolylineId('road_route_pulse'),
          points: pulseSegment,
          color: _baedalPulse,
          width: 7,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 3,
        ));
      }
    }

    _polylines = newPolylines;
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerTrackOrder();
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    _movementController?.dispose();
    _routePulseController?.dispose();
    _breathingController?.dispose();
    _controller?.dispose();
    if(!Get.currentRoute.contains(RouteHelper.orderDetails)) {
      Get.find<OrderController>().cancelTimer();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _deliveryManUnassigned(OrderModel track) => track.orderType != 'take_away' && track.orderType != 'dine_in' && track.deliveryMan == null;

  bool _isOngoingOrder(OrderModel track) {
    return track.orderStatus != 'delivered' && track.orderStatus != 'failed' && track.orderStatus != 'canceled'
        && track.orderStatus != 'refund_requested' && track.orderStatus != 'refunded' && track.orderStatus != 'refund_request_canceled';
  }

  List<Widget> _mapLayers(OrderModel track, double bottomInset) {
    return [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: MapCameraHelper.toLatLng(track.deliveryAddress?.latitude, track.deliveryAddress?.longitude) ?? const LatLng(0, 0),
          zoom: 15,
        ),
        minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        markers: _markers,
        polylines: _polylines,
        circles: _circles,
        mapType: MapType.normal,
        padding: const EdgeInsets.only(bottom: _sheetHeight),
        onCameraMoveStarted: _onCameraMoveStarted,
        onCameraIdle: () => _programmaticMove = false,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) {
              drawMarkers(track, fitCamera: _followMarkers);
            }
          });
        },
        style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
      ),

      _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

      Positioned(
        right: 10, bottom: bottomInset,
        child: Column(children: [
          MapActionButtonWidget(icon: Icons.center_focus_strong_outlined, onTap: () {
            _followMarkers = true;
            drawMarkers(track, fitCamera: true);
          }),
          const SizedBox(height: Dimensions.paddingSmall),

          MapActionButtonWidget(icon: Icons.my_location_outlined, onTap: () => _checkPermission(() async {
            _followMarkers = false;
            _markProgrammaticMove();
            await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
            if(mounted) {
              drawMarkers(track);
            }
          })),
        ]),
      ),
    ];
  }

  Widget _trackingBody(OrderController orderController, OrderModel track, double bottomInset) {
    if(_deliveryManUnassigned(track)) {
      return Stack(children: [
        ..._mapLayers(track, bottomInset),

        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingExtraSmall, right: Dimensions.paddingExtraSmall, bottom: Dimensions.paddingSmall),
            child: OrderStatusCard(order: track, ongoing: _isOngoingOrder(track), total: track.orderAmount ?? 0, floating: true),
          ),
        ),
      ]);
    }

    return ExpandableBottomSheet(
      background: Stack(children: _mapLayers(track, bottomInset)),
      persistentContentHeight: 170,
      expandableContent: track.orderType == 'dine_in' ? DineInRestaurantsCardWidget(restaurant: track.restaurant!) : Padding(
        padding: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
        child: TrackDetailsView(track: track, callback: () async {
          bool takeAway = track.orderType == 'take_away';
          orderController.cancelTimer();
          await Get.toNamed(RouteHelper.getChatRoute(
            notificationBody: takeAway ? NotificationBodyModel(restaurantId: track.restaurant!.id, orderId: int.parse(widget.orderID!))
                : NotificationBodyModel(deliverymanId: track.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
            user: User(
              id: takeAway ? track.restaurant!.id : track.deliveryMan!.id,
              fName: takeAway ? track.restaurant!.name : track.deliveryMan!.fName,
              lName: takeAway ? '' : track.deliveryMan!.lName,
              imageFullUrl: takeAway ? track.restaurant!.logoFullUrl : track.deliveryMan!.imageFullUrl,
            ),
          ));
          _timerTrackOrder();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = ResponsiveHelper.isDesktop(context) ? 210 : 180;

    return Scaffold(
      appBar: CustomAppBarWidget(title: '${'order'.tr}' ' #' '${widget.orderID.toString()}'),
      body: GetBuilder<OrderController>(builder: (orderController) {
        final OrderModel? track = orderController.trackModel;

        return track != null ? Center(child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: _trackingBody(orderController, track, bottomInset),
        )) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void _onCameraMoveStarted() {
    if(_programmaticMove && DateTime.now().difference(_lastProgrammaticMove) < _programmaticMoveGrace) return;
    _programmaticMove = false;
    _followMarkers = false;
  }

  void _markProgrammaticMove() {
    _programmaticMove = true;
    _lastProgrammaticMove = DateTime.now();
  }

  Future<void> _openInExternalMaps(LatLng position) async {
    final String url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=${position.latitude},${position.longitude}&travelmode=driving';
    if(await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('unable_to_launch_google_map'.tr);
    }
  }

  Future<void> _ensureIcons() async {
    if(_restaurantIcon != null && _deliveryManIcon != null && _destinationIcon != null) return;
    final List<BitmapDescriptor> icons = await Future.wait([
      MarkerHelper.getRestaurantMarker(size: 44),
      MarkerHelper.getDeliveryManMarker(size: 44),
      MarkerHelper.getUserMarker(size: 44),
    ]);
    _restaurantIcon = icons[0];
    _deliveryManIcon = icons[1];
    _destinationIcon = icons[2];
  }

  Future<void> _fetchRoadRouteIfNeeded(LatLng origin, LatLng destination) async {
    final String routeKey = '${origin.latitude.toStringAsFixed(3)},${origin.longitude.toStringAsFixed(3)}->'
        '${destination.latitude.toStringAsFixed(3)},${destination.longitude.toStringAsFixed(3)}';

    if (_currentRouteKey == routeKey || _isFetchingRoute) return;

    _isFetchingRoute = true;
    _currentRouteKey = routeKey;

    try {
      final List<LatLng> points = await RoadRoutingHelper.getRoadPolyline(origin, destination);
      if (mounted && points.isNotEmpty) {
        _fullRoadPoints = points;
        _updateRoadPolylines();
        setState(() {});
      }
    } catch (_) {
    } finally {
      _isFetchingRoute = false;
    }
  }

  Future<void> drawMarkers(OrderModel track, {bool fitCamera = false}) async {
    _lastTrackModel = track;
    final Restaurant? restaurant = track.restaurant;
    final DeliveryMan? deliveryMan = track.deliveryMan;
    final AddressModel? addressModel = _destinationAddress(track);

    final LatLng? restaurantLatLng = MapCameraHelper.toLatLng(restaurant?.latitude, restaurant?.longitude);
    final LatLng? deliveryManLatLng = MapCameraHelper.toLatLng(deliveryMan?.lat, deliveryMan?.lng);
    final LatLng? destinationLatLng = MapCameraHelper.toLatLng(addressModel?.latitude, addressModel?.longitude);

    final Set<Marker> markers = HashSet<Marker>();

    try {
      await _ensureIcons();

      // 1. Restaurant Pin (Clean Dark Navy Circle with Cutlery and Blue Glow)
      if(restaurantLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('restaurant'),
          position: restaurantLatLng,
          zIndexInt: 1,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: 'restaurant'.tr, snippet: restaurant!.address,
            onTap: () => _openInExternalMaps(restaurantLatLng),
          ),
          icon: _restaurantIcon!,
        ));
      }

      // 2. Destination Pin (Clean White Circle with Blue Home Icon & Ring)
      if(destinationLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          zIndexInt: 2,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: track.orderType == 'take_away' ? 'your_location'.tr : 'delivery_address'.tr,
            snippet: addressModel!.address,
            onTap: () => _openInExternalMaps(destinationLatLng),
          ),
          icon: _destinationIcon!,
        ));
      }

      // 3. Delivery Rider Pin (3D Baedal Blue Scooter Rider with smooth movement & bearing)
      if(deliveryManLatLng != null) {
        if (_currentRiderLatLng == null) {
          // First location update
          _currentRiderLatLng = deliveryManLatLng;
          _targetRiderLatLng = deliveryManLatLng;
          _isStationary = true;
          if (destinationLatLng != null) {
            _currentBearing = RoadRoutingHelper.calculateBearing(deliveryManLatLng, destinationLatLng);
            _targetBearing = _currentBearing;
          }
        } else if (RoadRoutingHelper.distanceBetween(_currentRiderLatLng!, deliveryManLatLng) > 2.0) {
          // Rider moved: trigger smooth animation
          _isStationary = false;
          _prevRiderLatLng = _currentRiderLatLng;
          _targetRiderLatLng = deliveryManLatLng;
          _prevBearing = _currentBearing;
          _targetBearing = RoadRoutingHelper.calculateBearing(_prevRiderLatLng!, _targetRiderLatLng!);

          _movementController?.forward(from: 0.0);
        } else {
          _isStationary = true;
        }

        markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: _currentRiderLatLng ?? deliveryManLatLng,
          zIndexInt: 5,
          rotation: _currentBearing,
          anchor: const Offset(0.5, 0.5), // Center anchor for rotating top-view vehicle
          flat: true,
          infoWindow: InfoWindow(
            title: 'delivery_man'.tr, snippet: deliveryMan!.location,
            onTap: () => _openInExternalMaps(deliveryManLatLng),
          ),
          icon: _deliveryManIcon!,
        ));
      }

      // 4. Fetch Real Road-Following Polyline (Connecting Restaurant -> Delivery Rider -> Customer Home)
      final LatLng? routeOrigin = restaurantLatLng ?? deliveryManLatLng;
      if (routeOrigin != null && destinationLatLng != null) {
        _fetchRoadRouteIfNeeded(routeOrigin, destinationLatLng);
      }
    } catch(_) {}

    if(!mounted) return;
    _updateRoadPolylines();

    setState(() {
      _markers = markers;
      _isLoading = _controller == null;
    });

    if(!fitCamera) return;
    _markProgrammaticMove();
    await MapCameraHelper.fitPoints(
      _controller,
      [destinationLatLng, _currentRiderLatLng ?? deliveryManLatLng, restaurantLatLng].whereType<LatLng>().toList(),
      padding: _markerEdgeGap,
      webBottomInset: _sheetHeight,
      maxSpanMeters: _maxFitSpanMeters,
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog());
    }else {
      onTap();
    }
  }
}