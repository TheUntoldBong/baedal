class ZoneResponseModel {
  final bool _isSuccess;
  final List<int> _zoneIds;
  final String? _message;
  final List<ZoneData> _zoneData;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String? get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
}

class ZoneData {
  int? id;
  int? status;
  double? minimumDeliveryCharge;
  double? minimumShippingCharge;
  double? increasedDeliveryFee;
  int? increasedDeliveryFeeStatus;
  String? increaseDeliveryFeeMessage;
  double? perKmShippingCharge;
  double? maxCodOrderAmount;
  double? maximumShippingCharge;
  bool? additionalDeliveryOptionStatus;
  MinimumDeliveryTime? minimumDeliveryTime;
  List<DeliveryOptions>? deliveryOptions;

  ZoneData({
    this.id,
    this.status,
    this.minimumDeliveryCharge,
    this.minimumShippingCharge,
    this.increasedDeliveryFee,
    this.increasedDeliveryFeeStatus,
    this.increaseDeliveryFeeMessage,
    this.perKmShippingCharge,
    this.maxCodOrderAmount,
    this.maximumShippingCharge,
    this.additionalDeliveryOptionStatus,
    this.minimumDeliveryTime,
    this.deliveryOptions,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    minimumDeliveryCharge = json['minimum_delivery_charge']?.toDouble();
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    increasedDeliveryFee = json['increased_delivery_fee']?.toDouble();
    increasedDeliveryFeeStatus = json['increased_delivery_fee_status'];
    increaseDeliveryFeeMessage = json['increase_delivery_charge_message'];
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
    maxCodOrderAmount = json['max_cod_order_amount']?.toDouble();
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
    additionalDeliveryOptionStatus = json['additional_delivery_option_status']??false;
    minimumDeliveryTime = json['minimum_delivery_time'] != null
        ? MinimumDeliveryTime.fromJson(json['minimum_delivery_time'])
        : null;
    if (json['delivery_options'] != null) {
      deliveryOptions = <DeliveryOptions>[];
      json['delivery_options'].forEach((v) {
        deliveryOptions!.add(DeliveryOptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['minimum_delivery_charge'] = minimumDeliveryCharge;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['increased_delivery_fee'] = increasedDeliveryFee;
    data['increased_delivery_fee_status'] = increasedDeliveryFeeStatus;
    data['increase_delivery_charge_message'] = increaseDeliveryFeeMessage;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['max_cod_order_amount'] = maxCodOrderAmount;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['additional_delivery_option_status'] = additionalDeliveryOptionStatus;
    if (minimumDeliveryTime != null) {
      data['minimum_delivery_time'] = minimumDeliveryTime!.toJson();
    }
    if (deliveryOptions != null) {
      data['delivery_options'] = deliveryOptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MinimumDeliveryTime {
  int? value;
  String? unit;

  MinimumDeliveryTime({this.value, this.unit});

  MinimumDeliveryTime.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    return data;
  }
}

class DeliveryOptions {
  int? id;
  int? zoneId;
  String? deliveryType;
  double? extraCharge;
  double? reduceCharge;
  MinimumDeliveryTime? addDeliveryTime;
  MinimumDeliveryTime? reduceDeliveryTime;
  String? createdAt;
  String? updatedAt;

  DeliveryOptions(
      {this.id,
        this.zoneId,
        this.deliveryType,
        this.extraCharge,
        this.reduceCharge,
        this.addDeliveryTime,
        this.reduceDeliveryTime,
        this.createdAt,
        this.updatedAt});

  DeliveryOptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zoneId = json['zone_id'];
    deliveryType = json['delivery_type'];
    extraCharge = double.tryParse(json['extra_charge'].toString());
    reduceCharge = double.tryParse(json['reduce_charge'].toString());
    addDeliveryTime = json['add_delivery_time'] != null
        ? MinimumDeliveryTime.fromJson(json['add_delivery_time'])
        : null;
    reduceDeliveryTime = json['reduce_delivery_time'] != null
        ? MinimumDeliveryTime.fromJson(json['reduce_delivery_time'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['zone_id'] = zoneId;
    data['delivery_type'] = deliveryType;
    data['extra_charge'] = extraCharge;
    data['reduce_charge'] = reduceCharge;
    if (addDeliveryTime != null) {
      data['add_delivery_time'] = addDeliveryTime!.toJson();
    }
    if (reduceDeliveryTime != null) {
      data['reduce_delivery_time'] = reduceDeliveryTime!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
