import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor/common/widgets/code_picker_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomTextFieldWithTitle extends StatefulWidget {
  final String titleText;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final String? prefixImage;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double prefixSize;
  final TextAlign textAlign;
  final bool isAmount;
  final bool isNumber;
  final bool showTitle;
  final bool showBorder;
  final double iconSize;
  final bool isPhone;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final bool showLabelText;
  final bool required;
  final String? labelText;
  final String? Function(String?)? validator;
  final double? labelTextSize;
  final Widget? suffixChild;
  final String? suffixImage;
  final Function()? suffixOnPressed;
  final bool divider;
  final bool fromUpdateProfile;
  final bool fromLogin;

  const CustomTextFieldWithTitle({
    super.key,
    this.titleText = 'Write something...',
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixImage,
    this.prefixIcon,
    this.suffixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.prefixSize = Dimensions.paddingSmall,
    this.textAlign = TextAlign.start,
    this.isAmount = false,
    this.isNumber = false,
    this.showTitle = false,
    this.showBorder = true,
    this.iconSize = 18,
    this.isPhone = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.showLabelText = true,
    this.required = false,
    this.labelText,
    this.validator,
    this.labelTextSize,
    this.suffixChild,
    this.suffixOnPressed,
    this.suffixImage,
    this.divider = false,
    this.fromUpdateProfile = false, this.fromLogin = false,
  });

  @override
  CustomTextFieldWithTitleState createState() => CustomTextFieldWithTitleState();
}

class CustomTextFieldWithTitleState extends State<CustomTextFieldWithTitle> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        widget.showTitle ? RichText(
          text:TextSpan(children: [
            TextSpan(text: widget.titleText, style: context.subHeading.defaultSize.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
            widget.required && !widget.fromLogin ? TextSpan(text: ' *', style: context.body.large.regular.overrideWith(color: Theme.of(context).colorScheme.error)) : const TextSpan(),
          ]),
        ) : const SizedBox(),
        SizedBox(height: widget.showTitle ? Dimensions.padding2xSmall : 0),

        TextFormField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: widget.textAlign,
          validator: widget.validator,
          style: context.body.defaultSize.overrideWith(color: context.textBaseDefault),
          textInputAction: widget.inputAction,
          keyboardType: widget.isAmount ? TextInputType.number : widget.inputType,
          cursorColor: context.primary,
          cursorHeight: 20,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9]'))]
              : widget.isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : widget.isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))] : null,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: ResponsiveHelper.isDesktop(context) ? 0.7 : 0.3, color: context.textBaseMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: 1, color: context.textBaseMedium),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, width: 0.3, color: context.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, color: Theme.of(context).colorScheme.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(style: widget.showBorder ? BorderStyle.solid : BorderStyle.none, color: context.outlineVariant),
            ),
            isDense: true,
            hintText: widget.hintText.isNotEmpty ? widget.hintText : '',
            fillColor: context.surfaceContainer,
            hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            filled: true,

            labelStyle : widget.showLabelText ? context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium) : null,
            errorStyle: context.body.small.regular,

            label: widget.showLabelText ? Text.rich(TextSpan(children: [

              TextSpan(
                text: widget.labelText ?? '',
                style: context.body.large.regular.overrideWith(
                  color: ((widget.focusNode?.hasFocus == true || widget.controller!.text.isNotEmpty ) &&  widget.isEnabled) ? Theme.of(context).textTheme.bodyLarge?.color :  context.textBaseLight,
                ).copyWith(fontSize: widget.labelTextSize),
              ),

              if(widget.required && widget.labelText != null)
                TextSpan(text : ' *', style: context.body.large.regular.overrideWith(color: Theme.of(context).colorScheme.error)),

              if(widget.isEnabled == false)
                TextSpan(text: widget.fromUpdateProfile ? ' (${'non_changeable'.tr})' : ' (${'non_changeable'.tr})', style: context.body.large.regular.overrideWith(color: Theme.of(context).colorScheme.error)),

            ])) : null,

            prefixIcon: (widget.isPhone || widget.countryDialCode != null) ? SizedBox(width: 95, child: Row(children: [
              Container(
                width: 85, height: 40,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusExtraSmall),
                    bottomLeft: Radius.circular(Dimensions.radiusExtraSmall),
                  ),
                ),
                margin: const EdgeInsets.only(right: 0),
                padding: const EdgeInsets.only(left: 5),
                child: Center(
                  child: CodePickerWidget(
                    flagWidth: 25,
                    padding: EdgeInsets.zero,
                    onChanged: widget.onCountryChanged,
                    initialSelection: widget.countryDialCode,
                    favorite: [widget.countryDialCode ?? ''],
                    enabled: Get.find<SplashController>().configModel?.countryPickerStatus,
                    dialogBackgroundColor: context.surfaceContainer,
                    textStyle: context.body.defaultSize.regular.overrideWith(
                      color: context.textBaseDefault,
                    ),
                  ),
                ),
              ),

              Container(
                height: 20, width: 2,
                color: context.surfaceContainerHigh
              )
            ]),
            ) : widget.prefixImage != null && widget.prefixIcon == null ? Padding(
              padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSmall : Dimensions.paddingDefault),
              child: CustomAssetImageWidget(widget.prefixImage!, height: 10, width: 10, fit: BoxFit.cover, color:  context.iconBaseMedium),
            ) : widget.prefixImage == null && widget.prefixIcon != null ? Icon(widget.prefixIcon, size: widget.iconSize, color: context.iconBaseMedium) : null,

            suffixIcon: widget.isPassword ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: context.textBaseMedium),
              onPressed: _toggle,
            ) : widget.suffixImage != null ? InkWell(
                onTap: widget.suffixOnPressed, child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSmall : Dimensions.paddingDefault),
              child: CustomAssetImageWidget(widget.suffixImage!, height: 10, width: 10, fit: BoxFit.cover),
            )) : widget.suffixChild,
          ),
          onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : widget.onSubmit != null ? widget.onSubmit!(text) : null,
          onChanged: widget.onChanged as void Function(String)?,
        ),

        widget.divider ? const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge), child: Divider()) : const SizedBox(),

      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
