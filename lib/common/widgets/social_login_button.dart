import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String? label;
  final String iconPath;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key, this.label,
    required this.iconPath, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      radius: Dimensions.radiusDefault,
      child: Container(
        height: 50, width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.outline),
          color: label != null ? context.surfaceContainer : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            CustomAssetImageWidget(iconPath, height: 24, width: 24),
            label != null ? const SizedBox(width: 2) : const SizedBox.shrink(),

            label != null ? Text(label ?? '', style: context.heading.defaultSize.strong) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}