import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class ProSuccessBottomSheetWidget extends StatelessWidget {
  final bool isRenewalMode;
  const ProSuccessBottomSheetWidget({super.key, this.isRenewalMode = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 450 : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(Dimensions.radiusExtraLarge),
          topRight: const Radius.circular(Dimensions.radiusExtraLarge),
          bottomLeft: Radius.circular(isDesktop ? Dimensions.radiusExtraLarge : 0),
          bottomRight: Radius.circular(isDesktop ? Dimensions.radiusExtraLarge : 0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimensions.paddingSmall),
          isDesktop ? const SizedBox() : Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.bgNeutralMedium,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
            child: CustomAssetImageWidget(Images.proPlanCrown, width: 40, height: 40, color: Colors.white),
          ),
          const SizedBox(height: Dimensions.paddingLarge),
          Text(
            isRenewalMode ? 'pro_plan_renewed_successfully'.tr : 'you_are_now_a_pro_member'.tr,
            style: context.heading.extraLarge.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge),
            child: Text(
              'pro_member_welcome_message'.tr,
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}
