import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';
import 'package:get/get_connect/connect.dart';

class CategoryService implements CategoryServiceInterface {
  final CategoryRepositoryInterface categoryRepositoryInterface;

  CategoryService({required this.categoryRepositoryInterface});

  @override
  Future<List<CategoryModel>?> getCategoryList({DataSourceEnum? source, String? search}) async {
    return await categoryRepositoryInterface.getList(source: source, search: search);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async {
    return await categoryRepositoryInterface.getSubCategoryList(parentID);
  }

  @override
  Future<ProductModel?> getCategoryProductList(String? categoryID, FilterDataModel? filterDataModel) async {
    return await categoryRepositoryInterface.getCategoryProductList(categoryID, filterDataModel);
  }

  @override
  Future<RestaurantModel?> getCategoryRestaurantList(String? categoryID, FilterDataModel? filterDataModel) async {
    return await categoryRepositoryInterface.getCategoryRestaurantList(categoryID, filterDataModel);
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isRestaurant, FilterDataModel? filterDataModel) async {
    return await categoryRepositoryInterface.getSearchData(query, categoryID, isRestaurant, filterDataModel);
  }

}