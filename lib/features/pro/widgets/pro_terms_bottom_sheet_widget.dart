import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/html/controllers/html_controller.dart';
import 'package:stackfood_multivendor/features/html/enums/html_type.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProTermsBottomSheetWidget extends StatefulWidget {
  const ProTermsBottomSheetWidget({super.key});

  @override
  State<ProTermsBottomSheetWidget> createState() => _ProTermsBottomSheetWidgetState();
}

class _ProTermsBottomSheetWidgetState extends State<ProTermsBottomSheetWidget> {
  @override
  void initState() {
    super.initState();
    Get.find<HtmlController>().resetHtmlText();
    Get.find<HtmlController>().getHtmlText(HtmlType.proTermsAndCondition);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSmall),
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.bgNeutralMedium,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
          GetBuilder<HtmlController>(builder: (htmlController) {
            if (htmlController.htmlTitle == null) {
              return SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
              child: Text(
                htmlController.htmlTitle?.toCapitalized() ?? 'terms_and_condition'.tr,
                style: context.heading.large.strong,
              ),
            );
          }),
          Divider( height: 1),
          Expanded(
            child: GetBuilder<HtmlController>(builder: (htmlController) {
              if (htmlController.htmlText == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                child: HtmlWidget(
                  htmlController.htmlText!,
                  textStyle: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                  onTapUrl: (String url) => launchUrlString(url),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
