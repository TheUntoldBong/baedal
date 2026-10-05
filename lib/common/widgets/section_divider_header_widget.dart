import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SectionDividerHeaderWidget extends StatelessWidget {
  final String? title;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const SectionDividerHeaderWidget({super.key, this.title, this.child, this.padding})
      : assert(title != null || child != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
          horizontal: Dimensions.paddingLarge,
          vertical: Dimensions.paddingSmall,
        ),
      child: Row(children: [
        const Expanded(child: _SectionDivider(pointToStart: false)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: child ??
              Text(
                title!.tr,
                style: context.heading.extraLarge.strong,
              ),
        ),
        const Expanded(child: _SectionDivider(pointToStart: true)),
      ]),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final bool pointToStart;
  const _SectionDivider({required this.pointToStart});

  @override
  Widget build(BuildContext context) {
    final Color color = context.outlineVariant;

    return SizedBox(
      height: 3,
      child: Center(
        child: Container(
          height: 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: pointToStart ? Alignment.centerRight : Alignment.centerLeft,
              end: pointToStart ? Alignment.centerLeft : Alignment.centerRight,
              colors: [color.withAlpha(10), color],
            ),
          ),
        ),
      ),
    );
  }
}
