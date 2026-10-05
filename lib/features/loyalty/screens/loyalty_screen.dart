import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/loyalty/widgets/loyalty_card_widget.dart';
import 'package:stackfood_multivendor/features/loyalty/widgets/loyalty_history_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    _initCall();

  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()){

      Get.find<ProfileController>().getUserInfo();

      Get.find<LoyaltyController>().getLoyaltyTransactionList('1', false);

      Get.find<LoyaltyController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<LoyaltyController>().transactionList != null
            && !Get.find<LoyaltyController>().isLoading) {
          int pageSize = (Get.find<LoyaltyController>().popularPageSize! / 10).ceil();
          if (Get.find<LoyaltyController>().offset < pageSize) {
            Get.find<LoyaltyController>().setOffset(Get.find<LoyaltyController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<LoyaltyController>().showBottomLoader();
            Get.find<LoyaltyController>().getLoyaltyTransactionList(Get.find<LoyaltyController>().offset.toString(), false);
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

    return Scaffold(
      backgroundColor: context.surface,
      appBar: CustomAppBarWidget(title: 'loyalty_points'.tr, isBackButtonExist: true),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return isLoggedIn ? profileController.userInfoModel != null ? SafeArea(
          child: RefreshIndicator(
            onRefresh: () async{
              Get.find<LoyaltyController>().getLoyaltyTransactionList('1', true);
              profileController.getUserInfo();
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  SizedBox(
                    child: SizedBox(width: Dimensions.webMaxWidth,
                      child: Column(children: [

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingLarge),
                          color: context.surface,
                          child: LoyaltyCardWidget(tooltipController: tooltipController),
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Dimensions.paddingLarge),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular( Dimensions.radiusLarge),
                          ),
                          child: const LoyaltyHistoryWidget(),
                        ),

                      ]),
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
    );
  }
}