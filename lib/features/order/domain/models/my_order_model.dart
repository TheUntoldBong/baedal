enum MyOrderTabType {
  running(status: 'running'),
  repeat(type: 'repeat'),
  history(status: 'history');

  final String? status;
  final String? type;
  const MyOrderTabType({this.status, this.type});
}

class MyOrderTabData {
  List<MyOrderModel>? orders;
  int? totalSize;
  int offset = 1;
  bool paginating = false;
  final List<int> loadedOffsets = <int>[];

  bool get loading => orders == null;
}

class PaginatedMyOrderModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<MyOrderModel>? orders;

  PaginatedMyOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedMyOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse(json['total_size'].toString());
    limit = int.tryParse(json['limit'].toString());
    offset = int.tryParse(json['offset'].toString());
    if (json['orders'] != null) {
      orders = <MyOrderModel>[];
      json['orders'].forEach((v) {
        orders!.add(MyOrderModel.fromJson(v));
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

class MyOrderModel {
  int? id;
  String? type;
  bool? isRepeat;
  int? subscriptionId;
  int? occurrenceCount;
  String? orderStatus;
  String? statusLabel;
  String? paymentStatus;
  String? paymentMethod;
  String? orderType;
  int? scheduled;
  String? scheduleAt;
  int? detailsCount;
  List<MyOrderItem>? items;
  double? orderAmount;
  String? couponCode;
  bool? isReviewed;
  bool? canReorder;
  String? currencySymbol;
  MyOrderRestaurant? restaurant;
  MyOrderCustomer? customer;
  String? createdAt;

  MyOrderModel({
    this.id,
    this.type,
    this.isRepeat,
    this.subscriptionId,
    this.occurrenceCount,
    this.orderStatus,
    this.statusLabel,
    this.paymentStatus,
    this.paymentMethod,
    this.orderType,
    this.scheduled,
    this.scheduleAt,
    this.detailsCount,
    this.items,
    this.orderAmount,
    this.couponCode,
    this.isReviewed,
    this.canReorder,
    this.currencySymbol,
    this.restaurant,
    this.customer,
    this.createdAt,
  });

  MyOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    isRepeat = json['is_repeat'];
    subscriptionId = json['subscription_id'];
    occurrenceCount = json['occurrence_count'];
    orderStatus = json['order_status'];
    statusLabel = json['status_label'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    orderType = json['order_type'];
    scheduled = json['scheduled'];
    scheduleAt = json['schedule_at'];
    detailsCount = json['details_count'];
    if (json['items'] != null) {
      items = <MyOrderItem>[];
      json['items'].forEach((v) {
        items!.add(MyOrderItem.fromJson(v));
      });
    }
    orderAmount = json['order_amount']?.toDouble();
    couponCode = json['coupon_code'];
    isReviewed = json['is_reviewed'];
    canReorder = json['can_reorder'];
    currencySymbol = json['currency_symbol'];
    restaurant = json['restaurant'] != null ? MyOrderRestaurant.fromJson(json['restaurant']) : null;
    customer = json['customer'] != null ? MyOrderCustomer.fromJson(json['customer']) : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['is_repeat'] = isRepeat;
    data['subscription_id'] = subscriptionId;
    data['occurrence_count'] = occurrenceCount;
    data['order_status'] = orderStatus;
    data['status_label'] = statusLabel;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['order_type'] = orderType;
    data['scheduled'] = scheduled;
    data['schedule_at'] = scheduleAt;
    data['details_count'] = detailsCount;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['order_amount'] = orderAmount;
    data['coupon_code'] = couponCode;
    data['is_reviewed'] = isReviewed;
    data['can_reorder'] = canReorder;
    data['currency_symbol'] = currencySymbol;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['created_at'] = createdAt;
    return data;
  }

  static const Set<String> trackableStatuses = <String>{
    'accepted', 'confirmed', 'processing', 'handover', 'picked_up',
  };

  static const Set<String> removableStatuses = <String>{
    'delivered', 'canceled', 'refund_requested', 'refund_request_canceled', 'refunded', 'failed',
  };

  bool get isTrackable => orderType == 'delivery' && trackableStatuses.contains((orderStatus ?? '').toLowerCase());

  bool get isRemovable => removableStatuses.contains((orderStatus ?? '').toLowerCase());

  bool get isRepeatOrder => (isRepeat ?? false) || subscriptionId != null;
}

class MyOrderItem {
  String? name;
  String? imageFullUrl;

  MyOrderItem({this.name, this.imageFullUrl});

  MyOrderItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class MyOrderRestaurant {
  int? id;
  String? name;
  String? phone;
  int? zoneId;
  String? logoFullUrl;

  MyOrderRestaurant({this.id, this.name, this.phone, this.zoneId, this.logoFullUrl});

  MyOrderRestaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    zoneId = json['zone_id'];
    logoFullUrl = json['logo_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['zone_id'] = zoneId;
    data['logo_full_url'] = logoFullUrl;
    return data;
  }
}

class MyOrderCustomer {
  int? id;
  bool? isGuest;
  String? name;
  String? phone;
  String? email;
  String? imageFullUrl;

  MyOrderCustomer({this.id, this.isGuest, this.name, this.phone, this.email, this.imageFullUrl});

  MyOrderCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isGuest = json['is_guest'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_guest'] = isGuest;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}
