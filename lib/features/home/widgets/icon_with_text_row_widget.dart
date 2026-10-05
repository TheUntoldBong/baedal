import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class IconWithTextRowWidget extends StatelessWidget {
  const IconWithTextRowWidget({
    super.key, required this.icon, required this.text, required this.style, this.color,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? context.primary, size: 20),
        const SizedBox(width: Dimensions.padding2xSmall),
        Flexible(child: Text(text, style: style, overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false)),
      ],
    );
  }
}



class ImageWithTextRowWidget extends StatelessWidget {
  const ImageWithTextRowWidget({
    super.key, required this.widget, required this.text, required this.style,
  });

  final Widget widget;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget,
        const SizedBox(width: Dimensions.padding2xSmall),
        Flexible(child: Text(text, style: style, overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false)),
      ],
    );
  }
}