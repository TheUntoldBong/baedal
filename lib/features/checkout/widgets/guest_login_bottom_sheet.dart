import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/auth_dialog_widget.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class GuestLoginBottomSheet extends StatelessWidget {
  final Function() callBack;
  const GuestLoginBottomSheet({super.key, required this.callBack});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 500 : context.width,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
      ),
      child: Stack(children: [
        Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 40,
            margin: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.bgNeutralMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text('please_login'.tr, style: context.heading.large.strong),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              'sign_in_to_enjoy_faster_checkout_and_easy_order_tracking'.tr,
              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Dimensions.paddingExtraLarge),

          CustomButtonWidget(
            width: 200,
            buttonText: 'login'.tr,
            onPressed: () async {
              Get.back(result: true);

              if(!isDesktop) {
                await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))!.then((value) {
                  if(AuthHelper.isLoggedIn()) {
                    callBack();
                  }
                });
              }else{
                showCustomDialog(child: const AuthDialogWidget(exitFromApp: false, backFromThis: true)).then((value) {
                  if(AuthHelper.isLoggedIn()) {
                    callBack();
                  }
                });
              }
            },
          ),
          SizedBox(height: Dimensions.paddingLarge),

        ]),

        Positioned(
          top: 0, right: 0,
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.clear, color: context.iconDisabledDefault, size: 20),
          ),
        ),
      ]),
    );
  }
}
