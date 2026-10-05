import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_with_title.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/social_login_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ManualLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final Function() onClickLoginButton;
  final Function()? onWebSubmit;
  final bool socialEnable;
  final Function()? onOtpViewClick;
  const ManualLoginWidget({
    super.key, required this.phoneController, required this.phoneFocus, required this.onClickLoginButton, required this.passwordController,
    required this.passwordFocus, this.onWebSubmit, this.socialEnable = false, this.onOtpViewClick,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
            boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
          ),
          child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('login_with_email_phone'.tr, style: context.heading.extraLarge.strong),
            Text('use_your_registered_email_phone_number_to_login'.tr,
                style: context.body.small.overrideWith(color: context.textBaseMedium)),
            const SizedBox(height: Dimensions.paddingOverLarge),

            CustomTextFieldWithTitle(
              titleText: 'email_or_phone'.tr,
              hintText: 'type_your_number_or_mail'.tr,
              showTitle: true,
              showLabelText: false,
              required: true,
              fromLogin: true,
              onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode!,
              countryDialCode: authController.isNumberLogin ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code : null,
              labelText: phoneFocus.hasFocus || passwordFocus.hasFocus ? null : 'type_your_number_or_mail'.tr,
              controller: phoneController,
              focusNode: phoneFocus,
              nextFocus: passwordFocus,
              inputType: TextInputType.emailAddress,
              onChanged: (String text){
                final numberRegExp = RegExp(r'^[+]?[0-9]+$');

                if(text.isEmpty && authController.isNumberLogin){
                  authController.toggleIsNumberLogin();
                }
                if(text.startsWith(numberRegExp) && !authController.isNumberLogin ){
                  authController.toggleIsNumberLogin();
                  phoneController.text = text.replaceAll("+", "");
                }
                final emailRegExp = RegExp(r'@');
                if(text.contains(emailRegExp) && authController.isNumberLogin){
                  authController.toggleIsNumberLogin();
                }

              },
              validator: (String? value){

                if(authController.isNumberLogin && ValidateCheck.getValidPhone(authController.countryDialCode+value!) == ""){
                  return "enter_valid_phone_number".tr;
                }
                return (GetUtils.isPhoneNumber(authController.countryDialCode+value!) || GetUtils.isEmail(value.tr)) ? null : 'enter_email_address_or_phone_number'.tr;
              },
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            CustomTextFieldWithTitle(
              hintText: 'ex_8_plus_character'.tr,
              titleText: 'password'.tr,
              showTitle: true,
              showLabelText: false,
              required: true,
              controller: passwordController,
              focusNode: passwordFocus,
              inputAction: TextInputAction.done,
              inputType: TextInputType.visiblePassword,
              isPassword: true,
              onSubmit: (text) => (GetPlatform.isWeb) ? onWebSubmit : null,
              labelText: passwordFocus.hasFocus ? null : 'password'.tr,
              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
              fromLogin: true,
            ),
            SizedBox(height: Dimensions.paddingDefault),


            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: () => authController.toggleRememberMe(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24, width: 24,
                      child: Checkbox(
                        side: BorderSide(color: context.textBaseMedium),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: context.primary,
                        value: authController.isActiveRememberMe,
                        onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Text('remember_me'.tr, style: context.body.defaultSize.regular),
                  ],
                ),
              ),

              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  if (FocusScope.of(context).hasFocus) {
                    FocusScope.of(context).unfocus();
                  }

                  Future.delayed(const Duration(milliseconds: 250), () {
                    Get.toNamed(RouteHelper.getForgotPassRoute());
                  });
                },
                child: Text('${'forgot_password'.tr} ?', style: context.body.defaultSize.regular.overrideWith(color: Colors.blueAccent)),
              ),
            ]),

            const SizedBox(height: Dimensions.paddingOverLarge),


            CustomButtonWidget(
              height: isDesktop ? 50 : null,
              width:  isDesktop ? 250 : null,
              buttonText: 'continue_to_login'.tr,
              radius: isDesktop ? Dimensions.radiusExtraSmall : Dimensions.radiusDefault,
              isBold: isDesktop ? false : true,
              isLoading: authController.isLoading,
              onPressed: onClickLoginButton,
            ),
          ]),
        ),

        const SizedBox(height: Dimensions.paddingLarge),


        onOtpViewClick != null ? Column(children: [
          
          Row(children: [
            Expanded(child: Divider()),
            const SizedBox(width: Dimensions.paddingSmall),
            Text("or".tr.toUpperCase(), style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
            const SizedBox(width: Dimensions.paddingSmall),
            Expanded(child: Divider()),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
          CustomButtonWidget(
            height: isDesktop ? 50 : null,
            width:  isDesktop ? 250 : null,
            buttonText: "${'sign_in_with'.tr} otp",
            radius: isDesktop ? Dimensions.radiusExtraSmall : Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: onOtpViewClick,
            color: context.surfaceContainer,
            textColor: context.textTheme.bodyLarge?.color,
          ),
        ]) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSmall),

        socialEnable ? const SocialLoginWidget(onlySocialLogin: false) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingLarge),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('new_to_stackfood'.tr, style: context.body.small),

          InkWell(
            onTap: authController.isLoading ? null : () {
              Get.toNamed(RouteHelper.getSignUpRoute());
            },
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
              child: Text('sign_up'.tr, style: context.subHeading.small.medium.overrideWith(color: Colors.blueAccent)),
            ),
          ),
        ]),

        SizedBox(height: Dimensions.paddingLarge,),
      ]);
    });
  }
}