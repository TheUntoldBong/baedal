class CuisineModel {
  List<Cuisines>? cuisines;

  CuisineModel({this.cuisines});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    if (json['Cuisines'] != null) {
      cuisines = <Cuisines>[];
      json['Cuisines'].forEach((v) {
        cuisines!.add(Cuisines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cuisines != null) {
      data['Cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cuisines {
  int? id;
  String? name;
  String? imageFullUrl;
  int? status;
  int? priority;
  String? slug;
  String? createdAt;
  String? updatedAt;

  Cuisines({
    this.id,
    this.name,
    this.imageFullUrl,
    this.status,
    this.priority,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  Cuisines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    status = json['status'];
    priority = json['priority'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['status'] = status;
    data['priority'] = priority;
    data['slug'] = slug;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
