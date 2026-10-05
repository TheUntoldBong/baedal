import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class GuestButtonWidget extends StatelessWidget {
  const GuestButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return !authController.guestLoading ? TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(1, 40),
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, RouteHelper.getInitialRoute());
        },
        child: RichText(text: TextSpan(children: [
          TextSpan(text: '${'continue_as'.tr} ', style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
          TextSpan(text: 'guest'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseDefault)),
        ])),
      ) : const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()));
    });
  }
}
