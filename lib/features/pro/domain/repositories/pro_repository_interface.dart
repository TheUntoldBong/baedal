import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_faq_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect.dart';

abstract class ProRepositoryInterface extends RepositoryInterface {
  Future<ProPlanModel?> getProPlans();
  Future<List<ProFaqModel>?> getProFaqs();
  Future<ProActiveOfferModel?> getProActiveOffer();
  Future<Response> subscribePlan({required int planId, required String paymentType, required String paymentMethod, String? callback, required String paymentPlatform});
  Future<Response> cancelSubscription();
  Future<bool> saveCurrentPath(String route);
  String? getSavedRoute();
  Future<bool> removeSavedRoute();
  bool getRenewBottomSheetShown();
  Future<bool> saveRenewBottomSheetShown(bool shown);
}
