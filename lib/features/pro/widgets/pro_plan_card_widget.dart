import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProPlanCardWidget extends StatelessWidget {
  final ProPlanModel? model;
  const ProPlanCardWidget({super.key, required this.model,});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> benefitItems = ProHelper.getPlanBenefitItems(model?.benefits);
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffDFDFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular( Dimensions.radiusExtraLarge), top: Radius.circular(Dimensions.radiusLarge)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingDefault),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSmall),
                      decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                      child: CustomAssetImageWidget(Images.proPlanCrown, width: 24, height: 24, color: context.surfaceContainer),
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),
                    Text(
                      model?.proBrand ?? 'stackfood_pro'.tr,
                      style: context.heading.large.strong.overrideWith(color: context.primary),
                    ),
                    const SizedBox(height: Dimensions.padding2xSmall),
                    Text(
                      'save_more_on_every_order'.tr,
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                    ),
                    const SizedBox(height: Dimensions.paddingDefault),
                  ],
                ),
              ),

              if (benefitItems.isNotEmpty) Padding(
                padding: EdgeInsets.all(Dimensions.paddingDefault),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingLarge),
                    ...benefitItems.map((item) => _buildBenefitsRow(context, item['title']!, item['subtitle']!)),
                  ],
                ),
              )
            ],
          ),
        )

      ],
    );

    return column;
  }

  Widget _buildBenefitsRow(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white , shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 12,),
          ),
          const SizedBox(width: Dimensions.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.subHeading.defaultSize.medium.overrideWith(color: Colors.black)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: context.body.small.regular.overrideWith(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
