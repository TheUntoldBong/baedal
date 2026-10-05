import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class OnHoverWidget extends StatefulWidget {
  final Widget child;
  final bool isItem;
  final bool fromMenu;
  const OnHoverWidget({super.key, required this.child, this.isItem = false, this.fromMenu = false});

  @override
  State<OnHoverWidget> createState() => _OnHoverWidgetState();
}

class _OnHoverWidgetState extends State<OnHoverWidget> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final hoverTransformed = Matrix4.identity()..scaleByDouble(1.05, 1.03, 1.0, 1.0);
    final transform = isHovered ? hoverTransformed : Matrix4.identity();
    final shadow1 = BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      color: widget.fromMenu ? context.primary.withValues(alpha: 0.10) : context.surfaceContainer,
      boxShadow: [
        widget.fromMenu ? const BoxShadow(color: Colors.transparent) :
        BoxShadow(
          color: context.shadow,
          blurRadius: 5,
          offset: Offset(0, 0),
        ),
      ],
    );
    final shadow2 = BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      boxShadow: const [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 0,
          offset: Offset(0, 0),
        )
      ],
    );
    return MouseRegion(
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: widget.isItem ? isHovered ? shadow1 : shadow2 : shadow2,
        transform: widget.isItem ? Matrix4.identity() : transform  ,
        child: widget.child,
      ),
    );
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }
}
