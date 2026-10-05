import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/repositories/bogo_offer_repository_interface.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/services/bogo_offer_service_interface.dart';

class BogoOfferService implements BogoOfferServiceInterface {
  final BogoOfferRepositoryInterface bogoOfferRepositoryInterface;
  BogoOfferService({required this.bogoOfferRepositoryInterface});

  @override
  Future<BogoHomeModel?> getBogoHomeData({int limit = 6, String? orderType}) async {
    return await bogoOfferRepositoryInterface.getBogoHomeData(limit: limit, orderType: orderType);
  }

  @override
  Future<BogoOfferListModel?> getBogoOfferList({int offset = 1, int limit = 10}) async {
    return await bogoOfferRepositoryInterface.getBogoOfferList(offset: offset, limit: limit);
  }

  @override
  Future<BogoOfferDetailsResponseModel?> getBogoOfferDetails({required String idOrSlug, int offset = 1, int limit = 10}) async {
    return await bogoOfferRepositoryInterface.getBogoOfferDetails(idOrSlug: idOrSlug, offset: offset, limit: limit);
  }
}
