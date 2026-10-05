import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(title: 'settings'.tr),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingDefault),
        child: CustomCard(
          isBorder: false,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Column(children: [

            GetBuilder<ThemeController>(builder: (themeController) {
              return SettingsButton(
                icon: themeController.darkTheme ? Images.darkModeLightIcon : Images.darkModeIcon,
                title: 'choose_theme'.tr,
                onTap: () {},
                trailing: _ThemeDropdown(
                  themeMode: themeController.themeMode,
                  onSelected: (AppThemeMode mode) {
                    if(mode != themeController.themeMode) {
                      themeController.setThemeMode(mode);
                    }
                  },
                ),
              );
            }),

            if(isLoggedIn) _Divider(),

            if(isLoggedIn) GetBuilder<AuthController>(builder: (authController) {
              return SettingsButton(
                icon: Images.notificationIcon, title: 'notification'.tr,
                onTap: () => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                trailing: CupertinoSwitch(
                  value: authController.notification,
                  onChanged: (bool isActive) => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                  activeTrackColor: context.primary,
                  inactiveTrackColor: context.bgNeutralMedium,
                ),
              );
            }),

            if(isLoggedIn) _Divider(),

            if(isLoggedIn) SettingsButton(
              icon: Images.passwordIcon, title: 'change_password'.tr,
              onTap: () {
                Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change'));
              },
            ),

            _Divider(),

            GetBuilder<LocalizationController>(builder: (localizationController) {
              int index = localizationController.selectedLanguageIndex;
              String languageName = index >= 0 && index < localizationController.languages.length
                  ? localizationController.languages[index].languageName ?? '' : '';
              return SettingsButton(
                icon: Images.language, title: 'language'.tr,
                onTap: () => _manageLanguageFunctionality(),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(languageName, style: context.subHeading.small.medium),
                ),
              );
            }),

          ]),
        ),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusSmall), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}

class SettingsButton extends StatelessWidget {
  final String icon;
  final String title;
  final Function onTap;
  final Widget? trailing;
  const SettingsButton({super.key, required this.icon, required this.title, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
        child: Row(children: [

          CustomAssetImageWidget(
            icon, height: 20, width: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Dimensions.paddingMedium),

          Expanded(child: Text(title, style: context.heading.defaultSize.medium)),

          ?trailing,

        ]),
      ),
    );
  }
}

class _ThemeDropdown extends StatelessWidget {
  final AppThemeMode themeMode;
  final Function(AppThemeMode mode) onSelected;
  const _ThemeDropdown({required this.themeMode, required this.onSelected});

  String _labelFor(AppThemeMode mode) {
    switch(mode) {
      case AppThemeMode.dark: return 'dark_mode'.tr;
      case AppThemeMode.system: return 'system_mode'.tr;
      case AppThemeMode.light: return 'light_mode'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppThemeMode>(
      onSelected: onSelected,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      itemBuilder: (context) => AppThemeMode.values.map((mode) {
        return PopupMenuItem<AppThemeMode>(
          value: mode,
          child: Text(_labelFor(mode), style: context.subHeading.small.regular),
        );
      }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: context.outline, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_labelFor(themeMode), style: context.subHeading.small.regular),
          const SizedBox(width: Dimensions.padding2xSmall),
          Icon(Icons.keyboard_arrow_down, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
        ]),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1);
  }
}
