import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service_interface.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:get/get_utils/get_utils.dart';

class CartService implements CartServiceInterface {
  final CartRepositoryInterface cartRepositoryInterface;
  CartService({required this.cartRepositoryInterface});

  @override
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    return cartRepositoryInterface.addMultipleCartItemOnline(carts);
  }

  @override
  List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel}) {

    List<CartModel> cartList = [];
    for (OnlineCartModel cart in onlineCartModel) {
      if(cart.bogoDetails != null) {
        cartList.add(CartModel.bogoBundle(bogoDetails: cart.bogoDetails!, restaurantId: cart.restaurantId));
        continue;
      }

      double price = cart.price!;
      double? discount = cart.product!.restaurantDiscount == 0 ? cart.product!.discount! : cart.product!.restaurantDiscount!;
      String? discountType = (cart.product!.restaurantDiscount == 0) ? cart.product!.discountType : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;

      double? discountAmount = price - discountedPrice;
      int? quantity = cart.quantity;

      List<List<bool?>> selectedFoodVariations = [];
      List<List<int?>> variationsStock = [];
      List<bool> collapsVariation = [];

      for(int index=0; index<cart.product!.variations!.length; index++) {
        selectedFoodVariations.add([]);
        collapsVariation.add(true);
        variationsStock.add([]);
        for(int i=0; i < cart.product!.variations![index].variationValues!.length; i++) {
          variationsStock[index].add(cart.product!.variations![index].variationValues![i].currentStock);
          if(cart.product!.variations![index].variationValues![i].isSelected ?? false){
            selectedFoodVariations[index].add(true);
          } else {
            selectedFoodVariations[index].add(false);
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];
      for (int index = 0; index < cart.addOnIds!.length; index++) {
        addOnIdList.add(AddOn(id: cart.addOnIds![index], quantity: cart.addOnQtys![index]));
        for (int i=0; i< cart.product!.addOns!.length; i++) {
          if(cart.addOnIds![index] == cart.product!.addOns![i].id) {
            addOnsList.add(AddOns(id: cart.product!.addOns![i].id, name: cart.product!.addOns![i].name, price: cart.product!.addOns![i].price));
          }
        }
      }
      int? quantityLimit = cart.product!.cartQuantityLimit;
      cartList.add(
        CartModel(
          cart.id, price, discountedPrice, discountAmount, quantity, addOnIdList,
          addOnsList, false, cart.product, selectedFoodVariations, quantityLimit, variationsStock,
        ),
      );
    }
    return cartList;
  }

  @override
  Future<DiscountEligibilityModel?> getDiscountEligibility(int restaurantId, {String? guestId}) async {
    return cartRepositoryInterface.getDiscountEligibility(restaurantId, guestId: guestId);
  }

  @override
  void addToSharedPrefCartList(List<CartBundleModel> cartBundleList) {
    cartRepositoryInterface.addToSharedPrefCartBundleList(cartBundleList);
  }


  @override
  Future<int> decideProductQuantity(List<CartModel> cartList, bool isIncrement, int index) async {
    int quantity = cartList[index].quantity!;
    if (isIncrement) {
      quantity = await _quantityLimitCheck(cartList[index].variations!, cartList[index].variationsStock!, cartList[index].product!.cartQuantityLimit, quantity, cartList[index].product!.stockType, cartList[index].product!.itemStock);
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  Future<int> _quantityLimitCheck(List<List<bool?>> selectedVariations, List<List<int?>> variationsStock, int? cartQuantityLimit, int quantity, String? stockType, int? itemStock) async {
    int qty = quantity;
    int? minimumStock;
    if(await _haveSelectedVariation(selectedVariations) && stockType != 'unlimited') {
      minimumStock = _minimumVariationStock(selectedVariations, variationsStock);
    }

    if(stockType != 'unlimited' && itemStock != null && qty >= itemStock) {
      showCustomSnackBar('maximum_food_quantity_limit'.tr);
    } else if(minimumStock != null && qty >= minimumStock) {
      showCustomSnackBar('${'maximum_variation_quantity_limit'.tr} $minimumStock');
    } else if(cartQuantityLimit != null && qty >= cartQuantityLimit && cartQuantityLimit != 0) {
      showCustomSnackBar('${'maximum_cart_quantity_limit'.tr} $cartQuantityLimit');
    } else {
      qty = qty + 1;
    }
    return qty;
  }

  Future<bool> _haveSelectedVariation(List<List<bool?>> selectedVariations) async{
    bool hasSelected = false;
    for(int i=0; i<selectedVariations.length; i++) {
      for(int j=0; j<selectedVariations[i].length; j++) {
        if(selectedVariations[i][j]!) {
          hasSelected = true;
        }
      }
    }
    return hasSelected;
  }

  int _minimumVariationStock(List<List<bool?>> selectedVariations, List<List<int?>> variationsStock) {
    List<int> stocks = [];
    for (int i=0; i<selectedVariations.length; i++) {
      for(int j=0; j<selectedVariations[i].length; j++) {
        if(selectedVariations[i][j]!) {
          stocks.add(variationsStock[i][j]!);
        }
      }
    }
    int minimumStock = stocks.reduce((curr, next) => curr < next? curr: next);
    return minimumStock;
  }

  @override
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId, {required int restaurantId}) async {
    return await cartRepositoryInterface.updateCartQuantityOnline(cartId, price, quantity, guestId, restaurantId: restaurantId);
  }

  @override
  (int bundleIndex, int cartIndex) isExistInCart(int? productID, int restaurantId, List<CartBundleModel> cartBundleList) {
    int bundleIndex = -1;
    for (int bIndex = 0; bIndex < cartBundleList.length; bIndex++) {
      if (cartBundleList[bIndex].restaurant?.id == restaurantId) {
        bundleIndex = bIndex;
        List<CartModel> carts = cartBundleList[bIndex].carts ?? [];
        for (int cIndex = 0; cIndex < carts.length; cIndex++) {
          if (carts[cIndex].product?.id == productID) {
            return (bIndex, cIndex);
          }
        }
        break;
      }
    }
    return (bundleIndex, -1);
  }

  @override
  bool existAnotherRestaurantProduct(int? restaurantID, List<CartModel> cartList) {
    for(CartModel cartModel in cartList) {
      if(cartModel.restaurantId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  @override
  int setAvailableIndex(int index, int notAvailableIndex) {
    int finalIndex = notAvailableIndex;
    if (notAvailableIndex == index) {
      finalIndex = -1;
    } else {
      finalIndex = index;
    }
    return finalIndex;
  }

  @override
  int cartQuantity(int productID, int restaurantId, List<CartBundleModel> cartBundleList) {
    int quantity = 0;

    if(cartBundleList.any((CartBundleModel bundle)=>bundle.restaurant?.id == restaurantId)){
      CartBundleModel cartBundleModel = cartBundleList.firstWhere((e)=>e.restaurant?.id == restaurantId);
      for(CartModel cart in cartBundleModel.carts!) {
        if(!cart.isBogoBundle && cart.product!.id == productID) {
          quantity += cart.quantity!;
        }
      }
    }
    return quantity;
  }

  @override
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    return await cartRepositoryInterface.addToCartOnline(cart, guestId);
  }

  @override
  Future<Response> addBogoToCartOnline(int bogoId, int quantity, String? guestId, {String? contactPersonNumber}) async {
    return await cartRepositoryInterface.addBogoToCartOnline(bogoId, quantity, guestId, contactPersonNumber: contactPersonNumber);
  }

  @override
  Future<Response> updateBogoBundleQuantityOnline(String bogoGroupId, int quantity, String? guestId) async {
    return await cartRepositoryInterface.updateBogoBundleQuantityOnline(bogoGroupId, quantity, guestId);
  }

  @override
  Future<bool> removeBogoBundleItemOnline(String bogoGroupId, String? guestId, {required int restaurantId}) async {
    return await cartRepositoryInterface.removeBogoBundleItemOnline(bogoGroupId, guestId, restaurantId: restaurantId);
  }

  @override
  Future<Response> updateCartOnline(OnlineCart cart, int? guestId) async {
    return await cartRepositoryInterface.update(cart.toJson(), guestId);
  }

  @override
  Future<List<OnlineCartModel>> getCartDataOnline(int? id, int? restaurantId) async {
    return await cartRepositoryInterface.getStoreCartItems(id, restaurantId);
  }

  @override
  Future<bool> removeCartItemOnline(int? cartId, String? guestId, int restaurantId) async {
    return await cartRepositoryInterface.deleteFromCart(cartId, guestId: guestId, restaurantId: restaurantId);
  }

  @override
  List<AddOns> prepareAddonList(CartModel cartModel) {
    List<AddOns> addOnList = [];
    for (var addOnId in cartModel.addOnIds!) {
      for(AddOns addOns in cartModel.product!.addOns!) {
        if(addOns.id == addOnId.id) {
          addOnList.add(addOns);
          break;
        }
      }
    }
    return addOnList;
  }

  @override
  double calculateAddonsPrice(List<AddOns> addOnList, double price, CartModel cartModel) {
    double addOnsPrice = price;
    for(int index=0; index<addOnList.length; index++) {
      addOnsPrice = addOnsPrice + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
    }
    return addOnsPrice;
  }

  @override
  double calculateVariationWithoutDiscountPrice(CartModel cartModel, double price, double? discount, String? discountType) {
    double variationWithoutDiscountPrice = price;
    if(cartModel.product!.variations!.isNotEmpty) {
      for(int index = 0; index< cartModel.product!.variations!.length; index++) {
        for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
          if(cartModel.variations![index][i]!) {
            variationWithoutDiscountPrice += (PriceConverter.convertWithDiscount(cartModel.product!.variations![index].variationValues![i].optionPrice!, discount, discountType, isVariation: true)! * cartModel.quantity!);
          }
        }
      }
    } else {
      variationWithoutDiscountPrice = 0;
    }
    return variationWithoutDiscountPrice;
  }

  @override
  double calculateVariationPrice(CartModel cartModel, double price) {
    double variationPrice = price;
    if(cartModel.product!.variations!.isNotEmpty) {
      for(int index = 0; index< cartModel.product!.variations!.length; index++) {
        for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
          if(cartModel.variations![index][i]!) {
            variationPrice += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    } else {
      variationPrice = 0;
    }
    return variationPrice;
  }

  @override
  Future<List<CartBundleModel>?> getCartBundleList({String? guestId}) async {
    final response =  await cartRepositoryInterface.getCartBundleList(guestId: guestId);
    if(response == null) {
      return null;
    }
    List<CartBundleModel> newCartList = [];
    response.body.forEach((cart) {
      newCartList.add(CartBundleModel.fromJson(cart));
    });
    for(int i =0; i< newCartList.length; i++){
      newCartList[i].carts = formatOnlineCartToLocalCart(
          onlineCartModel: List.generate((response.body[i]["carts"].length ?? 0),(index){
            return OnlineCartModel.fromJson(response.body[i]["carts"][index]);
        }
      ));
    }
    return newCartList;
  }

  @override
  Future<bool> removeCartBundle(int? restaurantId, {String? guestId}) async {
    return await cartRepositoryInterface.removeCartBundle(restaurantId, guestId: guestId);
  }

}