import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class BogoQuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const BogoQuantityButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        height: 36, width: 36,
        decoration: BoxDecoration(
          border: Border.all(color: context.outline),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Icon(icon, size: 18, color: onTap == null ? context.iconDisabledDefault : context.iconBaseDefault),
      ),
    );
  }
}
