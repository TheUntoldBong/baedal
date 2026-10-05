import 'package:flutter/material.dart';


class CustomInkWellWidget extends StatefulWidget {
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? highlightColor;
  final Color? splashColor;
  final bool enableRippleEffect;
  final bool enableScaleEffect;
  const CustomInkWellWidget({
    super.key, this.radius, required this.child, required this.onTap, this.onLongPress, this.highlightColor,
    this.padding = EdgeInsets.zero, this.splashColor, this.enableRippleEffect = true, this.enableScaleEffect = true,
  });

  @override
  State<CustomInkWellWidget> createState() => _CustomInkWellWidgetState();
}

class _CustomInkWellWidgetState extends State<CustomInkWellWidget> with SingleTickerProviderStateMixin {
  static const double _pressedScale = 0.93;
  static const Duration _pressDuration = Duration(milliseconds: 200);
  static const Duration _releaseDuration = Duration(milliseconds: 320);
  static const Duration _tapDelay = Duration(milliseconds: 100);

  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _pressDuration,
      reverseDuration: _releaseDuration,
    );
    _scale = Tween<double>(begin: 1.0, end: _pressedScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() => Future.delayed(_tapDelay, () => widget.onTap());

  Widget _buildChild() {
    Widget child = Padding(
      padding: widget.padding!,
      child: widget.child,
    );
    if (widget.enableScaleEffect) {
      child = ScaleTransition(scale: _scale, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableRippleEffect) {
      final BorderRadius borderRadius = BorderRadius.circular(widget.radius ?? 0.0);

      return Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: _handleTap,
          onLongPress: widget.onLongPress,
          onHighlightChanged: widget.enableScaleEffect
              ? (pressed) => pressed ? _controller.forward() : _controller.reverse()
              : null,
          borderRadius: borderRadius,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: _buildChild(),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enableScaleEffect ? (_) => _controller.forward() : null,
      onTapUp: widget.enableScaleEffect ? (_) => _controller.reverse() : null,
      onTapCancel: widget.enableScaleEffect ? () => _controller.reverse() : null,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: _buildChild(),
    );
  }
}
