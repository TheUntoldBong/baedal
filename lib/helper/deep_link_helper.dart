import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class DeepLinkHelper {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _initialized = false;
  static Uri? _pendingUri;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    // Listen to background / foreground deep links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('[DeepLinkHelper] Incoming stream URI: $uri');
        handleUri(uri);
      },
      onError: (err) {
        debugPrint('[DeepLinkHelper] Stream error: $err');
      },
    );

    // Check cold start initial deep link
    _checkInitialLink();
  }

  static Future<void> _checkInitialLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLinkHelper] Cold start initial URI: $initialUri');
        _pendingUri = initialUri;
        // Delay slightly until splash and routes are ready
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_pendingUri != null) {
            handleUri(_pendingUri!);
            _pendingUri = null;
          }
        });
      }
    } catch (e) {
      debugPrint('[DeepLinkHelper] Error reading initial link: $e');
    }
  }

  static void handleUri(Uri uri) async {
    debugPrint('[DeepLinkHelper] Handling URI: $uri (path=${uri.path}, host=${uri.host}, scheme=${uri.scheme})');

    String? type;
    String? id;
    String? slug;

    // 1. Query parameter based link:
    // e.g. https://baedalfooddelivery.com/share?type=item&id=124
    // or baedalfooddelivery://item?id=124
    if (uri.queryParameters.containsKey('type')) {
      type = uri.queryParameters['type'];
    }
    if (uri.queryParameters.containsKey('id')) {
      id = uri.queryParameters['id'];
    }
    if (uri.queryParameters.containsKey('slug')) {
      slug = uri.queryParameters['slug'];
    }

    // 2. Custom scheme path based:
    // e.g. baedalfooddelivery://item?id=124 or baedalfooddelivery://restaurant?id=15
    if (uri.scheme == 'baedalfooddelivery') {
      if (type == null) {
        if (uri.host == 'item' || uri.host == 'product') {
          type = 'item';
        } else if (uri.host == 'restaurant' || uri.host == 'restaurants') {
          type = 'restaurant';
        } else if (uri.pathSegments.isNotEmpty) {
          String first = uri.pathSegments.first;
          if (first == 'item' || first == 'product') type = 'item';
          if (first == 'restaurant' || first == 'restaurants') type = 'restaurant';
        }
      }
    }

    // 3. Path-based HTTPS App Links:
    // e.g. https://baedalfooddelivery.com/item/124
    // e.g. https://baedalfooddelivery.com/restaurants/pizzakar-s
    List<String> segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      String first = segments.first.toLowerCase();
      if (first == 'item' || first == 'product') {
        type = 'item';
        if (segments.length > 1) {
          id ??= segments[1];
        }
      } else if (first == 'restaurant' || first == 'restaurants') {
        type = 'restaurant';
        if (segments.length > 1) {
          slug ??= segments[1];
          if (int.tryParse(segments[1]) != null) {
            id ??= segments[1];
          }
        }
      }
    }

    if (type == 'item' || type == 'product') {
      int? productId = id != null ? int.tryParse(id) : null;
      if (productId != null) {
        await _openProduct(productId);
      }
    } else if (type == 'restaurant') {
      int? restId = id != null ? int.tryParse(id) : null;
      _openRestaurant(restId, slug);
    }
  }

  static Future<void> _openProduct(int productId) async {
    try {
      debugPrint('[DeepLinkHelper] Fetching product details for ID: $productId');

      // Wait if splash screen is still running
      if (Get.currentRoute.startsWith(RouteHelper.splash)) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      Product? product = await Get.find<ProductController>().getProductDetails(productId, null);
      if (product != null && Get.context != null) {
        if (ResponsiveHelper.isMobile(Get.context)) {
          Get.bottomSheet(
            FoodBottomSheetWidget(product: product, inRestaurantPage: false),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          );
        } else {
          Get.dialog(
            Dialog(child: FoodBottomSheetWidget(product: product, inRestaurantPage: false)),
          );
        }
      } else {
        showCustomSnackBar('Item could not be loaded or is currently unavailable.');
      }
    } catch (e) {
      debugPrint('[DeepLinkHelper] Error opening product: $e');
    }
  }

  static void _openRestaurant(int? restaurantId, String? slug) {
    try {
      debugPrint('[DeepLinkHelper] Opening restaurant: id=$restaurantId, slug=$slug');
      if (restaurantId != null || (slug != null && slug.isNotEmpty)) {
        Get.toNamed(RouteHelper.getRestaurantRoute(restaurantId, slug: slug ?? ''));
      }
    } catch (e) {
      debugPrint('[DeepLinkHelper] Error opening restaurant: $e');
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
  }
}
