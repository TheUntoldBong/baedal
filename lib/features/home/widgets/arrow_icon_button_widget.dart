import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class ArrowIconButtonWidget extends StatelessWidget {
  const ArrowIconButtonWidget({super.key, this.onTap, this.isLeft});

  final void Function()? onTap;
  final bool? isLeft;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: ResponsiveHelper.isMobile(context) ? 30 : 40, width: ResponsiveHelper.isMobile(context) ? 30 : 40,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          shape: BoxShape.circle,
          border: Border.all(color: context.primary.withValues(alpha: 0.3), width: 2),
        ),
        child: Icon(
          isLeft == true ? Icons.arrow_back : Icons.arrow_forward,  size: 20,
          color: context.primary,
        ),
      ),
    );
  }
}
