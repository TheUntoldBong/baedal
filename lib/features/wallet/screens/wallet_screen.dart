import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/bonus_banner_widget.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/wallet_card_widget.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/wallet_history_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class WalletScreen extends StatefulWidget {
  final String? fundStatus;
  final String? token;
  final bool fromMenuPage;
  final bool fromNotification;
  const WalletScreen({super.key, this.fundStatus, this.token, this.fromMenuPage = false, this.fromNotification = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    _initCall();

  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()){

      Get.find<WalletController>().insertFilterList();
      Get.find<WalletController>().setWalletFilerType('all', isUpdate: false);

      if((widget.fundStatus == 'success' || widget.fundStatus == 'fail' || widget.fundStatus == 'cancel') && Get.find<WalletController>().getWalletAccessToken() != widget.token){
        Future.delayed(const Duration(seconds: 2), (){

          Get.showSnackbar(GetSnackBar(
            backgroundColor: widget.fundStatus == 'fail' ? context.textDangerMedium : context.textSuccessMedium,
            message: widget.fundStatus == 'success' ? 'fund_successfully_added_to_wallet'.tr : 'fund_not_added_to_wallet'.tr,
            maxWidth: 500,
            duration: const Duration(seconds: 3),
            snackStyle: SnackStyle.FLOATING,
            margin:  const EdgeInsets.all(Dimensions.paddingOverLarge),
            borderRadius: Dimensions.radiusExtraLarge,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
          ));
        }).then((value) {
          Get.find<WalletController>().setWalletAccessToken(widget.token ?? '');
        });
      }
      Get.find<ProfileController>().getUserInfo();
      Get.find<WalletController>().getWalletBonusList(isUpdate: false);
      Get.find<WalletController>().getWalletTransactionList('1', false, Get.find<WalletController>().type);

      Get.find<WalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<WalletController>().transactionList != null
            && !Get.find<WalletController>().isLoading) {
          int pageSize = (Get.find<WalletController>().popularPageSize! / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>().setOffset(Get.find<WalletController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(Get.find<WalletController>().offset.toString(), false, Get.find<WalletController>().type);
          }
        }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return PopScope(
      canPop: widget.fromNotification ? Navigator.canPop(context) : false,
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification) {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else {
            return;
          }
        }else {
          if(widget.fromMenuPage){
            Future.delayed(const Duration(milliseconds: 10), () {
              Get.back();
            });
          }else{
            Future.delayed(const Duration(milliseconds: 10), () {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.surface,
        appBar: CustomAppBarWidget(title: 'wallet'.tr, isBackButtonExist: true, onBackPressed: (){
          if(widget.fromNotification) {
            if(widget.fromNotification) {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }else {
              Get.back();
            }
          }else {
            if(widget.fromMenuPage){
              Future.delayed(const Duration(milliseconds: 10), () {
                Get.back();
              });
            }else{
              Future.delayed(const Duration(milliseconds: 10), () {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              });
            }
          }
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GetBuilder<ProfileController>(builder: (profileController) {
          return isLoggedIn ? profileController.userInfoModel != null ? SafeArea(
            child: RefreshIndicator(
              onRefresh: () async{
                Get.find<WalletController>().setWalletFilerType('all');
                Get.find<WalletController>().getWalletTransactionList('1', true, 'all');
                Get.find<ProfileController>().getUserInfo();
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      child: SizedBox(width: Dimensions.webMaxWidth,
                        child: GetBuilder<WalletController>(builder: (walletController) {
                          return Column(children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                              child: WalletCardWidget(tooltipController: tooltipController),
                            ),
                           SizedBox(height: Dimensions.paddingLarge),

                           Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              ),
                              child: Column(children: [
                                const BonusBannerWidget(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                  child: const WalletHistoryWidget(),
                                ),
                              ]),
                            ),

                          ]);
                        }),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
            _initCall();
            setState(() {});
          });
        }),
      ),
    );
  }
}

class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: 0.01,
        childAspectRatio:4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingLarge), child: Divider(color: context.surfaceContainerLow)),
            ],
            ),
          ),
        );
      },
    );
  }
}