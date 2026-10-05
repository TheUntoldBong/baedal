import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class CustomStepper extends StatelessWidget {
  final bool isActive;
  final bool haveLeftBar;
  final bool haveRightBar;
  final String title;
  final bool rightActive;
  const CustomStepper({super.key, required this.title, required this.isActive, required this.haveLeftBar, required this.haveRightBar,
    required this.rightActive});

  @override
  Widget build(BuildContext context) {
    Color color = isActive ? context.primary : context.textBaseMedium;
    Color iconColor = isActive ? context.primary : context.iconBaseMedium;

    return Expanded(
      child: Column(children: [

        Row(children: [
          Expanded(child: haveLeftBar ? Divider(color: isActive ? context.primary : null, thickness: 2) : const SizedBox()),
          Padding(
            padding: EdgeInsets.symmetric(vertical: isActive ? 0 : 5),
            child: Icon(isActive ? Icons.check_circle : Icons.blur_circular, color: iconColor, size: isActive ? 25 : 15),
          ),
          Expanded(child: haveRightBar ? Divider(color: rightActive ? context.primary : null, thickness: 2) : const SizedBox()),
        ]),

        Text(
          '$title\n', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          style: context.subHeading.extraSmall.medium.overrideWith(color: color),
        ),

      ]),
    );
  }
}
