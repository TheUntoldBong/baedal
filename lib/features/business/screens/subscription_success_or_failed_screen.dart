import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/registration_stepper_widget.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionSuccessOrFailedScreen extends StatefulWidget {
  final bool success;
  final bool fromSubscription;
  final int? restaurantId;
  final int? packageId;
  const SubscriptionSuccessOrFailedScreen({super.key, required this.success, required this.fromSubscription, this.restaurantId, this.packageId});

  @override
  State<SubscriptionSuccessOrFailedScreen> createState() => _SubscriptionSuccessOrFailedScreenState();
}

class _SubscriptionSuccessOrFailedScreenState extends State<SubscriptionSuccessOrFailedScreen> {
  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        appBar: isDesktop ? CustomAppBarWidget(title: 'restaurant_registration'.tr) : null,

        body: SingleChildScrollView(
          child: SizedBox(
            child: Column(children: [

              SizedBox(width: Dimensions.webMaxWidth, child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                  SizedBox(height: isDesktop ? Dimensions.paddingOverLarge : 0),

                  isDesktop ? GetBuilder<BusinessController>(
                    builder: (businessController) {
                      return const SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: RegistrationStepperWidget(status: 'complete'),
                      );
                    }
                  ) : Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingLarge, right: Dimensions.paddingLarge, top: Dimensions.paddingSizeExtraOverLarge, bottom: Dimensions.paddingLarge,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text(
                        'restaurant_registration'.tr,
                        style: context.heading.large.medium,
                      ),

                      Text(
                        widget.success ? 'registration_success'.tr : 'transaction_failed'.tr,
                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      ),
                      const SizedBox(height: Dimensions.paddingSmall),

                      LinearProgressIndicator(
                        backgroundColor: context.iconBaseMedium, minHeight: 2,
                        value: widget.success ? 1 : 0.75,
                      ),

                    ]),
                  ),
                  SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraOverLarge : context.height * 0.2),

                  Container(
                    width: Dimensions.webMaxWidth,
                    padding: EdgeInsets.all(isDesktop ? 40 : 0),
                    decoration: isDesktop ? BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
                    ) : null,
                    child: Column(children: [

                      CustomAssetImageWidget(
                        widget.success ? Images.checkGif : Images.cancelGif,
                        height: isDesktop ? 100 : 100,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        child: widget.success ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                          const SizedBox(height: Dimensions.paddingSmall),

                          Text(
                            '${'congratulations'.tr}!',
                            style: context.heading.extraLarge.strong,
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),

                          SizedBox(
                            width: isDesktop ? 500 : context.width,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium).copyWith(height: 1.7), children: [
                                TextSpan(text: widget.fromSubscription ? '${'subscription_success_message'.tr} ' : '${'commission_base_success_message'.tr} '),
                              ]),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingOverLarge),

                          TextButton(
                            onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                            child: Text(
                              'continue_to_home_page'.tr,
                              style: context.body.defaultSize.medium.overrideWith(color: context.primary)
                                  .copyWith(decoration: TextDecoration.underline, decorationColor: context.primary),
                            ),
                          ),

                        ]) : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                          const SizedBox(height: Dimensions.paddingLarge),

                          Text(
                            '${'transaction_failed'.tr}!',
                            style: context.heading.extraLarge.strong,
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),

                          SizedBox(
                            width: isDesktop ? 500 : context.width,
                            child: Text(
                              'sorry_your_transaction_can_not_be_completed_please_choose_another_payment_method_or_try_again'.tr,
                              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingDefault),

                          TextButton(
                            onPressed: () {
                              if(!GetPlatform.isWeb){
                                Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(restaurantId: widget.restaurantId, packageId: widget.packageId));
                              }else{
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }
                            },
                            child: Text(
                              !GetPlatform.isWeb ? 'try_again'.tr : 'continue_to_home_page'.tr,
                              style: context.body.defaultSize.medium.overrideWith(color: context.primary)
                                  .copyWith(decoration: TextDecoration.underline, decorationColor: context.primary),
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ),

                ]),
              )),

            ]),
          ),
        ),
      ),
    );
  }
}
