import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/images.dart';

class ProBadgeAvatarWidget extends StatelessWidget {
  final Widget child;
  final double badgeSize;
  const ProBadgeAvatarWidget({super.key, required this.child, this.badgeSize = 24});

  @override
  Widget build(BuildContext context) {
    final bool isProUser = (Get.find<ProfileController>().userInfoModel?.proStatus ?? false) && (Get.find<SplashController>().configModel?.proMemberStatus ?? false);

    if (!isProUser) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            height: badgeSize,
            width: badgeSize,
            padding: EdgeInsets.all(badgeSize * 0.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surfaceContainer,
              boxShadow: [
                BoxShadow(color: context.shadow, blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
            child: CustomAssetImageWidget(Images.proPlanCrown, height: badgeSize, width: badgeSize, color: context.primary, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}
