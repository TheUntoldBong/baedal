import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';


class ProfileCardWidget extends StatelessWidget {
  final String image;
  final String title;
  final String data;
  const ProfileCardWidget({super.key, required this.data, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.primary.withValues(alpha: 0.05), blurRadius: 4, spreadRadius: 0)],
        border: Border.all(color: context.primary.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomAssetImageWidget(image, height: 30, width: 30),
        const SizedBox(height: Dimensions.padding2xSmall),
        Text(data, style: context.subHeading.large.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
        const SizedBox(height: Dimensions.padding2xSmall),
        Text(title, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
      ]),
    );
  }
}