import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class WalletCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletCardWidget({super.key, required this.tooltipController});

  void _openAddFund() {
    if(Get.find<SplashController>().configModel!.digitalPayment! && Get.find<SplashController>().configModel!.activePaymentMethodList!.isNotEmpty) {
      showCustomDialog(
        child: const DialogSheetBody(
          showCloseIcon: true,
          child: AddFundDialogueWidget(),
        ),
      );
    } else {
      showCustomSnackBar('currently_digital_payment_is_not_available'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: Dimensions.paddingDefault),
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: context.surfaceContainer,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(clipBehavior: Clip.none, children: [

            Positioned(
              right: -10, bottom: -10,
              child: Opacity(opacity: 0.5, child: CustomAssetImageWidget(Images.walletPay, height: 90, width: 90)),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('your_wallet_balance'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                const SizedBox(height: 4),
                Text(
                  PriceConverter.convertPrice(profileController.userInfoModel?.walletBalance ?? 0), textDirection: TextDirection.ltr,
                  style: context.heading.extraOverLarge.strong,
                ),
              ]),

              Get.find<SplashController>().configModel!.addFundStatus! ? InkWell(
                onTap: _openAddFund,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault-3, vertical: Dimensions.padding2xSmall+3),
                  decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2)),
                  child: Text(
                    'add_balance'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: context.heading.small.strong.overrideWith(color: context.onPrimary),
                  ),
                ),
              ) : const SizedBox(),
            ]),
          ]),
        );
    });
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: Dimensions.padding2xSmall),
            height: 15, width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.primary, width: 2),
            ),
          ),

          Expanded(
            child: VerticalDivider(
              thickness: 3,
              color: context.primary.withValues(alpha: 0.30),
            ),
          ),

          Container(
            height: 15, width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.primary, width: 2),
            ),
          ),

          Expanded(
            child: VerticalDivider(
              thickness: 3,
              color: context.primary.withValues(alpha: 0.30),
            ),
          ),

          Container(
            height: 15, width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.primary, width: 2),
            ),
          ),

          Expanded(
            child: VerticalDivider(
              thickness: 3,
              color: context.primary.withValues(alpha: 0.30),
            ),
          ),

          Container(
            height: 15, width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.primary, width: 2),
            ),
          ),
        ]),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('earn_money_to_your_wallet_by_completing_the_offer_challenged'.tr, style: context.body.defaultSize.regular),
              Text('convert_your_loyalty_points_into_wallet_money'.tr, style: context.body.defaultSize.regular),
              Text('amin_also_reward_their_top_customers_with_wallet_money'.tr, style: context.body.defaultSize.regular),
              Text('send_your_wallet_money_while_order'.tr, style: context.body.defaultSize.regular),
            ],
          ),
        ),
      ]),
    );
  }
}

