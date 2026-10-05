import 'package:stackfood_multivendor/common/models/restaurant_model.dart';

class HappyHourStoreModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Restaurant>? restaurants;

  HappyHourStoreModel({this.totalSize, this.limit, this.offset, this.restaurants});

  HappyHourStoreModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.tryParse(json['offset'].toString()) : null;
    if (json['restaurants'] != null) {
      restaurants = [];
      json['restaurants'].forEach((v) => restaurants!.add(Restaurant.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() => {
    'total_size': totalSize, 'limit': limit, 'offset': offset,
    'restaurants': restaurants?.map((v) => v.toJson()).toList(),
  };
}
