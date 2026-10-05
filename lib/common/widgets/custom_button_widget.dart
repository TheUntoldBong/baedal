import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  final bool takeMinimumWidth;
  final String? disabledMessage;
  final Color? disabledColor;
  const CustomButtonWidget({super.key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.radius = 10, this.icon, this.color, this.textColor, this.isLoading = false, this.isBold = true, this.takeMinimumWidth = false, this.padding,
    this.disabledMessage, this.disabledColor});

  @override
  Widget build(BuildContext context) {
    final bool showDisabledMessage = onPressed == null && disabledMessage != null && disabledMessage!.isNotEmpty;

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null ? disabledColor ?? context.surfaceContainerLowest : transparent
          ? Colors.transparent : color ?? context.primary,
      minimumSize: Size(takeMinimumWidth ? 0 : (width != null ? width! : Dimensions.webMaxWidth), height != null ? height! : 40),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      textStyle: (isBold ? context.heading.defaultSize.strong : context.heading.defaultSize.regular).copyWith(fontSize: fontSize),
    );

    return Center(child: SizedBox(width: takeMinimumWidth ? null : (width ?? Dimensions.webMaxWidth), height: height, child: Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: TextButton(
        onPressed: isLoading ? null : showDisabledMessage ? () => showCustomSnackBar(disabledMessage) : onPressed as void Function()?,
        style: flatButtonStyle,
        child: Padding(padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        child: isLoading ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: takeMinimumWidth ? MainAxisSize.min : MainAxisSize.max, children: [
          SizedBox(
            height: 15, width: 15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.onPrimary),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          Text('loading'.tr, style: context.heading.defaultSize.medium.overrideWith(color: context.onPrimary)),
        ]),
        ) : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: takeMinimumWidth ? MainAxisSize.min : MainAxisSize.max, children: [
          icon != null ? Padding(
            padding: const EdgeInsets.only(right: Dimensions.padding2xSmall),
            child: Icon(icon, color: transparent ? context.primary : context.onPrimary),
          ) : const SizedBox(),
          Flexible(
            child: Text(buttonText, maxLines: 1, textAlign: TextAlign.center,  style: isBold ? context.heading.defaultSize.strong.overrideWith(
              color: textColor ?? (transparent ? context.primary : onPressed == null ? context.onSurface : context.onPrimary),
            ).copyWith(fontSize: fontSize) : context.heading.defaultSize.regular.overrideWith(
              color: textColor ?? (transparent ? context.primary : onPressed == null ? context.onSurface : context.onPrimary),
            ).copyWith(fontSize: fontSize)
            ),
          ),
        ]),)
      ),
    )));
  }
}
