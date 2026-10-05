import 'package:flutter/material.dart';


class Gap extends StatelessWidget {
  final double size;
  final Axis? direction;

  const Gap(this.size, {super.key, this.direction});

  const Gap.horizontal(this.size, {super.key}) : direction = Axis.horizontal;

  const Gap.vertical(this.size, {super.key}) : direction = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final effectiveDirection = direction ?? _getParentDirection(context);

    if (effectiveDirection == Axis.horizontal) {
      return SizedBox(width: size);
    } else {
      return SizedBox(height: size);
    }
  }

  Axis _getParentDirection(BuildContext context) {
    final flex = context.findAncestorWidgetOfExactType<Flex>();
    if (flex != null) {
      return flex.direction;
    }
    return Axis.vertical;
  }
}