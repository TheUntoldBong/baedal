import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HappyHourPromoBannerCardWidget extends StatelessWidget {
  const HappyHourPromoBannerCardWidget({super.key});

  static const double _bannerMaxWidth = 900;
  static const double _bannerAspectRatio = 3 / 1;
  static const double _countdownOverlap = 20;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(builder: (happyHourController) {
      final HappyHourModel? happyHour = happyHourController.happyHour;
      if(happyHour == null) {
        return const SizedBox();
      }

      final String? coverImage = happyHour.coverImageFullUrl;
      final String title = (happyHour.title?.isNotEmpty ?? false)
          ? happyHour.title!
          : 'happy_hours_offer_title'.tr.replaceAll('{percentage}', happyHourController.discountLabel);
      final String description = (happyHour.shortDescription?.isNotEmpty ?? false)
          ? happyHour.shortDescription!
          : 'enjoy_happy_hour_specials_on_drinks_and_appetizers'.tr;

      return Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final double bannerWidth = constraints.maxWidth > _bannerMaxWidth ? _bannerMaxWidth : constraints.maxWidth;
            final double bannerHeight = bannerWidth / _bannerAspectRatio;
            return Center(
              child: SizedBox(
                width: bannerWidth,
                child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: (coverImage != null && coverImage.isNotEmpty)
                      ? CustomImageWidget(
                          image: coverImage,
                          height: bannerHeight, width: bannerWidth, fit: BoxFit.cover,
                        )
                      : CustomAssetImageWidget(
                          Images.happyHours,
                          height: bannerHeight, width: bannerWidth, fit: BoxFit.cover,
                        ),
                  ),

                  const Positioned(
                    bottom: -_countdownOverlap,
                    child: _CountdownPill(),
                  ),
                ]),
              ),
            );
          }),
          SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

          Text(title, textAlign: TextAlign.center, style: context.heading.extraLarge),
          const SizedBox(height: Dimensions.padding2xSmall),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.body.small.overrideWith(color: context.textBaseMedium),
          ),
          const SizedBox(height: Dimensions.paddingLarge),
        ],
      );
    });
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(id: HappyHourController.timerBuilderId, builder: (happyHourController) {
      final Duration remaining = happyHourController.remaining;
      final int minutes = remaining.inMinutes;
      final int seconds = remaining.inSeconds % 60;

      return Container(
        padding: const EdgeInsets.all(Dimensions.padding2xSmall),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: [
            BoxShadow(color: context.shadow, blurRadius: 8, offset: Offset(0,1)),
            BoxShadow(color: context.shadow, blurRadius: 2, offset: Offset(0,1)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          _TimeBox(value: minutes, label: 'min'.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
            child: Text(':', style: context.heading.large.overrideWith(color: context.textBaseLight)),
          ),
          _TimeBox(value: seconds, label: 'sec'.tr),
        ]),
      );
    });
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;
  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingExtraSmall),
      decoration: BoxDecoration(
        color: context.textBaseDefault,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Text(value.toString().padLeft(2, '0'), style: context.heading.large.overrideWith(color: context.textInfoOn)),
        const SizedBox(width: Dimensions.paddingOverSmall),
        Text(label, style: context.heading.defaultSize.regular.overrideWith(color: context.textInfoOn)),
      ]),
    );
  }
}
