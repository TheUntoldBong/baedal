import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class BogoOfferRepositoryInterface extends RepositoryInterface {
  Future<BogoHomeModel?> getBogoHomeData({int limit = 6, String? orderType});
  Future<BogoOfferListModel?> getBogoOfferList({int offset = 1, int limit = 10});
  Future<BogoOfferDetailsResponseModel?> getBogoOfferDetails({required String idOrSlug, int offset = 1, int limit = 10});
}
