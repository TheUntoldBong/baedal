import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/screens/new_user_setup_screen.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/splash_route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SocialLoginWidget extends StatefulWidget {
  final bool onlySocialLogin;
  final bool showWelcomeText;
  final Function()? onOtpViewClick;
  final bool isProminent;
  const SocialLoginWidget({super.key, this.onlySocialLogin = false, this.showWelcomeText = true, this.onOtpViewClick, this.isProminent = false});

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  bool _isgGogleLogin = false;
  bool _isFacebookLogin = false;

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    customLog('=====social: ${Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty} && ${Get.find<SplashController>().configModel!.appleLogin![0].status!} && ${!GetPlatform.isAndroid} && ${!GetPlatform.isWeb}');
    bool canAppleLogin = Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty && Get.find<SplashController>().configModel!.appleLogin![0].status!
        && !GetPlatform.isAndroid && !GetPlatform.isWeb;

    bool googleLoginActive = CentralizeLoginHelper.isSocialLoginActive(Get.find<SplashController>().configModel, 'google');
    bool facebookLoginActive = CentralizeLoginHelper.isSocialLoginActive(Get.find<SplashController>().configModel, 'facebook');
    bool canGoogleAndFacebookLogin = googleLoginActive || facebookLoginActive;
    customLog('=====googleLoginActive===> $googleLoginActive');
    customLog('=====facebookLoginActive===> $facebookLoginActive');
    customLog('=====canGoogleAndFacebookLogin===> $canGoogleAndFacebookLogin');

    if(widget.onlySocialLogin || widget.isProminent) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.isProminent)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
              child: Row(children: [
                Expanded(child: Container(height: 1, color: context.outline)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                  child: Text('or_continue_with'.tr.toCapitalized(), style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                ),
                Expanded(child: Container(height: 1, color: context.outline)),
              ]),
            ),
          canGoogleAndFacebookLogin ? Column(children: [

            widget.showWelcomeText ? Text('${'welcome_to'.tr} ${AppConstants.appName}', style: context.heading.large.medium) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingLarge),

            googleLoginActive ? Container(
              height: 48,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                border: Border.all(color: context.outline.withValues(alpha: 0.45), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _googleLogin(googleSignIn),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CustomAssetImageWidget(Images.google, height: 22, width: 22),
                    const SizedBox(width: Dimensions.paddingDefault),

                    Text('continue_with_google'.tr, style: context.subHeading.defaultSize.medium),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: googleLoginActive ? Dimensions.paddingSmall : 0),

            facebookLoginActive ? Container(
              height: 48,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                border: Border.all(color: context.outline.withValues(alpha: 0.45), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _facebookLogin(),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CustomAssetImageWidget(Images.facebookIcon, height: 22, width: 22),
                    const SizedBox(width: Dimensions.paddingDefault),

                    Text('continue_with_facebook'.tr, style: context.subHeading.defaultSize.medium),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: facebookLoginActive ? Dimensions.paddingSmall : 0),

            canAppleLogin ? Container(
              height: 48,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                border: Border.all(color: context.outline.withValues(alpha: 0.45), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _appleLogin(),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CustomAssetImageWidget(Images.appleLogo, height: 22, width: 22),
                    const SizedBox(width: Dimensions.paddingDefault),

                    Text('continue_with_apple'.tr, style: context.subHeading.defaultSize.medium),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSmall : widget.onOtpViewClick != null ? 0 : Dimensions.paddingSmall),

          ]) : const SizedBox(),

          widget.onOtpViewClick != null ? Container(
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
            ),
            margin: EdgeInsets.only(bottom: Dimensions.paddingOverLarge),
            child: CustomInkWellWidget(
              onTap: widget.onOtpViewClick!,
              radius: Dimensions.radiusDefault,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CustomAssetImageWidget(Images.otp, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Text('otp_sign_in'.tr, style: context.subHeading.defaultSize.medium),
                ]),
              ),
            ),
          ) : const SizedBox(),
        ],
      );
    }

    return canGoogleAndFacebookLogin || canAppleLogin ? Column(children: [

      const SizedBox(height: Dimensions.paddingSmall),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
        child: Row(children: [
          Expanded(child: Container(height: 1, color: context.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
            child: Text('or_continue_with'.tr.toCapitalized(), style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
          ),
          Expanded(child: Container(height: 1, color: context.outline)),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSmall),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [

        googleLoginActive ? InkWell(
          onTap: () async {
              if (_isgGogleLogin) return;
              setState(() => _isgGogleLogin = true);
              await _googleLogin(googleSignIn);
              setState(() => _isgGogleLogin = false);
          },
          child: Container(
            height: 40,width: 40,
            padding: const EdgeInsets.all(Dimensions.paddingSmall),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
            ),
            child: _isgGogleLogin ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary)) : CustomAssetImageWidget(Images.google),
          ),
        ) : const SizedBox(),

        facebookLoginActive ? Padding(
          padding: EdgeInsets.only(left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingLarge : 0, right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingLarge),
          child: InkWell(
            onTap: () async {
              if (_isFacebookLogin) return;
              setState(() => _isFacebookLogin = true);
              await _facebookLogin();
              setState(() => _isFacebookLogin = false);
            },
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: _isFacebookLogin ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary)) : CustomAssetImageWidget(Images.facebookIcon),
            ),
          ),
        ) : const SizedBox(),

        canAppleLogin ? Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingLarge),
          child: InkWell(
            onTap: ()=> _appleLogin(),
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: CustomAssetImageWidget(Images.appleLogo),
            ),
          ),
        ) : const SizedBox(),

      ]),
      const SizedBox(height: Dimensions.paddingSmall),

    ]) : const SizedBox();
  }

  Future<void> _googleLogin(GoogleSignIn googleSignIn) async {
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

  Future<void> _facebookLogin() async {
    LoginResult result = await FacebookAuth.instance.login(
      permissions: ["public_profile", "email"],
      loginTracking: LoginTracking.enabled,
    );
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
      Get.find<SplashController>().navigateToLocationScreen('sign-in', offNamed: true);
    }
  }
}

