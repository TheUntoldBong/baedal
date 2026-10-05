import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class TipsWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool isSuggested;
  final int index;
  const TipsWidget({super.key, required this.title, required this.isSelected, required this.onTap, required this.isSuggested, required this.index});

  @override
  Widget build(BuildContext context) {
    const double tileHeight = 44;
    final Color borderColor = isSelected ? context.primary : context.outlineVariant;
    final Color amountColor = isSelected ? context.surfaceContainer : context.textBaseDefault;
    final Color suggestedColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSmall, top: Dimensions.padding2xSmall, bottom: Dimensions.padding2xSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: onTap as void Function()?,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(height: tileHeight,
            decoration: BoxDecoration(
              color: isSelected ? context.primary : context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: borderColor),
            ),
            child: IntrinsicWidth(
              child: isSuggested ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    child: Text(title, textDirection: TextDirection.ltr, textAlign: TextAlign.center, 
                    style: context.subHeading.defaultSize.strong.overrideWith(color: amountColor)
                    ),
                  ),
                )),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: suggestedColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault - 1), bottomRight: Radius.circular(Dimensions.radiusDefault - 1)),
                    ),
                    child: Text('most_tipped'.tr, style: context.subHeading.small.medium.overrideWith(color: suggestedColor), textAlign: TextAlign.center),
                  ),
                ),
              ]) : Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                child: Text(title, textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: context.subHeading.defaultSize.strong.overrideWith(color: amountColor)),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
