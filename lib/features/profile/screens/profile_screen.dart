import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/auth_dialog_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/widgets/account_deletion_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/widgets/profile_button_widget.dart';
import 'package:stackfood_multivendor/features/profile/widgets/profile_card_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    if(Get.find<AuthController>().isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    if(Get.find<AuthController>().isLoggedIn() && Get.find<OrderController>().runningOrders == null){
      Get.find<OrderController>().getMyOrders(MyOrderTabType.running, 1, notify: false, limit: 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final bool showWalletCard = Get.find<SplashController>().configModel!.customerWalletStatus!
        || Get.find<SplashController>().configModel!.loyaltyPointStatus!;

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'profile'.tr),
      backgroundColor: isDesktop ? Theme.of(context).colorScheme.surface : context.surfaceContainer,
      body: GetBuilder<OrderController>(builder: (orderController) {
        return GetBuilder<ProfileController>(builder: (profileController) {
          return (isLoggedIn && profileController.userInfoModel == null && (orderController.runningOrders == null)) ? const Center(
            child: CircularProgressIndicator(),
          ) : Center(
            child: SingleChildScrollView(
              controller: scrollController,
              child: isLoggedIn ? Container(
                color: context.primary.withValues(alpha: 0.1),
                width: Dimensions.webMaxWidth, height: context.height - 80,
                child: Center(
                  child: Column(children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge, vertical: Dimensions.paddingOverLarge),
                      child: Row(children: [

                        ProBadgeAvatarWidget(
                          badgeSize: 26,
                          child: ClipOval(child: CustomImageWidget(
                            placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                            image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                            height: 70, width: 70, fit: BoxFit.cover, imageColor: isLoggedIn ? context.textBaseMedium : null,
                          )),
                        ),
                        const SizedBox(width: Dimensions.paddingDefault),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
                              style: context.heading.overLarge.strong,
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),

                            isLoggedIn ? Text(
                              profileController.userInfoModel?.createdAt != null ?'${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}' : '',
                              style: context.body.small.regular.overrideWith(color: context.textNeutralMedium),
                            ) : InkWell(
                              onTap: () async {
                                if(!isDesktop) {
                                  await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                }else{
                                  showCustomDialog(child: const AuthDialogWidget(exitFromApp: false, backFromThis: false)).then((value) {
                                    _initCall();
                                    setState(() {});
                                  });
                                }
                              },
                              child: Text(
                                'login_to_view_all_feature'.tr,
                                style: context.body.small.medium.overrideWith(color: context.textNeutralMedium),
                              ),
                            ),
                          ]),
                        ),

                        isLoggedIn ? InkWell(
                          onTap: ()=> Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.surfaceContainer,
                              boxShadow: Get.isDarkMode ? null : [BoxShadow(color: context.shadow, blurRadius: 3, spreadRadius: 1, offset: const Offset(0, 1))],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: CustomAssetImageWidget(Images.editBtn, width: 24),
                          ),
                        ) : InkWell(
                          onTap: () async {
                            if(!isDesktop) {
                              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                            }else{
                              showCustomDialog(child: const AuthDialogWidget(exitFromApp: false, backFromThis: false)).then((value) {
                                _initCall();
                                setState(() {});
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: context.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingLarge),
                            child: Text(
                              'login'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseDefault),
                            ),
                          ),
                        ),

                      ]),
                    ),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                          color: context.surfaceContainer,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
                        child: Column(children: [

                          (showWalletCard && isLoggedIn) ? Row(children: [

                            Get.find<SplashController>().configModel!.loyaltyPointStatus! ? Expanded(child: ProfileCardWidget(
                              image: Images.loyaltyIcon,
                              data: profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0',
                              title: 'loyalty_points'.tr,
                            )) : const SizedBox(),

                            SizedBox(width: Get.find<SplashController>().configModel!.loyaltyPointStatus! ? Dimensions.paddingSmall : 0),

                            isLoggedIn ?  Expanded(child: ProfileCardWidget(
                              image: Images.shoppingBagIcon,
                              data: profileController.userInfoModel?.orderCount != null ? profileController.userInfoModel!.orderCount.toString() : '0',
                              title: 'total_order'.tr,
                            )) : const SizedBox(),

                            SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus! ? Dimensions.paddingSmall : 0),

                            Get.find<SplashController>().configModel!.customerWalletStatus! ? Expanded(child: ProfileCardWidget(
                              image: Images.walletProfile,
                              data: PriceConverter.convertPrice(profileController.userInfoModel?.walletBalance != null ? profileController.userInfoModel!.walletBalance : 0),
                              title: 'wallet_balance'.tr,
                            )) : const SizedBox(),

                          ]) : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingLarge),

                          isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                            return ProfileButtonWidget(
                              icon: Icons.notifications, title: 'notification'.tr,
                              isButtonActive: authController.notification, onTap: () {
                              Get.bottomSheet(const NotificationStatusChangeBottomSheet());
                            },
                            );
                          }) : const SizedBox(),
                          SizedBox(height: isLoggedIn ? Dimensions.paddingSmall : 0),

                          isLoggedIn ? ProfileButtonWidget(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                            Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change'));
                          }) : const SizedBox(),
                          SizedBox(height: isLoggedIn ? Dimensions.paddingSmall : 0),

                          isLoggedIn ? ProfileButtonWidget(
                            icon: Icons.delete,
                            iconImage: Images.profileDelete,
                            title: 'delete_account'.tr,
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                                ),
                                builder: (context) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                    child: AccountDeletionBottomSheet(
                                      profileController: profileController,
                                      isRunningOrderAvailable: orderController.runningOrders?.isNotEmpty ?? false,
                                    ),
                                  );
                                },
                              );
                            },
                          ) : const SizedBox(),
                          SizedBox(height: isLoggedIn ? Dimensions.paddingLarge : 0),

                          const Expanded(child: SizedBox()),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${'version'.tr}:', style: context.body.extraSmall.regular),
                            const SizedBox(width: Dimensions.padding2xSmall),

                            Text(AppConstants.appVersion.toString(), style: context.body.extraSmall.medium),
                          ]),
                        ]),
                      ),
                    ),

                  ]),
                ),
              ) : SizedBox(
                width: Dimensions.webMaxWidth, height: context.height - 87,
                child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    ClipOval(child: CustomImageWidget(
                      placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                      image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                      height: 70, width: 70, fit: BoxFit.cover, imageColor: isLoggedIn ? context.textBaseMedium : null,
                    )),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Text(
                      'guest_user'.tr,
                      style: context.heading.extraLarge.strong,
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),

                    SizedBox(
                      width: context.width * 0.6,
                      child: Text(
                        'currently_you_are_in_guest_mode_please_login_to_view_all_the_features'.tr,
                        style: context.body.small.regular,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingOverLarge),

                    CustomButtonWidget(
                      buttonText: 'login'.tr,
                      width: 150,
                      onPressed: () async {
                        if(!isDesktop) {
                          await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))?.then((value) {
                            _initCall();
                            setState(() {});
                          });
                        }else{
                          showCustomDialog(child: const AuthDialogWidget(exitFromApp: false, backFromThis: false)).then((value) {
                            _initCall();
                            setState(() {});
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 50),

                  ]),
                ),
              ),
            ),
          );
        });
      }),
    );
  }
}
