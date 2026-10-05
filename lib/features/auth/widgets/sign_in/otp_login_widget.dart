import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/widgets/social_login_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  const OtpLoginWidget({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode, required this.onClickLoginButton, this.socialEnable = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final CentralizeLoginType configLoginType = CentralizeLoginHelper.getPreferredLoginMethod(
      Get.find<SplashController>().configModel!.centralizeLoginSetup!, false,
    ).type;
    final bool showSignUp = configLoginType == CentralizeLoginType.manual
        || configLoginType == CentralizeLoginType.manualAndOtp
        || configLoginType == CentralizeLoginType.manualAndSocial
        || configLoginType == CentralizeLoginType.manualAndSocialAndOtp;
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
         Container(
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
             borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
          ),
          child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('login_with_email_phone'.tr, style: context.subHeading.extraLarge.medium),
            Text('use_your_registered_email_phone_number_to_login'.tr, 
            style: context.body.small.overrideWith(color: context.textBaseMedium)),
            const SizedBox(height: Dimensions.paddingOverLarge),
               
            CustomTextFieldWidget(
              hintText: 'xxx-xxx-xxxxx'.tr,
              controller: phoneController,
              focusNode: phoneFocus,
              inputAction: TextInputAction.done,
              inputType: TextInputType.phone,
              isPhone: true,
              onCountryChanged: onCountryChanged,
              countryDialCode: CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
              labelText: 'phone'.tr,
              required: true,
              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
            ),
            const SizedBox(height: Dimensions.paddingDefault),

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => authController.toggleRememberMeForOtp(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24, width: 24,
                      child: Checkbox(
                        side: BorderSide(color: context.textBaseMedium),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: context.primary,
                        value: authController.isActiveRememberMeForOtp,
                        onChanged: (bool? isChecked) => authController.toggleRememberMeForOtp(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Text('remember_me'.tr, style: context.body.defaultSize.regular),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            CustomButtonWidget(
              buttonText: 'continue_to_login'.tr,
              radius: Dimensions.radiusDefault,
              isBold: isDesktop ? false : true,
              isLoading: authController.isLoading,
              onPressed: onClickLoginButton,
              fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
            ),
          ]),
        ),

          const SizedBox(height: Dimensions.paddingLarge),

          socialEnable ? const SocialLoginWidget(onlySocialLogin: false) : const SizedBox(),

          socialEnable && isDesktop ? const SizedBox(height: Dimensions.paddingLarge) : const SizedBox(),

          if(showSignUp) ...[
            !socialEnable ? const SizedBox(height: Dimensions.paddingLarge) : const SizedBox.shrink(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('new_to_stackfood'.tr, style: context.body.small),

              InkWell(
                onTap: authController.isLoading ? null : () {
                  Get.toNamed(RouteHelper.getSignUpRoute());
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                  child:  Text('sign_up'.tr, style: context.subHeading.small.medium.overrideWith(color: Colors.blueAccent)),
                ),
              ),
            ]),
          ],
        ]),
      );
    });
  }
}
