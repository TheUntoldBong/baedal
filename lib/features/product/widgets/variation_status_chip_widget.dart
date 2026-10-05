import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class VariationStatusChipWidget extends StatefulWidget {
  final String chipText;
  final Color chipColor;
  final Color chipTextColor;
  final bool emphasised;
  const VariationStatusChipWidget({super.key,
    required this.chipText, required this.chipColor, required this.chipTextColor, this.emphasised = false,
  });

  @override
  State<VariationStatusChipWidget> createState() => _VariationStatusChipWidgetState();
}

class _VariationStatusChipWidgetState extends State<VariationStatusChipWidget> with SingleTickerProviderStateMixin {
  static const Color _emphasisColor = Color(0xFFE0483D);

  late final AnimationController _controller;
  late final Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bgOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.emphasised) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant VariationStatusChipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emphasised && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.emphasised && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chipText.isEmpty) return const SizedBox();

    final Color textColor = widget.emphasised ? Colors.white : widget.chipTextColor;

    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
      child: AnimatedBuilder(
        animation: _bgOpacity,
        builder: (context, child) {
          final Color background = widget.emphasised
              ? _emphasisColor.withValues(alpha: _bgOpacity.value)
              : widget.chipColor;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall + 2, vertical: 5),
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(30)),
            child: child,
          );
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.chipText, style: context.body.small.medium.overrideWith(color: textColor)),
        ]),
      ),
    );
  }
}
