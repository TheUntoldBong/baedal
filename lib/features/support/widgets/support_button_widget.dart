import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

class SupportButtonWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? info;
  final Color color;
  final Function onTap;
  const SupportButtonWidget({super.key, required this.icon, required this.title, required this.info, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          color: context.surfaceContainer,
          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: context.subHeading.small.medium.overrideWith(color: color)),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text(info!, style: context.body.defaultSize.regular, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),

        ]),
      ),
    );
  }
}
