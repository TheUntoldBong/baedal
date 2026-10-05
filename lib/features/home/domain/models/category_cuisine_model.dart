class CategoryCuisineModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<CategoryCuisineItem>? data;

  CategoryCuisineModel({this.totalSize, this.limit, this.offset, this.data});

  CategoryCuisineModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['data'] != null) {
      data = <CategoryCuisineItem>[];
      json['data'].forEach((v) {
        data!.add(CategoryCuisineItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryCuisineItem {
  String? type;
  int? id;
  String? name;
  String? slug;
  String? imageFullUrl;
  int? itemCount;

  CategoryCuisineItem({this.type, this.id, this.name, this.slug, this.imageFullUrl, this.itemCount});

  bool get isCuisine => type == 'cuisine';

  CategoryCuisineItem.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    imageFullUrl = json['image_full_url'];
    itemCount = int.tryParse('${json['item_count']}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['image_full_url'] = imageFullUrl;
    data['item_count'] = itemCount;
    return data;
  }
}
