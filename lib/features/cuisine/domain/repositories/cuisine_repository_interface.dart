import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_data_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_restaurants_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class CuisineRepositoryInterface extends RepositoryInterface{
  @override
  Future<CuisineModel?> getList({int? offset, DataSourceEnum? source, String? search});
  Future<CuisineRestaurantModel?> getRestaurantList(int cuisineId, {String? name, FilterDataModel? filterDataModel});
  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchHistory();
  Future<bool> clearSearchHistory();
}