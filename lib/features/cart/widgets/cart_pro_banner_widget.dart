import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartProBannerWidget extends StatelessWidget {
  final VoidCallback? onExplore;
  const CartProBannerWidget({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Color(0xFF4B54D6), Color(0xFF6C5CE7)],
        ),
      ),
      child: Row(children: [

        Container(
          height: 34, width: 34,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.primary),
          child: CustomAssetImageWidget(Images.proPlanCrown, fit: BoxFit.contain, color: context.surfaceContainer,),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: RichText(
            text: TextSpan(
              text: '${'use'.tr} ',
              style: context.body.small.regular.overrideWith(color: Colors.white),
              children: [
                TextSpan(text: 'pro_plan'.tr, style: context.body.small.strong.overrideWith(color: Colors.white)),
                TextSpan(text: ' ${'to_get_extra_savings_in_every_order'.tr}', style: context.body.small.regular.overrideWith(color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        InkWell(
          onTap: onExplore,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('explore'.tr, style: context.body.small.medium.overrideWith(color: Colors.white)),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white),
          ]),
        ),

      ]),
    );
  }
}
