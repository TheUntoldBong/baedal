import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/registration_stepper_widget.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/features/business/widgets/payment_cart_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final int restaurantId;
  final int packageId;
  const SubscriptionPaymentScreen({super.key, required this.restaurantId, required this.packageId});

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  final bool _canBack = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<BusinessController>(builder: (businessController) {
      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async{
          if(_canBack) {
          }else {
            _showBackPressedDialogue('your_business_plan_not_setup_yet'.tr);
          }
        },
        child: Scaffold(
          appBar: isDesktop ? CustomAppBarWidget(title: 'restaurant_registration'.tr) : null,
          body: Column(children: [

            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

            isDesktop ? SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: RegistrationStepperWidget(status: Get.find<BusinessController>().businessPlanStatus),
              ),
            ) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical:  Dimensions.paddingSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  'restaurant_registration'.tr,
                  style: context.heading.large.medium,
                ),

                Text(
                  'you_are_one_step_away_choose_your_business_plan'.tr,
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                ),

                const SizedBox(height: Dimensions.paddingSmall),

                LinearProgressIndicator(
                  backgroundColor: context.surface, minHeight: 2,
                  value: 0.75,
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [

                    Container(
                      margin: EdgeInsets.only(top: isDesktop ? Dimensions.paddingSmall : 0),
                      decoration: isDesktop ? BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
                      ) : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 50 : 0,
                        vertical:  isDesktop ? Dimensions.paddingDefault : 0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingLarge),
                        child: Column(children: [

                          Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus ?? false ? PaymentCartWidget(
                            title: '${'continue_with'.tr} ${Get.find<SplashController>().configModel!.subscriptionFreeTrialDays} '
                                '${Get.find<SplashController>().configModel!.subscriptionFreeTrialType} ${'days_free_trial'.tr}',
                            index: 0,
                            onTap: () {
                              businessController.setPaymentIndex(0);
                            },
                          ) : const SizedBox(),
                          SizedBox(height: Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus ?? false ? Dimensions.paddingOverLarge : 0),

                          Get.find<SplashController>().configModel!.digitalPayment! ? Column(children: [
                            Row(children: [
                              Text('${'pay_via_online'.tr} ', style: context.subHeading.defaultSize.strong),
                              Text(
                                'faster_and_secure_way_to_pay_bill'.tr,
                                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                              ),
                            ]),

                            SizedBox(height: isDesktop ? Dimensions.paddingLarge : 0),

                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isDesktop ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                                crossAxisSpacing: Dimensions.paddingLarge,
                                mainAxisSpacing: Dimensions.paddingLarge,
                                mainAxisExtent: 55,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                              itemBuilder: (context, index) {
                                bool isSelected = businessController.paymentIndex == 1 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == businessController.digitalPaymentName;

                                return InkWell(
                                  onTap: (){
                                    businessController.setPaymentIndex(1);
                                    businessController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? context.primary.withValues(alpha: 0.05) : context.surfaceContainer,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      border: isSelected ? Border.all(color: isSelected ? context.primary : context.outline, width: 0.3) : null,
                                      boxShadow: isSelected ? null : [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
                                    child: Row(children: [
                                      Container(
                                        height: 20, width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle, color: isSelected ? context.primary : context.surfaceContainer,
                                          border: Border.all(color: context.outline),
                                        ),
                                        child: Icon(Icons.check, color: context.surfaceContainer, size: 16),
                                      ),
                                      const SizedBox(width: Dimensions.paddingDefault),

                                      Text(
                                        Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                        style: context.subHeading.defaultSize.medium,
                                      ),
                                      const Spacer(),

                                      CustomImageWidget(
                                        height: 20, fit: BoxFit.contain,
                                        image: '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                                      ),
                                      const SizedBox(width: Dimensions.paddingDefault),

                                    ]),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: !isDesktop ? Dimensions.paddingLarge : 0),
                          ]) : const SizedBox(),

                        ]),
                      ),
                    ),

                    SizedBox(height: isDesktop ? Dimensions.paddingOverLarge : 0),

                    isDesktop ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [

                      CustomButtonWidget(
                        textColor: context.surfaceContainer,
                        radius: Dimensions.radiusExtraSmall,
                        width: 140,
                        buttonText: 'confirm'.tr,
                        isLoading: businessController.isLoading,
                        onPressed: () {
                          if((Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus == false) && (businessController.paymentIndex == 0)){
                            showCustomSnackBar('please_select_payment_method'.tr);
                          }else{
                            businessController.submitBusinessPlan(restaurantId: widget.restaurantId, packageId: widget.packageId);
                          }
                        },
                        isBold: false,
                        fontSize: Dimensions.fontSizeSmall,
                      ),

                    ]) : const SizedBox(),

                  ]),
                ),
              ),
            ),

            !isDesktop ? Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
              child: CustomButtonWidget(
                buttonText: 'confirm'.tr,
                isLoading: businessController.isLoading,
                onPressed: () {
                  if((Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus == false) && (businessController.paymentIndex == 0)){
                    showCustomSnackBar('please_select_payment_method'.tr);
                  }else{
                    businessController.submitBusinessPlan(restaurantId: widget.restaurantId, packageId: widget.packageId);
                  }
                },
              ),
            ) : const SizedBox(),

          ]),
        ),
      );
    });
  }

  void _showBackPressedDialogue(String title){
    showCustomDialog(
      child: ConfirmationDialogWidget(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () {
        if(Get.isDialogOpen!){
          Get.back();
        }
        Get.back();
      },
    ),
    );
  }
}
