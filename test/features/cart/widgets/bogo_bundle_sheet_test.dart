import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_quantity_button.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_product_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

class MockCartController extends GetxController with Mock implements CartController {}
class MockBogoOfferController extends GetxController with Mock implements BogoOfferController {}
class MockSplashController extends GetxController with Mock implements SplashController {}

BogoCartDetails details({int quantity = 1, int? bundleId = 11}) => BogoCartDetails(
  bogoGroupId: 'group-1', bogoOfferId: 7, bundleId: bundleId, offerTitle: 'Buy 1 Get 1', offerSlug: 'buy-1-get-1',
  quantity: quantity, bundlePrice: 100, totalPrice: 100.0 * quantity, isAvailable: true,
  itemThumbnails: const [], buyItemThumbnails: const [], freeItemThumbnails: const [],
);

void main() {
  late MockCartController cart;

  setUpAll(() {
    registerFallbackValue(CartModel.bogoBundle(bogoDetails: details(), restaurantId: 3));
  });

  setUp(() {
    cart = MockCartController();
    when(() => cart.isLoading).thenReturn(false);
    Get.put<CartController>(cart);

    final MockBogoOfferController bogo = MockBogoOfferController();
    when(() => bogo.getCachedOfferDetails(any())).thenAnswer((_) async => BogoOfferDetailsResponseModel(
      offerLabel: 'BUY 1 GET 1', remainingUses: 3,
      bundles: [BogoBundleModel(bundleId: 11, bundlePrice: 100, finalPrice: 100, buyItems: const [], freeItems: const [])],
    ));
    Get.put<BogoOfferController>(bogo);

    final MockSplashController splash = MockSplashController();
    when(() => splash.configModel).thenReturn(ConfigModel(currencySymbol: '\$', currencySymbolDirection: 'left', digitAfterDecimalPoint: 2, timeformat: '12'));
    Get.put<SplashController>(splash);
  });

  tearDown(Get.reset);

  testWidgets('the details sheet reopens after a quantity update', (tester) async {
    when(() => cart.setBogoBundleQuantity(any(), any(), restaurantId: any(named: 'restaurantId')))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();

    final ValueNotifier<CartModel> row = ValueNotifier(CartModel.bogoBundle(bogoDetails: details(), restaurantId: 3));
    when(() => cart.setBogoBundleQuantity(any(), any(), restaurantId: any(named: 'restaurantId')))
        .thenAnswer((invocation) async {
          row.value = CartModel.bogoBundle(bogoDetails: details(quantity: invocation.positionalArguments[1] as int), restaurantId: 3);
          return true;
        });

    Get.to(() => Scaffold(
      body: ValueListenableBuilder<CartModel>(
        valueListenable: row,
        builder: (context, value, _) => CartProductWidget(
          cart: value, cartIndex: 0, addOns: const [], isAvailable: true, isRestaurantOpen: true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy 1 Get 1'));
    await tester.pumpAndSettle();
    expect(find.text('update_in_cart'), findsOneWidget, reason: 'the sheet opens on the first tap');

    await tester.tap(find.descendant(of: find.byType(BogoQuantityButton), matching: find.byIcon(Icons.add)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('update_in_cart'));
    await tester.pumpAndSettle();
    expect(find.text('update_in_cart'), findsNothing, reason: 'the sheet closes once the cart is updated');

    expect(find.text('cart_updated'), findsOneWidget, reason: 'the customer is told it worked');

    await tester.tap(find.text('Buy 1 Get 1'));
    await tester.pumpAndSettle();
    expect(find.text('update_in_cart'), findsOneWidget, reason: 'and opens again on the next tap');

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('opens for a cart row that carries no bundle id', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();

    Get.to(() => Scaffold(
      body: CartProductWidget(
        cart: CartModel.bogoBundle(bogoDetails: details(bundleId: null), restaurantId: 3),
        cartIndex: 0, addOns: const [], isAvailable: true, isRestaurantOpen: true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy 1 Get 1'));
    await tester.pumpAndSettle();

    expect(find.text('update_in_cart'), findsOneWidget);
  });
}
