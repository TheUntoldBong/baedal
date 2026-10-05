
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SectionWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.heading.large.strong, maxLines: 1, overflow: TextOverflow.ellipsis,),
          SizedBox(height: Dimensions.paddingSmall),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              color: context.surfaceContainer,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
