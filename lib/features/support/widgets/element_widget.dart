import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

class ElementWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final Function() onTap;
  const ElementWidget({super.key, required this.image, required this.title, required this.subTitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomAssetImageWidget(image, height: 45, width: 45, fit: BoxFit.cover),

        Text(title, style: context.heading.defaultSize.strong),

        Text(
          subTitle,
          style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
          overflow: TextOverflow.ellipsis, maxLines: 2,
        ),

      ]),
    );
  }
}
