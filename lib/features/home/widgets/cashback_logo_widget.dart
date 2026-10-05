import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CashBackLogoWidget extends StatelessWidget {
  const CashBackLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      const CustomAssetImageWidget(Images.cashBack, height: 60, width: 60),

      Positioned(
        top: 15, left: 12,
        child: Text('cash_back'.tr, style: (ResponsiveHelper.isDesktop(context) ? context.heading.small : context.heading.small).overrideWith(color: Colors.white)),
      ),

    ]);
  }
}
