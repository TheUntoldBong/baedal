import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:stackfood_multivendor/features/menu/domain/models/menu_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class MenuButton extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  const MenuButton({super.key, required this.menu, required this.isProfile, required this.isLogout});

  @override
  Widget build(BuildContext context) {
    int count = ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4;
    double size = ((context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth : context.width)/count)-Dimensions.paddingDefault;

    return InkWell(
      onTap: () async {
        if(isLogout) {
          Get.back();
          if(Get.find<AuthController>().isLoggedIn()) {
            showCustomDialog(
              child: ConfirmationDialogWidget(icon: Images.logOut, description: 'are_you_sure_to_logout'.tr, isLogOut: true,
                onYesPressed: () {
              Get.find<AuthController>().clearSharedData();
              Get.find<AuthController>().socialLogout();
               Get.find<CartController>().clearCartList();
              Get.find<FavouriteController>().removeFavourites();
              Get.find<OrderController>().clearLastOrders();
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }),
            );
          }else {
            Get.find<FavouriteController>().removeFavourites();
            Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
          }
        }else if(menu.route.startsWith('http')) {
          if(await canLaunchUrlString(menu.route)) {
            launchUrlString(menu.route, mode: LaunchMode.externalApplication);
          }
        }else {
          Get.offNamed(menu.route);
        }
      },
      child: Column(children: [

        Container(
          height: size-(size*0.2),
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            color: isLogout ? Get.find<AuthController>().isLoggedIn() ? Colors.red : Colors.green : context.primary,
            boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
          ),
          alignment: Alignment.center,
          child: isProfile ? ProfileImageWidget(size: size) : CustomAssetImageWidget(menu.icon, width: size, height: size, color: Colors.white),
        ),
        const SizedBox(height: Dimensions.padding2xSmall),

        Text(menu.title, style: context.subHeading.small.medium, textAlign: TextAlign.center),

      ]),
    );
  }
}

class ProfileImageWidget extends StatelessWidget {
  final double size;
  const ProfileImageWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (userController) {
      return ProBadgeAvatarWidget(
        badgeSize: size * 0.4,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: Colors.white)),
          child: ClipOval(
            child: CustomImageWidget(
              image: (userController.userInfoModel != null && Get.find<AuthController>().isLoggedIn()) ? userController.userInfoModel!.imageFullUrl ?? '' : '',
              width: size, height: size, fit: BoxFit.cover,
            ),
          ),
        ),
      );
    });
  }
}

