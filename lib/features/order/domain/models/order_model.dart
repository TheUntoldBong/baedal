import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/helper/type_convarter_helper.dart';

class OrderModel {
  int? id;
  int? userId;
  double? orderAmount;
  double? couponDiscountAmount;
  String? couponDiscountTitle;
  DiscountSource? discountSource;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? couponCode;
  String? orderNote;
  String? orderType;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  int? scheduled;
  double? restaurantDiscountAmount;
  String? failed;
  int? detailsCount;
  double? dmTips;
  int? processingTime;
  DeliveryMan? deliveryMan;
  Restaurant? restaurant;
  AddressModel? deliveryAddress;
  Refund? refund;
  bool? taxStatus;
  String? cancellationReason;
  String? cancellationNote;
  int? subscriptionId;
  SubscriptionModel? subscription;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  double? additionalCharge;
  double? partiallyPaidAmount;
  List<Payments>? payments;
  List<String>? orderProofFullUrl;
  OfflinePayment? offlinePayment;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  OrderReference? orderReference;
  double? bringChangeAmount;
  int? itemCampaignId;
  bool? isPos;
  String? deliveryType;
  double? deliveryTypeCharge;
  ProBenefitType? benefitType;
  double? deliveryFeeReductionAmount;
  ProOfferType? deliveryOfferType;
  double? proDiscount;
  OrderEta? eta;
  bool? isBogo;
  bool? isItemCampaign;

  OrderModel({
    this.id,
    this.userId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.couponCode,
    this.orderNote,
    this.orderType,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.scheduled,
    this.restaurantDiscountAmount,
    this.failed,
    this.dmTips,
    this.processingTime,
    this.detailsCount,
    this.deliveryMan,
    this.deliveryAddress,
    this.restaurant,
    this.refund,
    this.taxStatus,
    this.cancellationReason,
    this.cancellationNote,
    this.subscriptionId,
    this.subscription,
    this.cutlery,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.additionalCharge,
    this.partiallyPaidAmount,
    this.payments,
    this.orderProofFullUrl,
    this.offlinePayment,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.orderReference,
    this.bringChangeAmount,
    this.itemCampaignId,
    this.isPos,
    this.deliveryType,
    this.deliveryTypeCharge,
    this.benefitType,
    this.deliveryFeeReductionAmount,
    this.deliveryOfferType,
    this.proDiscount,
    this.eta,
    this.isBogo,
    this.isItemCampaign,
    this.discountSource,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderAmount = json['order_amount']?.toDouble();
    couponDiscountAmount = json['coupon_discount_amount']?.toDouble();
    couponDiscountTitle = json['coupon_discount_title'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = json['total_tax_amount']?.toDouble();
    paymentMethod = json['payment_method'];
    couponCode = json['coupon_code'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge']?.toDouble();
    scheduleAt = json['schedule_at'];
    otp = json['otp'];
    pending = json['pending'];
    accepted = json['accepted'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    refundRequested = json['refund_requested'];
    refunded = json['refunded'];
    scheduled = json['scheduled'];
    dmTips = json['dm_tips']?.toDouble();
    restaurantDiscountAmount = json['restaurant_discount_amount']?.toDouble();
    discountSource = DiscountSource.fromValue(json['restaurant_discount_type']);
    failed = json['failed'];
    detailsCount = json['details_count'];
    processingTime = json['processing_time'];
    deliveryMan = json['delivery_man'] != null ? DeliveryMan.fromJson(json['delivery_man']) : null;
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;
    deliveryAddress = json['delivery_address'] != null ? AddressModel.fromJson(json['delivery_address']) : null;
    refund = json['refund'] != null ? Refund.fromJson(json['refund']) : null;
    taxStatus = json['tax_status'] == 'included' ? true : false;
    cancellationReason = json['cancellation_reason'];
    cancellationNote = json['cancellation_note'];
    subscriptionId = json['subscription_id'];
    subscription = json['subscription'] != null ? SubscriptionModel.fromJson(json['subscription']) : null;
    cutlery = json['cutlery'];
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    additionalCharge = json['additional_charge']?.toDouble() ?? 0;
    if (json['partially_paid_amount'] != null) {
      partiallyPaidAmount = double.parse(json['partially_paid_amount'].toString());
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(Payments.fromJson(v));
      });
    }
    if (json['order_proof_full_url'] != null && json['order_proof_full_url'] != "null") {
      orderProofFullUrl = [];
      json['order_proof_full_url'].forEach((v) {
        if(v != null) {
          orderProofFullUrl!.add(v.toString());
        }
      });
    }
    offlinePayment = json['offline_payment'] != null ? OfflinePayment.fromJson(json['offline_payment']) : null;
    extraPackagingAmount = json['extra_packaging_amount']?.toDouble();
    referrerBonusAmount = json['ref_bonus_amount']?.toDouble();
    orderReference = json['order_reference'] != null ? OrderReference.fromJson(json['order_reference']) : null;
    bringChangeAmount = json['bring_change_amount']?.toDouble();
    itemCampaignId = json['item_campaign_id'];
    isPos = json['is_pos'];
    deliveryType = json['delivery_type'];
    deliveryTypeCharge = json['delivery_type_charge']?.toDouble();
    benefitType = ProBenefitType.fromString(json['benefit_type']);
    deliveryFeeReductionAmount = json['delivery_fee_reduction_amount']?.toDouble();
    deliveryOfferType = ProOfferType.fromString(json['delivery_offer_type']);
    proDiscount = json['pro_discount']?.toDouble();
    eta = json['eta'] != null ? OrderEta.fromJson(json['eta']) : null;
    isBogo = json['is_bogo'] != null ? TypeConvarterHelper.getBoolValue(json['is_bogo']) : null;
    isItemCampaign = json['is_item_campaign'] != null ? TypeConvarterHelper.getBoolValue(json['is_item_campaign']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['coupon_code'] = couponCode;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    data['scheduled'] = scheduled;
    data['restaurant_discount_amount'] = restaurantDiscountAmount;
    data['restaurant_discount_type'] = discountSource?.value;
    data['failed'] = failed;
    data['dm_tips'] = dmTips;
    data['processing_time'] = processingTime;
    data['details_count'] = detailsCount;
    if (deliveryMan != null) {
      data['delivery_man'] = deliveryMan!.toJson();
    }
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (refund != null) {
      data['refund'] = refund!.toJson();
    }
    data['subscription_id'] = subscriptionId;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['additional_charge'] = additionalCharge;
    data['partially_paid_amount'] = partiallyPaidAmount;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['order_proof_full_url'] = orderProofFullUrl;
    if (offlinePayment != null) {
      data['offline_payment'] = offlinePayment!.toJson();
    }
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    if (orderReference != null) {
      data['order_reference'] = orderReference!.toJson();
    }
    data['bring_change_amount'] = bringChangeAmount;
    data['item_campaign_id'] = itemCampaignId;
    data['is_pos'] = isPos;
    data['delivery_type'] = deliveryType;
    data['delivery_type_charge'] = deliveryTypeCharge;
    data['benefit_type'] = benefitType?.name == 'deliveryFee' ? 'delivery_fee' : benefitType?.name;
    data['delivery_fee_reduction_amount'] = deliveryFeeReductionAmount;
    data['delivery_offer_type'] = deliveryOfferType?.toJson();
    data['pro_discount'] = proDiscount;
    if (eta != null) {
      data['eta'] = eta!.toJson();
    }
    data['is_bogo'] = isBogo;
    data['is_item_campaign'] = isItemCampaign;
    return data;
  }
}

class OrderEta {
  int? min;
  int? max;
  String? unit;
  String? text;
  String? from;
  String? to;
  String? window;
  String? fromAt;
  String? toAt;
  String? timezone;
  String? stage;

  OrderEta({this.min, this.max, this.unit, this.text, this.from, this.to, this.window, this.fromAt, this.toAt, this.timezone, this.stage});

  OrderEta.fromJson(Map<String, dynamic> json) {
    min = json['min'] != null ? int.tryParse(json['min'].toString()) : null;
    max = json['max'] != null ? int.tryParse(json['max'].toString()) : null;
    unit = json['unit'];
    text = json['text'];
    from = json['from'];
    to = json['to'];
    window = json['window'];
    fromAt = json['from_at'];
    toAt = json['to_at'];
    timezone = json['timezone'];
    stage = json['stage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    data['unit'] = unit;
    data['text'] = text;
    data['from'] = from;
    data['to'] = to;
    data['window'] = window;
    data['from_at'] = fromAt;
    data['to_at'] = toAt;
    data['timezone'] = timezone;
    data['stage'] = stage;
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  int? zoneId;
  int? active;
  int? available;
  double? avgRating;
  int? ratingCount;
  String? lat;
  String? lng;
  String? location;
  int? restaurantId;

  DeliveryMan({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.zoneId,
    this.active,
    this.available,
    this.avgRating,
    this.ratingCount,
    this.lat,
    this.lng,
    this.location,
    this.restaurantId,
  });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    zoneId = json['zone_id'];
    active = json['active'];
    available = json['available'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count'];
    lat = json['lat'];
    lng = json['lng'];
    location = json['location'];
    restaurantId = json['restaurant_id'] != null ? int.parse(json['restaurant_id'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['available'] = available;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['lat'] = lat;
    data['lng'] = lng;
    data['location'] = location;
    data['restaurant_id'] = restaurantId;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments({
    this.id,
    this.orderId,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble();
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OfflinePayment {
  List<Input>? input;
  Data? data;
  List<MethodFields>? methodFields;

  OfflinePayment({this.input, this.data, this.methodFields});

  OfflinePayment.fromJson(Map<String, dynamic> json) {
    if (json['input'] != null) {
      input = <Input>[];
      json['input'].forEach((v) {
        input!.add(Input.fromJson(v));
      });
    }
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (input != null) {
      data['input'] = input!.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (methodFields != null) {
      data['method_fields'] = input!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Input {
  String? userInput;
  String? userData;

  Input({this.userInput, this.userData});

  Input.fromJson(Map<String, dynamic> json) {
    userInput = json['user_input'].toString();
    userData = json['user_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_input'] = userInput;
    data['user_data'] = userData;
    return data;
  }
}

class Data {
  String? status;
  String? methodId;
  String? methodName;
  String? customerNote;

  Data({
    this.status,
    this.methodId,
    this.methodName,
    this.customerNote,
  });

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    methodId = json['method_id'].toString();
    methodName = json['method_name'];
    customerNote = json['customer_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['method_id'] = methodId;
    data['method_name'] = methodName;
    data['customer_note'] = customerNote;
    return data;
  }
}

class MethodFields {
  String? inputName;
  String? inputData;

  MethodFields({this.inputName, this.inputData});

  MethodFields.fromJson(Map<String, dynamic> json) {
    inputName = json['input_name'];
    inputData = json['input_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_name'] = inputName;
    data['input_data'] = inputData;
    return data;
  }
}

class SubscriptionModel {
  int? id;
  String? status;
  String? startAt;
  String? endAt;
  String? note;
  String? type;
  int? quantity;
  int? userId;
  int? restaurantId;
  double? billingAmount;
  double? paidAmount;
  String? createdAt;
  String? updatedAt;
  bool? isPausedToday;
  Restaurant? restaurant;

  SubscriptionModel({
    this.id,
    this.status,
    this.startAt,
    this.endAt,
    this.note,
    this.type,
    this.quantity,
    this.userId,
    this.restaurantId,
    this.billingAmount,
    this.paidAmount,
    this.createdAt,
    this.updatedAt,
    this.isPausedToday,
    this.restaurant,
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    startAt = json['start_at'];
    endAt = json['end_at'];
    note = json['note'];
    type = json['type'];
    quantity = json['quantity'];
    userId = json['user_id'];
    restaurantId = json['restaurant_id'];
    billingAmount = json['billing_amount'].toDouble();
    paidAmount = json['paid_amount'].toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isPausedToday = json['is_paused_today'];
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['store']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['start_at'] = startAt;
    data['end_at'] = endAt;
    data['note'] = note;
    data['type'] = type;
    data['quantity'] = quantity;
    data['user_id'] = userId;
    data['restaurant_id'] = restaurantId;
    data['billing_amount'] = billingAmount;
    data['paid_amount'] = paidAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_paused_today'] = isPausedToday;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    return data;
  }
}

class OrderReference {
  int? id;
  int? orderId;
  String? tokenNumber;
  String? tableNumber;
  String? createdAt;
  String? updatedAt;

  OrderReference({this.id,
        this.orderId,
        this.tokenNumber,
        this.tableNumber,
        this.createdAt,
        this.updatedAt});

  OrderReference.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    tokenNumber = json['token_number'];
    tableNumber = json['table_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['token_number'] = tokenNumber;
    data['table_number'] = tableNumber;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}