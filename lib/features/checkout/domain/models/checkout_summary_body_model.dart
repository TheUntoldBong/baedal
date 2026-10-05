class CheckoutSummaryBodyModel {
  int? restaurantId;
  double? orderAmount;
  String? orderType;
  double? distance;
  String? latitude;
  String? longitude;
  int? zipCodeId;
  int? areaId;

  CheckoutSummaryBodyModel({this.restaurantId, this.orderAmount, this.orderType, this.distance,
    this.latitude, this.longitude, this.zipCodeId, this.areaId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['order_amount'] = orderAmount;
    data['order_type'] = orderType;
    data['distance'] = distance;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (zipCodeId != null) {
      data['zip_code_id'] = zipCodeId;
    }
    if (areaId != null) {
      data['area_id'] = areaId;
    }
    return data;
  }
}
