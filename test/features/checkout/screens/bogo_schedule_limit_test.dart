import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/checkout/screens/checkout_screen.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/order_place_button.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/time_slot_bottom_sheet.dart';

CartModel food() => CartModel(
  1, 100, 100, 0, 1, const [], const [], false, Product(id: 1, price: 100, restaurantId: 3), const [], null, const [],
);

CartModel bundle({String? endsAt}) => CartModel.bogoBundle(
  bogoDetails: BogoCartDetails(
    bogoGroupId: 'group-1', bogoOfferId: 7, bundleId: 11, quantity: 1, bundlePrice: 100, totalPrice: 100,
    offerEndDate: endsAt, isAvailable: true,
    itemThumbnails: const [], buyItemThumbnails: const [], freeItemThumbnails: const [],
  ),
  restaurantId: 3,
);

void main() {
  group('when the cart stops being schedulable', () {
    test('is the end of the offer it holds', () {
      expect(
        CheckoutScreenState.bundleOfferEndsAt([food(), bundle(endsAt: '2026-08-29 12:27:00')]),
        DateTime(2026, 8, 29, 12, 27),
      );
    });

    test('is the earliest end when the cart holds more than one offer', () {
      expect(
        CheckoutScreenState.bundleOfferEndsAt([
          bundle(endsAt: '2026-09-11 10:00:00'),
          bundle(endsAt: '2026-08-29 12:27:00'),
        ]),
        DateTime(2026, 8, 29, 12, 27),
      );
    });

    test('is never, for an open ended offer or a cart without one', () {
      expect(CheckoutScreenState.bundleOfferEndsAt([bundle()]), null);
      expect(CheckoutScreenState.bundleOfferEndsAt([bundle(endsAt: '')]), null);
      expect(CheckoutScreenState.bundleOfferEndsAt([bundle(endsAt: 'not a date')]), null);
      expect(CheckoutScreenState.bundleOfferEndsAt([food()]), null);
      expect(CheckoutScreenState.bundleOfferEndsAt(null), null);
    });
  });

  group('a slot may be chosen', () {
    final DateTime endsAt = DateTime(2026, 8, 29, 12, 27);

    test('while it starts inside the offer', () {
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 29, 12, 0), endsAt), true);
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 29, 12, 27), endsAt), true, reason: 'the end itself still counts');
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 20, 9, 0), endsAt), true);
    });

    test('but not after the offer has ended', () {
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 29, 12, 28), endsAt), false);
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 30, 9, 0), endsAt), false);
    });

    test('and any slot at all when the offer is open ended', () {
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2030, 1, 1), null), true);
    });
  });

  group('a dine in arrival', () {
    final DateTime endsAt = DateTime(2026, 8, 29, 12, 27);

    test('is judged against the offer end like a delivery slot is', () {
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 29, 11, 0), endsAt), true);
      expect(OrderPlaceButton.isScheduleWithinOffer(DateTime(2026, 8, 29, 13, 0), endsAt), false);
    });
  });

  group('a day is offered in the picker', () {
    final DateTime endsAt = DateTime(2026, 8, 29, 12, 27);

    test('up to and including the day the offer ends, even late in it', () {
      expect(TimeSlotBottomSheet.isDayWithinLimit(DateTime(2026, 8, 29, 23, 30), endsAt), true);
      expect(TimeSlotBottomSheet.isDayWithinLimit(DateTime(2026, 8, 28), endsAt), true);
    });

    test('and not after it', () {
      expect(TimeSlotBottomSheet.isDayWithinLimit(DateTime(2026, 8, 30), endsAt), false);
    });

    test('with no limit at all for an open ended offer', () {
      expect(TimeSlotBottomSheet.isDayWithinLimit(DateTime(2030, 1, 1), null), true);
    });
  });
}
