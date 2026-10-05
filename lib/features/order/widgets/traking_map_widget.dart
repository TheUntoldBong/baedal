import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/road_routing_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:collection';

class TrackingMapWidget extends StatefulWidget {
  final OrderModel? track;
  const TrackingMapWidget({super.key, required this.track});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: ResponsiveHelper.isMobilePhone() ? width : 1170.0 - 100.0,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(Dimensions.padding2xSmall),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: widget.track!.deliveryMan != null ? Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(widget.track!.deliveryAddress!.latitude!),
                  double.parse(widget.track!.deliveryAddress!.longitude!),
                ),
                zoom: 16,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomControlsEnabled: false,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _isLoading = false;
                setMarker(
                  widget.track!.restaurant, widget.track!.deliveryMan,
                  widget.track!.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? widget.track!.deliveryAddress : AddressModel(
                    latitude: Get.find<LocationController>().position.latitude.toString(),
                    longitude: Get.find<LocationController>().position.longitude.toString(),
                    address: Get.find<LocationController>().address,
                  ) : widget.track!.deliveryAddress,
                  widget.track!.orderType == 'take_away',
                );
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),
          ),

          _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))) : const SizedBox(),
        ],
      ) : FittedBox(child: Text('no_delivery_man_data_found'.tr)),
    );
  }

  void setMarker(Restaurant? restaurant, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway) async {
    try {
      final List<BitmapDescriptor> icons = await Future.wait([
        MarkerHelper.getRestaurantMarker(size: 42),
        MarkerHelper.getDeliveryManMarker(size: 48),
        MarkerHelper.getUserMarker(size: 42),
      ]);

      final BitmapDescriptor restaurantImageData = icons[0];
      final BitmapDescriptor deliveryBoyImageData = icons[1];
      final BitmapDescriptor destinationImageData = icons[2];

      LatLng? restaurantLatLng = restaurant?.latitude != null ? LatLng(double.parse(restaurant!.latitude!), double.parse(restaurant.longitude!)) : null;
      LatLng? deliveryManLatLng = deliveryMan?.lat != null && deliveryMan!.lat != '0' ? LatLng(double.parse(deliveryMan.lat!), double.parse(deliveryMan.lng!)) : null;
      LatLng? destinationLatLng = addressModel?.latitude != null ? LatLng(double.parse(addressModel!.latitude!), double.parse(addressModel.longitude!)) : null;

      // Fit bounds
      if(_controller != null && addressModel != null && restaurant != null) {
        LatLngBounds bounds;
        if (double.parse(addressModel.latitude!) < double.parse(restaurant.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
          );
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
        }

        LatLng centerBounds = LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );

        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 15)));
        if(!ResponsiveHelper.isWeb()) {
          zoomToFit(_controller, bounds, centerBounds, padding: 10);
        }
      }

      final Set<Marker> markers = HashSet<Marker>();

      if (destinationLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: 'destination'.tr,
            snippet: addressModel?.address,
          ),
          icon: destinationImageData,
        ));
      }

      if (restaurantLatLng != null) {
        markers.add(Marker(
          markerId: const MarkerId('restaurant'),
          position: restaurantLatLng,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: restaurant?.name ?? 'restaurant'.tr,
            snippet: restaurant?.address,
          ),
          icon: restaurantImageData,
        ));
      }

      if (deliveryManLatLng != null) {
        double bearing = 0.0;
        if (destinationLatLng != null) {
          bearing = RoadRoutingHelper.calculateBearing(deliveryManLatLng, destinationLatLng);
        }

        markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: deliveryManLatLng,
          anchor: const Offset(0.5, 0.5), // Center anchor for rotating vehicle
          flat: true,
          infoWindow: InfoWindow(
            title: '${deliveryMan?.fName ?? ''} ${deliveryMan?.lName ?? ''}'.trim(),
            snippet: deliveryMan?.location ?? 'delivery_man'.tr,
          ),
          rotation: bearing,
          icon: deliveryBoyImageData,
        ));
      }

      // Fetch road polyline (Connecting Restaurant -> Delivery Rider -> Customer Home)
      final LatLng? origin = restaurantLatLng ?? deliveryManLatLng;
      if (origin != null && destinationLatLng != null) {
        final List<LatLng> roadPoints = await RoadRoutingHelper.getRoadPolyline(origin, destinationLatLng);
        if (roadPoints.length >= 2) {
          _polylines = {
            // Ambient outer Baedal blue glow
            Polyline(
              polylineId: const PolylineId('mini_road_glow'),
              points: roadPoints,
              color: const Color(0x3829A9E8),
              width: 9,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              zIndex: 1,
            ),
            // Smooth continuous solid Baedal blue route
            Polyline(
              polylineId: const PolylineId('mini_road_core'),
              points: roadPoints,
              color: const Color(0xFF29A9E8),
              width: 5,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              zIndex: 2,
            ),
          };
        }
      }

      _markers = markers;
    } catch (_) {}

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - 0.5;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }
}