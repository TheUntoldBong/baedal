import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/checkout/screens/checkout_screen.dart';

CartModel food() => CartModel(
  1, 100, 100, 0, 1, const [], const [], false, Product(id: 1, price: 100, restaurantId: 3), const [], null, const [],
);

CartModel bundle() => CartModel.bogoBundle(
  bogoDetails: BogoCartDetails(
    bogoGroupId: 'group-1', bogoOfferId: 7, bundleId: 11, quantity: 1, bundlePrice: 100, totalPrice: 100,
    isAvailable: true, itemThumbnails: const [], buyItemThumbnails: const [], freeItemThumbnails: const [],
  ),
  restaurantId: 3,
);

void main() {
  group('a cart holding a bogo bundle', () {
    test('is recognised whichever line the bundle sits on', () {
      expect(CheckoutScreenState.cartHasBogoBundle([food(), bundle()]), true);
      expect(CheckoutScreenState.cartHasBogoBundle([bundle()]), true);
    });

    test('is not claimed for ordinary carts, or before the cart loads', () {
      expect(CheckoutScreenState.cartHasBogoBundle([food()]), false);
      expect(CheckoutScreenState.cartHasBogoBundle(const []), false);
      expect(CheckoutScreenState.cartHasBogoBundle(null), false);
    });
  });

  group('repeat order is offered', () {
    test('for the same carts it was offered for before the bundle rule existed', () {
      for(final List<CartModel> cart in <List<CartModel>>[[food()], [food(), food()]]) {
        expect(
          CheckoutScreenState.canOfferRepeatOrder(
            restaurant: Restaurant(orderSubscriptionActive: true), fromCart: true, cartList: cart,
          ),
          true,
        );
      }
    });

    test('for a cart of ordinary items at a store that takes subscriptions', () {
      expect(
        CheckoutScreenState.canOfferRepeatOrder(
          restaurant: Restaurant(orderSubscriptionActive: true), fromCart: true, cartList: [food()],
        ),
        true,
      );
    });
  });

  group('repeat order is not offered', () {
    test('when the cart holds a bogo bundle, which is enrolled for one order', () {
      expect(
        CheckoutScreenState.canOfferRepeatOrder(
          restaurant: Restaurant(orderSubscriptionActive: true), fromCart: true, cartList: [food(), bundle()],
        ),
        false,
      );
    });

    test('when the store does not take subscriptions', () {
      expect(
        CheckoutScreenState.canOfferRepeatOrder(
          restaurant: Restaurant(orderSubscriptionActive: false), fromCart: true, cartList: [food()],
        ),
        false,
      );
    });

    test('outside the cart flow, or before the store is known', () {
      expect(
        CheckoutScreenState.canOfferRepeatOrder(
          restaurant: Restaurant(orderSubscriptionActive: true), fromCart: false, cartList: [food()],
        ),
        false,
      );
      expect(
        CheckoutScreenState.canOfferRepeatOrder(restaurant: null, fromCart: true, cartList: [food()]),
        false,
      );
    });
  });
}
