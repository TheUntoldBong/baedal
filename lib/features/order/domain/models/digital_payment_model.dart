import 'package:stackfood_multivendor/helper/type_convarter_helper.dart';

class DigitalPaymentStatusModel {
  bool? eligible;
  String? reason;
  double? amountDue;

  DigitalPaymentStatusModel({this.eligible, this.reason, this.amountDue});

  DigitalPaymentStatusModel.fromJson(Map<String, dynamic> json) {
    eligible = TypeConvarterHelper.getBoolValue(json['eligible']);
    reason = json['reason'];
    amountDue = json['amount_due'] != null ? double.tryParse(json['amount_due'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    return {'eligible': eligible, 'reason': reason, 'amount_due': amountDue};
  }
}

class PayDigitallyModel {
  String? paymentUrl;
  double? amountDue;

  PayDigitallyModel({this.paymentUrl, this.amountDue});

  PayDigitallyModel.fromJson(Map<String, dynamic> json) {
    paymentUrl = json['payment_url'];
    amountDue = json['amount_due'] != null ? double.tryParse(json['amount_due'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    return {'payment_url': paymentUrl, 'amount_due': amountDue};
  }
}

class PayDigitallyResponseModel {
  final bool isSuccess;
  final String? message;
  final PayDigitallyModel? data;

  PayDigitallyResponseModel({required this.isSuccess, this.message, this.data});
}
