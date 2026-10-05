import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/distance_duration_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class MockCheckoutService extends Mock implements CheckoutServiceInterface {}

class MockAuthController extends GetxController with Mock implements AuthController {}

const LatLng customer = LatLng(23.8103, 90.4125);
const LatLng otherCustomer = LatLng(23.7500, 90.3900);
const LatLng restaurant = LatLng(23.8113, 90.4135);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CheckoutController checkoutController;
  late MockCheckoutService mockCheckoutService;

  setUpAll(() {
    registerFallbackValue(customer);
  });

  setUp(() {
    final MockAuthController mockAuthController = MockAuthController();
    when(() => mockAuthController.getUserCountryCode()).thenReturn('+880');
    Get.put<AuthController>(mockAuthController);

    mockCheckoutService = MockCheckoutService();
    checkoutController = CheckoutController(checkoutServiceInterface: mockCheckoutService);

    when(() => mockCheckoutService.getDistanceAndDuration(any(), any()))
        .thenAnswer((_) async => DistanceDurationModel(distanceInKm: 0.519, durationInSecond: 420));
    when(() => mockCheckoutService.getExtraCharge(any())).thenAnswer((_) async => 0);
  });

  tearDown(() => Get.reset());

  test('overlapping requests for the same points share one api call', () async {
    await Future.wait([
      checkoutController.getDistanceInKM(customer, restaurant),
      checkoutController.getDistanceInKM(customer, restaurant),
    ]);

    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(1);
    expect(checkoutController.distance, 0.519);
    expect(checkoutController.deliveryDurationInSecond, 420);
  });

  test('a repeated request for the same points does not pay for the call again', () async {
    await checkoutController.getDistanceInKM(customer, restaurant);
    await checkoutController.getDistanceInKM(customer, restaurant);

    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(1);
  });

  test('a different address is fetched again', () async {
    await checkoutController.getDistanceInKM(customer, restaurant);
    await checkoutController.getDistanceInKM(otherCustomer, restaurant);

    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(2);
    expect(checkoutController.distance, 0.519);
  });

  test('a new checkout starts from a clean request', () async {
    await checkoutController.getDistanceInKM(customer, restaurant);
    checkoutController.clearPrevData();
    await checkoutController.getDistanceInKM(customer, restaurant);

    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(2);
    expect(checkoutController.deliveryDurationInSecond, 420);
  });

  test('a straight line fallback is not kept for the rest of the checkout', () async {
    when(() => mockCheckoutService.getDistanceAndDuration(any(), any()))
        .thenAnswer((_) async => DistanceDurationModel(distanceInKm: 0.4, isFallback: true));

    await Future.wait([
      checkoutController.getDistanceInKM(customer, restaurant),
      checkoutController.getDistanceInKM(customer, restaurant),
    ]);
    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(1);

    when(() => mockCheckoutService.getDistanceAndDuration(any(), any()))
        .thenAnswer((_) async => DistanceDurationModel(distanceInKm: 0.519, durationInSecond: 420));

    await checkoutController.getDistanceInKM(customer, restaurant);

    verify(() => mockCheckoutService.getDistanceAndDuration(any(), any())).called(1);
    expect(checkoutController.distance, 0.519);
    expect(checkoutController.deliveryDurationInSecond, 420);
  });

  group('checkout is the one place that asks for the distance', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        AppConstants.userAddress: jsonEncode(AddressModel(
          latitude: '${customer.latitude}', longitude: '${customer.longitude}', address: 'home',
        ).toJson()),
      });
      Get.put<SharedPreferences>(await SharedPreferences.getInstance());
    });

    test('asks for the distance between the saved address and the restaurant', () async {
      checkoutController.getDistanceFromRestaurant(Restaurant(
        latitude: '${restaurant.latitude}', longitude: '${restaurant.longitude}',
      ));
      await Future.delayed(Duration.zero);

      verify(() => mockCheckoutService.getDistanceAndDuration(customer, restaurant)).called(1);
    });

    test('does not ask when the restaurant has no coordinates', () async {
      checkoutController.getDistanceFromRestaurant(Restaurant(latitude: null, longitude: null));
      checkoutController.getDistanceFromRestaurant(null);
      await Future.delayed(Duration.zero);

      verifyNever(() => mockCheckoutService.getDistanceAndDuration(any(), any()));
    });
  });

  test('clearing checkout data drops the distance and the duration', () async {
    await checkoutController.getDistanceInKM(customer, restaurant);
    checkoutController.clearPrevData();

    expect(checkoutController.distance, null);
    expect(checkoutController.deliveryDurationInSecond, null);
  });
}
