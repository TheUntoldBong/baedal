import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  const SignInScreen({super.key, required this.exitFromApp, required this.backFromThis, this.fromResetPassword = false});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    Color primaryColor = Theme.of(context).primaryColor;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if (Get.find<AuthController>().isOtpViewEnable) {
            Get.find<AuthController>().enableOtpView(enable: false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDesktop
            ? Colors.transparent
            : (Get.isDarkMode ? Theme.of(context).colorScheme.surface : const Color(0xFFFBFBFC)),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: context.width > 700 ? 500 : context.width,
                  margin: EdgeInsets.symmetric(
                    horizontal: context.width > 700 ? 50 : Dimensions.paddingSizeDefault,
                    vertical: context.width > 700 ? 40 : Dimensions.paddingSizeSmall,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.width > 700 ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeDefault,
                    vertical: context.width > 700 ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(context.width > 700 ? 20 : Dimensions.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.3 : 0.05),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Action Bar: Back button and Skip button
                      _buildTopActionBar(context, isDesktop),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // Brand Hero Section
                      _buildBrandHero(primaryColor),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // Sign In Form View
                      SignInView(
                        exitFromApp: widget.exitFromApp,
                        backFromThis: widget.backFromThis,
                        fromResetPassword: widget.fromResetPassword,
                        isOtpViewEnable: (v) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionBar(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isDesktop)
          const SizedBox(width: 40)
        else if (!widget.exitFromApp)
          InkWell(
            onTap: () {
              if (Get.find<AuthController>().isOtpViewEnable) {
                Get.find<AuthController>().enableOtpView(enable: false);
              } else {
                Get.back(result: false);
              }
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          )
        else
          const SizedBox(width: 40),

        if (isDesktop)
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close_rounded),
          )
        else
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                side: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouteHelper.getInitialRoute());
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'skip'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBrandHero(Color primaryColor) {
    String? logoUrl = Get.find<SplashController>().configModel?.logoFullUrl;

    return Column(
      children: [
        // Single Brand Logo
        if (logoUrl != null && logoUrl.isNotEmpty)
          CustomImageWidget(
            image: logoUrl,
            height: 48,
            width: 160,
            fit: BoxFit.contain,
          )
        else
          Image.asset(
            Images.logo,
            height: 48,
            width: 160,
            fit: BoxFit.contain,
          ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(
          'hey_there_welcome'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'login_suggestion_description'.tr,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}


