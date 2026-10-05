import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository implements CartRepositoryInterface<OnlineCart> {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    List<Map<String, dynamic>> cartList = [];
    for (var cart in carts) {
      cartList.add(cart.toJson());
    }
    return await apiClient.postData(AppConstants.addMultipleItemCartUri, {'item_list': cartList});
  }

  @override
  void addToSharedPrefCartBundleList(List<CartBundleModel> cartBundleList) {}

  @override
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId, {required int restaurantId}) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
      "restaurant_id": restaurantId,
    };
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', data);
    return (response.statusCode == 200);
  }

  @override
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    Response response = await apiClient.postData('${AppConstants.addCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart.toJson(), handleError: false);
    return response;
  }

  @override
  Future<Response> addBogoToCartOnline(int bogoId, int quantity, String? guestId, {String? contactPersonNumber}) async {
    Map<String, dynamic> body = {
      'bogo_id': bogoId,
      'quantity': quantity,
      if(contactPersonNumber != null && contactPersonNumber.isNotEmpty) 'contact_person_number': contactPersonNumber,
    };
    Response response = await apiClient.postData('${AppConstants.addCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', body, handleError: false);
    return response;
  }

  @override
  Future<bool> deleteFromCart(int? id, {String? guestId, required int restaurantId}) async {
    Response response = await apiClient.postData('${AppConstants.removeItemCartUri}?cart_id=$id${guestId != null ? '&guest_id=$guestId' : ''}&restaurant_id=$restaurantId', {"_method": "delete"});
    return (response.statusCode == 200);
  }

  @override
  Future<Response> updateBogoBundleQuantityOnline(String bogoGroupId, int quantity, String? guestId) async {
    Map<String, dynamic> data = {
      "bogo_group_id": bogoGroupId,
      "quantity": quantity,
    };
    return await apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', data, handleError: false);
  }

  @override
  Future<bool> removeBogoBundleItemOnline(String bogoGroupId, String? guestId, {required int restaurantId}) async {
    Response response = await apiClient.postData(
      '${AppConstants.removeItemCartUri}?bogo_group_id=$bogoGroupId${guestId != null ? '&guest_id=$guestId' : ''}&restaurant_id=$restaurantId',
      {"_method": "delete"}, handleError: false,
    );
    return (response.statusCode == 200);
  }

  @override
  Future<DiscountEligibilityModel?> getDiscountEligibility(int restaurantId, {String? guestId}) async {
    Response response = await apiClient.getData(
      '${AppConstants.cartDiscountEligibilityUri}?restaurant_id=$restaurantId${guestId != null ? '&guest_id=$guestId' : ''}',
    );
    if(response.statusCode == 200 && response.body != null) {
      return DiscountEligibilityModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<List<OnlineCartModel>> getStoreCartItems(int? id, int? restaurantId) async {
    List<OnlineCartModel> onlineCartList = [];
    Response response = await apiClient.getData('${AppConstants.getStoreCartListUri}${restaurantId != null ? '?restaurant_id=$restaurantId' : ''}${id != null ? '${restaurantId != null ? '&' : '?'}guest_id=$id' : ''}');
    if(response.statusCode == 200) {
      onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
    }
    return onlineCartList;
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Response> update(Map<String, dynamic> cart, int? id) async {
    return await _updateCartOnline(cart, id);
  }

  Future<Response> _updateCartOnline(Map<String, dynamic> cart, int? guestId) async {
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${guestId != null ? '?guest_id=$guestId' : ''}', cart, handleError: false);
    return response;
  }

  @override
  Future add(OnlineCart value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<Response?> getCartBundleList({String? guestId}) async {
    Response response = await apiClient.getData('${AppConstants.getAllCartListUri}${guestId != null ? '?guest_id=$guestId' : ''}');
    if (response.statusCode == 200) {
      return response;
    }
    return null;
  }

  @override
  Future<bool> removeCartBundle(int? restaurantId, {String? guestId}) async {
    final List<String> queries = [
      if(restaurantId != null) 'restaurant_id=$restaurantId',
      if(guestId != null) 'guest_id=$guestId',
    ];
    Response response = await apiClient.postData(
      '${AppConstants.removeCartBundleUri}${queries.isEmpty ? '' : '?${queries.join('&')}'}',
      {"_method": "delete"},
    );
    return (response.statusCode == 200);
  }

  @override
  Future<dynamic> delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }


}
