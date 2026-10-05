import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProfileStatData {
  final String value;
  final String label;
  final String image;
  final VoidCallback onTap;

  const ProfileStatData({required this.value, required this.label, required this.image, required this.onTap});
}

class ProfileStatCardWidget extends StatelessWidget {
  final ProfileStatData stat;
  final double width;

  const ProfileStatCardWidget({super.key, required this.stat, this.width = 130});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: stat.onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium, vertical: Dimensions.paddingMedium),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Expanded(child: Text(stat.value, maxLines: 1, overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style: context.heading.defaultSize.strong,
            )),
            Icon(Icons.arrow_forward, size: 16),
          ]),
          const SizedBox(height: Dimensions.paddingMedium),

          Row(children: [
            CustomAssetImageWidget(stat.image, height: 20, width: 20),
            const SizedBox(width: Dimensions.padding2xSmall),
            Flexible(child: Text(stat.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.body.small.regular.overrideWith(color: context.textNeutralMedium),
            )),
          ]),
        ]),
      ),
    );
  }
}
