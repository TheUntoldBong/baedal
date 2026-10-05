import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class ChatSearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData suffixIcon;
  final Function iconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  final Function()? onTap;
  const ChatSearchFieldWidget({super.key, required this.controller, required this.hint, required this.suffixIcon, required this.iconPressed,
    this.onSubmit, this.onChanged, this.onTap});

  @override
  State<ChatSearchFieldWidget> createState() => _ChatSearchFieldWidgetState();
}

class _ChatSearchFieldWidgetState extends State<ChatSearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onTap: widget.onTap,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraSmall : 60),
          borderSide: BorderSide(width: 1, color: context.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraSmall : 60),
          borderSide: BorderSide(width: 1, color: context.primary.withValues(alpha: 0.3)),
        ),
        hintText: widget.hint,
        hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraSmall : 60),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: context.surfaceContainer,
        contentPadding: const EdgeInsets.all(Dimensions.paddingDefault),
        suffixIcon: IconButton(
          onPressed: widget.iconPressed as void Function()?,
          icon: Icon(widget.suffixIcon, color: context.iconDisabledDefault, size: 25),
        ),
      ),
      onSubmitted: widget.onSubmit as void Function(String)?,
      onChanged: widget.onChanged as void Function(String)?,
    );
  }
}
