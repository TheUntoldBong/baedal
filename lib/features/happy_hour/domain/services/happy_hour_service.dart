import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_store_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/repositories/happy_hour_repository_interface.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/services/happy_hour_service_interface.dart';

class HappyHourService implements HappyHourServiceInterface {
  final HappyHourRepositoryInterface happyHourRepositoryInterface;

  HappyHourService({required this.happyHourRepositoryInterface});

  @override
  Future<RunningHappyHourModel?> getRunningHappyHour() async {
    return await happyHourRepositoryInterface.getRunningHappyHour();
  }

  @override
  Future<HappyHourStoreModel?> getStoreList({required int offset, int limit = 10, bool runningOnly = true}) async {
    return await happyHourRepositoryInterface.getList(offset: offset, limit: limit, runningOnly: runningOnly);
  }

  @override
  bool isValidHappyHour(RunningHappyHourModel? model) {
    final HappyHourModel? happyHour = model?.happyHour;
    return (model?.isRunning ?? false) && happyHour != null && (happyHour.discount ?? 0) > 0;
  }

  @override
  int resolveRemainingSeconds(HappyHourModel happyHour) {
    final int? remaining = happyHour.remainingSeconds;
    if (remaining != null && remaining > 0) {
      return remaining;
    }
    final DateTime? endsAt = DateTime.tryParse(happyHour.endsAt ?? '');
    if (endsAt == null) {
      return 0;
    }
    final int seconds = endsAt.difference(DateTime.now()).inSeconds;
    return seconds > 0 ? seconds : 0;
  }
}
