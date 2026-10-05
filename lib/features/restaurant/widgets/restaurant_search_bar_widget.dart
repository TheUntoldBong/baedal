import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  const RestaurantSearchBarWidget({
    super.key, required this.controller, required this.hintText,
    required this.onChanged, required this.onSubmitted, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: context.primary.withValues(alpha: 0.3), width: 1),
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        style: context.body.large.regular,
        textInputAction: TextInputAction.search,
        cursorColor: context.primary,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: context.body.large.regular.overrideWith(color: context.textBaseMedium),
          isDense: true,
          filled: true,
          fillColor: context.surfaceContainer,
          contentPadding: const EdgeInsets.all(Dimensions.paddingSmall),
          border: border, enabledBorder: border, focusedBorder: border,
          prefixIcon: Icon(CupertinoIcons.search, size: 20, color: context.textBaseMedium),
          suffixIcon: value.text.isEmpty ? null : IconButton(
            icon: Icon(Icons.clear, size: 20, color: context.textBaseMedium),
            onPressed: onClear,
          ),
        ),
      ),
    );
  }
}
