import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class AddressRepoInterface<T> implements RepositoryInterface<AddressModel> {
  @override
  Future<List<AddressModel>?> getList({int? offset, bool isLocal = false, DataSourceEnum? source});
  Future<ResponseModel> markDefault(int id);
}