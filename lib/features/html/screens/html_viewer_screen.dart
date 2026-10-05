import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:stackfood_multivendor/features/html/controllers/html_controller.dart';
import 'package:stackfood_multivendor/features/html/enums/html_type.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<HtmlController>().resetHtmlText();
    Get.find<HtmlController>().getHtmlText(widget.htmlType);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPrivacyMobile = widget.htmlType == HtmlType.privacyPolicy && !ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: isPrivacyMobile ? context.surfaceContainer : null,
      appBar: CustomAppBarWidget(title: widget.htmlType == HtmlType.termsAndCondition ? 'terms_conditions'.tr
          : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr : widget.htmlType == HtmlType.privacyPolicy
          ? 'privacy_policy'.tr :  widget.htmlType == HtmlType.shippingPolicy ? 'shipping_policy'.tr
          : widget.htmlType == HtmlType.refund ? 'refund_policy'.tr :  widget.htmlType == HtmlType.cancellation
          ? 'cancellation_policy'.tr : widget.htmlType == HtmlType.proTermsAndCondition
          ? 'terms_and_condition'.tr : 'no_data_found'.tr),
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        if(htmlController.htmlText == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if(isPrivacyMobile) {
          const double heroHeight = 54;
          const double heroVerticalPadding = Dimensions.paddingDefault * 2;

          return LayoutBuilder(builder: (context, constraints) {
            double minCardHeight = constraints.maxHeight - heroHeight - heroVerticalPadding;
            if(minCardHeight < 0) {
              minCardHeight = 0;
            }

            return SingleChildScrollView(
              controller: scrollController,
              child: SizedBox(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        child: CustomAssetImageWidget(Images.privacyPolicyHero, height: heroHeight, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minCardHeight),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Dimensions.paddingLarge),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        child: HtmlWidget(
                          htmlController.htmlText ?? '',
                          key: Key(widget.htmlType.toString()),
                          textStyle: context.subHeading.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                          onTapUrl: (String url){
                            return launchUrlString(url);
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          });
        }

        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: context.surfaceContainer,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingDefault,
                vertical: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingDefault,
              ),
              child: SizedBox(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ?  Dimensions.paddingLarge : 0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      ResponsiveHelper.isDesktop(context) ? Container(
                        height: 50, alignment: Alignment.center, color: context.surfaceContainer, width: Dimensions.webMaxWidth,
                        child: SelectableText(widget.htmlType == HtmlType.termsAndCondition ? 'terms_conditions'.tr
                            : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr : widget.htmlType == HtmlType.privacyPolicy
                            ? 'privacy_policy'.tr : widget.htmlType == HtmlType.shippingPolicy ? 'shipping_policy'.tr
                            : widget.htmlType == HtmlType.refund ? 'refund_policy'.tr :  widget.htmlType == HtmlType.cancellation
                            ? 'cancellation_policy'.tr : widget.htmlType == HtmlType.proTermsAndCondition
                            ? 'terms_and_condition'.tr : 'no_data_found'.tr,
                          style: context.subHeading.large.strong.overrideWith(color: context.textBaseMedium),
                        ),
                      ) : const SizedBox(),

                      HtmlWidget(
                        htmlController.htmlText ?? '',
                        key: Key(widget.htmlType.toString()),
                        textStyle: context.subHeading.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                        onTapUrl: (String url){
                          return launchUrlString(url);
                        },
                      ),

                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}