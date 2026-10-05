import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_active_card_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_faq_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_plan_card_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_plan_selector_widget.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_terms_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool fromDialog;
  final bool? flag;
  final bool isRenewalMode;
  const SubscriptionPlanScreen({super.key, this.fromDialog = false, this.flag, this.isRenewalMode = false});

  static void open() {
    if (ResponsiveHelper.isDesktop(Get.context!)) {
      Get.dialog(
        Dialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          insetPadding: const EdgeInsets.all(22),
          child: SizedBox(
            width: 700,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.92),
              child: Stack(
                children: [
                  const SubscriptionPlanScreen(fromDialog: true),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Theme.of(Get.context!).hintColor),
                      style: IconButton.styleFrom(backgroundColor: Get.context!.bgNeutralLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        useSafeArea: false,
      );
    } else {
      Get.to(() => const SubscriptionPlanScreen());
    }
  }

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  bool _isRenewalMode = false;
  bool _successShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _showProSuccess();
    });
  }

  Future<void> _showProSuccess() async {
    if (_successShown || !mounted) return;
    _successShown = true;

    if(widget.flag != null){
      Get.find<ProController>().showPlanSubscribeState(widget.isRenewalMode, paymentStatus: widget.flag!,);
    }
  }

  Future<void> _loadInitialData() async {
    await Get.find<ProController>().loadInitialData();
    await Get.find<ProfileController>().getUserInfo();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDataOnResume();
    }
  }

  Future<void> _refreshDataOnResume() async {
    await Get.find<ProfileController>().getUserInfo();
  }

  void _enterRenewalMode() {
    setState(() => _isRenewalMode = true);
  }

  void _cancelRenewalMode() {
    setState(() => _isRenewalMode = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      final bool isPro = profileController.userInfoModel?.proStatus == true;
      final bool isRenewal = _isRenewalMode;
      return Scaffold(
        backgroundColor: context.surfaceContainer,
        appBar: widget.fromDialog ? null : CustomAppBarWidget(
          title: isPro ? 'my_subscription'.tr : 'subscription_plan'.tr,
          isBackButtonExist: true,
        ),
        body: Column(children: [
          Expanded(
            child: GetBuilder<ProController>(builder: (proController) {

              if(proController.isLoading && proController.planModel == null) {
                return const Center(child: CustomLoaderWidget());
              }

              final ProPlanModel? model = proController.planModel;
              Widget child = Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: isPro ? isRenewal ? _RenewalView(model: model, proController:proController, fromDialog: widget.fromDialog, onCancel: _cancelRenewalMode)
                      : _SubscribedView(model: model, proController: proController, fromDialog: widget.fromDialog, onRenew: _enterRenewalMode)
                      : _UnsubscribedView(model: model, proController: proController, fromDialog: widget.fromDialog),
                ),
              );

              if(!widget.fromDialog) {
                child = SizedBox(child: child);
              }

              child = SingleChildScrollView(controller: scrollController, child: child);

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ResponsiveHelper.isDesktop(context) && !widget.fromDialog ? Scrollbar(
                  controller: scrollController,
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: child,
                ) : child,
              );
            }),
          ),
        ]),
      );
    });
  }
}

class _SubscribedView extends StatelessWidget {
  final ProPlanModel? model;
  final ProController proController;
  final bool fromDialog;
  final VoidCallback? onRenew;
  const _SubscribedView({required this.model, required this.proController, required this.fromDialog, this.onRenew});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(fromDialog) const _DialogHeader(titleKey: 'my_subscription'),
          const SizedBox(height: Dimensions.paddingLarge),

          ProActiveCardWidget(activeOfferModel: proController.activeOfferModel, onRenew: onRenew),
          const SizedBox(height: Dimensions.paddingLarge),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(color: context.outline)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProFaqWidget(faqList: proController.faqList),
                  const SizedBox(height: Dimensions.paddingExtraLarge),

                  const _TermsLink(),
                  const SizedBox(height: Dimensions.paddingLarge),
                ]
            ),
          ),

          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}

class _UnsubscribedView extends StatelessWidget {
  final ProPlanModel? model;
  final ProController proController;
  final bool fromDialog;
  const _UnsubscribedView({required this.model, required this.proController, required this.fromDialog});

  @override
  Widget build(BuildContext context) {
    final List<PlanItem> plans = model?.plans?.where((plan) => plan.status == true).toList() ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingLarge),
          Center(child: Text('choose_your_pro_plan'.tr, style: context.heading.large.medium)),
          Center(child: Text('unlock_exclusive_benefits_save_more'.tr, textAlign: TextAlign.center, style: context.body.small.regular.overrideWith(color: context.textBaseMedium))),
          const SizedBox(height: Dimensions.paddingDefault),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: context.outline)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProPlanCardWidget(model: model),

                if (plans.isNotEmpty) Padding(
                  padding: EdgeInsetsGeometry.all(Dimensions.paddingDefault),
                  child: Column(children: [
                    const SizedBox(height: Dimensions.paddingLarge),
                    ProPlanSelectorWidget(plans: plans),
                  ]),
                )
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingExtraLarge),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(color: context.outline)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProFaqWidget(faqList: proController.faqList),
                const SizedBox(height: Dimensions.paddingExtraLarge),

                const _TermsLink(),
                const SizedBox(height: Dimensions.paddingLarge),
              ]
            ),
          ),

          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}

class _RenewalView extends StatelessWidget {
  final ProPlanModel? model;
  final ProController proController;
  final bool fromDialog;
  final VoidCallback? onCancel;
  const _RenewalView({required this.model, required this.proController, required this.fromDialog, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final List<PlanItem> plans = model?.plans
        ?.where((plan) => plan.status == true && plan.planType != ProPlanType.freeTrial)
        .toList() ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(fromDialog) const SizedBox(height: 60),
          const SizedBox(height: Dimensions.paddingSmall),
          Center(child: Text('renew_your_subscription'.tr, textAlign: TextAlign.center, style: context.heading.extraLarge.strong)),

          Center(
            child: Text(
              'unlock_exclusive_benefits_save_more'.tr,
              textAlign: TextAlign.center,
              style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: context.outline)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProPlanCardWidget(model: model),

                if (plans.isNotEmpty) Padding(
                  padding: EdgeInsetsGeometry.all(Dimensions.paddingDefault),
                  child: Column(children: [
                    const SizedBox(height: Dimensions.paddingLarge),
                    ProPlanSelectorWidget(
                      plans: plans,
                      currentPlanId: proController.activeOfferModel?.benefit?.planId,
                      isRenewal: true,
                      onCancel: onCancel,
                    ),
                  ]),
                )
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingExtraLarge),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(color: context.outline)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProFaqWidget(faqList: proController.faqList),
                const SizedBox(height: Dimensions.paddingExtraLarge),

                const _TermsLink(),
                const SizedBox(height: Dimensions.paddingLarge),
              ]
            ),
          ),

          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String titleKey;
  const _DialogHeader({required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(titleKey.tr, textAlign: TextAlign.center, style: context.heading.extraOverLarge.strong),
          const SizedBox(height: Dimensions.paddingSmall),
          Text(
            'unlock_exclusive_benefits_save_more'.tr,
            textAlign: TextAlign.center,
            style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }
}

class _TermsLink extends StatelessWidget {
  const _TermsLink();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showTerms(context),
        child: Text(
          'terms_and_condition'.tr,
          style: context.body.defaultSize.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color).copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
          insetPadding: const EdgeInsets.all(22),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: const SizedBox(width: 600, child: ProTermsBottomSheetWidget()),
        ),
        useSafeArea: false,
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
        ),
        builder: (context) => const ProTermsBottomSheetWidget(),
      );
    }
  }
}
