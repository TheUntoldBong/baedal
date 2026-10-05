import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/screens/happy_hour_screen.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';


class HappyHourMilestoneBannerWidget extends StatelessWidget {
  static const double _iconSize = 18;
  static const double _progressHeight = 3;

  final double subtotal;

  final bool? isHappyHourRunning;

  final double bottomInset;
  final double? borderRadius;
  final Function()? onTap;

  const HappyHourMilestoneBannerWidget({super.key, required this.subtotal, this.isHappyHourRunning,  this.bottomInset = 0, this.borderRadius, this.onTap });

  void _openOffers(BuildContext context) {
    HappyHourScreen.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(builder: (happyHourController) {
      if (!happyHourController.showRestaurantBanner(isHappyHourRunning)) {
        return const SizedBox();
      }

      final bool hasMinOrder = happyHourController.hasMinOrderRequirement;
      final double remaining = happyHourController.remainingForDiscount(subtotal);
      final bool showProgress = hasMinOrder && remaining > 0;
      final String offLabel = 'percentage_off'.tr.replaceAll('{percentage}', happyHourController.discountLabel);

      final BorderRadius radius =  BorderRadius.vertical(top: Radius.circular(borderRadius ?? Dimensions.radiusDefault));
      final TextStyle regular = context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault);
      final TextStyle strong = context.body.defaultSize.strong.overrideWith(color: context.textBaseDefault);

      final Widget banner = Container(
        decoration: BoxDecoration(
          color: context.bgWarningMedium,
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () =>  _openOffers(context),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CustomAssetImageWidget(Images.percentTag, height: _iconSize, width: _iconSize, color: context.iconWarningMedium),
                            const SizedBox(width: Dimensions.paddingSmall),

                            Expanded(child: RichText(
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              text: showProgress ? TextSpan(children: [
                                TextSpan(text: '${'add'.tr} ', style: regular),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: PriceConverter.convertAnimationPrice(remaining, textStyle: strong),
                                ),
                                TextSpan(text: ' ${'more_to_get'.tr} ', style: regular),
                                TextSpan(text: offLabel, style: strong),
                              ]) : TextSpan(children: [
                                TextSpan(text: '${'order_now_and_get'.tr} ', style: regular),
                                TextSpan(text: offLabel, style: strong),
                              ]),
                            )),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingExtraSmall),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: LinearProgressIndicator(
                            minHeight: _progressHeight,
                            value: showProgress ? happyHourController.progressForDiscount(subtotal) : 1,
                            backgroundColor: context.bgWarningLight,
                            valueColor: AlwaysStoppedAnimation<Color>(context.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingLarge),

                  GetBuilder<HappyHourController>(id: HappyHourController.timerBuilderId, builder: (timerController) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                      decoration: BoxDecoration(color: context.bgNeutralDefault, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      child: Text(
                        timerController.formattedRemaining,
                        style: context.body.defaultSize.strong.overrideWith(color: context.textNeutralOn),
                      ),
                    );
                  }),
                ]),
              ),


            ]),
          ),
        ),
      );

      return banner;
    });
  }
}
