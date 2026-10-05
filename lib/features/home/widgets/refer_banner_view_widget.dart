import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ReferBannerViewWidget extends StatelessWidget {
  const ReferBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if(!(Get.find<SplashController>().configModel?.refEarningStatus ?? false)) {
      return const SizedBox();
    }

    final bool isMobile = ResponsiveHelper.isMobile(context);
    final double iconSize = isMobile ? 52 : 64;
    final String earning = PriceConverter.convertPrice(Get.find<SplashController>().configModel!.refEarningExchangeRate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Container(
        decoration: BoxDecoration(
          color: context.bgInfoMedium,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [

          Positioned(
            right: -26, top: -18, height: 100, width: 100,
            child: DecoratedBox(decoration: BoxDecoration(
              shape: BoxShape.circle, color: context.bgInfoDefault.withValues(alpha: 0.08),
            )),
          ),

          Positioned(
            right: 14, top: 30, height: 66, width: 66,
            child: DecoratedBox(decoration: BoxDecoration(
              shape: BoxShape.circle, color: context.bgInfoDefault.withValues(alpha: 0.08),
            )),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingDefault,
              vertical: isMobile ? Dimensions.paddingMedium : Dimensions.paddingDefault,
            ),
            child: Row(children: [

              CustomAssetImageWidget(Images.referFriendsNetwork, height: iconSize, width: iconSize, fit: BoxFit.contain),
              const SizedBox(width: Dimensions.paddingMedium),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  Text(
                    '${'earn'.tr} $earning · ${'refer_a_friend'.tr}',
                    style: context.heading.defaultSize,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Text(
                    'refer_friends_and_earn_for_each'.trParams({'amount': earning}),
                    style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),

                ]),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              CustomButtonWidget(
                buttonText: 'refer_now'.tr,
                height: 28, takeMinimumWidth: true,
                radius: Dimensions.radiusMedium, fontSize: Dimensions.fontSizeSmall,
                textColor: context.onPrimary,
                onPressed: () => Get.toNamed(RouteHelper.getReferAndEarnRoute()),
              ),

            ]),
          ),

        ]),
      ),
    );
  }
}
