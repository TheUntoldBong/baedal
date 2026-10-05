import 'package:stackfood_multivendor/api/api_checker.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/cart_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_bundle_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/services/cart_service_interface.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;
  CartController({required this.cartServiceInterface});

  List<CartModel> cartList(int restaurantId) {
    int bundleIndex = getBundleIndexByRestaurantId(restaurantId);
    if(bundleIndex == -1) return [];
    return _cartBundleList[bundleIndex].carts ?? [];
  }

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _restaurantDiscountPrice = 0;
  double get restaurantDiscountPrice => _restaurantDiscountPrice;

  DiscountEligibilityModel? _discountEligibility;
  int? _discountEligibilityRestaurantId;

  DiscountEligibilityModel? discountEligibility(int restaurantId) =>
      _discountEligibilityRestaurantId == restaurantId ? _discountEligibility : null;

  bool isDiscountEligibilityResolved(int restaurantId) => discountEligibility(restaurantId) != null;

  double _addOnsPrice = 0;
  double get addOns => _addOnsPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  int? _derivedRestaurantId;
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];

  int _loadingCount = 0;
  bool get isLoading => _loadingCount > 0;

  void _beginLoading() {
    _loadingCount++;
    if(_loadingCount == 1) {
      _publish();
    }
  }

  void _endLoading() {
    if(_loadingCount > 0) {
      _loadingCount--;
    }
    _publish();
  }

  void _publish() {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if(phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => update());
    } else {
      update();
    }
  }

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  List<CartBundleModel> _cartBundleList = [];
  List<CartBundleModel> get cartBundleList => _cartBundleList;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  int? _deletingRestaurantId;
  int? get deletingRestaurantId => _deletingRestaurantId;

  bool _isClearingAll = false;
  bool get isClearingAll => _isClearingAll;


  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setNeedExtraPackage(bool needExtraPackage) {
    _needExtraPackage = needExtraPackage;
    update();
  }

  ({
    double itemPrice, double itemDiscountPrice, double addOnsPrice, double variationPrice,
    double restaurantDiscountPrice, double subTotal, List<List<AddOns>> addOnsList, List<bool> availableList,
  }) _computeTotals(int restaurantId) {
    double itemPrice = 0;
    double itemDiscountPrice = 0;
    double addOnsPrice = 0;
    double totalVariationPrice = 0;
    List<bool> availableList = [];
    List<List<AddOns>> addOnsList = [];
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    int currentBundleIndex = getBundleIndexByRestaurantId(restaurantId);
    List<CartModel> currentCartList = currentBundleIndex == -1 ? [] : (_cartBundleList[currentBundleIndex].carts ?? []);
    for (var cartModel in currentCartList) {

      if(cartModel.isBogoBundle) {
        addOnsList.add([]);
        availableList.add(cartModel.bogoDetails!.isAvailable);
        itemPrice += cartModel.bogoDetails!.totalPrice;
        continue;
      }

      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      double? discount = cartModel.product!.discount;
      String? discountType = cartModel.product!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      addOnsList.add(addOnList);
      availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

      addOnsPrice = cartServiceInterface.calculateAddonsPrice(addOnList, addOnsPrice, cartModel);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(cartModel, variationWithoutDiscountPrice, discount, discountType);
      variationPrice = cartServiceInterface.calculateVariationPrice(cartModel, variationPrice);

      double price = (cartModel.product!.price! * cartModel.quantity!);
      double discountPrice =  (price - (PriceConverter.convertWithDiscount(cartModel.product!.price!, discount, discountType)! * cartModel.quantity!));

      totalVariationPrice += variationPrice;
      itemPrice = itemPrice + price;
      itemDiscountPrice = itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);
    }
    double subTotal = (itemPrice - itemDiscountPrice) + addOnsPrice + totalVariationPrice;
    double restaurantDiscountPrice = _eligibleDiscountOf(restaurantId, subTotal);

    return (
      itemPrice: itemPrice, itemDiscountPrice: itemDiscountPrice, addOnsPrice: addOnsPrice,
      variationPrice: totalVariationPrice, restaurantDiscountPrice: restaurantDiscountPrice,
      subTotal: subTotal - restaurantDiscountPrice, addOnsList: addOnsList, availableList: availableList,
    );
  }

  double calculationCart(int restaurantId){
    final totals = _computeTotals(restaurantId);
    _itemPrice = totals.itemPrice;
    _itemDiscountPrice = totals.itemDiscountPrice;
    _addOnsPrice = totals.addOnsPrice;
    _variationPrice = totals.variationPrice;
    _restaurantDiscountPrice = totals.restaurantDiscountPrice;
    _subTotal = totals.subTotal;
    _addOnsList = totals.addOnsList;
    _availableList = totals.availableList;
    _derivedRestaurantId = restaurantId;
    return _subTotal;
  }

  double subTotalOf(int restaurantId) => _computeTotals(restaurantId).subTotal;

  void _recalculateDerived() {
    if(_derivedRestaurantId != null) {
      calculationCart(_derivedRestaurantId!);
    }
  }

  double _eligibleDiscountOf(int restaurantId, double subTotal) {
    final DiscountEligibilityModel? eligibility = discountEligibility(restaurantId);
    if (eligibility == null || !eligibility.isQualified) return 0;
    return eligibility.discountAmount.clamp(0, subTotal > 0 ? subTotal : 0).toDouble();
  }

  Future<void> getDiscountEligibility(int restaurantId) async {
    _discountEligibility = null;
    _discountEligibilityRestaurantId = restaurantId;
    update();

    final DiscountEligibilityModel? eligibility = await cartServiceInterface.getDiscountEligibility(
      restaurantId, guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
    );
    if(_discountEligibilityRestaurantId != restaurantId) return;

    _discountEligibility = eligibility ?? const DiscountEligibilityModel();
    calculationCart(restaurantId);
    update();
  }

  double calculationCartGlobal(){
    double totalPrice = 0.0;
    for(int i =0; i< cartBundleList.length; i++){
      double itemPrice = 0 ;
      double itemDiscountPrice = 0;
      double subTotal = 0;
      double addOnsPrice = 0;
      List availableList= [];
      List addOnsList = [];
      double variationPrice0 = 0;
      double variationWithoutDiscountPrice = 0;
      double variationPrice = 0;
      for (var cartModel in cartBundleList[i].carts!) {

        if(cartModel.isBogoBundle) {
          addOnsList.add([]);
          availableList.add(cartModel.bogoDetails!.isAvailable);
          itemPrice += cartModel.bogoDetails!.totalPrice;
          continue;
        }

        variationWithoutDiscountPrice = 0;
        variationPrice = 0;

        double? discount = cartModel.product!.discount;
        String? discountType = cartModel.product!.discountType;

        List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

        addOnsList.add(addOnList);
        availableList.add(DateConverter.isAvailable(cartModel.product!.availableTimeStarts, cartModel.product!.availableTimeEnds));

        addOnsPrice = cartServiceInterface.calculateAddonsPrice(addOnList, addOnsPrice, cartModel);

        variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(cartModel, variationWithoutDiscountPrice, discount, discountType);
        variationPrice = cartServiceInterface.calculateVariationPrice(cartModel, variationPrice);

        double price = (cartModel.product!.price! * cartModel.quantity!);
        double discountPrice =  (price - (PriceConverter.convertWithDiscount(cartModel.product!.price!, discount, discountType)! * cartModel.quantity!));

        variationPrice0 += variationPrice;
        itemPrice = itemPrice + price;
        itemDiscountPrice = itemDiscountPrice + discountPrice + (variationPrice - variationWithoutDiscountPrice);

        debugPrint('==check : ${cartBundleList[i].carts!.indexOf(cartModel)} ====> $itemDiscountPrice = $itemDiscountPrice + $discountPrice + ($variationPrice - $variationWithoutDiscountPrice)');
      }
      subTotal = (itemPrice - itemDiscountPrice) + addOnsPrice + variationPrice0;
      totalPrice += subTotal;
    }
    return totalPrice;
  }

  Future<int?> reorderAddToCart(List<OnlineCart> cartList) async {
    return _addMultipleCartItemOnline(cartList);
  }

  int itemCountOfGlobalCart(){
    int count = 0;
    for(int i =0; i < cartBundleList.length; i++){
      count += cartBundleList[i].carts?.length ?? 0;
    }
    return count;
  }

  int getBundleIndexByRestaurantId(int restaurantId){
    for (int bIndex = 0; bIndex < (cartBundleList.length); bIndex++) {
      if (cartBundleList[bIndex].restaurant?.id == restaurantId) {
        return bIndex;
      }
    }
    return -1;
  }

  int _cartIndexById(List<CartModel> carts, int? id) {
    if(id == null) return -1;
    for(int i = 0; i < carts.length; i++) {
      if(carts[i].id == id) return i;
    }
    return -1;
  }

  Future<void> setQuantity(bool isIncrement, CartModel cart, {int? cartIndex, required int restaurantId, int? bundleIndex}) async {
    if(isLoading) return;
    bundleIndex ??= getBundleIndexByRestaurantId(restaurantId);
    if(bundleIndex < 0 || bundleIndex >= _cartBundleList.length) return;

    final List<CartModel> carts = _cartBundleList[bundleIndex].carts ?? [];
    int index = (cartIndex != null && cartIndex >= 0 && cartIndex < carts.length && carts[cartIndex].id == cart.id)
        ? cartIndex : _cartIndexById(carts, cart.id);
    if(index == -1) return;

    _beginLoading();
    try {
      carts[index].quantity = await cartServiceInterface.decideProductQuantity(carts, isIncrement, index);
      cartServiceInterface.addToSharedPrefCartList(_cartBundleList);

      calculationCart(restaurantId);
      await updateCartQuantityOnline(carts[index].id!, carts[index].price!, carts[index].quantity!, restaurantId);
    } finally {
      _endLoading();
    }
  }

  Future<void> removeFromCart({required int cartIndex, required int restaurantId}) async {
    if(isLoading) return;
    int bIndex = getBundleIndexByRestaurantId(restaurantId);
    if(bIndex == -1) return;

    final List<CartModel> carts = _cartBundleList[bIndex].carts ?? [];
    if(cartIndex < 0 || cartIndex >= carts.length) return;

    int? cartId = carts[cartIndex].id;
    if(cartId == null) return;

    _beginLoading();
    try {
      carts.removeAt(cartIndex);
      _cartBundleList[bIndex].restaurant?.itemCount = carts.length;
      _recalculateDerived();
      update();
      await removeCartItemOnline(cartId, restaurantId);
    } finally {
      _endLoading();
    }
  }

  Future<void> clearCartList() async {
    _cartBundleList = [];
    _recalculateDerived();
    update();
  }

  void removeAddOn(int bundleIndex, int index, int addOnIndex) {
    if(bundleIndex < 0 || bundleIndex >= _cartBundleList.length) return;

    final List<CartModel> carts = _cartBundleList[bundleIndex].carts ?? [];
    if(index < 0 || index >= carts.length) return;

    final List<AddOn> addOnIds = carts[index].addOnIds ?? [];
    if(addOnIndex < 0 || addOnIndex >= addOnIds.length) return;

    final int? bundleRestaurantId = _cartBundleList[bundleIndex].restaurant?.id;
    if(bundleRestaurantId == null) return;

    addOnIds.removeAt(addOnIndex);
    cartServiceInterface.addToSharedPrefCartList(_cartBundleList);
    calculationCart(bundleRestaurantId);
    update();
  }

  (int bundleIndex, int cartIndex) isExistInCart(int? productID, int restaurantId,) {
    return cartServiceInterface.isExistInCart(productID, restaurantId, cartBundleList);
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}){
    _notAvailableIndex = cartServiceInterface.setAvailableIndex(index, _notAvailableIndex);
    if(willUpdate) {
      update();
    }
  }

  int cartQuantity(int productID, int restaurantId) {
    return cartServiceInterface.cartQuantity(productID, restaurantId, _cartBundleList);
  }

  Future<void> addToCartOnline(OnlineCart onlineCart, {CartModel? existCartData, bool popAfterAdd = false}) async {
    if(AddressHelper.getAddressFromSharedPref() == null) {
      Get.find<SplashController>().navigateToLocationScreen('home');
      return;
    }

    _beginLoading();
    try {
      Response response = await cartServiceInterface.addToCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

      if(response.statusCode == 200) {
        List<OnlineCartModel> onlineCartList = [];
        response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
        List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        await _updateGlobalCartData(onlineCart.restaurantId!, tempCartList);
        calculationCart(onlineCart.restaurantId!);
        if(popAfterAdd) {
          Get.back();
        }
        if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
          showCartSnackBarWidget(restaurantId: onlineCartList.first.product?.restaurantId);
        }
      } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
        showCustomSnackBar(response.body['errors'][0]['message']);
        Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
      } else {
        ApiChecker.checkApi(response);
      }
    } finally {
      _endLoading();
    }
  }

  Future<bool> addBogoToCartOnline(int bogoId, int quantity, {String? contactPersonNumber}) async {
    if(AddressHelper.getAddressFromSharedPref() == null) {
      Get.find<SplashController>().navigateToLocationScreen('home');
      return false;
    }

    _beginLoading();
    try {
      Response response = await cartServiceInterface.addBogoToCartOnline(
        bogoId, quantity, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), contactPersonNumber: contactPersonNumber,
      );

      bool isSuccess = response.statusCode == 200;
      if(isSuccess) {
        List<OnlineCartModel> onlineCartList = [];
        for (var cart in (response.body['data'] as List)) {
          onlineCartList.add(OnlineCartModel.fromJson(cart));
        }
        List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        int? restaurantId = onlineCartList.isNotEmpty ? (onlineCartList.first.restaurantId ?? onlineCartList.first.product?.restaurantId) : null;
        if(restaurantId != null) {
          await _updateGlobalCartData(restaurantId, tempCartList);
          calculationCart(restaurantId);
        }
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _endLoading();
    }
  }

  Future<void> updateBogoBundleQuantity(bool isIncrement, CartModel cart, {required int restaurantId}) async {
    if(!cart.isBogoBundle) return;
    await setBogoBundleQuantity(cart, (cart.quantity ?? 1) + (isIncrement ? 1 : -1), restaurantId: restaurantId);
  }

  CartModel? findBogoBundleInCart(int? bundleId, {int? restaurantId}) {
    if(bundleId == null) {
      return null;
    }
    for(final CartBundleModel bundle in _cartBundleList) {
      if(restaurantId != null && bundle.restaurant?.id != restaurantId) {
        continue;
      }
      for(final CartModel cart in bundle.carts ?? const <CartModel>[]) {
        if(cart.isBogoBundle && cart.bogoDetails?.bundleId == bundleId) {
          return cart;
        }
      }
    }
    return null;
  }

  Future<bool> setBogoBundleQuantity(CartModel cart, int quantity, {required int restaurantId}) async {
    if(isLoading || !cart.isBogoBundle || quantity < 1) return false;

    _beginLoading();
    try {
      Response response = await cartServiceInterface.updateBogoBundleQuantityOnline(
        cart.bogoDetails!.bogoGroupId, quantity, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
      );
      final bool isSuccess = response.statusCode == 200;
      if(isSuccess) {
        await getCartDataOnline(restaurantId);
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _endLoading();
    }
  }

  Future<void> removeBogoBundle(CartModel cart, {required int restaurantId}) async {
    if(isLoading || !cart.isBogoBundle) return;

    _beginLoading();
    try {
      await cartServiceInterface.removeBogoBundleItemOnline(
        cart.bogoDetails!.bogoGroupId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), restaurantId: restaurantId,
      );
      await getCartDataOnline(restaurantId);
    } finally {
      _endLoading();
    }
  }

  Future<void> _updateGlobalCartData(int restaurantId, List<CartModel> cartList)async{
    int bundleIndex = getBundleIndexByRestaurantId(restaurantId);
    if(bundleIndex == -1){
      await getCartBundleList();
    }else{
      _cartBundleList[bundleIndex].carts = cartList;
      _cartBundleList[bundleIndex].restaurant?.itemCount = cartList.length;
    }
    _recalculateDerived();
  }

  Future<int?> _addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    _beginLoading();
    try {
      Response response = await cartServiceInterface.addMultipleCartItemOnline(cartList);
      if(response.statusCode == 200) {
        List<OnlineCartModel> onlineCartList = [];
        response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
        List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        await _updateGlobalCartData(cartList.first.restaurantId!, tempCartList);
        calculationCart(cartList.first.restaurantId!);
      }
      return response.statusCode;
    } finally {
      _endLoading();
    }
  }

  Future<void> updateCartOnline(OnlineCart onlineCart, {CartModel? existCartData}) async {
    _beginLoading();
    try {
      Response response = await cartServiceInterface.updateCartOnline(onlineCart, AuthHelper.isLoggedIn() ? null : int.parse(AuthHelper.getGuestId()));
      if(response.statusCode == 200) {
        List<OnlineCartModel> onlineCartList = [];
        response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
        List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        await _updateGlobalCartData(onlineCart.restaurantId!, tempCartList);
        calculationCart(onlineCart.restaurantId!);
        Get.back();
        if(!Get.currentRoute.contains(RouteHelper.restaurant)) {
          showCartSnackBarWidget();
        }
      } else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'stock_out') {
        showCustomSnackBar(response.body['errors'][0]['message']);
        Get.find<ProductController>().getProductDetails(onlineCart.itemId!, existCartData);
      } else {
        ApiChecker.checkApi(response);
      }
    } finally {
      _endLoading();
    }
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity, int restaurantId) async {
    bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, price, quantity, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), restaurantId: restaurantId);
    if(success) {
      await getCartDataOnline(restaurantId);
      calculationCart(restaurantId);
    }
  }

  Future<void> getCartDataOnline(int restaurantId) async {
    _beginLoading();
    try {
      List<OnlineCartModel> onlineCartList = await cartServiceInterface.getCartDataOnline(AuthHelper.isLoggedIn() ? null : int.tryParse(AuthHelper.getGuestId()), restaurantId);
      List<CartModel> tempCartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
      _derivedRestaurantId = restaurantId;
      await _updateGlobalCartData(restaurantId, tempCartList);
      await getDiscountEligibility(restaurantId);
      calculationCart(restaurantId);
    } finally {
      _endLoading();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, int restaurantId) async {
    _beginLoading();
    try {
      bool isSuccess = await cartServiceInterface.removeCartItemOnline(cartId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(), restaurantId);
      await getCartDataOnline(restaurantId,);
      return isSuccess;
    } finally {
      _endLoading();
    }
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }

  Future<void> getCartBundleList() async {
    _beginLoading();
    try {
      _cartBundleList = await cartServiceInterface.getCartBundleList(
        guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
      )??[];
      _recalculateDerived();
    } finally {
      _endLoading();
    }
  }

  Future<bool> removeCartBundle(int restaurantId) async {
    _isDeleting = true;
    _deletingRestaurantId = restaurantId;
    update();
    bool success = await cartServiceInterface.removeCartBundle(
      restaurantId,
      guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
    );
    if (success) {
      _cartBundleList.removeWhere((cart) => cart.restaurant?.id == restaurantId);
      _recalculateDerived();
    }
    _isDeleting = false;
    _deletingRestaurantId = null;
    update();
    return success;
  }

  Future<bool> clearAllCartBundles() async {
    if(_isClearingAll || _cartBundleList.isEmpty) return false;
    _isClearingAll = true;
    update();

    final bool success = await cartServiceInterface.removeCartBundle(
      null,
      guestId: AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
    );
    if(success) {
      _cartBundleList = [];
      _recalculateDerived();
    }

    _isClearingAll = false;
    update();
    return success;
  }

}