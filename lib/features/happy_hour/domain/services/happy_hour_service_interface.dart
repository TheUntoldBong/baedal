import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_store_model.dart';

abstract class HappyHourServiceInterface {
  Future<RunningHappyHourModel?> getRunningHappyHour();
  Future<HappyHourStoreModel?> getStoreList({required int offset, int limit = 10, bool runningOnly = true});

  bool isValidHappyHour(RunningHappyHourModel? model);
  int resolveRemainingSeconds(HappyHourModel happyHour);
}
