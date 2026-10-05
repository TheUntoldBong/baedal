import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_model.dart' as cuisine_model;
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';

class AiChatMessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? conversationId;
  List<AiChatMessage>? messages;

  AiChatMessageModel({this.totalSize, this.limit, this.offset, this.conversationId, this.messages});

  AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'] is String ? int.tryParse(json['limit']) : json['limit'];
    offset = json['offset'] is String ? int.tryParse(json['offset']) : json['offset'];
    conversationId = json['conversation_id'];

    final dynamic rawMessages = json['data'] ?? json['messages'];
    if (rawMessages != null) {
      messages = <AiChatMessage>[];
      rawMessages.forEach((v) {
        messages!.add(AiChatMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['conversation_id'] = conversationId;
    if (messages != null) {
      data['data'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiChatMessage {
  int? id;
  int? conversationId;
  String? role;
  String? content;
  String? toolName;
  AiChatMetadata? metadata;
  String? createdAt;
  String? updatedAt;
  bool sending;

  AiChatMessage({
    this.id,
    this.conversationId,
    this.role,
    this.content,
    this.toolName,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.sending = false,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  AiChatMessage.fromJson(Map<String, dynamic> json)
      : sending = false {
    id = json['id'];
    conversationId = json['conversation_id'];
    role = json['role'];
    content = json['content'] ?? json['message'];
    toolName = json['tool_name'];
    metadata = json['metadata'] != null && json['metadata'] is Map<String, dynamic>
        ? AiChatMetadata.fromJson(json['metadata'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['role'] = role;
    data['content'] = content;
    data['tool_name'] = toolName;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class AiChatMetadata {
  List<Product>? products;
  List<Restaurant>? restaurants;
  List<CategoryModel>? categories;
  List<cuisine_model.Cuisines>? cuisines;
  List<BogoOfferCardModel>? bogoOffers;
  List<HappyHourModel>? happyHours;
  AiChatCart? cart;
  bool? cartUpdated;

  AiChatMetadata({
    this.products, this.restaurants, this.categories, this.cuisines,
    this.bogoOffers, this.happyHours, this.cart, this.cartUpdated,
  });

  AiChatMetadata.fromJson(Map<String, dynamic> json) {
    cartUpdated = json['cart_updated'] is bool ? json['cart_updated'] as bool : null;

    if (json['products'] is List) {
      products = <Product>[];
      for (var v in (json['products'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            products!.add(Product.fromJson(_normalizeProductJson(v)));
          } catch (_) {}
        }
      }
    }

    final dynamic rawRestaurants = json['restaurants'] ?? json['stores'];
    if (rawRestaurants is List) {
      restaurants = <Restaurant>[];
      for (var v in rawRestaurants) {
        if (v is Map<String, dynamic>) {
          try {
            restaurants!.add(Restaurant.fromJson(_normalizeRestaurantJson(v)));
          } catch (_) {}
        }
      }
    }

    if (json['categories'] is List) {
      categories = <CategoryModel>[];
      for (var v in (json['categories'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            categories!.add(CategoryModel.fromJson(_normalizeCategoryJson(v)));
          } catch (_) {}
        }
      }
    }

    if (json['cuisines'] is List) {
      cuisines = <cuisine_model.Cuisines>[];
      for (var v in (json['cuisines'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            cuisines!.add(cuisine_model.Cuisines.fromJson(_normalizeCuisineJson(v)));
          } catch (_) {}
        }
      }
    }

    if (json['bogo_offers'] is List) {
      bogoOffers = <BogoOfferCardModel>[];
      for (var v in (json['bogo_offers'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            bogoOffers!.add(BogoOfferCardModel.fromJson(v));
          } catch (_) {}
        }
      }
    }

    if (json['happy_hours'] is List) {
      happyHours = <HappyHourModel>[];
      for (var v in (json['happy_hours'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            happyHours!.add(HappyHourModel.fromJson(v));
          } catch (_) {}
        }
      }
    }

    if (json['cart'] is Map<String, dynamic>) {
      try {
        cart = AiChatCart.fromJson(json['cart']);
      } catch (_) {}
    }
  }

  bool get hasProducts => products != null && products!.isNotEmpty;
  bool get hasRestaurants => restaurants != null && restaurants!.isNotEmpty;
  bool get hasCategories => categories != null && categories!.isNotEmpty;
  bool get hasCuisines => cuisines != null && cuisines!.isNotEmpty;
  bool get hasBogoOffers => bogoOffers != null && bogoOffers!.isNotEmpty;
  bool get hasHappyHours => happyHours != null && happyHours!.isNotEmpty;
  bool get hasCart => cart != null && cart!.stores.isNotEmpty;
  bool get isEmpty => !hasProducts && !hasRestaurants && !hasCategories && !hasCuisines
      && !hasBogoOffers && !hasHappyHours && !hasCart;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (cuisines != null) {
      data['cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    if (bogoOffers != null) {
      data['bogo_offers'] = bogoOffers!.map((v) => v.toJson()).toList();
    }
    if (happyHours != null) {
      data['happy_hours'] = happyHours!.map((v) => v.toJson()).toList();
    }
    if (cart != null) {
      data['cart'] = cart!.toJson();
    }
    if (cartUpdated != null) {
      data['cart_updated'] = cartUpdated;
    }
    return data;
  }
}

class AiChatCart {
  List<AiChatCartStoreGroup> stores;
  double? grandTotal;
  int? totalItems;

  AiChatCart({required this.stores, this.grandTotal, this.totalItems});

  AiChatCart.fromJson(Map<String, dynamic> json) : stores = <AiChatCartStoreGroup>[] {
    grandTotal = (json['grand_total'] as num?)?.toDouble();
    totalItems = json['total_items'] is String ? int.tryParse(json['total_items']) : json['total_items'];

    if (json['stores'] is List) {
      for (var v in (json['stores'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            stores.add(AiChatCartStoreGroup.fromJson(v));
          } catch (_) {}
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stores'] = stores.map((v) => v.toJson()).toList();
    data['grand_total'] = grandTotal;
    data['total_items'] = totalItems;
    return data;
  }
}

class AiChatCartStoreGroup {
  int? storeId;
  String? storeName;
  List<AiChatCartItem> items;
  double? storeSubtotal;

  AiChatCartStoreGroup({this.storeId, this.storeName, required this.items, this.storeSubtotal});

  AiChatCartStoreGroup.fromJson(Map<String, dynamic> json) : items = <AiChatCartItem>[] {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeSubtotal = (json['store_subtotal'] as num?)?.toDouble();

    if (json['items'] is List) {
      for (var v in (json['items'] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            items.add(AiChatCartItem.fromJson(_normalizeCartItemJson(v)));
          } catch (_) {}
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['items'] = items.map((v) => v.toJson()).toList();
    data['store_subtotal'] = storeSubtotal;
    return data;
  }
}

class AiChatCartItem {
  int? cartId;
  int? itemId;
  String? name;
  String? variation;
  String? image;
  String? imageFullUrl;
  int? quantity;
  double? unitPrice;
  double? lineTotal;
  AiChatCartBogoDetails? bogoDetails;

  AiChatCartItem({
    this.cartId, this.itemId, this.name, this.variation, this.image,
    this.imageFullUrl, this.quantity, this.unitPrice, this.lineTotal, this.bogoDetails,
  });

  bool get isBogoBundle => bogoDetails != null;

  AiChatCartItem.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    itemId = json['item_id'];
    name = json['name'];
    variation = json['variation'];
    image = json['image'];
    imageFullUrl = json['image_full_url'];
    quantity = json['quantity'] is String ? int.tryParse(json['quantity']) : json['quantity'];
    unitPrice = (json['unit_price'] as num?)?.toDouble();
    lineTotal = (json['line_total'] as num?)?.toDouble();
    if (json['bogo_details'] is Map<String, dynamic>) {
      try {
        bogoDetails = AiChatCartBogoDetails.fromJson(json['bogo_details']);
      } catch (_) {}
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['item_id'] = itemId;
    data['name'] = name;
    data['variation'] = variation;
    data['image'] = image;
    data['image_full_url'] = imageFullUrl;
    data['quantity'] = quantity;
    data['unit_price'] = unitPrice;
    data['line_total'] = lineTotal;
    data['bogo_details'] = bogoDetails?.toJson();
    return data;
  }
}

class AiChatCartBogoDetails {
  String? bogoGroupId;
  int? bogoOfferId;
  int? bundleId;
  String? offerTitle;
  String? offerSlug;
  String? offerStartDate;
  String? offerEndDate;
  int? quantity;
  double? bundlePrice;
  double? totalPrice;
  double? originalPrice;
  double? discountPercentage;
  double? discountAmount;
  double? finalPrice;
  double? totalDiscountAmount;
  double? totalFinalPrice;
  bool isHappyHour;
  bool isAvailable;
  String? unavailableReason;
  List<AiChatCartItem> buyItems;
  List<AiChatCartItem> freeItems;

  AiChatCartBogoDetails({
    this.bogoGroupId, this.bogoOfferId, this.bundleId, this.offerTitle, this.offerSlug,
    this.offerStartDate, this.offerEndDate, this.quantity, this.bundlePrice, this.totalPrice,
    this.originalPrice, this.discountPercentage, this.discountAmount, this.finalPrice,
    this.totalDiscountAmount, this.totalFinalPrice, this.isHappyHour = false,
    this.isAvailable = true, this.unavailableReason,
    List<AiChatCartItem>? buyItems, List<AiChatCartItem>? freeItems,
  })  : buyItems = buyItems ?? <AiChatCartItem>[],
        freeItems = freeItems ?? <AiChatCartItem>[];

  double get savings {
    double original = originalPrice ?? 0;
    double charged = totalFinalPrice ?? totalPrice ?? bundlePrice ?? 0;
    double saved = original - charged;
    return saved > 0 ? saved : 0;
  }

  AiChatCartBogoDetails.fromJson(Map<String, dynamic> json)
      : buyItems = <AiChatCartItem>[],
        freeItems = <AiChatCartItem>[],
        isHappyHour = json['is_happy_hour'] == true,
        isAvailable = json['is_available'] != false {
    bogoGroupId = json['bogo_group_id']?.toString();
    bogoOfferId = int.tryParse('${json['bogo_offer_id']}');
    bundleId = int.tryParse('${json['bundle_id']}');
    offerTitle = json['offer_title'];
    offerSlug = json['offer_slug']?.toString();
    offerStartDate = json['offer_start_date'];
    offerEndDate = json['offer_end_date'];
    quantity = int.tryParse('${json['quantity']}');
    bundlePrice = double.tryParse('${json['bundle_price']}');
    totalPrice = double.tryParse('${json['total_price']}');
    originalPrice = double.tryParse('${json['original_price']}');
    discountPercentage = double.tryParse('${json['discount_percentage']}');
    discountAmount = double.tryParse('${json['discount_amount']}');
    finalPrice = double.tryParse('${json['final_price']}');
    totalDiscountAmount = double.tryParse('${json['total_discount_amount']}');
    totalFinalPrice = double.tryParse('${json['total_final_price']}');
    unavailableReason = json['unavailable_reason']?.toString();

    for (final String key in const ['buy_items', 'free_items']) {
      if (json[key] is! List) {
        continue;
      }
      for (var v in (json[key] as List)) {
        if (v is Map<String, dynamic>) {
          try {
            AiChatCartItem item = AiChatCartItem.fromJson(_normalizeCartItemJson(v));
            key == 'buy_items' ? buyItems.add(item) : freeItems.add(item);
          } catch (_) {}
        }
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'bogo_group_id': bogoGroupId, 'bogo_offer_id': bogoOfferId, 'bundle_id': bundleId,
    'offer_title': offerTitle, 'offer_slug': offerSlug,
    'offer_start_date': offerStartDate, 'offer_end_date': offerEndDate,
    'quantity': quantity, 'bundle_price': bundlePrice, 'total_price': totalPrice,
    'original_price': originalPrice, 'discount_percentage': discountPercentage,
    'discount_amount': discountAmount, 'final_price': finalPrice,
    'total_discount_amount': totalDiscountAmount, 'total_final_price': totalFinalPrice,
    'is_happy_hour': isHappyHour, 'is_available': isAvailable,
    'unavailable_reason': unavailableReason,
    'buy_items': buyItems.map((v) => v.toJson()).toList(),
    'free_items': freeItems.map((v) => v.toJson()).toList(),
  };
}


Map<String, dynamic> _normalizeProductJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if (json['veg'] is bool) {
    json['veg'] = (json['veg'] as bool) ? 1 : 0;
  }

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  json['price'] ??= 0;
  json['discount'] ??= 0;
  json['restaurant_discount'] ??= 0;
  json['avg_rating'] ??= 0;

  return json;
}

Map<String, dynamic> _normalizeRestaurantJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if (json['veg'] is bool) {
    json['veg'] = (json['veg'] as bool) ? 1 : 0;
  }
  if (json['non_veg'] is bool) {
    json['non_veg'] = (json['non_veg'] as bool) ? 1 : 0;
  }

  if (json['open'] == null && json['is_open'] != null) {
    json['open'] = (json['is_open'] is bool)
        ? ((json['is_open'] as bool) ? 1 : 0)
        : json['is_open'];
  }

  if (json['distance'] == null && json['distance_km'] != null) {
    json['distance'] = (json['distance_km'] as num).toDouble();
  }

  if ((json['logo_full_url'] == null || json['logo_full_url'].toString().isEmpty)
      && json['logo'] != null && json['logo'].toString().isNotEmpty) {
    json['logo_full_url'] = json['logo'];
  } else if ((json['logo_full_url'] == null || json['logo_full_url'].toString().isEmpty)
      && json['restaurant_logo'] != null && json['restaurant_logo'].toString().isNotEmpty) {
    json['logo_full_url'] = json['restaurant_logo'];
  }

  if ((json['cover_photo_full_url'] == null || json['cover_photo_full_url'].toString().isEmpty)
      && json['cover_photo'] != null && json['cover_photo'].toString().isNotEmpty) {
    json['cover_photo_full_url'] = json['cover_photo'];
  }

  if (json['discount'] is Map) {
    final Map<String, dynamic> discount = Map<String, dynamic>.from(json['discount'] as Map);
    discount['discount'] ??= 0;
    discount['min_purchase'] ??= 0;
    discount['max_discount'] ??= 0;
    json['discount'] = discount;
  }

  return json;
}

Map<String, dynamic> _normalizeCartItemJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  return json;
}

Map<String, dynamic> _normalizeCuisineJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  return json;
}

Map<String, dynamic> _normalizeCategoryJson(Map<String, dynamic> raw) {
  final Map<String, dynamic> json = Map<String, dynamic>.from(raw);

  if ((json['image_full_url'] == null || json['image_full_url'].toString().isEmpty)
      && json['image'] != null && json['image'].toString().isNotEmpty) {
    json['image_full_url'] = json['image'];
  }

  return json;
}
