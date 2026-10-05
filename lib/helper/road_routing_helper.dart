import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RoadRoutingHelper {
  static final Map<String, List<LatLng>> _routeCache = {};

  /// Fetches a real road-following polyline between [origin] and [destination].
  /// Uses OSRM driving service (returns turn-by-turn road geometry).
  /// Falls back to straight line if network fails.
  static Future<List<LatLng>> getRoadPolyline(LatLng origin, LatLng destination) async {
    // Generate cache key rounded to ~10m accuracy
    final String key = '${origin.latitude.toStringAsFixed(4)},${origin.longitude.toStringAsFixed(4)}->'
        '${destination.latitude.toStringAsFixed(4)},${destination.longitude.toStringAsFixed(4)}';

    if (_routeCache.containsKey(key)) {
      return List<LatLng>.from(_routeCache[key]!);
    }

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final List coords = data['routes'][0]['geometry']['coordinates'];
          final List<LatLng> points = coords.map<LatLng>((c) {
            final double lng = (c[0] as num).toDouble();
            final double lat = (c[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          if (points.isNotEmpty) {
            _routeCache[key] = points;
            return List<LatLng>.from(points);
          }
        }
      }
    } catch (e) {
      debugPrint('Road routing request exception: $e');
    }

    // Fallback: simple direct path
    return [origin, destination];
  }

  /// Calculates bearing angle (0 to 360 degrees) from [start] to [end].
  static double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * (math.pi / 180.0);
    final double lon1 = start.longitude * (math.pi / 180.0);
    final double lat2 = end.latitude * (math.pi / 180.0);
    final double lon2 = end.longitude * (math.pi / 180.0);
    final double dLon = lon2 - lon1;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final double radians = math.atan2(y, x);
    return (radians * (180.0 / math.pi) + 360.0) % 360.0;
  }

  /// Calculates distance in meters between two coordinates.
  static double distanceBetween(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000; // meters
    final double dLat = (p2.latitude - p1.latitude) * (math.pi / 180.0);
    final double dLon = (p2.longitude - p1.longitude) * (math.pi / 180.0);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * (math.pi / 180.0)) *
            math.cos(p2.latitude * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Interpolates between two LatLng positions by [fraction] (0.0 to 1.0).
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * fraction,
      from.longitude + (to.longitude - from.longitude) * fraction,
    );
  }

  /// Smoothly interpolates an angle handling 0/360 wrap-around.
  static double interpolateAngle(double from, double to, double fraction) {
    double diff = (to - from) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (from + diff * fraction + 360) % 360;
  }

  /// Trims route to only the remaining path from the rider's position to destination.
  static List<LatLng> trimRemainingRoute(List<LatLng> fullRoute, LatLng riderPos) {
    if (fullRoute.length < 2) return fullRoute;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < fullRoute.length; i++) {
      final double dist = distanceBetween(riderPos, fullRoute[i]);
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    final List<LatLng> remaining = [riderPos];
    for (int i = closestIndex + 1; i < fullRoute.length; i++) {
      remaining.add(fullRoute[i]);
    }
    if (remaining.length == 1 && fullRoute.isNotEmpty) {
      remaining.add(fullRoute.last);
    }
    return remaining;
  }

  /// Calculates total cumulative distance of a polyline in meters.
  static double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distanceBetween(points[i], points[i + 1]);
    }
    return total;
  }

  /// Extracts a subsegment along [points] centered at [progress] (0.0 to 1.0)
  /// for the moving highlight / pulse effect.
  static List<LatLng> getPulseSegment(List<LatLng> points, double progress, {double pulseLengthMeters = 70.0}) {
    if (points.length < 2) return [];

    final double totalDistance = calculateTotalDistance(points);
    if (totalDistance <= 10) return [];

    final double centerDistance = progress * totalDistance;
    final double startDistance = math.max(0.0, centerDistance - (pulseLengthMeters / 2));
    final double endDistance = math.min(totalDistance, centerDistance + (pulseLengthMeters / 2));

    if (startDistance >= endDistance) return [];

    final List<LatLng> segment = [];
    double currentDist = 0.0;
    bool started = false;

    for (int i = 0; i < points.length - 1; i++) {
      final double segmentDist = distanceBetween(points[i], points[i + 1]);
      final double nextDist = currentDist + segmentDist;

      if (!started && startDistance <= nextDist) {
        final double fraction = segmentDist > 0 ? (startDistance - currentDist) / segmentDist : 0.0;
        segment.add(interpolate(points[i], points[i + 1], fraction.clamp(0.0, 1.0)));
        started = true;
      }

      if (started) {
        if (endDistance <= nextDist) {
          final double fraction = segmentDist > 0 ? (endDistance - currentDist) / segmentDist : 1.0;
          segment.add(interpolate(points[i], points[i + 1], fraction.clamp(0.0, 1.0)));
          break;
        } else {
          segment.add(points[i + 1]);
        }
      }

      currentDist = nextDist;
    }

    return segment.length >= 2 ? segment : [];
  }
}