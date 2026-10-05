import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/services/bogo_offer_service_interface.dart';
import 'package:get/get.dart';

class BogoOfferController extends GetxController implements GetxService {
  final BogoOfferServiceInterface bogoOfferServiceInterface;
  BogoOfferController({required this.bogoOfferServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BogoHomeModel? _bogoHomeModel;
  BogoHomeModel? get bogoHomeModel => _bogoHomeModel;

  bool get showHomeCard => _bogoHomeModel?.isLive ?? false;

  Future<void> getBogoHomeData({int limit = 6, String? orderType}) async {
    _bogoHomeModel = await bogoOfferServiceInterface.getBogoHomeData(limit: limit, orderType: orderType);
    update();
  }

  BogoOfferListModel? _bogoOfferListModel;
  List<BogoOfferCardModel>? get bogoOfferList => _bogoOfferListModel?.offers;

  bool _bogoOfferPaginate = false;
  bool get bogoOfferPaginate => _bogoOfferPaginate;

  int _offerListRequestId = 0;

  Future<void> getBogoOfferList({bool showLoader = true}) async {
    final int requestId = ++_offerListRequestId;
    if(showLoader) {
      _isLoading = true;
      update();
    }

    BogoOfferListModel? offerList = await bogoOfferServiceInterface.getBogoOfferList();
    if(requestId != _offerListRequestId) {
      return;
    }

    _bogoOfferListModel = offerList;
    _bogoOfferPaginate = false;
    _isLoading = false;
    update();
  }

  Future<void> loadMoreBogoOffers() async {
    if(_bogoOfferPaginate || _bogoOfferListModel?.offers == null) {
      return;
    }
    int limit = int.tryParse(_bogoOfferListModel!.limit ?? '10') ?? 10;
    int totalPage = ((_bogoOfferListModel!.totalSize ?? 0) / limit).ceil();
    int nextOffset = (_bogoOfferListModel!.offset ?? 1) + 1;
    if(nextOffset > totalPage) {
      return;
    }

    final int requestId = _offerListRequestId;
    _bogoOfferPaginate = true;
    update();

    BogoOfferListModel? nextPage = await bogoOfferServiceInterface.getBogoOfferList(offset: nextOffset, limit: limit);
    if(requestId != _offerListRequestId) {
      return;
    }
    if(nextPage != null) {
      _bogoOfferListModel!.offers!.addAll(nextPage.offers ?? []);
      _bogoOfferListModel!.offset = nextPage.offset;
      _bogoOfferListModel!.totalSize = nextPage.totalSize;
    }
    _bogoOfferPaginate = false;
    update();
  }

  final Map<String, Future<BogoOfferDetailsResponseModel?>> _offerDetailsCache = {};

  Future<BogoOfferDetailsResponseModel?> getCachedOfferDetails(String idOrSlug, {int limit = 100}) {
    return _offerDetailsCache.putIfAbsent(
      idOrSlug, () => bogoOfferServiceInterface.getBogoOfferDetails(idOrSlug: idOrSlug, limit: limit),
    );
  }
}
