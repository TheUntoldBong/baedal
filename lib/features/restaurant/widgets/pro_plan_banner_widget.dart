import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProPlanBannerWidget extends StatelessWidget {
  final VoidCallback? onSubscribe;
  const ProPlanBannerWidget({super.key, this.onSubscribe,});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<ProController>(
      builder: (proController) {
        if(ProHelper.showActiveBenefitBanner){
          return SizedBox();
        }
        else if(ProHelper.showUnsubscribedBanner){
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A1F4A) : const Color(0xFFEFEAFB),
                image: isDark ? null : DecorationImage(image: AssetImage(Images.proBanner)),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
            ),
            child: Stack(children: [

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSmall,
                  vertical: Dimensions.paddingSmall,
                ),
                child: Row(children: [

                  Container(
                    height: 32, width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.primary,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6),
                    child: CustomAssetImageWidget(Images.proPlanCrown, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: '${'enjoy_extra_savings_on_every_order_with_a'.tr} ',
                        style: context.body.small.regular.overrideWith(color: context.textBaseDefault),
                        children: [
                          TextSpan(
                            text: 'pro_plan'.tr,
                            style: context.body.small.strong.overrideWith(color: context.textBaseDefault),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSmall),
                    child: InkWell(
                      onTap: onSubscribe,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingDefault,
                          vertical: Dimensions.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B4DFF),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        ),
                        child: Text(
                          'subscribe_now'.tr,
                          style: context.body.small.medium.overrideWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        }
        else{
          return SizedBox();
        }
      }
    );
  }
}
