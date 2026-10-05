import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/helper/type_convarter_helper.dart';

class CartBundleModel {
  Restaurant? restaurant;
  List<CartModel>? carts;
  CartBundleModel({this.restaurant, this.carts});

  CartBundleModel.fromJson(Map<String, dynamic> json) {
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;
    carts = [];
  }
}

class Restaurant {
  int? id;
  String? name;
  String? logo;
  String? logoFullUrl;
  int? itemCount;
  bool? verifiedSeller;

  Restaurant({this.id, this.name, this.logo, this.logoFullUrl, this.itemCount});

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    logoFullUrl = json['logo_full_url'];
    itemCount = json['item_count'];
    verifiedSeller = TypeConvarterHelper.getBoolValue(json['verified_seller']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['logo_full_url'] = logoFullUrl;
    data['item_count'] = itemCount;
    data['verified_seller'] = verifiedSeller;
    return data;
  }
}
