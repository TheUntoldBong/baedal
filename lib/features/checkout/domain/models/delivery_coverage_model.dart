class DeliveryCoverageModel {
  String? deliveryChargeType;
  List<CoverageAreaModel>? data;

  DeliveryCoverageModel({this.deliveryChargeType, this.data});

  DeliveryCoverageModel.fromJson(Map<String, dynamic> json) {
    deliveryChargeType = json['delivery_charge_type'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CoverageAreaModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['delivery_charge_type'] = deliveryChargeType;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CoverageAreaModel {
  int? id;
  int? zoneId;
  String? name;
  double? deliveryCharge;

  CoverageAreaModel({this.id, this.zoneId, this.name, this.deliveryCharge});

  CoverageAreaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zoneId = json['zone_id'];
    name = json['name']?.toString();
    deliveryCharge = json['delivery_charge'] != null ? double.tryParse(json['delivery_charge'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['zone_id'] = zoneId;
    data['name'] = name;
    data['delivery_charge'] = deliveryCharge;
    return data;
  }
}
