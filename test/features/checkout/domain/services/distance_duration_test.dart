import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:stackfood_multivendor/features/checkout/domain/services/checkout_service.dart';

class MockCheckoutRepository extends Mock implements CheckoutRepositoryInterface {}

const LatLng origin = LatLng(23.8103, 90.4125);
const LatLng destination = LatLng(23.8113, 90.4135);

Map<String, dynamic> distanceApiResponse({dynamic distanceMeters = 519, dynamic duration = '420s'}) {
  return {
    'distanceMeters': distanceMeters,
    'duration': duration,
    'localizedValues': {
      'distance': {'text': '0.5 km'},
      'duration': {'text': '7 mins'},
    },
  };
}

PlaceOrderBodyModel buildOrderBody({double? distance, int? deliveryDuration}) {
  return PlaceOrderBodyModel(
    cart: [OnlineCart(1, 1, null, '100', [], 1, [], [], [], 'food', variationOptionIds: [])],
    orderAmount: 100, orderType: 'delivery', paymentMethod: 'cash_on_delivery',
    distance: distance, deliveryDuration: deliveryDuration,
    discountAmount: 0, taxAmount: 0, cutlery: 0, partialPayment: 0, isBuyNow: 0,
    unavailableItemNote: '', deliveryInstruction: '', guestId: 0, extraPackagingAmount: 0,
  );
}

void main() {
  late CheckoutService checkoutService;
  late MockCheckoutRepository mockCheckoutRepository;

  setUpAll(() {
    registerFallbackValue(origin);
  });

  setUp(() {
    mockCheckoutRepository = MockCheckoutRepository();
    checkoutService = CheckoutService(checkoutRepositoryInterface: mockCheckoutRepository);
  });

  void mockDistanceApi(Response response) {
    when(() => mockCheckoutRepository.getDistanceInMeter(any(), any())).thenAnswer((_) async => response);
  }

  group('parseDurationInSecond', () {
    test('reads the seconds off the api format', () {
      expect(checkoutService.parseDurationInSecond('420s'), 420);
      expect(checkoutService.parseDurationInSecond('420'), 420);
      expect(checkoutService.parseDurationInSecond(420), 420);
    });

    test('rounds a fractional duration to whole seconds', () {
      expect(checkoutService.parseDurationInSecond('419.6s'), 420);
    });

    test('drops a duration it can not read instead of defaulting it', () {
      expect(checkoutService.parseDurationInSecond(null), null);
      expect(checkoutService.parseDurationInSecond(''), null);
      expect(checkoutService.parseDurationInSecond('unknown'), null);
    });
  });

  group('getDistanceAndDuration', () {
    test('keeps both the distance in km and the duration in seconds', () async {
      mockDistanceApi(Response(statusCode: 200, body: distanceApiResponse()));

      final result = await checkoutService.getDistanceAndDuration(origin, destination);

      expect(result.distanceInKm, 0.519);
      expect(result.durationInSecond, 420);
      expect(result.durationInHour, closeTo(0.1167, 0.0001));
    });

    test('keeps the distance when the api sends no duration', () async {
      mockDistanceApi(Response(statusCode: 200, body: distanceApiResponse(duration: null)));

      final result = await checkoutService.getDistanceAndDuration(origin, destination);

      expect(result.distanceInKm, 0.519);
      expect(result.durationInSecond, null);
      expect(result.durationInHour, null);
    });
  });

  group('place order body', () {
    test('submits the duration as delivery_duration', () {
      final json = buildOrderBody(distance: 0.519, deliveryDuration: 420).toJson();

      expect(json['distance'], 0.519);
      expect(json['delivery_duration'], 420);
    });

    test('leaves delivery_duration out when there is no duration to send', () {
      final json = buildOrderBody(distance: 0.519).toJson();

      expect(json['distance'], 0.519);
      expect(json.containsKey('delivery_duration'), false);
    });

    test('survives the offline payment round trip', () {
      final PlaceOrderBodyModel restored = PlaceOrderBodyModel.fromJson(buildOrderBody(distance: 0.519, deliveryDuration: 420).toJson());

      expect(restored.distance, 0.519);
      expect(restored.deliveryDuration, 420);
      expect(restored.toJson()['delivery_duration'], 420);
    });
  });
}
