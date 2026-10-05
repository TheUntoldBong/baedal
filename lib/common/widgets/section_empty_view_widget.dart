import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SectionEmptyViewWidget extends StatelessWidget {
  final String image;
  final String message;

  const SectionEmptyViewWidget({super.key, required this.image, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge, horizontal: Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CustomAssetImageWidget(image, width: 60, height: 60),
          const SizedBox(height: Dimensions.paddingSmall),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
          ),
        ]),
      ),
    );
  }
}
