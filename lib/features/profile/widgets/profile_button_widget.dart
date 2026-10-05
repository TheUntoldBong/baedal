import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';


class ProfileButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  final Color? color;
  final String? iconImage;
  final bool isThemeSwitchButton;
  const ProfileButtonWidget({super.key, this.icon, required this.title, required this.onTap, this.isButtonActive, this.color, this.iconImage, this.isThemeSwitchButton = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: isThemeSwitchButton ? 30 : 70,
        padding: EdgeInsets.symmetric(
          horizontal: isThemeSwitchButton ? 0 : Dimensions.paddingLarge,
          vertical: isButtonActive != null ? Dimensions.padding2xSmall : Dimensions.paddingDefault,
        ),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: ResponsiveHelper.isDesktop(context) || isThemeSwitchButton ? null : Border.all(color: context.primary.withValues(alpha: 0.1), width: 1.5),
          boxShadow: isThemeSwitchButton ? null : [BoxShadow(color: context.primary.withValues(alpha: 0.05), spreadRadius: 0, blurRadius: 4)],
        ),
        child: Row(children: [
          iconImage != null ? CustomAssetImageWidget(iconImage!, height: 18, width: 25) : Icon(icon, size: isThemeSwitchButton ? 20 : 25, color: color ?? context.textBaseDefault),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Text(title, style: context.subHeading.defaultSize.regular)),

          isButtonActive != null ? CupertinoSwitch(
            value: isButtonActive!,
            activeTrackColor: context.primary,
            onChanged: (bool? value) => onTap(),
            inactiveTrackColor: context.primary.withValues(alpha: 0.5),
          ) : const SizedBox()
        ]),
      ),
    );
  }
}