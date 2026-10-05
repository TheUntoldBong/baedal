import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_with_title.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SignUpWidget extends StatefulWidget {
  final ScrollController? scrollController;
  const SignUpWidget({super.key, this.scrollController});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeySignUp;

  @override
  void initState() {
    super.initState();
    _formKeySignUp = GlobalKey<FormState>();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKeySignUp,
      child: GetBuilder<AuthController>(builder: (authController) {
        return Stack(
          children: [
            SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingLarge,
                      vertical: Dimensions.paddingLarge,
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingLarge),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('sign_up'.tr, style: context.heading.extraLarge.strong),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'to_get_all_personalized_feature_sign_up'.tr,
                              style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'login'.tr,
                              style: context.body.small.regular.overrideWith(color: Colors.blueAccent).copyWith(decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                if(Get.currentRoute == RouteHelper.signUp) {
                                  Get.back();
                                } else {
                                  Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                                }
                              },
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'now'.tr,
                              style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                          ]),
                        ),
                        SizedBox(height: Dimensions.paddingOverLarge),
                        CustomTextFieldWithTitle(
                          titleText: 'user_name'.tr,
                          hintText: 'ex_jhon'.tr,
                          showTitle: true,
                          showLabelText: false,
                          required: true,
                          controller: _nameController,
                          focusNode: _nameFocus,
                          nextFocus: _phoneFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
                        ),

                        SizedBox(height: Dimensions.paddingLarge),

                        CustomTextFieldWithTitle(
                          hintText: 'xxx-xxx-xxxxx'.tr,
                          titleText: 'phone_number'.tr,
                          showTitle: true,
                          showLabelText: false,
                          required: true,
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          nextFocus: _emailFocus,
                          inputType: TextInputType.phone,
                          isPhone: true,
                          onCountryChanged: (CountryCode countryCode) {
                            _countryDialCode = countryCode.dialCode;
                          },
                          countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                              : Get.find<LocalizationController>().locale.countryCode,
                          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                        ),
                        SizedBox(height: Dimensions.paddingLarge),

                        CustomTextFieldWithTitle(
                          titleText: 'email'.tr,
                          hintText: 'olivia@untitledui.com'.tr,
                          showTitle: true,
                          showLabelText: false,
                          required: true,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocus: _passwordFocus,
                          inputType: TextInputType.emailAddress,
                          prefixIcon: CupertinoIcons.mail_solid,
                          validator: (value) => ValidateCheck.validateEmail(value),
                        ),
                        SizedBox(height: Dimensions.paddingLarge),

                        CustomTextFieldWithTitle(
                          hintText: 'ex_8_plus_character'.tr,
                          titleText: 'password'.tr,
                          showTitle: true,
                          showLabelText: false,
                          required: true,
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          nextFocus: _confirmPasswordFocus,
                          inputType: TextInputType.visiblePassword,
                          isPassword: true,
                          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
                        ),
                        SizedBox(height: Dimensions.paddingLarge),

                        CustomTextFieldWithTitle(
                          hintText: 'ex_8_plus_character'.tr,
                          titleText: 'confirm_password'.tr,
                          showTitle: true,
                          showLabelText: false,
                          required: true,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          nextFocus: Get.find<SplashController>().configModel!.refEarningStatus! ? _referCodeFocus : null,
                          inputAction: Get.find<SplashController>().configModel!.refEarningStatus! ? TextInputAction.next : TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          isPassword: true,
                          onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
                          validator: (value) => ValidateCheck.validateConfirmPassword(value, _passwordController.text),
                        ),

                        if (Get.find<SplashController>().configModel!.refEarningStatus!) ...[
                          SizedBox(height: Dimensions.paddingLarge),
                          CustomTextFieldWithTitle(
                            hintText: 'Ex: 4894HUI65'.tr,
                            titleText: 'refer_code'.tr,
                            showTitle: true,
                            showLabelText: false,
                            controller: _referCodeController,
                            focusNode: _referCodeFocus,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.words,
                            divider: false,
                            prefixSize: 14,
                          ),
                        ],
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    child: TramsConditionsCheckBoxWidget(authController: authController, fromSignUp: true, fromDialog: false),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('already_have_account'.tr, style: context.body.small),
                        InkWell(
                          onTap: authController.isLoading ? null : () {
                            if(Get.currentRoute == RouteHelper.signUp) {
                              Get.back();
                            } else {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                            child: Text('sign_in'.tr, style: context.subHeading.small.medium.overrideWith(color: Colors.blueAccent)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                    topRight: Radius.circular(Dimensions.radiusExtraLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: Center(
                  child: CustomButtonWidget(
                    height: 56,
                    width: context.width > 700 ? 300 : null,
                    radius: Dimensions.radiusDefault,
                    isBold: true,
                    buttonText: 'sign_up'.tr,
                    isLoading: authController.isLoading,
                    onPressed: (_isFormValid() && authController.acceptTerms) ? () => _register(authController, _countryDialCode!) : null,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty;
  }

  void _register(AuthController authController, String countryCode) async {
    SignUpBodyModel? signUpModel = await _prepareSignUpBody(countryCode);

    if(signUpModel == null) {
      return;
    } else {
      authController.registration(signUpModel).then((status) async {
        _handleResponse(status, countryCode);
      });
    }
  }

  void _handleResponse(ResponseModel status, String countryCode) {
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryCode + _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (status.isSuccess) {
      Get.find<LoyaltyController>().saveEarningPoint('');
      Get.find<CartController>().getCartBundleList();

      if(status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
          Get.find<AuthController>().firebaseVerifyPhoneNumber(numberWithCountryCode, status.message, CentralizeLoginType.manual.name, fromSignUp: true);
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            numberWithCountryCode, null, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
          ));
        }
      } else if(status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        Get.toNamed(RouteHelper.getVerificationRoute(
          null, email, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
        ));
      } else {
        Get.find<ProfileController>().getUserInfo();
        Get.find<SplashController>().navigateToLocationScreen(RouteHelper.signUp);
      }
    } else {
      if(status.code == 'phone'){
        FocusScope.of(context).requestFocus(_phoneFocus);
      }else if(status.code == 'email'){
        FocusScope.of(context).requestFocus(_emailFocus);
      }else if(status.code == 'ref_code'){
        FocusScope.of(context).requestFocus(_referCodeFocus);
      }

      showCustomSnackBar(status.message);
    }
  }

  Future<SignUpBodyModel?> _prepareSignUpBody(String countryCode) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode + number;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeySignUp!.currentState!.validate()) {
      if (name.isEmpty) {
        showCustomSnackBar('please_enter_your_name'.tr);
      } else if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (number.isEmpty) {
        showCustomSnackBar('enter_phone_number'.tr);
      } else if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 8) {
        showCustomSnackBar('password_should_be'.tr);
      } else if (password != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
      } else if (referCode.isNotEmpty && referCode.length != 10) {
        showCustomSnackBar('invalid_refer_code'.tr);
      } else {
        SignUpBodyModel signUpBody = SignUpBodyModel(
          name: name,
          email: email,
          phone: numberWithCountryCode,
          password: password,
          refCode: referCode,
        );
        return signUpBody;
      }
    }
    return null;
  }
}
