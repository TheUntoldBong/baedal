import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class PackageWidget extends StatelessWidget {
  final String title;
  final bool isSelect;
  const PackageWidget({super.key, required this.title, this.isSelect = false});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(Icons.check_circle, size: 18, color: isSelect ? context.surfaceContainer : Colors.green),
          const SizedBox(width: Dimensions.paddingSmall),

          Text(title.tr, style: (isDesktop ? context.body.extraSmall : context.body.small).regular.overrideWith(color: isSelect ? context.surfaceContainer
              : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),

        ]),
      ),

      Divider(indent: 20, endIndent: 50, thickness: 1),

    ]);
  }
}
