import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SlotWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool fromCustomDate;
  final bool isEnabled;
  const SlotWidget({super.key, required this.title, required this.isSelected, required this.onTap, this.fromCustomDate = false,
    this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: fromCustomDate ? Dimensions.paddingSmall : Dimensions.padding2xSmall),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? context.primary : isDesktop || fromCustomDate ? context.bgNeutralLight : context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
        ),
        child: Text(
          title,
          style: context.subHeading.small.medium
              .overrideWith(color: isSelected ? context.surfaceContainer : isEnabled ? context.textBaseDefault : context.iconDisabledDefault)
              .copyWith(fontSize: isDesktop ? 10 : fromCustomDate ? Dimensions.fontSizeSmall : Dimensions.fontSizeSmall),
        ),
      ),
    );
  }
}
