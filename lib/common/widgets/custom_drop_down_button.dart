import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomDropdownButton<T> extends StatefulWidget {
  final List<String>? items;
  final bool showTitle;
  final bool isBorder;
  final String? hintText;
  final double? borderRadius;
  final Color? backgroundColor;
  final Function(T?)? onChanged;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final FontWeight? titleFontWeight;
  final T? selectedValue;
  final List<DropdownMenuItem<T>>? dropdownMenuItems;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final Widget? prefixIcon;

  const CustomDropdownButton({super.key, this.items, this.showTitle = true, this.isBorder = true, this.hintText, this.borderRadius,
    this.backgroundColor, this.onChanged, this.validator, this.onSaved, this.titleFontWeight, this.selectedValue,
    this.dropdownMenuItems, this.selectedItemBuilder, this.prefixIcon});

  @override
  State<CustomDropdownButton<T>> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  late final ValueNotifier<T?> _valueNotifier = ValueNotifier<T?>(widget.selectedValue);

  @override
  void didUpdateWidget(covariant CustomDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _valueNotifier.value = widget.selectedValue;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownItem<T>>? convertedItems = widget.dropdownMenuItems
        ?.map((e) => DropdownItem<T>(value: e.value, child: e.child))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.surfaceContainer,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? Dimensions.radiusDefault),
      ),
      child: DropdownButtonFormField2<T>(
        isExpanded: true,
        decoration: InputDecoration(
          prefix: Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 5),
            child: widget.prefixIcon,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          focusedBorder: _border(),
          enabledBorder: _border(),
          disabledBorder: _border(),
          focusedErrorBorder: _border(),
          errorBorder: _border(),
        ),
        hint: Text(widget.hintText ?? 'select_an_option'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
        valueListenable: _valueNotifier,
        items: (convertedItems ?? widget.items?.map((item) => DropdownItem<T>(
          value: item as T,
          child: Text(item.tr, style: context.body.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
        )).toList()) ?? [
          DropdownItem<T>(
            value: null,
            child: Text('no_data_available'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            ),
          )
        ],
        validator: widget.validator ?? (value) {
          if (value == null) {
            return 'please_select_an_option'.tr;
          }
          return null;
        },
        onChanged: (value) {
          _valueNotifier.value = value;
          widget.onChanged?.call(value);
        },
        onSaved: widget.onSaved,
        selectedItemBuilder: widget.selectedItemBuilder,
        buttonStyleData: const FormFieldButtonStyleData(padding: EdgeInsets.only(right: 8)),
        iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down, color: context.iconBaseMedium)),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: widget.prefixIcon != null ? 0 : 5)),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? Dimensions.radiusDefault)),
      borderSide: BorderSide(width: 1, color: widget.isBorder ? context.outline : Colors.transparent),
    );
  }
}