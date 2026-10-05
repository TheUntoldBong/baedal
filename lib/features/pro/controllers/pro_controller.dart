import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_faq_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/services/pro_service_interface.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_failed_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_renew_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_success_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

class ProController extends GetxController implements GetxService {
  final ProServiceInterface proServiceInterface;
  ProController({required this.proServiceInterface});

  ProPlanModel? _planModel;
  ProPlanModel? get planModel => _planModel;

  List<ProFaqModel>? _faqList;
  List<ProFaqModel>? get faqList => _faqList;

  ProActiveOfferModel? _activeOfferModel;
  ProActiveOfferModel? get activeOfferModel => _activeOfferModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubscribeLoading = false;
  bool get isSubscribeLoading => _isSubscribeLoading;

  bool _isCancelLoading = false;
  bool get isCancelLoading => _isCancelLoading;

  Future<void> getProPlans() async {
    _planModel = await proServiceInterface.getProPlans();
    update();
  }

  Future<void> getProFaqs() async {
    _faqList = await proServiceInterface.getProFaqs();
    update();
  }

  Future<void> getProActiveOffer() async {
    if(!Get.find<ProfileController>().isPro) {
      _activeOfferModel = null;
      update();
      return;
    }
    _activeOfferModel = await proServiceInterface.getProActiveOffer();
    update();
  }

  Future<void> loadInitialData()async{
    _isLoading = true;
    update();
    await Future.wait([
      getProActiveOffer(),
      getProFaqs(),
      getProPlans()
    ]);
    _isLoading = false;
    update();
  }

  Future<void> subscribePlan(PlanItem plan, String paymentType, String paymentMethod, bool isRenew) async {
    if(plan.id == null) {
      showCustomSnackBar('no_data_found'.tr);
      return;
    }

    _isSubscribeLoading = true;
    update();
    String? hostname = html.window.location.hostname;
    String protocol = html.window.location.protocol;
    String paymentPlatform = GetPlatform.isWeb ? 'web' : 'app';
    String? callback = kIsWeb ? '$protocol//$hostname${RouteHelper.subscriptionPlan}${isRenew ? '/renew' : ''}' : null;
    Response response = await proServiceInterface.subscribePlan(planId: plan.id!, paymentType: paymentType, paymentMethod: paymentMethod, callback: callback, paymentPlatform: paymentPlatform);
    _isSubscribeLoading = false;
    update();

    if(response.statusCode == 200) {
      if(response.body['redirect_link'] != null) {
        _proSubscriptionPayment(response.body['redirect_link'], paymentMethod, isRenew);
      } else {
        showPlanSubscribeState(isRenew);
        await Get.find<ProfileController>().getUserInfo();
        await getProPlans();
        await getProActiveOffer();
      }
    } else {
      showCustomSnackBar(response.statusText);
    }
  }

  void saveCurrentPath(){
    final String currentRoute = kIsWeb
        ? (Uri.base.hasQuery ? '${Uri.base.path}?${Uri.base.query}' : Uri.base.path)
        : Get.currentRoute;
    proServiceInterface.saveCurrentPath(currentRoute);
  }

  String? getSavedRoute() {
    return proServiceInterface.getSavedRoute();
  }

  void removeSavedRoute() {
    proServiceInterface.removeSavedRoute();
  }

  bool getRenewBottomSheetStatus() {
    return proServiceInterface.getRenewBottomSheetShown();
  }

  bool get shouldShowRenewBottomSheet {
    final sub = Get.find<ProfileController>().userInfoModel?.proSubscription;
    return sub?.isExpired == true && ProHelper.showUnsubscribedBanner;
  }

  void saveRenewBottomSheetStatus(bool shown) {
    proServiceInterface.saveRenewBottomSheetShown(shown);
  }

  static const List<String> _renewSkipRoutes = [
    RouteHelper.splash, RouteHelper.language, RouteHelper.onBoarding,
    RouteHelper.signIn, RouteHelper.signUp, RouteHelper.verification,
    RouteHelper.accessLocation, RouteHelper.pickMap, RouteHelper.newUserSetupScreen,
    RouteHelper.interest,
  ];

  Future<void> maybeShowRenewOnRoute(String? route) async {
    if(!AuthHelper.isLoggedIn() || getRenewBottomSheetStatus()) return;

    final String current = (route ?? '').split('?').first;
    if(current.isEmpty) return;
    final bool isFlowRoute = _renewSkipRoutes.any((r) => current == r || current.startsWith('$r/'));
    if(isFlowRoute) return;

    Future.delayed(const Duration(milliseconds: 600), () => showRenewProBottomSheet());
  }

  Future<void> showRenewProBottomSheet() async {
    final bool showRenew = Get.find<ProController>().shouldShowRenewBottomSheet;
    if(!showRenew) return;
    Get.find<ProController>().saveRenewBottomSheetStatus(true);
    ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: const ProRenewBottomSheetWidget(),
    ), useSafeArea: false) : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) => const ProRenewBottomSheetWidget(),
    );
  }

  void showPlanSubscribeState(bool isRenew, {bool redirect = false, bool paymentStatus = true, bool isOffAll = false,})async{
    if(Get.isOverlaysOpen){
      Get.back();
    }
    if(redirect){
      if(isOffAll){
        Get.offAllNamed(RouteHelper.getSubscriptionPlanRoute(flag: paymentStatus, isRenew: isRenew));
      }else{
        Get.offNamed(RouteHelper.getSubscriptionPlanRoute(flag: paymentStatus, isRenew: isRenew), preventDuplicates: false);
      }
    }else{
      String? route = getSavedRoute();
      if(route != null && route.isNotEmpty){
        removeSavedRoute();
        Get.offNamed(route);
      }
      if(paymentStatus){
        saveRenewBottomSheetStatus(false);
        ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
            insetPadding: const EdgeInsets.all(22),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: ProSuccessBottomSheetWidget(isRenewalMode: isRenew,),
          ),
          useSafeArea: false,
        ) : Get.bottomSheet(
          ProSuccessBottomSheetWidget(isRenewalMode: isRenew,),
          isScrollControlled: true,
          backgroundColor: Get.theme.cardColor,
        );
      }else{
        Get.bottomSheet(
          const ProFailedBottomSheetWidget(),
          isScrollControlled: true,
          backgroundColor: Get.theme.cardColor,
        );
      }
    }
  }


  Future<void> cancelSubscription() async {
    _isCancelLoading = true;
    update();
    Response response = await proServiceInterface.cancelSubscription();
    _isCancelLoading = false;
    update();

    if(response.statusCode == 200) {
      showCustomSnackBar(response.body['message'] ?? 'subscription_cancelled_successfully'.tr, isError: false);
      await Get.find<ProfileController>().getUserInfo();
      await getProPlans();
      await getProActiveOffer();
    } else {
      showCustomSnackBar(response.statusText);
    }
  }

  Future<void> _proSubscriptionPayment(String redirectUrl, String paymentMethod, bool isRenew  ) async {
    if(GetPlatform.isWeb) {
      html.window.open(redirectUrl, '_self',);
    } else {
      Get.toNamed(RouteHelper.getPaymentRoute(
        OrderModel(),
        paymentMethod,
        subscriptionUrl: redirectUrl,
        guestId: Get.find<AuthController>().getGuestId(),
        isProSubscription: true,
        isRenew: isRenew
      ));
    }
  }
}
