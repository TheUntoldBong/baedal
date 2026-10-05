import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';


class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.icon,
    required this.onPressed,
    this.size = 22,
    this.color,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    this.image,
  });

  final IconData? icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: padding,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: padding,
      ),
      icon: image != null
          ? CustomAssetImageWidget(image!, height: size, width: size, color: color ?? context.textBaseDefault)
          : Icon(icon, size: size, color: color ?? context.textBaseDefault,),
    );
  }
}