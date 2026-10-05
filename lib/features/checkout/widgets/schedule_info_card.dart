import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ScheduleInfoCard extends StatelessWidget {
  final bool isDesktop;
  final String title;
  final String subtitle;
  final Widget? valueDisplay;
  final VoidCallback onEditTap;
  final EdgeInsetsGeometry? margin;
  final bool hasValue;

  const ScheduleInfoCard({
    super.key, required this.isDesktop, required this.title, required this.subtitle,
    this.valueDisplay, required this.onEditTap, required this.hasValue, this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault+1),
      padding: EdgeInsets.all(Dimensions.paddingSmall+2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
        color: context.surface,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: context.heading.large.strong),
          const SizedBox(height: Dimensions.padding2xSmall),

          Text(
            subtitle,
            style: context.heading.small.regular.copyWith(color: context.textBaseMedium),
          ),
          const SizedBox(height: Dimensions.paddingMedium),

          valueDisplay ?? SizedBox.shrink(),
        ])),
        const SizedBox(width: Dimensions.paddingLarge),

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
          child: InkWell(
            onTap: onEditTap,
            child: CustomAssetImageWidget(hasValue ? Images.editBtn : Images.calendarClockIcon, width: 22, height: 22),
          ),
        ),
      ]),
    );
  }
}
