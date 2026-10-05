import 'dart:async';

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/update_user_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/verification/controllers/verification_controller.dart';
import 'package:stackfood_multivendor/features/verification/domein/model/verification_data_model.dart';
import 'package:stackfood_multivendor/features/verification/screens/new_pass_screen.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

enum VerificationTypeEnum{phone, email}

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? email;
  final bool fromSignUp;
  final String? token;
  final String? password;
  final String loginType;
  final String? firebaseSession;
  final bool fromForgetPassword;
  final UpdateUserModel? userModel;
  const VerificationScreen({super.key, required this.number, required this.password, required this.fromSignUp,
    required this.token, this.email, required this.loginType, this.firebaseSession, required this.fromForgetPassword, this.userModel});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  String? _email;
  Timer? _timer;
  int _seconds = 0;
  final ScrollController _scrollController = ScrollController();

  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    Get.find<VerificationController>().updateVerificationCode('', canUpdate: false);
    if(widget.number != null && widget.number!.isNotEmpty) {
      _number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    }
    _email = widget.email;
    _startTimer();
  }

  void _startTimer() {
    int remaining = Get.find<AuthController>().otpResendRemainingSeconds(_number);
    _seconds = remaining > 0 ? remaining : 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double borderWidth = 0.7;
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
          child: GetBuilder<VerificationController>(builder: (verificationController) {
            final String contact = (_email != null && _email!.isNotEmpty) ? _email! : (_number ?? '');
            return Column( mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
                ),
                child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    (_email != null && _email!.isNotEmpty) ? 'check_mail_to_verification'.tr : 'check_phone_to_verification'.tr,
                    style: context.heading.extraLarge.strong,
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Get.find<SplashController>().configModel!.demo! ? Text('for_demo_purpose'.tr,
                    style: context.body.defaultSize.regular,
                  ) : RichText(text: TextSpan(children: [
                    TextSpan(text: "${'we_have_sent_a_verification_code_to'.tr} ", style: context.body.defaultSize.regular),
                    TextSpan(text: contact, style: context.body.small.overrideWith(color: context.textBaseMedium)),
                  ])),
                  const SizedBox(height: Dimensions.paddingOverLarge),
                  LayoutBuilder(builder: (context, constraints) {
                    const int length = 6;
                    const double spacing = 8;
                    final double cellWidth = ((constraints.maxWidth - spacing * (length - 1)) / length).clamp(36.0, 52.0);
                    return MaterialPinField(
                      length: length,
                      autoFocus: true,
                      keyboardType: TextInputType.number,
                      onChanged: verificationController.updateVerificationCode,
                      theme: MaterialPinTheme(
                        shape: MaterialPinShape.outlined,
                        cellSize: Size(cellWidth, 52),
                        spacing: spacing,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderWidth: borderWidth,
                        focusedBorderWidth: borderWidth,
                        errorBorderWidth: borderWidth,
                        textStyle: context.subHeading.defaultSize.medium.copyWith(fontSize: 20),
                        cursorColor: Theme.of(context).textTheme.bodyLarge!.color,
                        entryAnimation: MaterialPinAnimation.slide,
                        animationDuration: const Duration(milliseconds: 300),
                        fillColor: context.surfaceContainer,
                        focusedFillColor: context.surfaceContainer,
                        filledFillColor: context.surfaceContainer,
                        followingFillColor: context.surfaceContainer,
                        borderColor: context.outlineVariant,
                        focusedBorderColor: context.outlineVariant,
                        followingBorderColor: context.outlineVariant,
                        filledBorderColor: hasError ? Colors.orange : context.outlineVariant,
                        errorBorderColor: Colors.orange,
                      ),
                    );
                  }),
                  const SizedBox(height: Dimensions.paddingOverLarge),

                  GetBuilder<ProfileController>(
                      builder: (profileController) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: CustomButtonWidget(
                            radius: Dimensions.radiusDefault,
                            buttonText: 'verify_and_continue'.tr,
                            isLoading: verificationController.isLoading || profileController.isLoading,
                            onPressed: verificationController.verificationCode.length < 6 ? null : () {
                              if(widget.firebaseSession != null && widget.userModel == null) {
                                verificationController.verifyFirebaseOtp(
                                  phoneNumber: _number!, session: widget.firebaseSession!, loginType: widget.loginType,
                                  otp: verificationController.verificationCode, token: widget.token, isForgetPassPage: widget.fromForgetPassword,
                                  isSignUpPage: widget.loginType == CentralizeLoginType.otp.name ? false : true,
                                ).then((value) {
                                  if(value.isSuccess) {
                                    _handleVerifyResponse(value, _number, _email);
                                  }else {
                                    showCustomSnackBar(value.message);
                                  }
                                });
                              } else if(widget.userModel != null) {
                                widget.userModel!.otp = verificationController.verificationCode;
                                Get.find<ProfileController>().updateUserInfo(widget.userModel!, Get.find<AuthController>().getUserToken(), fromButton: true).then((response) async {
                                  if(response.isSuccess) {
                                    profileController.getUserInfo();
                                    Get.back();
                                    Get.back();
                                    showCustomSnackBar(response.message, isError: false);
                                  } else if(!response.isSuccess && response.updateProfileResponseModel != null){
                                    showCustomSnackBar(response.updateProfileResponseModel!.message);
                                  } else {
                                    showCustomSnackBar(response.message);
                                  }
                                });
                              } else if(widget.fromSignUp) {
                                verificationController.verifyPhone(data: VerificationDataModel(
                                  phone: _number, email: _email, verificationType: _number != null
                                    ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
                                  otp: verificationController.verificationCode, loginType: widget.loginType,
                                  guestId: AuthHelper.getGuestId(),
                                )).then((value) {
                                  if(value.isSuccess) {
                                    _handleVerifyResponse(value, _number, _email);
                                  } else {
                                    showCustomSnackBar(value.message);
                                  }
                                });
                              } else {
                                verificationController.verifyToken(phone: _number, email: _email).then((value) {
                                  if(value.isSuccess) {
                                    if(ResponsiveHelper.isDesktop(Get.context!)){
                                      Get.back();
                                      Get.dialog(Center(child: NewPassScreen(resetToken: verificationController.verificationCode, number : _number, email: _email, fromPasswordChange: false, fromDialog: true )));
                                    }else{
                                      Get.toNamed(RouteHelper.getResetPasswordRoute(phone: _number, email: _email, token: verificationController.verificationCode, page: 'reset-password'));
                                    }
                                  }else {
                                    showCustomSnackBar(value.message);
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingDefault),

               _seconds < 1 ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.padding2xSmall,),
                    child: Text('did_not_receive_the_code'.tr, style: context.body.defaultSize.regular),
                  ),
                  InkWell(
                    onTap: _seconds < 1 ? () async {
                      if(widget.firebaseSession != null) {
                        await Get.find<AuthController>().firebaseVerifyPhoneNumber(_number!, widget.token, widget.loginType, fromSignUp: widget.fromSignUp, canRoute: false);
                        _startTimer();
                      } else {
                        _resendOtp();
                      }
                    } : null,
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall, top: Dimensions.paddingSmall, bottom: Dimensions.padding2xSmall),
                      child: Text('${'resent_it'.tr}${_seconds > 0 ? ' (${_seconds}s)' : ''}', style: context.body.defaultSize.regular.overrideWith(color: Colors.blueAccent)),
                    ),
                  ),
                ]) : InkWell(
                  onTap: _seconds < 1 ? () async {
                    if(widget.firebaseSession != null) {
                      await Get.find<AuthController>().firebaseVerifyPhoneNumber(_number!, widget.token, widget.loginType, fromSignUp: widget.fromSignUp, canRoute: false);
                      _startTimer();
                    } else {
                      _resendOtp();
                    }
                  } : null,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall, top: Dimensions.paddingSmall, bottom: Dimensions.padding2xSmall),
                    child: Center(
                      child: RichText(textAlign: TextAlign.center, text: TextSpan(children: [
                        TextSpan(text: "${'resend_code_in'.tr} ", style: context.body.defaultSize.regular),
                        TextSpan(text: '0.$_seconds min', style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                      ])),
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingExtraLarge),

            ]);
          }),
        ),
      ))),
    );
  }

  void _handleVerifyResponse(ResponseModel response, String? number, String? email) {
    if(response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      Get.bottomSheet(ExistingUserBottomSheet(
        userModel: response.authResponseModel!.isExistUser!, number: _number, email: _email,
        loginType: widget.loginType, otp: Get.find<VerificationController>().verificationCode,
      ));
    } else if(response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {
      Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: widget.loginType, phone: number, email: email));
    } else {
      if(widget.fromForgetPassword) {
        if(ResponsiveHelper.isDesktop(Get.context!)){
          Get.back();
          Get.dialog(Center(child: NewPassScreen(resetToken: Get.find<VerificationController>().verificationCode, number : _number, email: _email, fromPasswordChange: false, fromDialog: true )));
        }else{
          Get.toNamed(RouteHelper.getResetPasswordRoute(phone: _number, email: _email, token: Get.find<VerificationController>().verificationCode, page: 'reset-password'));
        }
      } else {
        final address = AddressHelper.getAddressFromSharedPref();
        if((address != null && (address.address?.isNotEmpty ?? false))) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          Get.offNamed(RouteHelper.getAccessLocationRoute('verification'));
        }
      }
    }
  }

  void _resendOtp() {
    if(widget.userModel != null) {
      Get.find<ProfileController>().updateUserInfo(widget.userModel!, Get.find<AuthController>().getUserToken(), fromVerification: true);
    } else if(widget.fromSignUp) {
      if(widget.loginType == CentralizeLoginType.otp.name) {
        Get.find<AuthController>().otpLogin(phone: _number!, otp: '', loginType: widget.loginType, verified: '').then((response) {
          if (response.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      } else {
        Get.find<AuthController>().login(
          emailOrPhone: _number != null ? _number! : _email ?? '', password: widget.password!, loginType: widget.loginType,
          fieldType: _number != null ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
        ).then((value) {
          if (value.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    } else {
      Get.find<VerificationController>().forgetPassword(phone: _number, email: _email).then((value) {
        if (value.isSuccess) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          showCustomSnackBar(value.message);
        }
      });
    }
  }
}
