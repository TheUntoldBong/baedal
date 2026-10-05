import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_store_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class HappyHourRepositoryInterface implements RepositoryInterface {
  Future<RunningHappyHourModel?> getRunningHappyHour();

  @override
  Future<HappyHourStoreModel?> getList({int? offset, int limit = 10, bool runningOnly = true});
}
