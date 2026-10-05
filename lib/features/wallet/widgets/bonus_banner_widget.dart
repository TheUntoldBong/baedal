import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BonusBannerWidget extends StatelessWidget {
  const BonusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (walletController) {
        return walletController.fundBonusList != null && walletController.fundBonusList!.isNotEmpty && Get.find<SplashController>().configModel!.addFundStatus! ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Dimensions.paddingLarge),
            SizedBox(
              height: 110,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: 0.8,
                  autoPlayInterval: const Duration(seconds: 7),
                  onPageChanged: (index, reason) {
                    walletController.setCurrentIndex(index, true);
                  },
                ),
                itemCount: walletController.fundBonusList!.length,
                itemBuilder: (context, index, _) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: context.surface,
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Text(
                          walletController.fundBonusList![index].title!, maxLines: 1,
                          style: context.subHeading.defaultSize.strong, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.paddingExtraSmall),

                        Text(
                          '${'valid_till'.tr} ${DateConverter.stringToReadableString(walletController.fundBonusList![index].endDate!)}',
                          style: context.body.small.regular,
                        ),
                        const SizedBox(height: Dimensions.paddingMedium),

                        Text(
                          '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(walletController.fundBonusList![index].minimumAddAmount)} ${'and_enjoy'.tr} ${walletController.fundBonusList![index].bonusAmount} '
                              '${walletController.fundBonusList![index].bonusType == 'amount' ? Get.find<SplashController>().configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                          style: context.subHeading.small.regular,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ])),

                      CustomAssetImageWidget(Images.walletBonus, height: 65, width: 65),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: Dimensions.padding2xSmall),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: walletController.fundBonusList!.map((bnr) {
                int index = walletController.fundBonusList!.indexOf(bnr);
                return TabPageSelectorIndicator(
                  backgroundColor: index == walletController.currentIndex ? Theme.of(context).textTheme.bodyLarge!.color!
                      : context.bgNeutralMedium,
                  borderColor: Theme.of(context).colorScheme.surface,
                  size: index == walletController.currentIndex ? 10 : 7,
                );
              }).toList(),
            ),

            SizedBox(height: Dimensions.paddingLarge),
          ],
        ) : const SizedBox();
      }
    );
  }
}
