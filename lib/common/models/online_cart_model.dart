import 'package:stackfood_multivendor/common/models/product_model.dart';

class OnlineCartModel {
  int? id;
  int? userId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  double? price;
  int? quantity;
  List<Variation>? variation;
  String? createdAt;
  String? updatedAt;
  Product? product;
  int? restaurantId;
  BogoCartDetails? bogoDetails;

  OnlineCartModel(
      {this.id,
        this.userId,
        this.itemId,
        this.isGuest,
        this.addOnIds,
        this.addOnQtys,
        this.itemType,
        this.price,
        this.quantity,
        this.variation,
        this.createdAt,
        this.updatedAt,
        this.product,
        this.restaurantId,
        this.bogoDetails});

  OnlineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    itemId = json['item_id'];
    isGuest = json['is_guest'];
    addOnIds = json['add_on_ids']?.cast<int>();
    addOnQtys = json['add_on_qtys']?.cast<int>();
    itemType = json['item_type'];
    price = json['price']?.toDouble();
    quantity = json['quantity'];
    if (json['variations'] != null) {
      variation = [];
      json['variations'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['item'] != null ? Product.fromJson(json['item']) : null;
    restaurantId = json['restaurant_id'];
    bogoDetails = json['bogo_details'] != null ? BogoCartDetails.fromJson(json['bogo_details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['item_id'] = itemId;
    data['is_guest'] = isGuest;
    data['add_on_ids'] = addOnIds;
    data['add_on_qtys'] = addOnQtys;
    data['item_type'] = itemType;
    data['price'] = price;
    data['quantity'] = quantity;
    if (variation != null) {
      data['variations'] = variation!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (product != null) {
      data['item'] = product!.toJson();
    }
    return data;
  }
}

class Variation {
  String? name;
  Value? values;

  Variation({this.name, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'] != null ? Value.fromJson(json['values']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class Value {
  List<String>? label;

  Value({this.label});

  Value.fromJson(Map<String, dynamic> json) {
    label = json['label'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}

class BogoCartDetails {
  final String bogoGroupId;
  final int? bogoOfferId;
  final int? bundleId;
  final String? offerTitle;
  final String? offerSlug;

  final String? offerStartDate;
  final String? offerEndDate;
  final int quantity;
  final double bundlePrice;

  final double? originalPrice;
  final double totalPrice;

  final double? finalPrice;
  final double? totalFinalPrice;
  final bool isAvailable;
  final String? unavailableReason;
  final List<String> itemThumbnails;
  final List<String> buyItemThumbnails;
  final List<String> freeItemThumbnails;

  const BogoCartDetails({
    required this.bogoGroupId, this.bogoOfferId, this.bundleId, this.offerTitle, this.offerSlug,
    this.offerStartDate, this.offerEndDate,
    required this.quantity, required this.bundlePrice, this.originalPrice, required this.totalPrice,
    this.finalPrice, this.totalFinalPrice,
    required this.isAvailable, this.unavailableReason, required this.itemThumbnails,
    required this.buyItemThumbnails, required this.freeItemThumbnails,
  });

  static List<String> _thumbnailsFrom(dynamic items) {
    List<String> thumbnails = [];
    if (items is List) {
      for (final item in items) {
        final String? url = item['image_full_url'] ?? item['item']?['image_full_url'];
        if (url != null && url.isNotEmpty) {
          thumbnails.add(url);
        }
      }
    }
    return thumbnails;
  }

  factory BogoCartDetails.fromJson(Map<String, dynamic> json) {
    final List<String> buyThumbnails = _thumbnailsFrom(json['buy_items']);
    final List<String> freeThumbnails = _thumbnailsFrom(json['free_items']);
    return BogoCartDetails(
      bogoGroupId: json['bogo_group_id'],
      bogoOfferId: json['bogo_offer_id'],
      bundleId: json['bundle_id'],
      offerTitle: json['offer_title'],
      offerSlug: json['offer_slug'],
      offerStartDate: json['offer_start_date'],
      offerEndDate: json['offer_end_date'],
      quantity: int.tryParse('${json['quantity']}') ?? 1,
      bundlePrice: double.tryParse('${json['bundle_price']}') ?? 0,
      originalPrice: double.tryParse('${json['original_price']}'),
      totalPrice: double.tryParse('${json['total_price']}') ?? 0,
      finalPrice: double.tryParse('${json['final_price']}'),
      totalFinalPrice: double.tryParse('${json['total_final_price']}'),
      isAvailable: json['is_available'] ?? true,
      unavailableReason: json['unavailable_reason'],
      itemThumbnails: [...buyThumbnails, ...freeThumbnails],
      buyItemThumbnails: buyThumbnails,
      freeItemThumbnails: freeThumbnails,
    );
  }
}
