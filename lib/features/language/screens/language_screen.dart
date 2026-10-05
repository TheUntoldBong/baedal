import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const LanguageScreen({super.key, required this.fromMenu});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBarWidget(title: 'language'.tr, isBackButtonExist: true) : null,
      backgroundColor: context.surface,
      body: GetBuilder<LocalizationController>(builder: (localizationController) {
        return Column(children: [

          Expanded(flex: 4,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge),
                child: CustomAssetImageWidget(Images.onboarding_4, height: context.height * 0.3, fit: BoxFit.contain),
              ),
            ),
          ),

          Expanded(flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
              ),
              child: SafeArea(top: false,
                child: Column(children: [
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Text('select_language'.tr, style: context.subHeading.extraLarge.strong),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Text('choose_your_prepared_language_to_use_the_app'.tr, style: context.body.small),
                  const SizedBox(height: Dimensions.paddingExtraLarge),

                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: localizationController.languages.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _LanguageOptionTile(
                          imageUrl: localizationController.languages[index].imageUrl ?? '',
                          title: localizationController.languages[index].languageName ?? '',
                          selected: localizationController.selectedLanguageIndex == index,
                          onTap: () => localizationController.setSelectLanguageIndex(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomButtonWidget(
                    buttonText: 'continue'.tr,
                    radius: Dimensions.radiusDefault,
                    fontSize: Dimensions.fontSizeDefault,
                    onPressed: () {
                      if(localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                        localizationController.setLanguage(Locale(
                          AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                          AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                        ));
                        if (widget.fromMenu) {
                          Navigator.pop(context);
                        } else {
                          Get.toNamed(RouteHelper.getOnBoardingRoute());
                        }
                      } else {
                        showCustomSnackBar('select_a_language'.tr);
                      }
                    },
                  ),
                ]),
              ),
            ),
          ),

        ]);
      }),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({required this.imageUrl, required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(color: selected ? context.outlineVariant : Colors.transparent, width: 1),
          ),
          child: Row(children: [

            ClipOval(
              child: CustomAssetImageWidget(imageUrl, height: 32, width: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: Text(title,
                style: selected ? context.heading.defaultSize.strong : context.body.defaultSize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            _LanguageRadio(selected: selected),
          ]),
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  final bool selected;

  const _LanguageRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? context.primary : context.outlineVariant;

    return Container(width: 20, height: 20,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color)),
      child: selected ? Center(
        child: Container(width: 11, height: 11, decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle)),
      ) : null,
    );
  }
}
