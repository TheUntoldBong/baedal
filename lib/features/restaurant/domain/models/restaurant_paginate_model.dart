import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';

enum RestaurantPaginateType { recommended, topPick, quickDelivery }

class RestaurantPaginateModel {
  List<Restaurant>? restaurants;
  int? totalSize;
  int offset = 1;
  bool paginating = false;
  VegType type = VegType.all;
  String searchQuery = '';
  final List<int> loadedOffsets = <int>[];

  bool get loading => restaurants == null;

  bool hasMore(int limit) {
    if (restaurants == null || totalSize == null) return false;
    return offset < (totalSize! / limit).ceil();
  }
}
