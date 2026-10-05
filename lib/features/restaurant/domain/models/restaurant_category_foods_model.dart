import 'package:stackfood_multivendor/common/models/product_model.dart';

class RestaurantCategoryFoodsModel {
  int? totalSize;
  int? limit;
  int? offset;
  String? categorySource;
  List<RestaurantCategoryItem>? categories;
  Map<String, List<Product>>? categoryWiseFoods;

  RestaurantCategoryFoodsModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.categorySource,
    this.categories,
    this.categoryWiseFoods,
  });

  factory RestaurantCategoryFoodsModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<Product>> categoryFoods = {};
    if (json['category_wise_foods'] != null) {
      (json['category_wise_foods'] as Map<String, dynamic>).forEach((key, value) {
        categoryFoods[key] = (value as List).map((e) => Product.fromJson(e)).toList();
      });
    }
    return RestaurantCategoryFoodsModel(
      totalSize: json['total_size'],
      limit: json['limit'],
      offset: json['offset'],
      categorySource: json['category_source'],
      categories: json['categories'] != null
          ? (json['categories'] as List).map((e) => RestaurantCategoryItem.fromJson(e)).toList()
          : null,
      categoryWiseFoods: categoryFoods,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_size': totalSize,
    'limit': limit,
    'offset': offset,
    'category_source': categorySource,
    'categories': categories?.map((e) => e.toJson()).toList(),
    'category_wise_foods': categoryWiseFoods?.map(
      (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
    ),
  };
}

class RestaurantCategoryItem {
  int? id;
  String? name;
  String? imageFullUrl;
  int? foodsCount;

  RestaurantCategoryItem({this.id, this.name, this.imageFullUrl, this.foodsCount});

  factory RestaurantCategoryItem.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryItem(
      id: json['id'],
      name: json['name'],
      imageFullUrl: json['image_full_url'],
      foodsCount: json['foods_count'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_full_url': imageFullUrl,
    'foods_count': foodsCount,
  };
}
