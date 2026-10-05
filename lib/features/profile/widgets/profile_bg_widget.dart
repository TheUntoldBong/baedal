import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class ProfileBgWidget extends StatelessWidget {
  final Widget circularImage;
  final Widget mainWidget;
  final bool backButton;
  const ProfileBgWidget({super.key, required this.mainWidget, required this.circularImage, required this.backButton});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Stack(clipBehavior: Clip.none, children: [

        SizedBox(
          width: context.width, height: 260,
          child: Center(child: CustomAssetImageWidget(Images.profileBg, height: 260, width: Dimensions.webMaxWidth, fit: BoxFit.fill)),
        ),

        Positioned(
          top: 200, left: 0, right: 0, bottom: 0,
          child: Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                color: context.surfaceContainer,
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top+10, left: 0, right: 0,
          child: Text(
            'profile'.tr, textAlign: TextAlign.center,
            style: context.heading.large.regular.overrideWith(color: context.surfaceContainer),
          ),
        ),

        backButton ? Positioned(
          top: MediaQuery.of(context).padding.top, left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.surfaceContainer, size: 20),
            onPressed: () => Get.back(),
          ),
        ) : const SizedBox(),

        Positioned(
          top: 150, left: 0, right: 0,
          child: circularImage,
        ),

      ]),

      Expanded(
        child: mainWidget,
      ),

    ]);
  }
}
