import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool showRemoveIcon;
  final Color? color;
  const QuantityButton({super.key, required this.isIncrement, required this.onTap, this.showRemoveIcon = false, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: 22, width: 22,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: showRemoveIcon ? Colors.transparent : isIncrement ? context.primary : context.outline),
          color: showRemoveIcon ? context.surfaceContainer : isIncrement ? color ?? context.primary : context.bgNeutralLight,
        ),
        alignment: Alignment.center,
        child: Icon(
          showRemoveIcon ? CupertinoIcons.trash : isIncrement ? Icons.add : Icons.remove,
          size: 20,
          color: showRemoveIcon ? Theme.of(context).colorScheme.error : isIncrement ? context.surfaceContainer : context.iconBaseMedium,
        ),
      ),
    );
  }
}