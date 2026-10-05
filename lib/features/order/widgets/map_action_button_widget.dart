import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';

class MapActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const MapActionButtonWidget({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Icon(icon, color: context.primary, size: 25),
      ),
    );
  }
}
