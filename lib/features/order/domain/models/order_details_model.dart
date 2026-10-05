import 'package:stackfood_multivendor/common/models/product_model.dart';

class OrderDetailsModel {
  int? id;
  int? foodId;
  int? orderId;
  double? price;
  Product? foodDetails;
  List<Variation>? variation;
  List<OldVariation>? oldVariation;
  List<AddOn>? addOns;
  double? discountOnFood;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  int? zoneId;
  String? bogoGroupId;
  OrderBogoDetailsModel? bogoDetails;

  bool get isBogoBundle => bogoDetails != null;

  OrderDetailsModel(
      {this.id,
        this.foodId,
        this.orderId,
        this.price,
        this.foodDetails,
        this.variation,
        this.oldVariation,
        this.addOns,
        this.discountOnFood,
        this.discountType,
        this.quantity,
        this.taxAmount,
        this.variant,
        this.createdAt,
        this.updatedAt,
        this.itemCampaignId,
        this.totalAddOnPrice,
        this.zoneId,
        this.bogoGroupId,
        this.bogoDetails,
      });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = json['price'] != null ? json['price'].toDouble() : 0.0;
    foodDetails = json['food_details'] != null ? Product.fromJson(json['food_details']) : null;
    variation = [];
    oldVariation = [];
    if (json['variation'] != null && json['variation'].isNotEmpty) {
      if(json['variation'][0]['values'] != null) {
        json['variation'].forEach((v) {
          variation!.add(Variation.fromJson(v));
        });
      }else {
        json['variation'].forEach((v) {
          oldVariation!.add(OldVariation.fromJson(v));
        });
      }
    }
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOn.fromJson(v));
      });
    }
    discountOnFood = json['discount_on_food'] != null ? json['discount_on_food'].toDouble() : 0.0;
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = json['tax_amount'] != null ? json['tax_amount'].toDouble() : 0.0;
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price'] != null ? json['total_add_on_price'].toDouble() : 0.0;
    zoneId = json['zone_id'];
    bogoGroupId = json['bogo_group_id'];
    bogoDetails = json['bogo_details'] != null ? OrderBogoDetailsModel.fromJson(json['bogo_details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (foodDetails != null) {
      data['food_details'] = foodDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_food'] = discountOnFood;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['zone_id'] = zoneId;
    data['bogo_group_id'] = bogoGroupId;
    return data;
  }
}

class OrderBogoDetailsModel {
  int? bogoOfferId;
  String? offerTitle;
  int? bundleId;
  int? quantity;
  double? bundlePrice;
  double? totalPrice;
  List<OrderBogoItemModel>? buyItems;
  List<OrderBogoItemModel>? freeItems;

  OrderBogoDetailsModel({
    this.bogoOfferId, this.offerTitle, this.bundleId, this.quantity,
    this.bundlePrice, this.totalPrice, this.buyItems, this.freeItems,
  });

  OrderBogoDetailsModel.fromJson(Map<String, dynamic> json) {
    bogoOfferId = json['bogo_offer_id'];
    offerTitle = json['offer_title'];
    bundleId = json['bundle_id'];
    quantity = json['quantity'];
    bundlePrice = double.tryParse('${json['bundle_price']}');
    totalPrice = double.tryParse('${json['total_price']}');
    if (json['buy_items'] != null) {
      buyItems = [];
      json['buy_items'].forEach((item) => buyItems!.add(OrderBogoItemModel.fromJson(item)));
    }
    if (json['free_items'] != null) {
      freeItems = [];
      json['free_items'].forEach((item) => freeItems!.add(OrderBogoItemModel.fromJson(item)));
    }
  }
}

class OrderBogoItemModel {
  int? foodId;
  String? name;
  String? imageFullUrl;
  double? price;
  int? quantity;

  OrderBogoItemModel({this.foodId, this.name, this.imageFullUrl, this.price, this.quantity});

  OrderBogoItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? foodDetails = json['food_details'];
    foodId = json['food_id'];
    name = foodDetails?['name'] ?? json['name'] ?? json['food_name'];
    imageFullUrl = foodDetails?['image_full_url'] ?? json['image_full_url'] ?? json['food_image_full_url'];
    price = double.tryParse('${json['price']}');
    quantity = json['quantity'];
  }
}

class AddOn {
  int? id;
  String? name;
  double? price;
  int? quantity;

  AddOn({this.id, this.name, this.price, this.quantity});

  AddOn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toDouble();
    quantity = int.parse(json['quantity'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class OldVariation {
  String? type;
  double? price;

  OldVariation({this.type, this.price});

  OldVariation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    return data;
  }
}