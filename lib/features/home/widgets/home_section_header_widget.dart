import 'package:flutter/material.dart';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeSectionHeaderWidget extends StatelessWidget {
  final String name;
  const HomeSectionHeaderWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Text(name.tr, style: context.heading.large),
    );
  }
}