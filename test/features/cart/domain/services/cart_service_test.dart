import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart' hide Variation;
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';

class MockCartRepository extends Mock implements CartRepositoryInterface<OnlineCart> {}

Product buildProduct({
  int id = 1,
  int restaurantId = 10,
  double price = 100,
  double discount = 0,
  String discountType = 'amount',
  double restaurantDiscount = 0,
  List<Variation>? variations,
  List<AddOns>? addOns,
  int? cartQuantityLimit,
  String stockType = 'unlimited',
  int? itemStock,
}) {
  return Product(
    id: id,
    restaurantId: restaurantId,
    price: price,
    discount: discount,
    discountType: discountType,
    restaurantDiscount: restaurantDiscount,
    variations: variations ?? [],
    addOns: addOns ?? [],
    cartQuantityLimit: cartQuantityLimit,
    stockType: stockType,
    itemStock: itemStock,
  );
}

CartModel buildCartModel({
  int id = 1,
  required Product product,
  int quantity = 1,
  List<AddOn>? addOnIds,
  List<List<bool?>>? variations,
  List<List<int?>>? variationsStock,
}) {
  return CartModel(
    id, product.price!, product.price, 0, quantity,
    addOnIds ?? [], [], false, product,
    variations ?? [], product.cartQuantityLimit, variationsStock ?? [],
  );
}

void main() {
  late CartService cartService;
  late MockCartRepository mockCartRepository;

  setUpAll(() {
    registerFallbackValue(OnlineCart(null, null, null, '0', [], 1, [], [], [], 'food'));
  });

  setUp(() {
    mockCartRepository = MockCartRepository();
    cartService = CartService(cartRepositoryInterface: mockCartRepository);
  });

  group('cartQuantity', () {
    test('returns 0 when no bundle matches the restaurant', () {
      final quantity = cartService.cartQuantity(1, 10, []);
      expect(quantity, 0);
    });

    test('sums quantity of matching product across the restaurant bundle', () {
      final product = buildProduct(id: 5, restaurantId: 10);
      final bundleList = [
        CartBundleModel(restaurant: Restaurant(id: 10), carts: [
          buildCartModel(product: product, quantity: 2),
          buildCartModel(id: 2, product: product, quantity: 3),
          buildCartModel(id: 3, product: buildProduct(id: 6, restaurantId: 10), quantity: 9),
        ]),
      ];

      expect(cartService.cartQuantity(5, 10, bundleList), 5);
    });
  });

  group('isExistInCart', () {
    final product = buildProduct(id: 5, restaurantId: 10);
    final bundleList = [
      CartBundleModel(restaurant: Restaurant(id: 10), carts: [buildCartModel(product: product)]),
    ];

    test('returns (-1, -1) when the restaurant has no bundle', () {
      expect(cartService.isExistInCart(5, 99, bundleList), (-1, -1));
    });

    test('returns (bundleIndex, -1) when the bundle exists but not the product', () {
      expect(cartService.isExistInCart(999, 10, bundleList), (0, -1));
    });

    test('returns (bundleIndex, cartIndex) when the product is already in the cart', () {
      expect(cartService.isExistInCart(5, 10, bundleList), (0, 0));
    });
  });

  group('existAnotherRestaurantProduct', () {
    test('is false when every cart item belongs to the given restaurant', () {
      final cartList = [buildCartModel(product: buildProduct(restaurantId: 10))];
      expect(cartService.existAnotherRestaurantProduct(10, cartList), isFalse);
    });

    test('is true when a cart item belongs to a different restaurant', () {
      final cartList = [buildCartModel(product: buildProduct(restaurantId: 99))];
      expect(cartService.existAnotherRestaurantProduct(10, cartList), isTrue);
    });
  });

  group('setAvailableIndex', () {
    test('collapses back to -1 when the same index is tapped again', () {
      expect(cartService.setAvailableIndex(2, 2), -1);
    });

    test('opens the tapped index when a different one was open', () {
      expect(cartService.setAvailableIndex(3, 1), 3);
    });
  });

  group('prepareAddonList', () {
    test('resolves addOnIds to their matching product AddOns', () {
      final addOns = [AddOns(id: 1, name: 'Cheese', price: 5), AddOns(id: 2, name: 'Olive', price: 3)];
      final product = buildProduct(addOns: addOns);
      final cartModel = buildCartModel(product: product, addOnIds: [AddOn(id: 2, quantity: 1)]);

      final result = cartService.prepareAddonList(cartModel);

      expect(result, hasLength(1));
      expect(result.first.name, 'Olive');
    });
  });

  group('calculateAddonsPrice', () {
    test('adds price times quantity for every selected addon', () {
      final addOns = [AddOns(id: 1, name: 'Cheese', price: 5), AddOns(id: 2, name: 'Olive', price: 3)];
      final cartModel = buildCartModel(
        product: buildProduct(addOns: addOns),
        addOnIds: [AddOn(id: 1, quantity: 2), AddOn(id: 2, quantity: 3)],
      );

      final price = cartService.calculateAddonsPrice(addOns, 0, cartModel);

      expect(price, (5 * 2) + (3 * 3));
    });
  });

  group('variation pricing', () {
    Product productWithOneVariation({required double optionPrice}) {
      return buildProduct(
        variations: [
          Variation(name: 'Size', variationValues: [VariationValue(level: 'Large', optionPrice: optionPrice)]),
        ],
      );
    }

    test('calculateVariationPrice is 0 when the product has no variations', () {
      final cartModel = buildCartModel(product: buildProduct(variations: []));
      expect(cartService.calculateVariationPrice(cartModel, 0), 0);
    });

    test('calculateVariationPrice sums the selected option price per quantity', () {
      final product = productWithOneVariation(optionPrice: 20);
      final cartModel = buildCartModel(product: product, quantity: 2, variations: [[true]]);

      expect(cartService.calculateVariationPrice(cartModel, 0), 20 * 2);
    });

    test('calculateVariationWithoutDiscountPrice ignores an amount discount on variations', () {
      final product = productWithOneVariation(optionPrice: 20);
      final cartModel = buildCartModel(product: product, quantity: 1, variations: [[true]]);

      final price = cartService.calculateVariationWithoutDiscountPrice(cartModel, 0, 5, 'amount');

      expect(price, 20);
    });

    test('calculateVariationWithoutDiscountPrice applies a percent discount to the option price', () {
      final product = productWithOneVariation(optionPrice: 20);
      final cartModel = buildCartModel(product: product, quantity: 1, variations: [[true]]);

      final price = cartService.calculateVariationWithoutDiscountPrice(cartModel, 0, 10, 'percent');

      expect(price, 18);
    });
  });

  group('decideProductQuantity', () {
    test('decrements the quantity by one', () async {
      final cartList = [buildCartModel(product: buildProduct(), quantity: 3)];
      final quantity = await cartService.decideProductQuantity(cartList, false, 0);
      expect(quantity, 2);
    });

    test('increments the quantity when there is no stock limit', () async {
      final cartList = [buildCartModel(product: buildProduct(stockType: 'unlimited'), quantity: 3)];
      final quantity = await cartService.decideProductQuantity(cartList, true, 0);
      expect(quantity, 4);
    });

    test('increments the quantity while it stays under a limited item stock', () async {
      final cartList = [buildCartModel(product: buildProduct(stockType: 'limited', itemStock: 10), quantity: 3)];
      final quantity = await cartService.decideProductQuantity(cartList, true, 0);
      expect(quantity, 4);
    });
  });

  group('formatOnlineCartToLocalCart', () {
    test('maps price, discount and selected variations from the server payload', () {
      final product = Product(
        id: 1, restaurantId: 10, price: 100, discount: 10, discountType: 'amount', restaurantDiscount: 0,
        addOns: const [], variations: [
          Variation(name: 'Size', variationValues: [
            VariationValue(level: 'Small', optionPrice: 0, isSelected: false, currentStock: 5),
            VariationValue(level: 'Large', optionPrice: 20, isSelected: true, currentStock: 5),
          ]),
        ],
      );
      final onlineCart = OnlineCartModel(id: 1, price: 100, quantity: 2, addOnIds: [], addOnQtys: [], product: product);

      final result = cartService.formatOnlineCartToLocalCart(onlineCartModel: [onlineCart]);

      expect(result, hasLength(1));
      expect(result.first.discountedPrice, 90);
      expect(result.first.discountAmount, 10);
      expect(result.first.variations, [[false, true]]);
    });
  });

  group('repository delegation', () {
    test('addToCartOnline forwards the call and returns the repository response', () async {
      final onlineCart = OnlineCart(null, 1, 0, '10', [], 1, [], [], [], 'food', restaurantId: 10);
      final response = Response(statusCode: 200, body: []);
      when(() => mockCartRepository.addToCartOnline(onlineCart, 'guest-1')).thenAnswer((_) async => response);

      final result = await cartService.addToCartOnline(onlineCart, 'guest-1');

      expect(result, response);
      verify(() => mockCartRepository.addToCartOnline(onlineCart, 'guest-1')).called(1);
    });

    test('getCartBundleList returns null when the repository returns no response', () async {
      when(() => mockCartRepository.getCartBundleList(guestId: any(named: 'guestId'))).thenAnswer((_) async => null);

      final result = await cartService.getCartBundleList(guestId: 'guest-1');

      expect(result, isNull);
    });

    test('removeCartBundle forwards the repository result', () async {
      when(() => mockCartRepository.removeCartBundle(10, guestId: any(named: 'guestId'))).thenAnswer((_) async => true);

      final result = await cartService.removeCartBundle(10, guestId: 'guest-1');

      expect(result, isTrue);
    });
  });
}
