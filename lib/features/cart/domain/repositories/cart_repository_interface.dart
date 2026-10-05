import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class CartRepositoryInterface<OnlineCart> extends RepositoryInterface<OnlineCart> {
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts);
  void addToSharedPrefCartBundleList(List<CartBundleModel> cartBundleList);
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId, {required int restaurantId});
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId);
  Future<Response> addBogoToCartOnline(int bogoId, int quantity, String? guestId, {String? contactPersonNumber});
  Future<Response> updateBogoBundleQuantityOnline(String bogoGroupId, int quantity, String? guestId);
  Future<bool> removeBogoBundleItemOnline(String bogoGroupId, String? guestId, {required int restaurantId});
  Future<List<OnlineCartModel>> getStoreCartItems(int? id, int? restaurantId);
  Future<bool> deleteFromCart(int? id, {String? guestId, required int restaurantId});
  Future<Response?> getCartBundleList({String? guestId});
  Future<bool> removeCartBundle(int? restaurantId, {String? guestId});
  Future<DiscountEligibilityModel?> getDiscountEligibility(int restaurantId, {String? guestId});
}