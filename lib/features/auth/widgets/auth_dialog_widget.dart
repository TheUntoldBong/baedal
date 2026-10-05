import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class AuthDialogWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const AuthDialogWidget({super.key, required this.exitFromApp, required this.backFromThis});

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget> {

  bool _isOtpViewEnable = false;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetOtpView(isUpdate: false);
    _isOtpViewEnable = false;
  }

  @override
  Widget build(BuildContext context) {
    double width = _isOtpViewEnable ? 400 : CentralizeLoginHelper.getPreferredLoginMethod(Get.find<SplashController>().configModel!.centralizeLoginSetup!, false).size;
    return SizedBox(
      width: width,
      child: DialogSheetBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.clear)),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingOverLarge),
                child: Column(children: [

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    CustomAssetImageWidget(Images.logo, height: 40, width: 40),
                    const SizedBox(width: Dimensions.padding2xSmall),
                    CustomAssetImageWidget(Images.logoName, height: 50, width: 120),
                  ]),
                  const SizedBox(height: Dimensions.paddingLarge),

                  SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis,
                    isOtpViewEnable: (bool val) {
                    setState(() {
                      _isOtpViewEnable = true;
                    });
                    },
                  ),
                ]),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
