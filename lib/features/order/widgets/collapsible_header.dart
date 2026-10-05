import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor/helper/color_coverter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CollapsibleSectionHeader extends StatelessWidget {
  final String title;
  final String? titleSuffix;
  final String? subscriptionStatus;
  final int? id;
  final int? itemCount;
  final bool expanded;
  final VoidCallback onTap;

  const CollapsibleSectionHeader({super.key, required this.title, this.titleSuffix, this.id, this. itemCount, required this.expanded, required this.onTap, this.subscriptionStatus});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: context.heading.extraLarge,
                      children: [
                        TextSpan(text: title),
                        if (titleSuffix != null && titleSuffix!.isNotEmpty)
                          TextSpan(
                            text: ' ($titleSuffix)',
                            style: context.heading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                          ),
                      ],
                    ),
                  ),
                ),
                if (subscriptionStatus != null && subscriptionStatus!.isNotEmpty) ...[
                  const SizedBox(width: Dimensions.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorConverter.getStatusColor(subscriptionStatus ?? '').withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                    child: Text(
                      subscriptionStatus!.tr,
                      style: context.heading.defaultSize.regular.overrideWith(color: ColorConverter.getStatusColor(subscriptionStatus ?? '')),
                    ),
                  ),
                ],
              ]),
              if (id != null || itemCount != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  Text(
                    '#ID $id',
                    style: context.heading.small.regular.overrideWith(color: context.textBaseMedium),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 5, width: 5,
                    decoration: BoxDecoration(
                      color: context.bgNeutralMedium,
                      shape: BoxShape.circle
                    ),
                  ),
                  Text(
                    '$itemCount ${'items'.tr}',
                    style: context.heading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ]),
              ],
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSmall),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surfaceContainerLowest,
            ),
            child: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
