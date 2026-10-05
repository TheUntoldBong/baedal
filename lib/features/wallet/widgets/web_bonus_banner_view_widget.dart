import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebBonusBannerViewWidget extends StatelessWidget {
  const WebBonusBannerViewWidget ({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return GetBuilder<WalletController> (
      builder: (walletController) {
        return walletController.fundBonusList != null ? walletController.fundBonusList!.isNotEmpty ? Container(
          width: 1210, height: 130,
          padding: const EdgeInsets.symmetric( horizontal: 0, vertical: Dimensions.paddingSmall),
          alignment: Alignment.center,
          child:  Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSmall),
                child: PageView.builder(

                  controller: pageController,
                  itemCount: (walletController.fundBonusList!.length/2).ceil(),
                  itemBuilder: (context, index) {
                    int index1 = index * 2;
                    int index2 = (index * 2) + 1;
                    bool hasSecond = index2 < walletController.fundBonusList!.length;

                    return Row(children: [
                      Expanded(child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: context.primary),
                          color: context.primary.withValues(alpha: 0.03),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              walletController.fundBonusList![index1].title!,
                              maxLines: 1,
                              style: context.heading.defaultSize.strong.overrideWith(color: context.primary).copyWith(overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),

                            Text(
                              '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletController.fundBonusList![index1].endDate!)}',
                              style: context.body.small.medium,
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),

                            Text(
                              '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletController.fundBonusList![index1].minimumAddAmount)} ${'and_enjoy'.tr} ${walletController.fundBonusList![index1].bonusAmount} '
                                  '${walletController.fundBonusList![index1].bonusType == 'amount' ? Get.find<SplashController>().configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                              style: context.body.small.regular.overrideWith(color: context.primary),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ])),

                          CustomAssetImageWidget(Images.walletBonus, height: 65, width: 65,),
                        ]),
                        )
                      ),

                      const SizedBox(width: Dimensions.paddingLarge),

                      Expanded(child: hasSecond ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: context.primary),
                          color: context.primary.withValues(alpha: 0.03),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              walletController.fundBonusList![index2].title!,
                              maxLines: 1,
                              style: context.heading.defaultSize.strong.overrideWith(color: context.primary).copyWith(overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),

                            Text(
                              '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletController.fundBonusList![index2].endDate!)}',
                              style: context.body.small.medium,
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),

                            Text(
                              '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletController.fundBonusList![index2].minimumAddAmount)} ${'and_enjoy'.tr} ${walletController.fundBonusList![index2].bonusAmount} '
                                  '${walletController.fundBonusList![index2].bonusType == 'amount' ? Get.find<SplashController>().configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                              style: context.body.small.regular.overrideWith(color: context.primary),
                            ),
                          ])),

                          CustomAssetImageWidget(Images.walletBonus, height: 65, width: 65,),
                        ]),
                      ) : const SizedBox()),

                    ]);
                  },
                  onPageChanged: (int index) => walletController.setCurrentIndex(index, true),
                ),
              ),

              walletController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: 0,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: context.surfaceContainer,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ) : const SizedBox(),

              walletController.currentIndex != ((walletController.fundBonusList!.length/2).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: 0,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: context.surfaceContainer,
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ) : const SizedBox(),

            ],
          ),
        ) : const SizedBox() : WebBannerShimmer(walletController: walletController);
      }
    );
  }
}

class WebBannerShimmer extends StatelessWidget {
  final WalletController walletController;
  const WebBannerShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: walletController.fundBonusList == null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Row(children: [

            Expanded(child: Container(
              height: 220,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Colors.grey[300]),
            )),

            const SizedBox(width: Dimensions.paddingLarge),

            Expanded(child: Container(
              height: 220,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Colors.grey[300]),
            )),

          ]),
        ),
      ),
    );
  }
}

