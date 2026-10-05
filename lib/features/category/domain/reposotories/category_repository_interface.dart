import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class CategoryRepositoryInterface implements RepositoryInterface {
  @override
  Future<List<CategoryModel>?> getList({int? offset, DataSourceEnum? source, String? search});
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID);
  Future<ProductModel?> getCategoryProductList(String? categoryID, FilterDataModel? filterDataModel);
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, FilterDataModel? filterDataModel);
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, FilterDataModel? filterDataModel);
}