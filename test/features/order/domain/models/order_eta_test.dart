import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_status_card.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

class MockSplashController extends GetxController with Mock implements SplashController {}

Map<String, dynamic> etaJson() {
  return {
    'min': 124,
    'max': 130,
    'unit': 'min',
    'text': '124 - 130 min',
    'from': '07:39 PM',
    'to': '07:45 PM',
    'window': '07:39 PM - 07:45 PM',
    'from_at': '2026-08-17T19:39:37+06:00',
    'to_at': '2026-08-17T19:45:37+06:00',
    'timezone': 'Asia/Dhaka',
    'stage': 'before_processing',
  };
}

Map<String, dynamic> orderJson({Map<String, dynamic>? eta}) {
  return {
    'id': 101283,
    'order_status': 'processing',
    'created_at': '2026-08-17T17:35:37+06:00',
    'processing_time': 30,
    'eta': ?eta,
  };
}

void main() {
  setUp(() {
    final MockSplashController mockSplashController = MockSplashController();
    when(() => mockSplashController.configModel).thenReturn(ConfigModel(timeformat: '12'));
    Get.put<SplashController>(mockSplashController);
  });

  tearDown(() => Get.reset());

  group('order eta', () {
    test('reads the arrival window the server sends', () {
      final OrderModel order = OrderModel.fromJson(orderJson(eta: etaJson()));

      expect(order.eta?.window, '07:39 PM - 07:45 PM');
      expect(order.eta?.min, 124);
      expect(order.eta?.max, 130);
      expect(order.eta?.unit, 'min');
      expect(order.eta?.text, '124 - 130 min');
      expect(order.eta?.from, '07:39 PM');
      expect(order.eta?.to, '07:45 PM');
      expect(order.eta?.fromAt, '2026-08-17T19:39:37+06:00');
      expect(order.eta?.toAt, '2026-08-17T19:45:37+06:00');
      expect(order.eta?.timezone, 'Asia/Dhaka');
      expect(order.eta?.stage, 'before_processing');
    });

    test('reads the minutes when they arrive as strings', () {
      final OrderModel order = OrderModel.fromJson(orderJson(eta: {...etaJson(), 'min': '124', 'max': '130'}));

      expect(order.eta?.min, 124);
      expect(order.eta?.max, 130);
    });

    test('is null on an order that carries no eta', () {
      expect(OrderModel.fromJson(orderJson()).eta, null);
    });

    test('survives being carried through a route', () {
      final OrderModel restored = OrderModel.fromJson(OrderModel.fromJson(orderJson(eta: etaJson())).toJson());

      expect(restored.eta?.window, '07:39 PM - 07:45 PM');
      expect(restored.eta?.min, 124);
      expect(restored.eta?.stage, 'before_processing');
    });

    test('leaves the eta key out when there is none', () {
      expect(OrderModel.fromJson(orderJson()).toJson().containsKey('eta'), false);
    });
  });

  group('a scheduled order', () {
    String stamp(DateTime day) => '${day.toIso8601String().substring(0, 10)}T19:39:37+06:00';

    OrderModel scheduled({Map<String, dynamic>? eta, String scheduleAt = '2026-08-14 19:30:00'}) {
      return OrderModel.fromJson({
        ...orderJson(eta: eta),
        'scheduled': 1,
        'schedule_at': scheduleAt,
      });
    }

    test('shows the arrival window dated from the eta', () {
      expect(OrderStatusCard.scheduledAtFor(scheduled(eta: etaJson())), '17 Aug, 07:39 PM - 07:45 PM');
    });

    test('names today and tomorrow instead of the date', () {
      final DateTime now = DateTime.now();
      expect(
        OrderStatusCard.scheduledAtFor(scheduled(eta: {...etaJson(), 'from_at': stamp(now)})),
        'today, 07:39 PM - 07:45 PM',
      );
      expect(
        OrderStatusCard.scheduledAtFor(scheduled(eta: {...etaJson(), 'from_at': stamp(now.add(const Duration(days: 1)))})),
        'tomorrow, 07:39 PM - 07:45 PM',
      );
    });

    test('dates the window from the picked slot when the eta carries no from_at', () {
      final Map<String, dynamic> eta = {...etaJson()}..remove('from_at');

      expect(OrderStatusCard.scheduledAtFor(scheduled(eta: eta)), '14 Aug, 07:39 PM - 07:45 PM');
    });

    test('keeps showing the picked slot until an eta arrives', () {
      expect(OrderStatusCard.scheduledAtFor(scheduled()), '14 Aug 2026  07:30 PM');
    });

    test('is not claimed by an order that was never scheduled', () {
      expect(OrderStatusCard.scheduledAtFor(OrderModel.fromJson(orderJson(eta: etaJson()))), null);
    });
  });

  group('estimated arrival', () {
    test('shows the window the server sends', () {
      final OrderModel order = OrderModel.fromJson(orderJson(eta: etaJson()));

      expect(OrderStatusCard.arrivalRange(order), '07:39 PM - 07:45 PM');
    });

    test('falls back to the local estimate when the order carries no eta', () {
      final OrderModel order = OrderModel.fromJson(orderJson());
      order.restaurant = Restaurant(deliveryTime: '20-30');

      final String? arrival = OrderStatusCard.arrivalRange(order);

      expect(arrival, isNotNull);
      expect(arrival, isNot('07:39 PM - 07:45 PM'));
    });

    test('falls back when the window is empty', () {
      final OrderModel order = OrderModel.fromJson(orderJson(eta: {...etaJson(), 'window': '  '}));
      order.restaurant = Restaurant(deliveryTime: '20-30');

      expect(OrderStatusCard.arrivalRange(order), isNot('  '));
    });

    test('has nothing to show without an eta or a delivery time', () {
      final OrderModel order = OrderModel.fromJson({'id': 1, 'created_at': '2026-08-17T17:35:37+06:00'});

      expect(OrderStatusCard.arrivalRange(order), null);
    });

    test('shows the window a repeat order carries', () {
      final OrderModel order = OrderModel.fromJson({
        ...orderJson(eta: etaJson()),
        'subscription_id': 7,
        'subscription': {'id': 7, 'status': 'active', 'type': 'daily', 'billing_amount': 0, 'paid_amount': 0},
      });

      expect(order.subscription, isNotNull);
      expect(OrderStatusCard.arrivalRange(order), '07:39 PM - 07:45 PM');
    });
  });
}
