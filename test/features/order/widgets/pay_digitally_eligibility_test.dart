import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/payment_method_section.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

ConfigModel config({bool digitalPayment = true, bool codToDigital = true, bool hasGateway = true}) {
  return ConfigModel(
    digitalPayment: digitalPayment,
    codToDigitalPayment: codToDigital,
    activePaymentMethodList: hasGateway ? [PaymentBody(getWay: 'ssl_commerz_payment')] : [],
  );
}

OrderModel order({String status = 'processing', String method = 'cash_on_delivery', String paymentStatus = 'unpaid', Map<String, dynamic>? subscription, int? subscriptionId}) {
  return OrderModel.fromJson({
    'id': 1,
    'order_status': status,
    'payment_method': method,
    'payment_status': paymentStatus,
    'subscription_id': ?subscriptionId,
    'subscription': ?subscription,
  });
}

Map<String, dynamic> subscriptionJson() => {'id': 7, 'status': 'active', 'type': 'daily', 'billing_amount': 0, 'paid_amount': 0};

void main() {
  group('pay digitally is offered', () {
    test('on a live cash order', () {
      expect(PaymentMethodSection.canOfferDigitalPayment(order(), config()), true);
    });

    test('through every stage the order can still be paid in', () {
      for (final String status in ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up']) {
        expect(PaymentMethodSection.canOfferDigitalPayment(order(status: status), config()), true, reason: status);
      }
    });
  });

  group('pay digitally is not offered', () {
    test('on a repeat order, which is settled on its subscription', () {
      expect(PaymentMethodSection.canOfferDigitalPayment(order(subscription: subscriptionJson()), config()), false);
      expect(PaymentMethodSection.canOfferDigitalPayment(order(subscriptionId: 7), config()), false);
    });

    test('on an order that was not paid in cash, or is already paid', () {
      expect(PaymentMethodSection.canOfferDigitalPayment(order(method: 'digital_payment'), config()), false);
      expect(PaymentMethodSection.canOfferDigitalPayment(order(paymentStatus: 'paid'), config()), false);
    });

    test('once the order is no longer collectable', () {
      for (final String status in ['delivered', 'canceled', 'refunded', 'failed']) {
        expect(PaymentMethodSection.canOfferDigitalPayment(order(status: status), config()), false, reason: status);
      }
    });

    test('when the admin switched the feature off', () {
      expect(PaymentMethodSection.canOfferDigitalPayment(order(), config(codToDigital: false)), false);
      expect(PaymentMethodSection.canOfferDigitalPayment(order(), config(digitalPayment: false)), false);
      expect(PaymentMethodSection.canOfferDigitalPayment(order(), config(hasGateway: false)), false);
      expect(PaymentMethodSection.canOfferDigitalPayment(order(), null), false);
    });
  });
}
