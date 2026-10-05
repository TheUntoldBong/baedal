class PaginatedLatestOrderModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<LatestOrderModel>? orders;

  PaginatedLatestOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedLatestOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse(json['total_size'].toString());
    limit = int.tryParse(json['limit'].toString());
    offset = int.tryParse(json['offset'].toString());
    if (json['orders'] != null) {
      orders = <LatestOrderModel>[];
      json['orders'].forEach((v) {
        orders!.add(LatestOrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LatestOrderModel {
  int? id;
  String? createdAt;
  double? orderAmount;
  int? totalItemCount;
  bool? campaign;
  List<String>? itemImages;
  LatestOrderRestaurant? restaurant;

  LatestOrderModel({
    this.id,
    this.createdAt,
    this.orderAmount,
    this.totalItemCount,
    this.campaign,
    this.itemImages,
    this.restaurant,
  });

  LatestOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    orderAmount = json['order_amount']?.toDouble();
    totalItemCount = json['total_item_count'];
    campaign = json['campaign'];
    if (json['item_images'] != null) {
      itemImages = List<String>.from(json['item_images'].map((image) => image.toString()));
    }
    restaurant = json['restaurant'] != null ? LatestOrderRestaurant.fromJson(json['restaurant']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['order_amount'] = orderAmount;
    data['total_item_count'] = totalItemCount;
    data['campaign'] = campaign;
    data['item_images'] = itemImages;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    return data;
  }
}

class LatestOrderRestaurant {
  int? id;
  String? name;
  String? logoFullUrl;
  int? verifiedSeller;

  LatestOrderRestaurant({this.id, this.name, this.logoFullUrl, this.verifiedSeller});

  LatestOrderRestaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoFullUrl = json['logo_full_url'];
    verifiedSeller = json['verified_seller'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo_full_url'] = logoFullUrl;
    data['verified_seller'] = verifiedSeller;
    return data;
  }
}
