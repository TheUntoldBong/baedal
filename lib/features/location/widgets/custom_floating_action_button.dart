import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final String heroTag;
  final Function() onTap;
  final Color? iconColor;
  final double? iconSize;
  const CustomFloatingActionButton({super.key, required this.icon, required this.heroTag, required this.onTap, this.iconColor, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(width: 35, height: 35,
      decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(8)),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(icon, size: iconSize ?? 25, color: iconColor ?? Colors.black),
      ),
    );
  }
}
