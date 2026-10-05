import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCameraHelper {

  static const double _minSpan = 0.0015;

  static LatLng? toLatLng(String? latitude, String? longitude) {
    final double? lat = double.tryParse(latitude?.trim() ?? '');
    final double? lng = double.tryParse(longitude?.trim() ?? '');
    if(lat == null || lng == null) return null;
    if(lat == 0 && lng == 0) return null;
    if(lat.abs() > 90 || lng.abs() > 180) return null;
    return LatLng(lat, lng);
  }

  static LatLngBounds? boundsFrom(List<LatLng> points) {
    if(points.isEmpty) return null;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for(final LatLng point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  static LatLng centerOf(LatLngBounds bounds) => LatLng(
    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
    (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
  );

  static double spanMeters(LatLngBounds bounds) => Geolocator.distanceBetween(
    bounds.southwest.latitude, bounds.southwest.longitude,
    bounds.northeast.latitude, bounds.northeast.longitude,
  );

  static List<LatLng> _trimToSpan(List<LatLng> points, double maxSpanMeters) {
    List<LatLng> kept = points;
    while(kept.length > 2 && spanMeters(boundsFrom(kept)!) > maxSpanMeters) {
      kept = kept.sublist(0, kept.length - 1);
    }
    return kept;
  }

  static Future<void> fitPoints(GoogleMapController? controller, List<LatLng> points, {
    double padding = 60, double singlePointZoom = 16, bool animate = true, double webBottomInset = 0,
    double maxSpanMeters = 0,
  }) async {
    if(maxSpanMeters > 0 && points.length > 2) {
      points = _trimToSpan(points, maxSpanMeters);
    }
    final LatLngBounds? bounds = boundsFrom(points);
    if(controller == null || bounds == null) return;

    final LatLng center = centerOf(bounds);
    final bool degenerate = points.length == 1
        || ((bounds.northeast.latitude - bounds.southwest.latitude) < _minSpan
            && (bounds.northeast.longitude - bounds.southwest.longitude) < _minSpan);

    final CameraUpdate update = degenerate
        ? CameraUpdate.newLatLngZoom(center, singlePointZoom)
        : CameraUpdate.newLatLngBounds(bounds, padding);

    for(int attempt = 0; attempt < 3; attempt++) {
      try {
        await _move(controller, update, animate);
        if(GetPlatform.isWeb && webBottomInset > 0) {
          await controller.moveCamera(CameraUpdate.scrollBy(0, webBottomInset / 2));
        }
        return;
      } catch(_) {
        if(attempt == 2) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    try {
      await _move(controller, CameraUpdate.newLatLngZoom(center, singlePointZoom), animate);
    } catch(_) {}
  }

  static Future<void> _move(GoogleMapController controller, CameraUpdate update, bool animate) {
    return animate ? controller.animateCamera(update) : controller.moveCamera(update);
  }

}
