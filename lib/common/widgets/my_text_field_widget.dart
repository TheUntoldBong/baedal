import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class MyTextFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  final bool isPassword;
  final Function? onTap;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final Color? fillColor;
  final bool autoFocus;
  final bool showBorder;

  const MyTextFieldWidget({
    super.key,
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
    this.capitalization = TextCapitalization.none,
    this.onTap,
    this.fillColor,
    this.isPassword = false,
    this.autoFocus = false,
    this.showBorder = false,
    });

  @override
  MyTextFieldWidgetState createState() => MyTextFieldWidgetState();
}

class MyTextFieldWidgetState extends State<MyTextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), border: widget.showBorder ? Border.all(color: context.outline) : null),
      child: TextField(
        key: widget.key,
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: context.subHeading.defaultSize.regular,
        textInputAction: widget.inputAction,
        keyboardType: widget.inputType,
        cursorColor: context.primary,
        textCapitalization: widget.capitalization,
        enabled: widget.isEnabled,
        autofocus: widget.autoFocus,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))] : null,
        decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
          filled: true,
          fillColor: widget.fillColor ?? context.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), borderSide: BorderSide.none),
          hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
          suffixIcon: widget.isPassword ? IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: context.textBaseLight),
            onPressed: _toggle,
          ) : null,
        ),
        onTap: widget.onTap as void Function()?,
        onSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
            : widget.onSubmit != null ? widget.onSubmit!(text) : null,
        onChanged: widget.onChanged as void Function(String)?,
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
