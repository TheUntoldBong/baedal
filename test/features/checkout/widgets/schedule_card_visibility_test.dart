import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/top_section_widget.dart';

class MockCheckoutController extends GetxController with Mock implements CheckoutController {}

MockCheckoutController checkout({
  String orderType = 'delivery',
  bool subscriptionOrder = false,
  bool? scheduleOrder = true,
  bool hasRestaurant = true,
}) {
  final MockCheckoutController controller = MockCheckoutController();
  when(() => controller.orderType).thenReturn(orderType);
  when(() => controller.subscriptionOrder).thenReturn(subscriptionOrder);
  when(() => controller.restaurant).thenReturn(hasRestaurant ? Restaurant(scheduleOrder: scheduleOrder) : null);
  return controller;
}

void main() {
  group('a delivery order can be scheduled', () {
    test('when the store takes scheduled orders', () {
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout()), true);
    });

    test('without consulting saver delivery, which is a zone offer', () {
      final MockCheckoutController controller = checkout();
      when(() => controller.saverZoneData).thenThrow(StateError('saver data must not decide scheduling'));

      expect(TopSectionWidget.canScheduleDeliveryFor(controller), true);
    });
  });

  group('a delivery order can not be scheduled', () {
    test('when the store does not take scheduled orders', () {
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(scheduleOrder: false)), false);
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(scheduleOrder: null)), false);
    });

    test('on take away or dine in, which carry their own pickup card', () {
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(orderType: 'take_away')), false);
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(orderType: 'dine_in')), false);
    });

    test('on a repeat order, which carries its own date card', () {
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(subscriptionOrder: true)), false);
    });

    test('before the store details have arrived', () {
      expect(TopSectionWidget.canScheduleDeliveryFor(checkout(hasRestaurant: false)), false);
    });
  });
}
