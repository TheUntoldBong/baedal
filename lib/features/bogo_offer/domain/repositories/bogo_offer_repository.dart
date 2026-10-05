import 'package:get/get_connect.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/repositories/bogo_offer_repository_interface.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class BogoOfferRepository implements BogoOfferRepositoryInterface {
  final ApiClient apiClient;
  BogoOfferRepository({required this.apiClient});

  String get _guestQuery {
    final String guestId = AuthHelper.isLoggedIn() ? '' : AuthHelper.getGuestId();
    return guestId.isNotEmpty ? '&guest_id=$guestId' : '';
  }

  @override
  Future<BogoHomeModel?> getBogoHomeData({int limit = 6, String? orderType}) async {
    Response response = await apiClient.getData(
      '${AppConstants.bogoHomeUri}?limit=$limit${(orderType != null && orderType.isNotEmpty) ? '&order_type=$orderType' : ''}$_guestQuery',
      handleError: false,
    );
    if(response.statusCode == 200) {
      return BogoHomeModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<BogoOfferListModel?> getBogoOfferList({int offset = 1, int limit = 10}) async {
    Response response = await apiClient.getData(
      '${AppConstants.bogoOfferListUri}?limit=$limit&offset=$offset$_guestQuery', handleError: false,
    );
    if(response.statusCode == 200) {
      return BogoOfferListModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<BogoOfferDetailsResponseModel?> getBogoOfferDetails({required String idOrSlug, int offset = 1, int limit = 10}) async {
    Response response = await apiClient.getData(
      '${AppConstants.bogoOfferListUri}/$idOrSlug?limit=$limit&offset=$offset$_guestQuery', handleError: false,
    );
    if(response.statusCode == 200) {
      return BogoOfferDetailsResponseModel.fromJson(response.body);
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
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
