import 'package:flutter/foundation.dart';

class ProductModel {
  int? totalSize;
  double? minPrice;
  double? maxPrice;
  String? limit;
  int? offset;
  List<Product>? products;

  ProductModel({this.totalSize, this.minPrice, this.maxPrice, this.limit, this.offset, this.products});

  ProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    minPrice = json['min_price']?.toDouble();
    maxPrice = json['max_price']?.toDouble();
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        if (v['variations'] == null || v['variations'].isEmpty || v['variations'][0]['values'] != null) {
          products!.add(Product.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    data['limit'] = limit;
    data['offset'] = offset;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<AddOns>? addOns;
  List<ChoiceOptions>? choiceOptions;
  String? slug;
  double? price;
  double? discountedPrice;
  double? discountAmount;
  double? tax;
  double? discount;
  String? discountType;
  int? wishlist;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? restaurantId;
  String? restaurantName;
  String? restaurantLogoFullUrl;
  double? restaurantDiscount;
  int? restaurantStatus;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  int? cartQuantityLimit;
  bool? isRestaurantHalalActive;
  bool? isHalalFood;
  String? stockType;
  int? itemStock;
  List<String>? nutritionsName;
  List<String>? allergiesName;
  FoodSeoData? foodSeoData;
  int? reviewCount;
  List<Reviews>? reviews;
  List<int>? ratings;
  bool? verifiedSeller;
  List<String>? tags;
  Product({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.choiceOptions,
    this.slug,
    this.price,
    this.discountedPrice,
    this.discountAmount,
    this.tax,
    this.discount,
    this.discountType,
    this.wishlist,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.restaurantId,
    this.restaurantName,
    this.restaurantLogoFullUrl,
    this.restaurantDiscount,
    this.restaurantStatus,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.cartQuantityLimit,
    this.isRestaurantHalalActive,
    this.isHalalFood,
    this.stockType,
    this.itemStock,
    this.nutritionsName,
    this.allergiesName,
    this.foodSeoData,
    this.reviewCount,
    this.reviews,
    this.ratings,
    this.verifiedSeller,
    this.tags,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    categoryId = json['category_id'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = [];
      if(json['variations'] != null && json['variations'].length > 0 && json['variations'][0] != '[') {
        json['variations'].forEach((v) {
          variations!.add(Variation.fromJson(v));
        });
      }
    }
    if (json['add_ons'] != null && json['add_ons'].runtimeType == List) {
      addOns = [];
      json['add_ons']?.forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
    }
    if (json['choice_options'] != null && json['choice_options'] is! String) {
      choiceOptions = [];
      json['choice_options'].forEach((v) {
        choiceOptions!.add(ChoiceOptions.fromJson(v));
      });
    }
    slug = json['slug'];
    price = json['price']?.toDouble();
    discountedPrice = json['discounted_price']?.toDouble();
    discountAmount = json['discount_amount']?.toDouble();
    tax = json['tax']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    wishlist = json['wishlist'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    restaurantId = json['restaurant_id'];
    restaurantName = json['restaurant_name'];
    restaurantLogoFullUrl = json['restaurant_logo_full_url'] ?? json['restaurant_logo'] ?? json['logo_full_url'];
    restaurantDiscount = json['restaurant_discount']?.toDouble();
    restaurantStatus = json['restaurant_status'];
    scheduleOrder = json['schedule_order'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    veg = json['veg'] != null ? int.parse(json['veg'].toString()) : 0;
    cartQuantityLimit = json['maximum_cart_quantity'];
    isRestaurantHalalActive = json['halal_tag_status'] == 1;
    isHalalFood = json['is_halal'] == 1;
    stockType = json['stock_type'];
    itemStock = int.tryParse(json['item_stock'].toString());
    nutritionsName = json['nutritions_name']?.cast<String>();
    allergiesName = json['allergies_name']?.cast<String>();
    foodSeoData = json['food_seo_data'] != null ? FoodSeoData.fromJson(json['food_seo_data']) : null;
    reviewCount = json['review_count'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }

    if (json['ratings'] != null) {
      ratings = List<int>.filled(5, 0);
      if (json['ratings'] is Map) {
        (json['ratings'] as Map).forEach((key, value) {
          try {
            int ratingIndex = int.parse(key.toString()) - 1;
            if (ratingIndex >= 0 && ratingIndex < 5) {
              ratings![ratingIndex] = value is int ? value : 0;
            }
          } catch (e) {
            debugPrint('Error parsing rating key: $e');
          }
        });
      } else if (json['ratings'] is List) {
        ratings = List<int>.filled(5, 0);

      }
    }
    verifiedSeller = json["verified_seller"] == 1 || json["verified_seller"] == true;
    tags = json['tag'] != null ? List<String>.from(json['tag']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (choiceOptions != null) {
      data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['slug'] = slug;
    data['price'] = price;
    data['discounted_price'] = discountedPrice;
    data['discount_amount'] = discountAmount;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['wishlist'] = wishlist;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['restaurant_id'] = restaurantId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_logo_full_url'] = restaurantLogoFullUrl;
    data['restaurant_discount'] = restaurantDiscount;
    data['restaurant_status'] = restaurantStatus;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['veg'] = veg;
    data['maximum_cart_quantity'] = cartQuantityLimit;
    data['halal_tag_status'] = isRestaurantHalalActive;
    data['is_halal'] = isHalalFood;
    data['stock_type'] = stockType;
    data['item_stock'] = itemStock;
    data['nutritions_name'] = nutritionsName;
    data['allergies_name'] = allergiesName;
    if (foodSeoData != null) {
      data['food_seo_data'] = foodSeoData!.toJson();
    }
    data['review_count'] = reviewCount;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['ratings'] = ratings;
    data['verified_seller'] = verifiedSeller;
    data['tag'] = tags;
    return data;
  }
}

class CategoryIds {
  String? id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}

class Variation {
  String? name;
  bool? multiSelect;
  int? min;
  int? max;
  bool? required;
  List<VariationValue>? variationValues;

  Variation({this.name, this.multiSelect, this.min, this.max, this.required, this.variationValues});

  Variation.fromJson(Map<String, dynamic> json) {
    if (json['max'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min = multiSelect! ? int.parse(json['min'].toString()) : 0;
      max = multiSelect! ? int.parse(json['max'].toString()) : 0;
      required = json['required'] == 'on';
      if (json['values'] != null) {
        variationValues = [];
        json['values'].forEach((v) {
          variationValues!.add(VariationValue.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = multiSelect;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationValue {
  String? level;
  double? optionPrice;
  bool? isSelected;
  String? stockType;
  int? currentStock;
  int? optionId;
  bool? isTopPick;

  VariationValue({this.level, this.optionPrice, this.isSelected, this.stockType, this.currentStock, this.optionId, this.isTopPick});

  VariationValue.fromJson(Map<String, dynamic> json) {
    level = json['label'];
    optionPrice = double.parse(json['optionPrice'].toString());
    isSelected = json['isSelected'];
    stockType = json['stock_type'];
    currentStock = int.tryParse(json['current_stock'].toString());
    optionId = json['option_id'];
    isTopPick = json['is_top_pick'] == true || json['is_top_pick'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    data['isSelected'] = isSelected;
    data['stock_type'] = stockType;
    data['current_stock'] = currentStock;
    data['option_id'] = optionId;
    data['is_top_pick'] = isTopPick;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;
  String? stockType;
  int? addonStock;

  AddOns({
    this.id,
    this.name,
    this.price,
    this.stockType,
    this.addonStock,
  });

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toDouble();
    stockType = json['stock_type'];
    addonStock = json['addon_stock'] != null ? int.parse(json['addon_stock'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['stock_type'] = stockType;
    data['addon_stock'] = addonStock;
    return data;
  }
}

class ChoiceOptions {
  String? name;
  String? title;
  List<String>? options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class FoodSeoData {
  int? id;
  int? foodId;
  int? itemCampaignId;
  String? title;
  String? description;
  String? index;
  String? noFollow;
  String? noImageIndex;
  String? noArchive;
  String? noSnippet;
  String? maxSnippet;
  String? maxSnippetValue;
  String? maxVideoPreview;
  String? maxVideoPreviewValue;
  String? maxImagePreview;
  String? maxImagePreviewValue;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;

  FoodSeoData({
    this.id,
    this.foodId,
    this.itemCampaignId,
    this.title,
    this.description,
    this.index,
    this.noFollow,
    this.noImageIndex,
    this.noArchive,
    this.noSnippet,
    this.maxSnippet,
    this.maxSnippetValue,
    this.maxVideoPreview,
    this.maxVideoPreviewValue,
    this.maxImagePreview,
    this.maxImagePreviewValue,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
  });

  FoodSeoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    itemCampaignId = json['item_campaign_id'];
    title = json['title'];
    description = json['description'];
    index = json['index'];
    noFollow = json['no_follow'];
    noImageIndex = json['no_image_index'];
    noArchive = json['no_archive'];
    noSnippet = json['no_snippet'];
    maxSnippet = json['max_snippet'];
    maxSnippetValue = json['max_snippet_value'];
    maxVideoPreview = json['max_video_preview'];
    maxVideoPreviewValue = json['max_video_preview_value'];
    maxImagePreview = json['max_image_preview'];
    maxImagePreviewValue = json['max_image_preview_value'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['item_campaign_id'] = itemCampaignId;
    data['title'] = title;
    data['description'] = description;
    data['index'] = index;
    data['no_follow'] = noFollow;
    data['no_image_index'] = noImageIndex;
    data['no_archive'] = noArchive;
    data['no_snippet'] = noSnippet;
    data['max_snippet'] = maxSnippet;
    data['max_snippet_value'] = maxSnippetValue;
    data['max_video_preview'] = maxVideoPreview;
    data['max_video_preview_value'] = maxVideoPreviewValue;
    data['max_image_preview'] = maxImagePreview;
    data['max_image_preview_value'] = maxImagePreviewValue;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class Reviews {
  int? id;
  int? foodId;
  int? rating;
  String? comment;
  int? userId;
  String? createdAt;
  String? userName;

  Reviews({
    this.id,
    this.foodId,
    this.rating,
    this.comment,
    this.userId,
    this.createdAt,
    this.userName,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    rating = json['rating'];
    comment = json['comment'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['user_name'] = userName;
    return data;
  }
}
