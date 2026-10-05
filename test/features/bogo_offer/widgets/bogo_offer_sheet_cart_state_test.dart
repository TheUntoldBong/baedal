import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart' as restaurant_model;
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_offer_details_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_quantity_button.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

class MockCartController extends GetxController with Mock implements CartController {}
class MockSplashController extends GetxController with Mock implements SplashController {}

BogoCartDetails details({int quantity = 1, int? bundleId = 11}) => BogoCartDetails(
  bogoGroupId: 'group-1', bogoOfferId: 7, bundleId: bundleId, offerTitle: 'Buy 1 Get 1', offerSlug: 'buy-1-get-1',
  quantity: quantity, bundlePrice: 100, totalPrice: 100.0 * quantity, isAvailable: true,
  itemThumbnails: const [], buyItemThumbnails: const [], freeItemThumbnails: const [],
);

BogoBundleModel bundle() => BogoBundleModel(
  bundleId: 11, bundlePrice: 100, finalPrice: 100, buyItems: const [], freeItems: const [],
  restaurant: restaurant_model.Restaurant(id: 3, name: 'Pizza Place'),
);

void main() {
  late MockCartController cart;

  setUpAll(() {
    registerFallbackValue(CartModel.bogoBundle(bogoDetails: details(), restaurantId: 3));
  });

  setUp(() {
    cart = MockCartController();
    when(() => cart.cartBundleList).thenReturn([CartBundleModel(carts: const [])]);
    when(() => cart.findBogoBundleInCart(any(), restaurantId: any(named: 'restaurantId'))).thenReturn(null);
    Get.put<CartController>(cart);

    final MockSplashController splash = MockSplashController();
    when(() => splash.configModel).thenReturn(ConfigModel(currencySymbol: '\$', currencySymbolDirection: 'left', digitAfterDecimalPoint: 2, timeformat: '12'));
    Get.put<SplashController>(splash);
  });

  tearDown(Get.reset);

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();
    Get.to(() => Scaffold(body: Builder(builder: (context) => TextButton(
      onPressed: () => BogoOfferDetailsBottomSheet.show(context, bundle: bundle(), remainingUses: 3),
      child: const Text('open'),
    ))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for the cart when it has not been loaded yet', (tester) async {
    when(() => cart.cartBundleList).thenReturn(const []);
    when(() => cart.getCartBundleList()).thenAnswer((_) async {});

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();
    Get.to(() => Scaffold(body: GetBuilder<CartController>(builder: (_) => Builder(builder: (context) => TextButton(
      onPressed: () => BogoOfferDetailsBottomSheet.show(context, bundle: bundle(), remainingUses: 3),
      child: const Text('open'),
    )))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    verify(() => cart.getCartBundleList()).called(1);
  });

  testWidgets('offers to add when the bundle is not in the cart', (tester) async {
    await openSheet(tester);

    expect(find.text('add_to_cart'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('offers to update, at the count already in the cart', (tester) async {
    when(() => cart.findBogoBundleInCart(any(), restaurantId: any(named: 'restaurantId')))
        .thenReturn(CartModel.bogoBundle(bogoDetails: details(quantity: 2), restaurantId: 3));

    await openSheet(tester);

    expect(find.text('update_in_cart'), findsOneWidget);
    expect(find.text('2'), findsOneWidget, reason: 'the count comes from the cart, not from 1');
  });

  testWidgets('updates the cart row rather than adding a second one', (tester) async {
    final CartModel inCart = CartModel.bogoBundle(bogoDetails: details(quantity: 2), restaurantId: 3);
    when(() => cart.findBogoBundleInCart(any(), restaurantId: any(named: 'restaurantId'))).thenReturn(inCart);
    when(() => cart.setBogoBundleQuantity(any(), any(), restaurantId: any(named: 'restaurantId'))).thenAnswer((_) async => true);

    await openSheet(tester);
    await tester.tap(find.descendant(of: find.byType(BogoQuantityButton), matching: find.byIcon(Icons.add)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('update_in_cart'));
    await tester.pump();
    await tester.pump();

    verify(() => cart.setBogoBundleQuantity(inCart, 3, restaurantId: 3)).called(1);
    verifyNever(() => cart.addBogoToCartOnline(any(), any()));
    expect(find.text('cart_updated'), findsOneWidget, reason: 'the customer is told it worked');

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('will not go past the uses the offer has left', (tester) async {
    when(() => cart.findBogoBundleInCart(any(), restaurantId: any(named: 'restaurantId')))
        .thenReturn(CartModel.bogoBundle(bogoDetails: details(quantity: 3), restaurantId: 3));

    await openSheet(tester);
    await tester.tap(find.descendant(of: find.byType(BogoQuantityButton), matching: find.byIcon(Icons.add)));
    await tester.pump();

    expect(find.text('3'), findsOneWidget, reason: 'three remaining uses, three already in the cart');

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
}
