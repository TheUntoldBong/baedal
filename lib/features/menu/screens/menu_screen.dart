import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/menu/widgets/portion_widget.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/widgets/profile_stat_card_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'my_profile'.tr,
        isBackButtonExist: true,
        centerTitle: false,
        onBackPressed: () => Get.find<DashboardController>().selectTab(0),
      ),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return GetBuilder<SplashController>(builder: (splashController) {

          bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
          final configModel = splashController.configModel;

          return SingleChildScrollView(
            child: Column(children: [

              _buildHeader(context, profileController, splashController, isLoggedIn, isDesktop),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  _sectionTitle(context, 'general'.tr),
                  const SizedBox(height: Dimensions.paddingMedium),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    child: Column(children: [
                      isLoggedIn ? PortionWidget(icon: Images.editProfileIcon, title: 'edit_profile'.tr, route: RouteHelper.getUpdateProfileRoute()) : const SizedBox(),

                      PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),

                      isLoggedIn && configModel!.proMemberStatus! ? PortionWidget(icon: Images.proPlanCrown, title: 'my_subscription'.tr, route: RouteHelper.getSubscriptionPlanRoute(), changeIconColor: false) : const SizedBox(),

                      PortionWidget(icon: Images.settingsIcon, title: 'settings'.tr, route: RouteHelper.getSettingsRoute()),

                      GetBuilder<NotificationController>(builder: (notificationController) {
                        final int count = notificationController.unseenCount;
                        return PortionWidget(
                          icon: Images.notificationIcon, title: 'notification'.tr, hideDivider: true,
                          route: RouteHelper.getNotificationRoute(),
                          suffix: AuthHelper.isLoggedIn() && count > 0 ? (count > 999 ? '999+' : '$count') : null,
                        );
                      }),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  _sectionTitle(context, 'promotional_activity'.tr),
                  const SizedBox(height: Dimensions.paddingMedium),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    child: Column(children: [
                      PortionWidget(icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(fromCheckout: false)),

                      configModel!.loyaltyPointStatus! ? PortionWidget(
                        icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
                        hideDivider: configModel.customerWalletStatus! ? false : true,
                        suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? Get.find<ProfileController>().userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}' ,
                      ) : const SizedBox(),

                      configModel.customerWalletStatus! ? PortionWidget(
                        icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(fromMenuPage: true),
                        suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.walletBalance : 0),
                      ) : const SizedBox(),
                    ]),
                  ),

                  configModel.refEarningStatus! || (configModel.toggleDmRegistration! && !isDesktop)|| (configModel.toggleRestaurantRegistration! && !isDesktop) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: Dimensions.paddingLarge),

                    _sectionTitle(context, 'earnings'.tr),
                    const SizedBox(height: Dimensions.paddingMedium),

                    CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: Column(children: [

                        configModel.refEarningStatus! ? PortionWidget(
                          icon: Images.referIcon, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute(),
                        ) : const SizedBox(),

                        (configModel.toggleDmRegistration! && !isDesktop) ? PortionWidget(
                          icon: Images.dmIcon, title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute(),
                        ) : const SizedBox(),

                        (configModel.toggleRestaurantRegistration! && !isDesktop) ? PortionWidget(
                          icon: Images.storeIcon, title: 'open_store'.tr, hideDivider: true, route: RouteHelper.getRestaurantRegistrationRoute(),
                        ) : const SizedBox(),
                      ]),
                    ),
                  ]) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingLarge),

                  _sectionTitle(context, 'help_and_support'.tr),
                  const SizedBox(height: Dimensions.paddingMedium),

                  CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    child: Column(children: [
                      PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                      PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                      PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getAboutUsRoute()),
                      PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getTermsAndConditionRoute()),
                      PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getPrivacyPolicyRoute()),

                      configModel.refundPolicyStatus! ? PortionWidget(
                        icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getRefundPolicyRoute(),
                      ) : const SizedBox(),

                      configModel.cancellationPolicyStatus! ? PortionWidget(
                        icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getCancellationPolicyRoute(),
                      ) : const SizedBox(),

                      configModel.shippingPolicyStatus! ? PortionWidget(
                        icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getShippingPolicyRoute(),
                      ) : const SizedBox(),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  isLoggedIn ? InkWell(
                    onTap: () async {
                      showCustomDialog(
                        child: ConfirmationDialogWidget(icon: Images.logOut, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                        Get.find<ProfileController>().setForceFullyUserEmpty();
                        Get.find<AuthController>().socialLogout();
                        Get.find<AuthController>().resetOtpView();
                        Get.find<CartController>().clearCartList();
                        Get.find<FavouriteController>().removeFavourites();
                        Get.find<OrderController>().clearLastOrders();
                        await Get.find<AuthController>().clearSharedData();
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                          child: Icon(Icons.power_settings_new_sharp, size: 14, color: context.surfaceContainer),
                        ),
                        const SizedBox(width: Dimensions.padding2xSmall),

                        Text('logout'.tr, style: context.subHeading.defaultSize.medium),
                      ]),
                    ),
                  ) : const SizedBox(),

                  const SizedBox(height: Dimensions.paddingLarge),

                ]),
              ),
            ]),
          );
        });
      }),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingMedium),
      child: Text(title, style: context.subHeading.large.regular.overrideWith(color: context.textBaseLight)),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileController profileController, SplashController splashController, bool isLoggedIn, bool isDesktop) {
    final user = profileController.userInfoModel;

    return Container(
      width: double.infinity,
      color: context.surfaceContainer,
      padding: const EdgeInsets.only(top: Dimensions.paddingLarge, bottom: Dimensions.paddingLarge),
      child: Column(children: [

        ProBadgeAvatarWidget(
          badgeSize: 26,
          child: Container(
            decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
            padding: const EdgeInsets.all(1),
            child: ClipOval(child: CustomImageWidget(
              placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
              image: '${(user != null && isLoggedIn) ? user.imageFullUrl : ''}',
              height: 60, width: 60, fit: BoxFit.cover, imageColor: isLoggedIn ? context.textBaseMedium : null,
            )),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSmall),

        (isLoggedIn && user == null) ? Shimmer(
          duration: const Duration(seconds: 2), enabled: true,
          child: Container(
            height: 16, width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ),
          ),
        ) : Text(
          isLoggedIn ? '${user?.fName?.toCapitalized() ?? ''}. ${user?.lName ?? ''}' : 'guest_user'.tr,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.heading.overLarge.strong,
        ),
        const SizedBox(height: Dimensions.paddingExtraSmall),

        if (isLoggedIn && user?.createdAt != null) Text(
          '${'joined'.tr} : ${DateConverter.containTAndZToUTCFormat(user!.createdAt!)}',
          style: context.body.defaultSize.regular.overrideWith(color: context.textNeutralMedium),
        ),

        if (!isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge, vertical: Dimensions.paddingSmall),
            child: Text('for_more_personalised_and_smooth_experience'.tr, textAlign: TextAlign.center,
              style: context.body.small.regular.overrideWith(color: context.textNeutralMedium),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          SizedBox(
            width: 160,
            child: CustomButtonWidget(
              buttonText: '${'login'.tr}/ ${'signup'.tr}', height: 40,
              onPressed: () async {
                if(!isDesktop) {
                  Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))?.then((value) {
                    if(AuthHelper.isLoggedIn()) { profileController.getUserInfo(); }
                  });
                } else {
                  showCustomDialog(child: const SignInScreen(exitFromApp: true, backFromThis: true)).then((value) {
                    if(AuthHelper.isLoggedIn()) { profileController.getUserInfo(); }
                  });
                }
              },
            ),
          ),
        ],

        if (isLoggedIn) ...[
          const SizedBox(height: Dimensions.paddingLarge),
          _buildStatCards(context, profileController, splashController),
        ],
      ]),
    );
  }

  Widget _buildStatCards(BuildContext context, ProfileController profileController, SplashController splashController) {
    final user = profileController.userInfoModel;
    final bool loyaltyOn = splashController.configModel!.loyaltyPointStatus!;
    final bool walletOn = splashController.configModel!.customerWalletStatus!;

    final List<ProfileStatData> stats = [
      if (loyaltyOn) ProfileStatData(
        value: PriceConverter.compactNumber(user?.loyaltyPoint ?? 0),
        label: 'loyalty_point'.tr, image: Images.loyaltyCoin,
        onTap: () => Get.toNamed(RouteHelper.getLoyaltyRoute()),
      ),
      if (walletOn) ProfileStatData(
        value: PriceConverter.convertPrice(user?.walletBalance ?? 0, compact: true),
        label: 'wallet'.tr, image: Images.blueWallet,
        onTap: () => Get.toNamed(RouteHelper.getWalletRoute(fromMenuPage: true)),
      ),
      ProfileStatData(
        value: PriceConverter.compactNumber(user?.orderCount ?? 0),
        label: 'order'.tr, image: Images.shoppingBagIcon,
        onTap: () => Get.toNamed(RouteHelper.getOrderRoute()),
      ),
    ];

    const double cardWidth = 150;
    return SizedBox(
      height: 80,
      child: LayoutBuilder(builder: (context, constraints) {
        final double contentWidth = stats.length * cardWidth + (stats.length - 1) * Dimensions.paddingSmall + 2 * Dimensions.paddingDefault;

        if (contentWidth <= constraints.maxWidth) {
          return Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (int i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: Dimensions.paddingMedium),
                ProfileStatCardWidget(stat: stats[i], width: cardWidth),
              ],
            ]),
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          itemCount: stats.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingMedium),
          itemBuilder: (_, i) => ProfileStatCardWidget(stat: stats[i], width: cardWidth),
        );
      }),
    );
  }
}
