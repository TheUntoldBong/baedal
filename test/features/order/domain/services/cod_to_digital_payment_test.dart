import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/repositories/order_repository_interface.dart';
import 'package:stackfood_multivendor/features/order/domain/services/order_service.dart';
import 'package:stackfood_multivendor/helper/cod_to_digital_payment_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class MockOrderRepository extends Mock implements OrderRepositoryInterface {}

void main() {
  late OrderService orderService;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    orderService = OrderService(orderRepositoryInterface: mockOrderRepository);
  });

  group('digital payment status model', () {
    test('reads an eligible order with the amount still owed', () {
      final model = DigitalPaymentStatusModel.fromJson({'eligible': true, 'reason': null, 'amount_due': 159.6});

      expect(model.eligible, true);
      expect(model.reason, null);
      expect(model.amountDue, 159.6);
    });

    test('reads an ineligible order with its reason', () {
      final model = DigitalPaymentStatusModel.fromJson({'eligible': false, 'reason': 'This order is already paid', 'amount_due': 0});

      expect(model.eligible, false);
      expect(model.reason, 'This order is already paid');
      expect(model.amountDue, 0);
    });

    test('treats a missing eligible flag as not eligible', () {
      final model = DigitalPaymentStatusModel.fromJson({});

      expect(model.eligible, false);
      expect(model.amountDue, null);
    });
  });

  group('payDigitally', () {
    test('returns the payment url the gateway must be opened with', () async {
      when(() => mockOrderRepository.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment', callback: 'callback://back'))
          .thenAnswer((_) async => Response(statusCode: 200, body: {'payment_url': 'https://pay/cod-to-digital', 'amount_due': 159.6}));

      final result = await orderService.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment', callback: 'callback://back');

      expect(result.isSuccess, true);
      expect(result.data?.paymentUrl, 'https://pay/cod-to-digital');
      expect(result.data?.amountDue, 159.6);
    });

    test('fails with the server reason when the order can no longer be paid', () async {
      when(() => mockOrderRepository.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment', callback: null))
          .thenAnswer((_) async => Response(statusCode: 403, statusText: 'Forbidden', body: {
            'errors': [{'code': 'order', 'message': 'This order is already paid'}]
          }));

      final result = await orderService.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment');

      expect(result.isSuccess, false);
      expect(result.message, 'This order is already paid');
      expect(result.data, null);
    });

    test('fails when a 200 carries no payment url', () async {
      when(() => mockOrderRepository.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment', callback: null))
          .thenAnswer((_) async => Response(statusCode: 200, body: {'amount_due': 159.6}));

      final result = await orderService.payDigitally(orderId: 1, paymentMethod: 'ssl_commerz_payment');

      expect(result.isSuccess, false);
    });
  });

  group('gateway callback outcome', () {
    test('is undecided while the gateway flow is still running', () {
      expect(CodToDigitalPaymentHelper.readOutcome('https://gateway.example/checkout'), null);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.baseUrl}/payment-mobile/cod-to-digital?order_id=1'), null);
    });

    test('reads the status appended to the callback', () {
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}?status=success'), true);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}?status=fail'), false);
      expect(CodToDigitalPaymentHelper.readOutcome(AppConstants.codToDigitalCallbackUrl), false);
    });

    test('reads a status the callback url can not be parsed for', () {
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}&status=success'), true);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}&status=fail'), false);

      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}?status=&status=success'), true);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.codToDigitalCallbackUrl}?status=success'), true);

      expect(CodToDigitalPaymentHelper.readOutcome('stackfood://back&status=success'), true);
    });

    test('keeps waiting while the callback has not been reached', () {
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.baseUrl}/payment-mobile/cod-to-digital?order_id=1&status='), null);
      expect(CodToDigitalPaymentHelper.readStatus('${AppConstants.baseUrl}/payment-mobile/cod-to-digital?order_id=1'), null);
    });

    test('falls back to the default gateway redirect pages', () {
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.baseUrl}/payment-success'), true);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.baseUrl}/payment-fail'), false);
      expect(CodToDigitalPaymentHelper.readOutcome('${AppConstants.baseUrl}/payment-cancel'), false);
    });
  });
}
