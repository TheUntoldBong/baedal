import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/helper/type_convarter_helper.dart';

class CheckoutSummaryModel {
  SummaryTaxModel? tax;
  SummaryDeliveryModel? delivery;
  SummarySurgeModel? surge;
  SummaryCashbackModel? cashback;
  SummaryProModel? pro;

  CheckoutSummaryModel({this.tax, this.delivery, this.surge, this.cashback, this.pro});

  CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    tax = json['tax'] != null ? SummaryTaxModel.fromJson(json['tax']) : null;
    delivery = json['delivery'] != null ? SummaryDeliveryModel.fromJson(json['delivery']) : null;
    surge = json['surge'] != null ? SummarySurgeModel.fromJson(json['surge']) : null;
    cashback = json['cashback'] != null ? SummaryCashbackModel.fromJson(json['cashback']) : null;
    pro = json['pro'] != null ? SummaryProModel.fromJson(json['pro']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    if (delivery != null) {
      data['delivery'] = delivery!.toJson();
    }
    if (surge != null) {
      data['surge'] = surge!.toJson();
    }
    if (cashback != null) {
      data['cashback'] = cashback!.toJson();
    }
    if (pro != null) {
      data['pro'] = pro!.toJson();
    }
    return data;
  }
}

class SummaryProModel {
  bool? status;
  ProBenefitType? type;
  double? discount;
  double? deliverySavings;
  double? totalSavings;

  SummaryProModel({this.status, this.type, this.discount, this.deliverySavings, this.totalSavings});

  SummaryProModel.fromJson(Map<String, dynamic> json) {
    status = TypeConvarterHelper.getBoolValue(json['status']);
    type = json['type'] != null ? ProBenefitType.fromString(json['type'].toString()) : null;
    discount = double.tryParse(json['discount'].toString()) ?? 0;
    deliverySavings = double.tryParse(json['delivery_savings'].toString()) ?? 0;
    totalSavings = double.tryParse(json['total_savings'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['type'] = type == ProBenefitType.deliveryFee ? 'delivery_fee' : type?.name;
    data['discount'] = discount;
    data['delivery_savings'] = deliverySavings;
    data['total_savings'] = totalSavings;
    return data;
  }
}

class SummaryTaxModel {
  double? taxAmount;
  String? taxStatus;
  int? taxIncluded;
  double? totalPrice;

  SummaryTaxModel({this.taxAmount, this.taxStatus, this.taxIncluded, this.totalPrice});

  SummaryTaxModel.fromJson(Map<String, dynamic> json) {
    taxAmount = double.tryParse(json['tax_amount'].toString()) ?? 0;
    taxStatus = json['tax_status'];
    taxIncluded = int.tryParse(json['tax_included'].toString());
    totalPrice = double.tryParse(json['total_price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tax_amount'] = taxAmount;
    data['tax_status'] = taxStatus;
    data['tax_included'] = taxIncluded;
    data['total_price'] = totalPrice;
    return data;
  }
}

class SummaryDeliveryModel {
  double? deliveryCharge;
  double? originalDeliveryCharge;
  double? baseDeliveryCharge;
  double? surgeAmount;
  String? freeDeliveryBy;
  double? proCustomerSavings;
  double? deliveryTypeCharge;
  int? vehicleId;

  SummaryDeliveryModel({this.deliveryCharge, this.originalDeliveryCharge, this.baseDeliveryCharge,
    this.surgeAmount, this.freeDeliveryBy, this.proCustomerSavings, this.deliveryTypeCharge, this.vehicleId});

  SummaryDeliveryModel.fromJson(Map<String, dynamic> json) {
    deliveryCharge = double.tryParse(json['delivery_charge'].toString());
    originalDeliveryCharge = double.tryParse(json['original_delivery_charge'].toString());
    baseDeliveryCharge = double.tryParse(json['base_delivery_charge'].toString());
    surgeAmount = double.tryParse(json['surge_amount'].toString()) ?? 0;
    freeDeliveryBy = json['free_delivery_by']?.toString();
    proCustomerSavings = double.tryParse(json['pro_customer_savings'].toString());
    deliveryTypeCharge = double.tryParse(json['delivery_type_charge'].toString());
    vehicleId = int.tryParse(json['vehicle_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['delivery_charge'] = deliveryCharge;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['base_delivery_charge'] = baseDeliveryCharge;
    data['surge_amount'] = surgeAmount;
    data['free_delivery_by'] = freeDeliveryBy;
    data['pro_customer_savings'] = proCustomerSavings;
    data['delivery_type_charge'] = deliveryTypeCharge;
    data['vehicle_id'] = vehicleId;
    return data;
  }
}

class SummarySurgeModel {
  String? title;
  String? customerNote;
  int? customerNoteStatus;
  double? price;
  String? priceType;
  int? zoneId;

  SummarySurgeModel({this.title, this.customerNote, this.customerNoteStatus, this.price, this.priceType, this.zoneId});

  SummarySurgeModel.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    customerNote = json['customer_note']?.toString();
    customerNoteStatus = int.tryParse(json['customer_note_status'].toString());
    price = double.tryParse(json['price'].toString());
    priceType = json['price_type']?.toString();
    zoneId = int.tryParse(json['zone_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['customer_note'] = customerNote;
    data['customer_note_status'] = customerNoteStatus;
    data['price'] = price;
    data['price_type'] = priceType;
    data['zone_id'] = zoneId;
    return data;
  }
}

class SummaryCashbackModel {
  int? id;
  double? calculatedAmount;
  double? cashbackAmount;
  String? cashbackType;
  double? minPurchase;
  double? maxDiscount;

  SummaryCashbackModel({this.id, this.calculatedAmount, this.cashbackAmount, this.cashbackType,
    this.minPurchase, this.maxDiscount});

  SummaryCashbackModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    calculatedAmount = double.tryParse(json['calculated_amount'].toString()) ?? 0;
    cashbackAmount = double.tryParse(json['cashback_amount'].toString()) ?? 0;
    cashbackType = json['cashback_type']?.toString();
    minPurchase = double.tryParse(json['min_purchase'].toString()) ?? 0;
    maxDiscount = double.tryParse(json['max_discount'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['calculated_amount'] = calculatedAmount;
    data['cashback_amount'] = cashbackAmount;
    data['cashback_type'] = cashbackType;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    return data;
  }
}
