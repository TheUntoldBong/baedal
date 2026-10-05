import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor/util/images.dart';

class RestaurantVerifiedIconWidget extends StatelessWidget {
  final double size;
  const RestaurantVerifiedIconWidget({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return CustomToolTip(
      message: 'verified_restaurant'.tr,
      child: CustomAssetImageWidget(Images.verifiedIcon, width: size, height: size, color: context.iconInfoMedium,),
    );
  }
}