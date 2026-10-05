import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/services/bogo_offer_service_interface.dart';
import 'package:get/get.dart';

class BogoOfferDetailsController extends GetxController implements GetxService {
  final BogoOfferServiceInterface bogoOfferServiceInterface;
  BogoOfferDetailsController({required this.bogoOfferServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BogoOfferDetailsResponseModel? _bogoOfferDetailsModel;
  BogoOfferDetailsResponseModel? get bogoOfferDetailsModel => _bogoOfferDetailsModel;

  bool _bundlePaginate = false;
  bool get bundlePaginate => _bundlePaginate;

  String? _idOrSlug;

  Future<void> getBogoOfferDetails(String idOrSlug) async {
    _idOrSlug = idOrSlug;
    _isLoading = true;
    update();

    _bogoOfferDetailsModel = await bogoOfferServiceInterface.getBogoOfferDetails(idOrSlug: idOrSlug);

    _isLoading = false;
    update();
  }

  Future<void> loadMoreBundles() async {
    if(_bundlePaginate || _idOrSlug == null || _bogoOfferDetailsModel?.bundles == null) {
      return;
    }
    int limit = int.tryParse(_bogoOfferDetailsModel!.limit ?? '10') ?? 10;
    int totalPage = ((_bogoOfferDetailsModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_bogoOfferDetailsModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    _bundlePaginate = true;
    update();

    BogoOfferDetailsResponseModel? nextPage = await bogoOfferServiceInterface.getBogoOfferDetails(idOrSlug: _idOrSlug!, offset: nextOffset, limit: limit);
    if(nextPage != null) {
      _bogoOfferDetailsModel!.bundles!.addAll(nextPage.bundles ?? []);
      _bogoOfferDetailsModel!.offset = nextPage.offset;
      _bogoOfferDetailsModel!.totalSize = nextPage.totalSize;
    }
    _bundlePaginate = false;
    update();
  }
}
