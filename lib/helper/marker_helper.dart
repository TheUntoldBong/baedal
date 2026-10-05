import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/util/images.dart';

class MarkerHelper {
  static final Map<String, BitmapDescriptor> _cachedMarkers = {};

  static const Color baedalPrimary = Color(0xFF29A9E8);
  static const Color baedalNavy = Color(0xFF102A43);
  static const Color baedalLightBlue = Color(0xFFEAF7FF);

  static Future<BitmapDescriptor> convertAssetToBitmapDescriptor({
    required final String imagePath,
    final int? width,
    final int? height,
    final double? logicalWidth,
  }) async {
    try {
      final double targetDim = logicalWidth ?? (width != null ? width.toDouble() : 44.0);
      if (GetPlatform.isWeb) {
        return await BitmapDescriptor.asset(
          ImageConfiguration(devicePixelRatio: 2.0, size: Size(targetDim, targetDim)),
          imagePath,
        );
      }
      final ByteData byteDataFromImage = await rootBundle.load(imagePath).timeout(const Duration(seconds: 8));
      // Scale top-view vehicle to fit neatly like user/restaurant icons (~35px length, ~15px width)
      final ui.Codec codec = await ui
          .instantiateImageCodec(
            byteDataFromImage.buffer.asUint8List(),
            targetHeight: (targetDim * 0.80).round(),
          )
          .timeout(const Duration(seconds: 8));
      final ui.FrameInfo frameInfo = await codec.getNextFrame().timeout(const Duration(seconds: 8));
      final ByteData? byteDataFromFrame =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png).timeout(const Duration(seconds: 8));
      if (byteDataFromFrame != null) {
        final Uint8List uint8List = byteDataFromFrame.buffer.asUint8List();
        return BitmapDescriptor.bytes(uint8List, width: targetDim);
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      }
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    }
  }

  /// Clean circular marker with dark navy background, white cutlery, and subtle blue glow for Restaurant
  static Future<BitmapDescriptor> createBaedalRestaurantMarker({double size = 44}) async {
    final String key = 'baedal_restaurant_marker_$size';
    if (_cachedMarkers.containsKey(key)) {
      return _cachedMarkers[key]!;
    }

    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final double dimension = size * 1.35;
      final Offset center = Offset(dimension / 2, dimension / 2);
      final double radius = size * 0.40;

      // 1. Soft realistic contact shadow underneath
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + (radius * 0.28)),
          width: radius * 2.1,
          height: radius * 1.8,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
      );

      // 2. Subtle outer Baedal blue glow ring
      canvas.drawCircle(
        center,
        radius * 1.14,
        Paint()
          ..color = baedalPrimary.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // 3. Crisp white outer border
      canvas.drawCircle(
        center,
        radius * 1.08,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // 4. Dark navy circular body
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = baedalNavy
          ..style = PaintingStyle.fill,
      );

      // 5. White fork & knife cutlery icon
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.restaurant_rounded.codePoint),
        style: TextStyle(
          fontSize: radius * 1.05,
          fontFamily: Icons.restaurant_rounded.fontFamily,
          package: Icons.restaurant_rounded.fontPackage,
          color: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - (textPainter.width / 2),
          center.dy - (textPainter.height / 2),
        ),
      );

      final ui.Image image = await pictureRecorder.endRecording().toImage(dimension.toInt(), dimension.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final descriptor = BitmapDescriptor.bytes(byteData.buffer.asUint8List(), width: size);
        _cachedMarkers[key] = descriptor;
        return descriptor;
      }
    } catch (e) {
      debugPrint('Error creating Baedal restaurant marker: $e');
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  /// Clean circular marker with white background, blue home icon, and blue outer ring/glow
  static Future<BitmapDescriptor> createBaedalCustomerMarker({double size = 44}) async {
    final String key = 'baedal_customer_marker_$size';
    if (_cachedMarkers.containsKey(key)) {
      return _cachedMarkers[key]!;
    }

    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final double dimension = size * 1.35;
      final Offset center = Offset(dimension / 2, dimension / 2);
      final double radius = size * 0.40;

      // 1. Soft drop shadow underneath
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + (radius * 0.28)),
          width: radius * 2.1,
          height: radius * 1.8,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
      );

      // 2. Subtle outer Baedal blue glow
      canvas.drawCircle(
        center,
        radius * 1.15,
        Paint()
          ..color = baedalPrimary.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // 3. Baedal Blue outer ring
      canvas.drawCircle(
        center,
        radius * 1.08,
        Paint()
          ..color = baedalPrimary
          ..style = PaintingStyle.fill,
      );

      // 4. White circular body
      canvas.drawCircle(
        center,
        radius * 0.96,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // 5. Baedal Blue Home Icon
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.home_rounded.codePoint),
        style: TextStyle(
          fontSize: radius * 1.10,
          fontFamily: Icons.home_rounded.fontFamily,
          package: Icons.home_rounded.fontPackage,
          color: baedalPrimary,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - (textPainter.width / 2),
          center.dy - (textPainter.height / 2),
        ),
      );

      final ui.Image image = await pictureRecorder.endRecording().toImage(dimension.toInt(), dimension.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final descriptor = BitmapDescriptor.bytes(byteData.buffer.asUint8List(), width: size);
        _cachedMarkers[key] = descriptor;
        return descriptor;
      }
    } catch (e) {
      debugPrint('Error creating Baedal customer marker: $e');
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
  }

  /// Canvas vector fallback for 3D Baedal scooter rider
  static Future<BitmapDescriptor> createBaedalRiderCanvasMarker({double size = 54}) async {
    final String key = 'baedal_scooter_canvas_$size';
    if (_cachedMarkers.containsKey(key)) {
      return _cachedMarkers[key]!;
    }

    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final double dimension = size * 1.3;
      final Offset center = Offset(dimension / 2, dimension / 2);

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center.dx, center.dy + (size * 0.3)), width: size * 0.85, height: size * 0.32),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Glow
      canvas.drawCircle(
        center,
        size * 0.46,
        Paint()
          ..color = baedalPrimary.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Outer white ring
      canvas.drawCircle(
        center,
        size * 0.44,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Inner Baedal sky blue fill
      canvas.drawCircle(
        center,
        size * 0.38,
        Paint()
          ..color = baedalPrimary
          ..style = PaintingStyle.fill,
      );

      // Scooter / Bike Icon
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.moped_rounded.codePoint),
        style: TextStyle(
          fontSize: size * 0.48,
          fontFamily: Icons.moped_rounded.fontFamily,
          package: Icons.moped_rounded.fontPackage,
          color: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)),
      );

      final ui.Image image = await pictureRecorder.endRecording().toImage(dimension.toInt(), dimension.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final descriptor = BitmapDescriptor.bytes(byteData.buffer.asUint8List(), width: size);
        _cachedMarkers[key] = descriptor;
        return descriptor;
      }
    } catch (_) {}
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
  }

  /// Restaurant marker matching Baedal design: Dark navy circle with white cutlery and blue glow
  static Future<BitmapDescriptor> getRestaurantMarker({double size = 44}) async {
    return createBaedalRestaurantMarker(size: size);
  }

  /// Destination / User marker matching Baedal design: White circle with blue home icon and blue ring
  static Future<BitmapDescriptor> getUserMarker({double size = 44}) async {
    return createBaedalCustomerMarker(size: size);
  }

  static Future<BitmapDescriptor> getDestinationMarker({double size = 44}) async {
    return createBaedalCustomerMarker(size: size);
  }

  /// Delivery partner marker matching Baedal design: Premium 3D top-view delivery scooter
  static Future<BitmapDescriptor> getDeliveryManMarker({double size = 44, bool isMotorcycle = true}) async {
    final String cacheKey = 'baedal_topview_scooter_premium_v4_$size';
    if (_cachedMarkers.containsKey(cacheKey)) {
      return _cachedMarkers[cacheKey]!;
    }

    try {
      // High-res 3D Baedal electric scooter rider asset sized to match user & restaurant pins
      final BitmapDescriptor descriptor = await convertAssetToBitmapDescriptor(
        imagePath: Images.scooterRider,
        logicalWidth: size,
      );
      _cachedMarkers[cacheKey] = descriptor;
      return descriptor;
    } catch (_) {
      // Fallback: Custom canvas Baedal blue scooter marker
      return createBaedalRiderCanvasMarker(size: size);
    }
  }

  /// Keep backward compatibility for other screens
  static Future<BitmapDescriptor> createModernMarker({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    double size = 44,
    String? cacheKey,
  }) async {
    return createBaedalRestaurantMarker(size: size);
  }
}