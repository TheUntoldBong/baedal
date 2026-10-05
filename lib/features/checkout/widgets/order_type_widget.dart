import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderTypeWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const OrderTypeWidget({super.key, required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault+2),
      onTap: onTap as void Function()?,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        ),
        child: Text(
          title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.heading.defaultSize.strong.overrideWith(
            color: isSelected ? context.surfaceContainer : context.textBaseMedium,
          ),
        ),
      ),
    );
  }
}
