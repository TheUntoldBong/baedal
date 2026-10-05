import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_model.dart';

void main() {
  group('CheckoutSummaryModel.fromJson', () {
    test('parses a live delivery response', () {
      final json = jsonDecode('''
      {"tax":{"tax_amount":0,"tax_status":"excluded","tax_included":0},
       "delivery":{"delivery_charge":180,"original_delivery_charge":180,"base_delivery_charge":180,
                   "surge_amount":0,"free_delivery_by":null,"vehicle_id":2},
       "surge":null,
       "cashback":{"calculated_amount":0,"cashback_amount":0,"cashback_type":"","min_purchase":0,"max_discount":0,"id":null}}
      ''');

      final model = CheckoutSummaryModel.fromJson(json);

      expect(model.tax!.taxAmount, 0);
      expect(model.tax!.taxIncluded, 0);
      expect(model.delivery!.deliveryCharge, 180);
      expect(model.delivery!.originalDeliveryCharge, 180);
      expect(model.delivery!.baseDeliveryCharge, 180);
      expect(model.delivery!.surgeAmount, 0);
      expect(model.delivery!.freeDeliveryBy, null);
      expect(model.delivery!.vehicleId, 2);
      expect(model.surge, null);
      expect(model.cashback!.calculatedAmount, 0);
      expect(model.cashback!.cashbackType, '');
      expect(model.cashback!.id, null);
    });

    test('parses a take_away response with null vehicle', () {
      final json = jsonDecode('''
      {"tax":{"tax_amount":0,"tax_status":"excluded","tax_included":0},
       "delivery":{"delivery_charge":0,"original_delivery_charge":0,"base_delivery_charge":0,
                   "surge_amount":0,"free_delivery_by":null,"vehicle_id":null},
       "surge":null,
       "cashback":{"calculated_amount":0,"cashback_amount":0,"cashback_type":"","min_purchase":0,"max_discount":0,"id":null}}
      ''');

      final model = CheckoutSummaryModel.fromJson(json);

      expect(model.delivery!.deliveryCharge, 0);
      expect(model.delivery!.vehicleId, null);
    });

    test('parses a live response with an active surge and cashback', () {
      final json = jsonDecode('''
      {"tax":{"tax_amount":0,"tax_status":"excluded","tax_included":0,"total_price":697.2},
       "delivery":{"delivery_charge":242,"original_delivery_charge":242,"base_delivery_charge":220,
                   "surge_amount":22,"free_delivery_by":null,"pro_customer_savings":0,
                   "delivery_type_charge":0,"vehicle_id":1},
       "surge":{"title":"Late Night Fee","customer_note":"Open up this is FBI","customer_note_status":1,
                "price":10,"price_type":"percent","zone_id":1},
       "cashback":{"calculated_amount":69.72,"cashback_amount":10,"cashback_type":"percentage",
                   "min_purchase":100,"max_discount":1000,"id":3}}
      ''');

      final model = CheckoutSummaryModel.fromJson(json);

      expect(model.tax!.totalPrice, 697.2);
      expect(model.delivery!.deliveryCharge, 242);
      expect(model.delivery!.baseDeliveryCharge, 220);
      expect(model.delivery!.surgeAmount, 22);
      expect(model.delivery!.proCustomerSavings, 0);
      expect(model.delivery!.deliveryTypeCharge, 0);
      expect(model.surge!.title, 'Late Night Fee');
      expect(model.surge!.customerNote, 'Open up this is FBI');
      expect(model.surge!.customerNoteStatus, 1);
      expect(model.surge!.price, 10);
      expect(model.surge!.priceType, 'percent');
      expect(model.surge!.zoneId, 1);
      expect(model.cashback!.calculatedAmount, 69.72);
      expect(model.cashback!.cashbackAmount, 10);
      expect(model.cashback!.cashbackType, 'percentage');
      expect(model.cashback!.id, 3);
    });

    test('handles string encoded numbers and free delivery', () {
      final json = jsonDecode('''
      {"tax":{"tax_amount":"12.50","tax_status":"included","tax_included":1},
       "delivery":{"delivery_charge":"0","original_delivery_charge":"120.5","base_delivery_charge":"100",
                   "surge_amount":"20.5","free_delivery_by":"admin","vehicle_id":"3"},
       "surge":{"title":"Rain","customer_note":"","customer_note_status":0,"price":"20.5","price_type":"amount"},
       "cashback":{"calculated_amount":"15","cashback_amount":"10","cashback_type":"amount","min_purchase":"100","max_discount":"50","id":4}}
      ''');

      final model = CheckoutSummaryModel.fromJson(json);

      expect(model.tax!.taxAmount, 12.5);
      expect(model.tax!.taxIncluded, 1);
      expect(model.tax!.totalPrice, null);
      expect(model.delivery!.deliveryCharge, 0);
      expect(model.delivery!.originalDeliveryCharge, 120.5);
      expect(model.delivery!.baseDeliveryCharge, 100);
      expect(model.delivery!.surgeAmount, 20.5);
      expect(model.delivery!.freeDeliveryBy, 'admin');
      expect(model.delivery!.vehicleId, 3);
      expect(model.surge!.customerNoteStatus, 0);
      expect(model.surge!.price, 20.5);
      expect(model.cashback!.calculatedAmount, 15);
      expect(model.cashback!.cashbackType, 'amount');
    });

    test('survives missing sections and unparsable values', () {
      final model = CheckoutSummaryModel.fromJson(jsonDecode('{}'));

      expect(model.tax, null);
      expect(model.delivery, null);
      expect(model.cashback, null);

      final partial = CheckoutSummaryModel.fromJson(jsonDecode(
        '{"tax":{},"delivery":{"delivery_charge":"abc"},"cashback":{}}',
      ));

      expect(partial.tax!.taxAmount, 0);
      expect(partial.tax!.taxIncluded, null);
      expect(partial.delivery!.deliveryCharge, null);
      expect(partial.delivery!.surgeAmount, 0);
      expect(partial.cashback!.calculatedAmount, 0);
    });
  });
}
