import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_up_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/social_login_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SignInView extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  final Function(bool val)? isOtpViewEnable;
  const SignInView({super.key, required this.exitFromApp, required this.backFromThis, this.fromResetPassword = false, this.isOtpViewEnable});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _otpPhoneFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpPhoneController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyLogin;
  int _selectedTab = 0; // 0: OTP (Default focus), 1: Password

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    AuthController authController = Get.find<AuthController>();

    _countryDialCode = authController.getUserCountryCode().isNotEmpty
        ? authController.getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _phoneController.text = authController.getUserNumber();
    _passwordController.text = authController.getUserPassword();
    _otpPhoneController.text = authController.getUserOtpPhoneNumber();

    final setup = Get.find<SplashController>().configModel?.centralizeLoginSetup;
    bool canOtp = setup?.otpLoginStatus ?? true;
    bool canManual = setup?.manualLoginStatus ?? true;
    if (!canOtp && canManual) {
      _selectedTab = 1;
    } else {
      _selectedTab = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isOtpActive = CentralizeLoginHelper.getPreferredLoginMethod(
            Get.find<SplashController>().configModel!.centralizeLoginSetup!,
            authController.isOtpViewEnable,
          ).type == CentralizeLoginType.otp ||
          CentralizeLoginHelper.getPreferredLoginMethod(
            Get.find<SplashController>().configModel!.centralizeLoginSetup!,
            authController.isOtpViewEnable,
          ).type == CentralizeLoginType.otpAndSocial;

      if (_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@') && isOtpActive) {
        _phoneController.text = '';
      } else if (_countryDialCode != "" && _phoneController.text != "" && !_phoneController.text.contains('@')) {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.initCountryCode(countryCode: _countryDialCode != "" ? _countryDialCode : null);
    });

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            FocusScope.of(Get.context!).requestFocus(_selectedTab == 0 ? _otpPhoneFocus : _phoneFocus);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _otpPhoneFocus.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      final setup = Get.find<SplashController>().configModel?.centralizeLoginSetup;
      bool canOtp = setup?.otpLoginStatus ?? true;
      bool canManual = setup?.manualLoginStatus ?? true;
      bool canSocial = (setup?.socialLoginStatus ?? true)
          || (Get.find<SplashController>().configModel?.socialLogin?.isNotEmpty ?? false);

      // Only social login scenario
      if (!canOtp && !canManual && canSocial) {
        return const SocialLoginWidget(onlySocialLogin: true, isProminent: true);
      }

      return Form(
        key: _formKeyLogin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Form Section (Defaults to OTP)
            if (_selectedTab == 0 && canOtp)
              _buildOtpSection(authController)
            else
              _buildPasswordSection(authController),

            // Subtle Switcher for Password / OTP (keeps password secondary)
            if (canOtp && canManual) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () {
                    setState(() => _selectedTab = _selectedTab == 0 ? 1 : 0);
                    if (widget.isOtpViewEnable != null) {
                      widget.isOtpViewEnable!(_selectedTab == 0);
                    }
                  },
                  icon: Icon(
                    _selectedTab == 0 ? Icons.lock_outline_rounded : Icons.phone_android_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    _selectedTab == 0 ? 'sign_in_with_password'.tr : 'sign_in_with_phone_number'.tr,
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ],

            // Prominent Social Login
            if (canSocial) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              const SocialLoginWidget(isProminent: true),
            ],

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Footer: Sign Up
            _buildSignUpFooter(),

            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      );
    });
  }


  Widget _buildOtpSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_phone_number'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(height: 4),
        Text(
          'we_will_send_you_a_one_time_code_to_confirm_your_phone_number'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomTextFieldWidget(
          hintText: 'xxx-xxx-xxxxx'.tr,
          controller: _otpPhoneController,
          focusNode: _otpPhoneFocus,
          inputAction: TextInputAction.done,
          inputType: TextInputType.phone,
          isPhone: true,
          onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
          countryDialCode: _countryDialCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
          labelText: 'phone'.tr,
          required: true,
          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        InkWell(
          onTap: () => authController.toggleRememberMeForOtp(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24, width: 24,
                child: Checkbox(
                  side: BorderSide(color: Theme.of(context).hintColor),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Theme.of(context).primaryColor,
                  value: authController.isActiveRememberMeForOtp,
                  onChanged: (bool? isChecked) => authController.toggleRememberMeForOtp(),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('remember_me'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        TramsConditionsCheckBoxWidget(authController: authController, fromDialog: true),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomButtonWidget(
          buttonText: 'continue'.tr,
          icon: Icons.arrow_forward_rounded,
          radius: Dimensions.radiusDefault,
          isBold: true,
          isLoading: authController.isLoading,
          onPressed: () => _otpLogin(authController, _countryDialCode!, CentralizeLoginType.otp),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hey_there_welcome'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(height: 4),
        Text(
          'sign_in'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomTextFieldWidget(
          onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode!,
          countryDialCode: authController.isNumberLogin ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code : null,
          labelText: 'email_or_phone'.tr,
          hintText: 'enter_email_or_phone'.tr,
          controller: _phoneController,
          focusNode: _phoneFocus,
          nextFocus: _passwordFocus,
          inputType: TextInputType.emailAddress,
          prefixIcon: authController.isNumberLogin ? null : Icons.email_outlined,
          onChanged: (String text) {
            final numberRegExp = RegExp(r'^[+]?[0-9]+$');
            if (text.isEmpty && authController.isNumberLogin) {
              authController.toggleIsNumberLogin();
            }
            if (text.startsWith(numberRegExp) && !authController.isNumberLogin) {
              authController.toggleIsNumberLogin();
              _phoneController.text = text.replaceAll("+", "");
            }
            final emailRegExp = RegExp(r'@');
            if (text.contains(emailRegExp) && authController.isNumberLogin) {
              authController.toggleIsNumberLogin();
            }
          },
          validator: (String? value) {
            if (authController.isNumberLogin && ValidateCheck.getValidPhone(authController.countryDialCode + value!) == "") {
              return "enter_valid_phone_number".tr;
            }
            return (GetUtils.isPhoneNumber(authController.countryDialCode + value!) || GetUtils.isEmail(value.tr))
                ? null
                : 'enter_email_address_or_phone_number'.tr;
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomTextFieldWidget(
          hintText: '8_character'.tr,
          controller: _passwordController,
          focusNode: _passwordFocus,
          inputAction: TextInputAction.done,
          inputType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          labelText: 'password'.tr,
          required: true,
          validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => authController.toggleRememberMe(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('remember_me'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
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
              child: Text(
                '${'forgot_password'.tr}?',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        TramsConditionsCheckBoxWidget(authController: authController, fromDialog: true),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        CustomButtonWidget(
          buttonText: 'login'.tr,
          radius: Dimensions.radiusDefault,
          isBold: true,
          isLoading: authController.isLoading,
          onPressed: () => _login(authController, CentralizeLoginType.manual),
        ),
      ],
    );
  }

  Widget _buildSignUpFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'do_not_have_account'.tr,
          style: robotoRegular.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        InkWell(
          onTap: () {
            if (ResponsiveHelper.isDesktop(context)) {
              Get.back();
              Get.dialog(
                SizedBox(
                  width: 700,
                  child: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    backgroundColor: Theme.of(context).cardColor,
                    insetPadding: EdgeInsets.zero,
                    child: const SignUpWidget(),
                  ),
                ),
              );
            } else {
              Get.toNamed(RouteHelper.getSignUpRoute());
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'sign_up'.tr,
              style: robotoBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _otpLogin(AuthController authController, String countryDialCode, CentralizeLoginType loginType) async {
    String phone = _otpPhoneController.text.trim();
    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeyLogin!.currentState!.validate()) {
      if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        authController.otpLogin(
          phone: numberWithCountryCode,
          otp: '',
          loginType: loginType.name,
          verified: '',
          alreadyInApp: widget.backFromThis,
        ).then((response) {
          if (response.isSuccess) {
            _processOtpSuccessSetup(response, authController, phone, countryDialCode);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      }
    }
  }

  void _login(AuthController authController, CentralizeLoginType loginType) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = authController.countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeyLogin!.currentState!.validate()) {
      String isPhone = ValidateCheck.getValidPhone(authController.countryDialCode + _phoneController.text.trim(), withCountryCode: true);

      if (isPhone != "" && !phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        authController.login(
          emailOrPhone: isPhone != "" ? isPhone : phone,
          password: password,
          loginType: loginType.name,
          fieldType: isPhone != "" ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
          alreadyInApp: widget.backFromThis,
        ).then((status) async {
          if (status.isSuccess) {
            _processSuccessSetup(authController, phone, isPhone, password, status);
          } else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }

  Future<void> _processSuccessSetup(AuthController authController, String phone, String email, String password, ResponseModel status) async {
    if (authController.isActiveRememberMe) {
      authController.saveUserNumberAndPassword(number: phone, password: password, countryCode: authController.countryDialCode, otpPoneNumber: '');
    } else {
      authController.clearUserNumberAndPassword();
    }
    if (GetPlatform.isWeb) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if (status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token ?? '';
      if (Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(phone, token, CentralizeLoginType.manual.name, fromSignUp: true);
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(
          phone, null, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
        ));
      }
    } else if (status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token ?? '';
      Get.toNamed(RouteHelper.getVerificationRoute(null, email, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name));
    } else {
      if (widget.backFromThis) {
        if (ResponsiveHelper.isDesktop(Get.context) || widget.fromResetPassword) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }
        }
      } else {
        Get.find<SplashController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }

  void _processOtpSuccessSetup(ResponseModel response, AuthController authController, String phone, String countryDialCode) async {
    if (authController.isActiveRememberMeForOtp) {
      authController.saveUserNumberAndPassword(number: '', password: '', countryCode: countryDialCode, otpPoneNumber: phone);
    } else {
      authController.clearUserNumberAndPassword();
    }
    if (GetPlatform.isWeb && response.authResponseModel == null) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if (response.authResponseModel != null && !response.authResponseModel!.isPhoneVerified!) {
      if (Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(countryDialCode + phone, '', CentralizeLoginType.otp.name, fromSignUp: true);
      } else {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: countryDialCode + phone, email: null, token: '', fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.otp.name, password: '',
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            countryDialCode + phone, null, '', RouteHelper.signUp, null, CentralizeLoginType.otp.name,
          ));
        }
      }
    } else {
      if (widget.backFromThis) {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      } else {
        Get.find<SplashController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }
}

