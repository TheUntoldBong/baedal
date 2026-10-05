import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BottomNavItem extends StatefulWidget {
  final Widget icon;
  final Function? onTap;
  final bool isSelected;
  final String title;
  final bool isCart;
  const BottomNavItem({
    super.key,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    required this.title,
    this.isCart = false,
  });

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 55,
      ),
    ]).animate(_controller);

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSelected && widget.isSelected) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap == null ? null : _handleTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with subtle animated bounce
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                        child: child,
                      ),
                      child: widget.icon,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Minimal clean title
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: widget.isSelected
                      ? context.subHeading.small.strong.overrideWith(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 10.5, letterSpacing: -0.1)
                      : context.subHeading.small.overrideWith(
                          color: context.textBaseLight,
                          fontWeight: FontWeight.w500,
                        ).copyWith(fontSize: 10.5, letterSpacing: -0.1),
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),

                // Minimal refined micro-pill indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: widget.isSelected ? 12 : 0,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
