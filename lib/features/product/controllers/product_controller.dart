import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/product/domain/services/product_service_interface.dart';

import 'package:get/get.dart';

class ProductController extends GetxController implements GetxService {
  final ProductServiceInterface productServiceInterface;
  ProductController({required this.productServiceInterface});

  FilterDataModel? _filterDataModel;
  FilterDataModel? get getFilterDataModel => _filterDataModel;
  void setFilterDataModel(FilterDataModel filterDataModel){
    _filterDataModel = filterDataModel;
  }
  
  List<Product>? _popularProductList;
  List<Product>? get popularProductList => _popularProductList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<List<bool?>> _selectedVariations = [];
  List<List<bool?>> get selectedVariations => _selectedVariations;

  int? _quantity = 1;
  int? get quantity => _quantity;

  List<bool> _addOnActiveList = [];
  List<bool> get addOnActiveList => _addOnActiveList;

  List<int?> _addOnQtyList = [];
  List<int?> get addOnQtyList => _addOnQtyList;

  final String _popularType = 'all';
  String get popularType => _popularType;

  int _cartIndex = -1;
  int get cartIndex => _cartIndex;

  int _cartBundleIndex = -1;
  int get cartBundleIndex => _cartBundleIndex;

  int _imageIndex = 0;
  int get imageIndex => _imageIndex;

  List<bool> _collapseVariation = [];
  List<bool> get collapseVariation => _collapseVariation;

  bool _canAddToCartProduct = true;
  bool get canAddToCartProduct => _canAddToCartProduct;

  List<List<int?>> _variationsStock = [];
  List<List<int?>> get variationsStock => _variationsStock;

  Product? _product;
  Product? get product => _product;


  void changeCanAddToCartProduct(bool status) {
    _canAddToCartProduct = status;
  }

  Future<Product?> getProductDetails(int id, CartModel? cart, {bool isCampaign = false}) async {
    _product = null;
    _product = await productServiceInterface.getProductDetails(id: id, isCampaign: isCampaign);
    if(_product != null) {
      initData(_product, cart);
    }
    update();
    return _product;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if(notify) {
      update();
    }
  }

  void initData(Product? product, CartModel? cart) {
    _canAddToCartProduct = true;
    _selectedVariations = [];
    _variationsStock = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _collapseVariation = [];
    if(cart != null) {
      _quantity = cart.quantity;
      _selectedVariations.addAll(cart.variations!);
      _variationsStock = productServiceInterface.initializeVariationsStock(product!.variations);
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, cart.addOnIds);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, cart.addOnIds);
      _collapseVariation = productServiceInterface.initializeCollapseVariation(product.variations);

    }else {
      _quantity = 1;
      _selectedVariations = productServiceInterface.initializeSelectedVariation(product!.variations);
      _variationsStock = productServiceInterface.initializeVariationsStock(product.variations);
      _collapseVariation = productServiceInterface.initializeCollapseVariation(product.variations);
      _addOnActiveList = productServiceInterface.initializeAddonActiveList(product.addOns);
      _addOnQtyList = productServiceInterface.initializeAddonQuantityList(product.addOns);

    }
    setExistInCartForBottomSheet(product, selectedVariations);
  }

  String? checkOutOfStockVariationSelected(List<Variation>? variations) {
    if(variations == null) return null;
    for(int i=0; i< _selectedVariations.length; i++) {
      if(i >= variations.length) break;
      for(int j=0; j< _selectedVariations[i].length; j++) {
        if(_selectedVariations[i][j] == true) {
          final values = variations[i].variationValues;
          if (values != null && j < values.length && values[j].currentStock != null && values[j].currentStock! <= 0 && values[j].stockType != 'unlimited') {
            return '${values[j].level} ${'variation_is_out_of_stock'.tr}';
          }
        }
      }
    }
    return null;
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    return productServiceInterface.selectedVariationLength(selectedVariations, index);
  }

  int setExistInCart(Product product, {bool notify = true}) {
    if (product.restaurantId == null) return -1;
    var prIndex = Get.find<CartController>().isExistInCart(product.id, product.restaurantId!);
    _cartBundleIndex = prIndex.$1;
    _cartIndex = prIndex.$2;

    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartBundleList[_cartBundleIndex].carts![_cartIndex].quantity;
      final addOnIds = Get.find<CartController>().cartBundleList[_cartBundleIndex].carts![_cartIndex].addOnIds;
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, addOnIds);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, addOnIds);
    }
    return _cartIndex;
  }

  int setExistInCartForBottomSheet(Product product, List<List<bool?>>? selectedVariations, {bool notify = true}) {

    final pr = productServiceInterface.isExistInCartForBottomSheet(Get.find<CartController>().cartBundleList, product.id, product.restaurantId, null, selectedVariations,);
    _cartBundleIndex = pr.$1;
    _cartIndex = pr.$2;

    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartBundleList[_cartBundleIndex].carts![_cartIndex].quantity;
      _addOnActiveList = productServiceInterface.initializeCartAddonActiveList(product, Get.find<CartController>().cartBundleList[_cartBundleIndex].carts![_cartIndex].addOnIds!);
      _addOnQtyList = productServiceInterface.initializeCartAddonQuantityList(product, Get.find<CartController>().cartBundleList[_cartBundleIndex].carts![_cartIndex].addOnIds!);
    } else {
      _quantity = 1;
    }
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index, String? stockType, int? addonStock) {
    _addOnQtyList[index] = productServiceInterface.setAddonQuantity(_addOnQtyList[index]!, isIncrement, stockType, addonStock);
    update();
  }

  void setQuantity(bool isIncrement, int? cartQuantityLimit, String? stockType, int? itemStock, bool isCampaign) {
    _quantity = productServiceInterface.setQuantity(isIncrement, cartQuantityLimit, _quantity!, _selectedVariations, _variationsStock, stockType, itemStock, isCampaign);
    update();
  }

  void setCartVariationIndex(int index, int i, Product? product, bool isMultiSelect) {
    _selectedVariations = productServiceInterface.setCartVariationIndex(index, i, product!.variations, isMultiSelect, _selectedVariations);
    update();
  }

  void addAddOn(bool isAdd, int index, String? stockType, int? stock) {
    if(stock != null && (stock > 0 && stockType != 'unlimited') || (stockType == 'unlimited')) {
      _addOnActiveList[index] = isAdd;
    }
    update();
  }

  void showMoreSpecificSection(int index){
    _collapseVariation[index] = !_collapseVariation[index];
    update();
  }
}
