import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:stackfood_multivendor/features/refer_and_earn/widgets/bottom_sheet_view_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final ScrollController scrollController = ScrollController();
  final JustTheController tooltipController = JustTheController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    Get.find<ReferAndEarnController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'refer_and_earn'.tr),
      body: isLoggedIn ? Column(children: [

        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingLarge),
            child: SizedBox(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController) {
                    void shareText() => SharePlus.instance.share(
                      ShareParams(text: Get.find<SplashController>().configModel?.appUrlAndroid != null ? '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                        : '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode}'),
                    );
                    String qrLink = '${Get.find<SplashController>().configModel?.appUrlAndroid ?? ''}?ref=${referAndEarnController.userInfoModel?.refCode ?? ''}';

                    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraOverLarge : Dimensions.paddingOverLarge),

                      CustomAssetImageWidget(
                        Images.reference, width: 500,
                        height: isDesktop ? 250 : 86, fit: BoxFit.contain,
                      ),
                      const SizedBox(height: Dimensions.paddingDefault),

                       ...[
                        Text('invite_friends_and_get_rewarded'.tr, style: context.heading.large.strong, textAlign: TextAlign.center),
                        const SizedBox(height: Dimensions.paddingExtraSmall),

                        Text('copy_your_code_share_it_with_your_friends'.tr,
                            style: context.heading.small.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center),
                        const SizedBox(height: Dimensions.paddingExtraLarge),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Column(children: [
                            const SizedBox(height: Dimensions.paddingOverLarge),
                            Text('invitation_qr_code'.tr, style: context.heading.defaultSize.strong),
                            const SizedBox(height: Dimensions.paddingDefault),

                            (referAndEarnController.userInfoModel != null) ? QrImageView(
                              data: qrLink,
                              version: QrVersions.auto,
                              size: 80,
                              eyeStyle: QrEyeStyle(
                                color: context.textBaseDefault,
                                eyeShape: QrEyeShape.square
                              )
                            ) : const SizedBox(
                              height: 80, width: 80,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            const SizedBox(height: Dimensions.paddingOverLarge),

                            Divider( height: 1, thickness: 1),
                            const SizedBox(height: Dimensions.paddingDefault),

                            Text('your_referral_code'.tr, style: context.heading.defaultSize.strong),
                            const SizedBox(height: Dimensions.paddingDefault),

                            (referAndEarnController.userInfoModel != null) ? Container(
                              padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                              decoration: BoxDecoration(
                                color: context.surface,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(children: [
                                Expanded(child: Text(
                                  referAndEarnController.userInfoModel!.refCode ?? '',
                                  style: context.heading.defaultSize.medium,
                                )),

                                JustTheTooltip(
                                  backgroundColor: context.bgUtilBlanket,
                                  controller: tooltipController,
                                  preferredDirection: AxisDirection.up,
                                  tailLength: 14,
                                  tailBaseWidth: 20,
                                  triggerMode: TooltipTriggerMode.manual,
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('copied'.tr, style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseMedium)),
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      if(referAndEarnController.userInfoModel!.refCode!.isNotEmpty){
                                        tooltipController.showTooltip();
                                        Clipboard.setData(ClipboardData(text: '${referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode : ''}'));
                                      }

                                      Future.delayed(const Duration(seconds: 2), () {
                                        tooltipController.hideTooltip();
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                                      decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(50)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        CustomAssetImageWidget(Images.copyCopy, height: 16, width: 16, color: context.surfaceContainer),
                                        const SizedBox(width: 4),
                                        Text('copy'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.surfaceContainer)),
                                      ]),
                                    ),
                                  ),
                                ),
                              ]),
                            ) : const CircularProgressIndicator(),
                            const SizedBox(height: Dimensions.paddingExtraLarge),

                            Text('or_share'.tr, style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center),
                            const SizedBox(height: Dimensions.paddingExtraLarge),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              InkWell(onTap: shareText, child: CustomAssetImageWidget(Images.inMessenger, height: 48, width: 48)),
                              InkWell(onTap: shareText, child: CustomAssetImageWidget(Images.inWhatsapp, height: 48, width: 48)),
                              InkWell(onTap: shareText, child: CustomAssetImageWidget(Images.inMail, height: 48, width: 48)),
                              InkWell(onTap: shareText, child: CustomAssetImageWidget(Images.inViber, height: 48, width: 48)),
                              InkWell(onTap: shareText, child: CustomAssetImageWidget(Images.inShare, height: 48, width: 48)),
                            ]),
                          ]),
                        ),
                        const SizedBox(height: Dimensions.paddingExtraLarge),
                      ],

                    ]);
                  }),
                ),
              ),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          color: context.surfaceContainer,
          child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: const HowItWorkWidget())),
        ),

      ]) : NotLoggedInScreen(callBack: (value){
        _initCall();
        setState(() {});
      }),
    );
  }
}
