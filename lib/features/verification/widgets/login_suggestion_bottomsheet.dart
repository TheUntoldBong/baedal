import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/social_login_button.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/screens/new_user_setup_screen.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LoginSuggestionBottomSheet extends StatelessWidget {
  final bool fromCartPage;
  const LoginSuggestionBottomSheet({super.key, this.fromCartPage = false});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    bool googleLoginActive = CentralizeLoginHelper.isSocialLoginActive(Get.find<SplashController>().configModel, 'google');

    bool facebookLoginActive = CentralizeLoginHelper.isSocialLoginActive(Get.find<SplashController>().configModel, 'facebook');

    bool canAppleLogin = Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty && Get.find<SplashController>().configModel!.appleLogin![0].status!
        && !GetPlatform.isAndroid;
    bool appleLoginActive = canAppleLogin && Get.find<SplashController>().configModel!.centralizeLoginSetup!.socialLoginStatus!
        && Get.find<SplashController>().configModel!.centralizeLoginSetup!.appleLoginStatus!;

    bool isOtpActive = Get.find<SplashController>().configModel!.centralizeLoginSetup!.otpLoginStatus!;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack( children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Column(mainAxisSize: MainAxisSize.min,  children: <Widget>[
              const SizedBox(height: Dimensions.paddingDefault),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                child: Column(children: [
                  Text(
                    fromCartPage ? 'create_account'.tr : 'welcome_back'.tr,
                    style: context.heading.extraOverLarge.strong,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingExtraSmall),

                  Text(
                    fromCartPage ? 'login_or_signup_to_view_and_track_your_orders'.tr : "to_get_more_personalised_experience".tr,
                    style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                    textAlign: TextAlign.center,
                  ),
                   if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingDefault),
                  if(facebookLoginActive || googleLoginActive || appleLoginActive)
                    Text( "continue_with".tr.toCapitalized(), style: context.subHeading.small.strong),
                    const SizedBox(height: Dimensions.paddingDefault),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: Row(spacing: 16, children: <Widget>[
                        if(facebookLoginActive)
                          Expanded(child: SocialLoginButton(
                            iconPath: Images.facebookIcon,
                            onTap: () {
                              Get.back();
                              _facebookLogin();
                            },
                          )),
            
                        if(googleLoginActive)
                          Expanded(child: SocialLoginButton(
                            iconPath: Images.google,
                            onTap: () {
                              Get.back();
                              _googleLogin(googleSignIn);
                            },
                          )),
            
                        if(appleLoginActive)
                          Expanded(child: SocialLoginButton(
                            iconPath: Images.appleLogo,
                            onTap: () {
                              Get.back();
                              _appleLogin();
                            },
                          )),
                      ]),
                    ),
                    if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingLarge),
                    if(facebookLoginActive || googleLoginActive || appleLoginActive) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: Row(children: [
                        Expanded(child: Divider(color: context.outline)),
                        const SizedBox(width: Dimensions.paddingDefault),
                        Text("or".tr.toUpperCase(), style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                        const SizedBox(width: Dimensions.paddingDefault),
                        Expanded(child: Divider(color: context.outline)),
                      ]),
                    ),
                    if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingLarge),
            
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: CustomButtonWidget(
                        height: 50,
                        buttonText: 'login_with_password'.tr,
                        fontSize: Dimensions.fontSizeDefault,
                        onPressed: () async {
                          Get.back();
                          await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                        },
                      ),
                    ),
                    if(isOtpActive) const SizedBox(height: Dimensions.paddingLarge),
            
                    if(isOtpActive)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        child: CustomButtonWidget(
                          height: 50,
                          buttonText: 'login_with_otp'.tr,
                          color: context.surfaceContainerLowest,
                          textColor: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: Dimensions.fontSizeDefault,
                          onPressed: () async {
                            Get.back();
                            Get.find<AuthController>().enableOtpView(enable: true);
                            await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                          },
                        ),
                      ),
            
                    const SizedBox(height: Dimensions.paddingLarge),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: InkWell(
                        onTap: () =>Get.back(),
                        child: Text("continue_as_guest".tr, style: context.heading.defaultSize.strong.overrideWith(color: context.textInfoDefault))
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
            
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: RichText(textAlign: TextAlign.center,
                        text: TextSpan(
                          style: context.body.small.overrideWith(color: context.textBaseDefault),
                          children: [
                            TextSpan(
                              text: 'by_continuing_you_agree_to_our'.tr,
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'terms_and_conditions'.tr,
                              style: TextStyle(color: context.textInfoDefault),
                              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.termsAndCondition),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'and'.tr,
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: 'privacy_policy'.tr,
                              style: TextStyle(color: context.textInfoDefault),
                              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.privacyPolicy),
                            ),
                          ]
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),
                  ],
                ),
              ),
            ]),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: context.iconBaseMedium),
              style: IconButton.styleFrom(
                backgroundColor: context.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ]),
      ]),
    );
  }

  void _googleLogin(GoogleSignIn googleSignIn) async {
    if(kIsWeb) {
      await _googleWebSignIn();

    }else{
      try{
        if(googleSignIn.supportsAuthenticate()) {
          await googleSignIn.initialize(serverClientId: AppConstants.googleServerClientId).then((_) async {

            googleSignIn.signOut();
            GoogleSignInAccount googleAccount = await googleSignIn.authenticate();
            const List<String> scopes = <String>['email'];
            GoogleSignInClientAuthorization? auth = await googleAccount.authorizationClient.authorizationForScopes(scopes);

            SocialLogInBodyModel googleBodyModel = SocialLogInBodyModel(
              email: googleAccount.email, token: auth?.accessToken, uniqueId: googleAccount.id,
              medium: 'google', accessToken: 1, loginType: CentralizeLoginType.social.name,
            );

            Get.find<AuthController>().loginWithSocialMedia(googleBodyModel).then((response) {
              if (response.isSuccess) {
                _processSocialSuccessSetup(response, googleBodyModel, null, null);
              } else {
                showCustomSnackBar(response.message);
              }
            });

          });
        }else {
          debugPrint("Google Sign-In not supported on this device.");
        }
      }catch(e){
        debugPrint('Error in google sign in: $e');
      }
    }
  }

  Future<void> _googleWebSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await auth.signInWithPopup(googleProvider);

      SocialLogInBodyModel googleBodyModel =  SocialLogInBodyModel(
        uniqueId: userCredential.credential?.accessToken,
        token: userCredential.credential?.accessToken,
        accessToken: 1,
        medium: 'google',
        email: userCredential.user?.email,
        loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(googleBodyModel).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, googleBodyModel, null, null);
        } else {
          showCustomSnackBar(response.message);
        }
      });

    } catch (e) {
      showCustomSnackBar(e.toString());
    }
  }

  void _facebookLogin() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);
    if (result.status == LoginStatus.success) {
      Map userData = await FacebookAuth.instance.getUserData();

      SocialLogInBodyModel facebookBodyModel = SocialLogInBodyModel(
        email: userData['email'], token: result.accessToken!.tokenString, uniqueId: userData['id'],
        medium: 'facebook', loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, null, null, facebookBodyModel);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    }
  }

  void _appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);


    SocialLogInBodyModel appleBodyModel = SocialLogInBodyModel(
      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode,
      medium: 'apple', loginType: CentralizeLoginType.social.name,
    );

    Get.find<AuthController>().loginWithSocialMedia(appleBodyModel).then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, null, appleBodyModel, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _processSocialSuccessSetup(ResponseModel response, SocialLogInBodyModel? googleBodyModel, SocialLogInBodyModel? appleBodyModel, SocialLogInBodyModel? facebookBodyModel) {
    String? email = googleBodyModel != null ? googleBodyModel.email : appleBodyModel != null ? appleBodyModel.email : facebookBodyModel?.email;
    if(response.isSuccess && response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
        appleBodyModel.email = email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, email: email, loginType: CentralizeLoginType.social.name,
            socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!, loginType: CentralizeLoginType.social.name,
          socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, email: email,
        ));
      }
    } else if(response.isSuccess && response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)){
        Get.back();
        Get.dialog(NewUserSetupScreen(name: '', loginType: CentralizeLoginType.social.name, phone: '', email: email));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: CentralizeLoginType.social.name, phone: '', email: email));
      }
    } else {
      Get.offAllNamed(RouteHelper.getAccessLocationRoute('sign-in'));
    }
  }
}
