import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';

class BogoHomeModel {
  final bool? isLive;
  final String? title;
  final String? description;
  final int? totalOffers;
  final List<BogoOfferCardModel>? offers;

  const BogoHomeModel({this.isLive, this.title, this.description, this.totalOffers, this.offers});

  factory BogoHomeModel.fromJson(Map<String, dynamic> json) => BogoHomeModel(
    isLive: json['is_live'] == true || json['is_live'] == 1,
    title: json['title'],
    description: json['description'],
    totalOffers: int.tryParse('${json['total_offers']}'),
    offers: json['offers'] is List ? (json['offers'] as List).map((offer) => BogoOfferCardModel.fromJson(offer)).toList() : null,
  );
}

class BogoOfferCardModel {
  final int? id;
  final String? slug;
  final String? title;
  final String? description;
  final String? imageFullUrl;
  final int? buyQty;
  final int? getQty;
  final String? offerLabel;
  final List<String>? orderTypes;
  final String? startDate;
  final String? endDate;
  final String? validUntil;
  final int? usageLimitPerCustomer;
  final int? remainingUses;

  const BogoOfferCardModel({
    this.id, this.slug, this.title, this.description, this.imageFullUrl,
    this.buyQty, this.getQty, this.offerLabel, this.orderTypes,
    this.startDate, this.endDate, this.validUntil,
    this.usageLimitPerCustomer, this.remainingUses,
  });

  factory BogoOfferCardModel.fromJson(Map<String, dynamic> json) => BogoOfferCardModel(
    id: json['id'],
    slug: json['slug']?.toString(),
    title: json['title'],
    description: json['description'],
    imageFullUrl: json['image_full_url'],
    buyQty: int.tryParse('${json['buy_qty']}'),
    getQty: int.tryParse('${json['get_qty']}'),
    offerLabel: json['offer_label'],
    orderTypes: json['order_types'] is List ? (json['order_types'] as List).map((type) => type.toString()).toList() : null,
    startDate: json['start_date'],
    endDate: json['end_date'],
    validUntil: json['valid_until'],
    usageLimitPerCustomer: json['usage_limit_per_customer'] != null ? int.tryParse('${json['usage_limit_per_customer']}') : null,
    remainingUses: json['remaining_uses'] != null ? int.tryParse('${json['remaining_uses']}') : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'slug': slug, 'title': title, 'description': description,
    'image_full_url': imageFullUrl, 'buy_qty': buyQty, 'get_qty': getQty,
    'offer_label': offerLabel, 'order_types': orderTypes,
    'start_date': startDate, 'end_date': endDate, 'valid_until': validUntil,
    'usage_limit_per_customer': usageLimitPerCustomer, 'remaining_uses': remainingUses,
  };
}

class BogoOfferListModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<BogoOfferCardModel>? offers;

  BogoOfferListModel({this.totalSize, this.limit, this.offset, this.offers});

  BogoOfferListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if(json['offers'] != null) {
      offers = [];
      json['offers'].forEach((offer) => offers!.add(BogoOfferCardModel.fromJson(offer)));
    }
  }
}

class RestaurantBogoOfferModel {
  final BogoOfferCardModel offer;
  final BogoBundleModel bundle;

  const RestaurantBogoOfferModel({required this.offer, required this.bundle});

  factory RestaurantBogoOfferModel.fromJson(Map<String, dynamic> json, {Restaurant? restaurant}) {
    final BogoBundleModel bundle = BogoBundleModel.fromJson(json);
    return RestaurantBogoOfferModel(
      offer: BogoOfferCardModel.fromJson(json),
      bundle: (restaurant != null && bundle.restaurant == null) ? bundle.copyWith(restaurant: restaurant) : bundle,
    );
  }
}

class RestaurantBogoOfferListModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<RestaurantBogoOfferModel>? offers;

  RestaurantBogoOfferListModel({this.totalSize, this.limit, this.offset, this.offers});

  RestaurantBogoOfferListModel.fromJson(Map<String, dynamic> json, {Restaurant? restaurant}) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if(json['offers'] != null) {
      offers = [];
      json['offers'].forEach((offer) => offers!.add(RestaurantBogoOfferModel.fromJson(offer, restaurant: restaurant)));
    }
  }
}

class BogoOfferDetailsResponseModel {
  int? id;
  String? slug;
  String? title;
  String? description;
  String? imageFullUrl;
  int? buyQty;
  int? getQty;
  String? offerLabel;
  String? validUntil;
  int? usageLimitPerCustomer;
  int? remainingUses;
  int? totalSize;
  String? limit;
  int? offset;
  List<BogoBundleModel>? bundles;

  BogoOfferDetailsResponseModel({
    this.id, this.slug, this.title, this.description, this.imageFullUrl, this.buyQty, this.getQty,
    this.offerLabel, this.validUntil, this.usageLimitPerCustomer,
    this.remainingUses, this.totalSize, this.limit, this.offset, this.bundles,
  });

  BogoOfferDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug']?.toString();
    title = json['title'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    buyQty = int.tryParse('${json['buy_qty']}');
    getQty = int.tryParse('${json['get_qty']}');
    offerLabel = json['offer_label'];
    validUntil = json['valid_until'];
    usageLimitPerCustomer = json['usage_limit_per_customer'];
    remainingUses = json['remaining_uses'];
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if(json['bundles'] != null) {
      bundles = [];
      json['bundles'].forEach((bundle) => bundles!.add(BogoBundleModel.fromJson(bundle)));
    }
  }
}

class BogoBundleModel {
  final int? bundleId;
  final int? buyCount;
  final int? getCount;
  final List<String?>? itemThumbnails;
  final Restaurant? restaurant;
  final double? bundlePrice;
  final double? originalPrice;
  final double? discountPercentage;
  final double? discountAmount;
  final double? finalPrice;
  final bool? isHappyHour;
  final BogoHappyHourSummary? happyHour;
  final List<BogoOfferItemModel> buyItems;
  final List<BogoOfferItemModel> freeItems;

  const BogoBundleModel({
    this.bundleId, this.buyCount, this.getCount, this.itemThumbnails, this.restaurant,
    this.bundlePrice, this.originalPrice, this.discountPercentage, this.discountAmount,
    this.finalPrice, this.isHappyHour, this.happyHour, required this.buyItems, required this.freeItems,
  });

  factory BogoBundleModel.fromJson(Map<String, dynamic> json) {
    final Restaurant? restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;

    return BogoBundleModel(
      bundleId: json['bundle_id'],
      buyCount: json['buy_count'],
      getCount: json['get_count'],
      itemThumbnails: json['item_thumbnails'] is List ? (json['item_thumbnails'] as List).map((thumbnail) => thumbnail?.toString()).toList() : null,
      restaurant: restaurant,
      bundlePrice: double.tryParse('${json['bundle_price']}'),
      originalPrice: double.tryParse('${json['original_price']}'),
      discountPercentage: double.tryParse('${json['discount_percentage']}'),
      discountAmount: double.tryParse('${json['discount_amount']}'),
      finalPrice: double.tryParse('${json['final_price']}'),
      isHappyHour: json['is_happy_hour'] == true,
      happyHour: json['happy_hour'] != null ? BogoHappyHourSummary.fromJson(json['happy_hour']) : null,
      buyItems: json['buy_items'] is List ? (json['buy_items'] as List).map((item) => BogoOfferItemModel.fromBundleItemJson(
        item, restaurantId: restaurant?.id, restaurantName: restaurant?.name,
      )).toList() : [],
      freeItems: json['free_items'] is List ? (json['free_items'] as List).map((item) => BogoOfferItemModel.fromBundleItemJson(
        item, restaurantId: restaurant?.id, restaurantName: restaurant?.name, isFree: true,
      )).toList() : [],
    );
  }

  BogoBundleModel copyWith({Restaurant? restaurant}) => BogoBundleModel(
    bundleId: bundleId, buyCount: buyCount, getCount: getCount, itemThumbnails: itemThumbnails,
    restaurant: restaurant ?? this.restaurant, bundlePrice: bundlePrice, originalPrice: originalPrice,
    discountPercentage: discountPercentage, discountAmount: discountAmount, finalPrice: finalPrice,
    isHappyHour: isHappyHour, happyHour: happyHour, buyItems: buyItems, freeItems: freeItems,
  );
}

class BogoHappyHourSummary {
  final int? id;
  final String? slug;
  final String? title;
  final double? discount;
  final String? endTime;

  const BogoHappyHourSummary({this.id, this.slug, this.title, this.discount, this.endTime});

  factory BogoHappyHourSummary.fromJson(Map<String, dynamic> json) => BogoHappyHourSummary(
    id: json['id'],
    slug: json['slug']?.toString(),
    title: json['title'],
    discount: double.tryParse('${json['discount']}'),
    endTime: json['end_time'],
  );
}

class BogoOfferItemModel {
  final Product product;
  final int quantity;
  final String variationText;
  final String addOnText;

  const BogoOfferItemModel({
    required this.product,
    required this.quantity,
    required this.variationText,
    this.addOnText = '',
  });

  static String _summariseAddOns(dynamic addOns) {
    if(addOns is! List) {
      return '';
    }
    final List<String> parts = [];
    for(final addOn in addOns) {
      if(addOn is! Map) {
        continue;
      }
      final String name = '${addOn['name'] ?? ''}'.trim();
      if(name.isEmpty) {
        continue;
      }
      final int quantity = int.tryParse('${addOn['quantity']}') ?? 1;
      parts.add(quantity > 1 ? '$name x $quantity' : name);
    }
    return parts.join(', ');
  }

  factory BogoOfferItemModel.fromBundleItemJson(Map<String, dynamic> json, {int? restaurantId, String? restaurantName, bool isFree = false}) {
    final double price = double.tryParse('${json['price']}') ?? 0;
    return BogoOfferItemModel(
      quantity: int.tryParse('${json['quantity']}') ?? 1,
      variationText: json['variation_summary'] ?? '',
      addOnText: _summariseAddOns(json['add_ons']),
      product: Product(
        id: json['food_id'] ?? json['id'],
        slug: json['slug']?.toString(),
        name: json['name'],
        imageFullUrl: json['image_full_url'],
        price: price,
        avgRating: double.tryParse('${json['avg_rating']}'),
        ratingCount: int.tryParse('${json['rating_count']}'),
        veg: json['veg'],
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        variations: const [],
      ),
    );
  }
}
