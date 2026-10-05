import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/category_cuisine_row_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class WhatOnYourMindViewWidget extends StatelessWidget {
  final bool merged;
  const WhatOnYourMindViewWidget({super.key, this.merged = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final bool hasItems = homeController.categoryCuisineList?.isNotEmpty ?? false;
      final bool isDesktop = ResponsiveHelper.isDesktop(context);
      final double topPadding = merged && !isDesktop
          ? Dimensions.paddingSmall
          : (!isDesktop ? Dimensions.paddingLarge : Dimensions.paddingOverLarge);
      return hasItems ?  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            top: topPadding,
            left: Get.find<LocalizationController>().isLtr ? Dimensions.padding2xSmall : 0,
            right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.padding2xSmall,
          ),
          child: Center(child: Text(
            'what_on_your_mind'.tr,
            textAlign: TextAlign.center,
            style: context.heading.extraLarge,
          )),
        ),

        SizedBox(height: Dimensions.paddingDefault,),
        const CategoryCuisineRowWidget(),
      ]) : const SizedBox();
    });
  }
}

