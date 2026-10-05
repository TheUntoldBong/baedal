import 'package:get/get_connect.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_store_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/repositories/happy_hour_repository_interface.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class HappyHourRepository implements HappyHourRepositoryInterface {
  final ApiClient apiClient;

  HappyHourRepository({required this.apiClient});

  String get _guestParam => AuthHelper.isGuestLoggedIn() ? 'guest_id=${AuthHelper.getGuestId()}' : '';

  @override
  Future<RunningHappyHourModel?> getRunningHappyHour() async {
    final String guest = _guestParam;
    Response response = await apiClient.getData(
      '${AppConstants.happyHourRunningUri}${guest.isEmpty ? '' : '?$guest'}', handleError: false,
    );
    if (response.statusCode == 200) {
      return RunningHappyHourModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<HappyHourStoreModel?> getList({int? offset, int limit = 10, bool runningOnly = true}) async {
    final String guest = _guestParam;
    Response response = await apiClient.getData(
      '${AppConstants.happyHourStoreUri}?limit=$limit&offset=${offset ?? 1}'
      '${runningOnly ? '&running=1' : ''}${guest.isEmpty ? '' : '&$guest'}',
    );
    if (response.statusCode == 200) {
      return HappyHourStoreModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
