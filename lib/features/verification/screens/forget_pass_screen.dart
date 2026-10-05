import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/verification/controllers/verification_controller.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromDialog;
  const ForgetPassScreen({super.key, this.fromDialog = false});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  GlobalKey<FormState>? _formKeyLogin;
  bool isEmail = false;
  bool isPhone = false;

  @override
  void initState() {
    super.initState();

    isPhone = (Get.find<SplashController>().configModel!.isSmsActive! || Get.find<SplashController>().configModel!.firebaseOtpVerification!);
    isEmail = Get.find<SplashController>().configModel!.isMailActive!;

    _formKeyLogin = GlobalKey<FormState>();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_numberFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(child: Align( alignment: Alignment.topCenter, child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.width > 700 ? 0 : Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
        child: Container(
          width: context.width > 700 ? 500 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingLarge) : null,
          decoration: context.width > 700 ? BoxDecoration(
            color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          ) : null,
          child: Column( mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              InkWell(
                onTap: () => Get.back(result: false),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                  child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Get.back(result: false),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                  child: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
                ),
              ),
            ]),
            SizedBox(height: Dimensions.paddingLarge),

              (isPhone || isEmail) ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
                  boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
                ),
                child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    isPhone ? 'use_phone_for_recovery'.tr : 'use_email_for_recovery'.tr,
                    style: context.heading.extraLarge.strong,
                  ),
                  Text(
                    isPhone ? 'please_enter_the_registered_phone_where_you_want'.tr : 'please_enter_the_registered_email_where_you_want'.tr,
                    style: context.body.small.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: Dimensions.paddingOverLarge),
                    Form(
                      key: _formKeyLogin,
                      child: isPhone ? CustomTextFieldWidget(
                        titleText: 'xxx-xxx-xxxxx'.tr,
                        controller: _numberController,
                        focusNode: _numberFocusNode,
                        inputType: TextInputType.phone,
                        inputAction: TextInputAction.done,
                        isPhone: true,
                        onCountryChanged: (CountryCode countryCode) {
                          _countryDialCode = countryCode.dialCode;
                        },
                        countryDialCode: CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
                        onSubmit: (text) => GetPlatform.isWeb ? _onPressedForgetPass(_countryDialCode!) : null,
                        labelText: 'phone'.tr,
                        validator: (value) => ValidateCheck.validateEmptyText(value, null),
                      ) : CustomTextFieldWidget(
                        titleText: 'enter_email'.tr,
                        labelText: 'email'.tr,
                        showLabelText: true,
                        required: true,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.done,
                        prefixIcon: CupertinoIcons.mail_solid,
                        validator: (value) => ValidateCheck.validateEmail(value),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingOverLarge),

                    GetBuilder<VerificationController>(builder: (verificationController) {
                      return GetBuilder<AuthController>(builder: (authController) {
                        return CustomButtonWidget(
                          radius: Dimensions.radiusDefault,
                          buttonText: 'get_otp'.tr,
                          isLoading: verificationController.isLoading || authController.isLoading,
                          onPressed: () {
                            _onPressedForgetPass(_countryDialCode!);
                          },
                        );
                      });
                    }),
                  ],
                ),
              ) : Padding(
                padding: widget.fromDialog ? const EdgeInsets.all(Dimensions.paddingOverLarge) : context.width > 700 ? const EdgeInsets.all(Dimensions.paddingDefault) : const EdgeInsets.all(Dimensions.paddingLarge),
                child: Column(children: [
                  CustomAssetImageWidget(Images.forgot, height:  widget.fromDialog ? 160 : 220),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                    child: Text('sorry_something_went_wrong'.tr, style: context.heading.extraLarge.strong, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: Text(
                      'please_try_again_after_some_time_or_contact_with_our_support_team'.tr,
                      style: widget.fromDialog ? context.body.small : context.body.defaultSize, textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingOverLarge),
                  CustomButtonWidget(
                    buttonText: 'help_and_support'.tr,
                    onPressed: () {
                      Get.toNamed(RouteHelper.getSupportRoute());
                    }
                  ),
                ]),
              ),
            const SizedBox(height: Dimensions.paddingLarge),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('new_to_stackfood'.tr, style: context.body.small),
              InkWell(
                onTap: () {
                  Get.toNamed(RouteHelper.getSignUpRoute());
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                  child: Text('sign_up'.tr, style: context.subHeading.small.medium.overrideWith(color: Colors.blueAccent)),
                ),
              ),
            ]),
          ]),
          ),
        ),
      )),
    );
  }

  void _onPressedForgetPass(String countryCode) async {
    String phone = _numberController.text.trim();
    String email = _emailController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    if(phoneValid.phone.isNotEmpty) {
      numberWithCountryCode = phoneValid.phone;
    }

    if(_formKeyLogin!.currentState!.validate()) {
      if (isPhone && (!phoneValid.isValid || phoneValid.phone.isEmpty)) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        Get.find<VerificationController>().forgetPassword(email: email, phone: numberWithCountryCode).then((status) async {
          if (status.isSuccess) {
            if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
              Get.find<AuthController>().firebaseVerifyPhoneNumber(numberWithCountryCode, status.message, '', fromSignUp: false);
            } else {
              if(ResponsiveHelper.isDesktop(Get.context)) {
                Get.back();
                Get.dialog(VerificationScreen(
                  number: numberWithCountryCode, email: email, token: '', fromSignUp: false,
                  fromForgetPassword: true, loginType: '', password: '',
                ));
              } else {
                Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, email, '', RouteHelper.forgotPassword, '', ''));
              }
            }
          }else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }
}
