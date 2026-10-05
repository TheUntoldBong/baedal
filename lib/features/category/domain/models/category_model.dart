class CategoryModel {
  int? id;
  String? name;
  int? parentId;
  int? position;
  int? status;
  int? priority;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;

  CategoryModel({
    this.id,
    this.name,
    this.parentId,
    this.position,
    this.status,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentId = json['parent_id'];
    position = json['position'];
    status = json['status'];
    priority = json['priority'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['parent_id'] = parentId;
    data['position'] = position;
    data['status'] = status;
    data['priority'] = priority;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}
