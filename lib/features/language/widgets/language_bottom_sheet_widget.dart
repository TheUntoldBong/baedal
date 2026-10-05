import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/language/widgets/language_card_widget.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LanguageBottomSheetWidget extends StatefulWidget {
  const LanguageBottomSheetWidget({super.key});

  @override
  State<LanguageBottomSheetWidget> createState() => _LanguageBottomSheetWidgetState();
}

class _LanguageBottomSheetWidgetState extends State<LanguageBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(builder: (localizationController) {
      return Container(
        padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: context.bgNeutralLight,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Text('choose_your_language'.tr, style: context.heading.large.strong),
            const SizedBox(height: Dimensions.padding2xSmall),

            Text('choose_your_language_to_proceed'.tr, style: context.body.small.regular),

          ]),
          const SizedBox(height: Dimensions.paddingExtraLarge),

          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                itemBuilder: (context, index) {
                  return LanguageCardWidget(
                    languageModel: localizationController.languages[index],
                    localizationController: localizationController,
                    index: index, fromBottomSheet: true,
                  );
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault, horizontal: Dimensions.paddingExtraLarge),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, spreadRadius: 0)],
            ),
            margin: const EdgeInsets.only(top: Dimensions.paddingSmall),
            child: CustomButtonWidget(
              buttonText: 'update'.tr,
              onPressed: () {
                if(localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                  localizationController.saveCacheLanguage(Locale(
                    AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                    AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                  ));
                }
                Get.back();
              },
            ),
          ),

        ]),

      );
    });
  }
}
