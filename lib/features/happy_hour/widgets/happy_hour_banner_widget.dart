import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/screens/happy_hour_screen.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HappyHourBannerWidget extends StatefulWidget {
  const HappyHourBannerWidget({super.key});

  @override
  State<HappyHourBannerWidget> createState() => _HappyHourBannerWidgetState();
}

class _HappyHourBannerWidgetState extends State<HappyHourBannerWidget> {
  final GlobalKey _bannerKey = GlobalKey();

  static const Duration _slideDuration = Duration(milliseconds: 250);

  void _openOffers() {
    HappyHourScreen.show(context);
  }

  void _reportHeight(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) {
        return;
      }
      final HappyHourController happyHourController = Get.find<HappyHourController>();
      if(!visible) {
        happyHourController.reportHeight(0);
        return;
      }
      final double? height = (_bannerKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
      if(height != null) {
        happyHourController.reportHeight(height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(builder: (happyHourController) {
      final bool visible = happyHourController.showHomeBanner;
      _reportHeight(visible);

      if(!visible) {
        return const SizedBox();
      }

      final String offLabel = 'percentage_off'.tr.replaceAll('{percentage}', happyHourController.discountLabel);
      final String? iconUrl = happyHourController.happyHour?.iconFullUrl;

      return GetBuilder<OrderController>(builder: (orderController) {
        final bool orderSheetVisible = orderController.runningSheetVisible;

        return Container(
          decoration: BoxDecoration(
            color: context.bgErrorLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
            boxShadow: [
              BoxShadow(color: context.shadow, blurRadius: 12, offset: const Offset(0, -6)),
              BoxShadow(color: context.shadow, blurRadius: 24, offset: const Offset(0, -8)),
            ],
          ),
          child: AnimatedPadding(
            duration: _slideDuration,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: orderSheetVisible ? OrderController.runningSheetPeek : 0),
            child: Stack(key: _bannerKey, clipBehavior: Clip.none, children: [

              InkWell(
                onTap: _openOffers,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingMedium),
                  child: Row(children: [

                    (iconUrl != null && iconUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(image: iconUrl, height: 40, width: 40, fit: BoxFit.cover),
                        )
                      : CustomAssetImageWidget(Images.happyHours, height: 40, width: 40),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('$offLabel ${'happy_hour'.tr}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
                      const SizedBox(height: Dimensions.paddingOverSmall),
                      Text('tap_to_view_offers'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: context.body.small.regular.overrideWith(color: context.textDangerMedium)),
                    ])),

                    const SizedBox(width: Dimensions.paddingSmall),

                    GetBuilder<HappyHourController>(id: HappyHourController.timerBuilderId, builder: (timerController) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: Dimensions.paddingSmall),
                        decoration: BoxDecoration(color: context.error, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        child: Text(
                          timerController.formattedRemaining,
                          style: context.heading.defaultSize.strong.overrideWith(color: context.textInfoOn
                        )),
                      );
                    }),
                    SizedBox(width: Dimensions.paddingDefault)
                  ]),
                ),
              ),

              Get.find<LocalizationController>().isLtr ? Positioned(top: 6, right: 6, child: InkWell(
                customBorder: const CircleBorder(),
                onTap: happyHourController.dismiss,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                  child: Icon(Icons.close, size: 14, color: context.iconBaseMedium),
                ),
              )) : Positioned(top: 6, left: 6, child: InkWell(
                customBorder: const CircleBorder(),
                onTap: happyHourController.dismiss,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                  child: Icon(Icons.close, size: 14, color: context.iconBaseMedium),
                ),
              )),

            ]),
          ),
        );
      });
    });
  }
}
