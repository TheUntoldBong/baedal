
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';

abstract class CartServiceInterface {
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts);
  List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel});
  void addToSharedPrefCartList(List<CartBundleModel> cartBundleList);
  Future<int> decideProductQuantity(List<CartModel> cartList, bool isIncrement, int index);
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId, {required int restaurantId});
  (int bundleIndex, int cartIndex) isExistInCart(int? productID, int restaurantId, List<CartBundleModel> cartBundleList);
  bool existAnotherRestaurantProduct(int? restaurantID, List<CartModel> cartList);
  int setAvailableIndex(int index, int notAvailableIndex);
  int cartQuantity(int productID, int restaurantId, List<CartBundleModel> cartBundleList);
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId);
  Future<Response> addBogoToCartOnline(int bogoId, int quantity, String? guestId, {String? contactPersonNumber});
  Future<Response> updateBogoBundleQuantityOnline(String bogoGroupId, int quantity, String? guestId);
  Future<bool> removeBogoBundleItemOnline(String bogoGroupId, String? guestId, {required int restaurantId});
  Future<Response> updateCartOnline(OnlineCart cart, int? guestId);
  Future<List<OnlineCartModel>> getCartDataOnline(int? id, int? restaurantId);
  Future<bool> removeCartItemOnline(int? cartId, String? guestId, int restaurantId);
  List<AddOns> prepareAddonList(CartModel cartModel);
  double calculateAddonsPrice(List<AddOns> addOnList, double price, CartModel cartModel);
  double calculateVariationWithoutDiscountPrice(CartModel cartModel, double price, double? discount, String? discountType);
  double calculateVariationPrice(CartModel cartModel, double price);
  Future<List<CartBundleModel>?> getCartBundleList({String? guestId});
  Future<bool> removeCartBundle(int? restaurantId, {String? guestId});
  Future<DiscountEligibilityModel?> getDiscountEligibility(int restaurantId, {String? guestId});
}