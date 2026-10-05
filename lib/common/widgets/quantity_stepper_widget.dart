import 'dart:async';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class QuantityStepperWidget extends StatefulWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onAdd;
  final double buttonSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final IconData decrementIcon;
  final IconData incrementIcon;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;
  final Duration collapseAfter;
  final bool collapsible;
  final Color? border;

  const QuantityStepperWidget({super.key,
    required this.quantity, this.onIncrement, this.onDecrement, this.onAdd, this.buttonSize = 36,
    this.backgroundColor, this.iconColor,
    this.iconSize = 18, this.decrementIcon = Icons.remove, this.incrementIcon = Icons.add, this.textStyle,
    this.boxShadow, this.collapseAfter = const Duration(seconds: 3), this.collapsible = false, this.border,
  });

  @override
  State<QuantityStepperWidget> createState() => _QuantityStepperWidgetState();
}

class _QuantityStepperWidgetState extends State<QuantityStepperWidget> {
  bool _expanded = false;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.collapsible || widget.quantity > 0;
  }

  @override
  void didUpdateWidget(covariant QuantityStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collapsible && oldWidget.quantity == 0 && widget.quantity > 0) {
      _expand();
    }
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _restartCollapseTimer() {
    if (!widget.collapsible) return;
    _collapseTimer?.cancel();
    _collapseTimer = Timer(widget.collapseAfter, () {
      if (mounted) setState(() => _expanded = false);
    });
  }

  void _expand() {
    if (!widget.collapsible) return;
    setState(() => _expanded = true);
    _restartCollapseTimer();
  }

  void _handleStep(VoidCallback? action) {
    if (action == null) return;
    action();
    if (widget.collapsible) {
      _restartCollapseTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = widget.textStyle ?? context.subHeading.small;

    final BoxDecoration decoration = BoxDecoration(
      color: widget.backgroundColor ?? context.surfaceContainer,
      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      boxShadow: widget.boxShadow ?? [BoxShadow(color: context.shadow, blurRadius: 10, offset: Offset(0, 3))],
      border: Border.all(color: widget.border ?? context.outline)
    );

    if (widget.quantity <= 0 && widget.onAdd != null) {
      return InkWell(
        onTap: widget.onAdd,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        child: AddSquareButton(size: widget.buttonSize, decoration: decoration,),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.centerRight,
      child: (widget.collapsible && !_expanded) ? InkWell(
        onTap: _expand,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        child: Container(
          height: widget.buttonSize,
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: widget.buttonSize),
          child: Text(widget.quantity.toString(), style: textStyle),
        ),
      ) : Container(
        height: widget.buttonSize,
        decoration: decoration,
        child: Row(mainAxisSize: MainAxisSize.min, children: [

          _StepIconButton(
            icon: widget.decrementIcon,
            iconColor: widget.iconColor,
            iconSize: widget.iconSize,
            onTap: widget.onDecrement == null ? null : () => _handleStep(widget.onDecrement),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
            child: Text(widget.quantity.toString(), style: textStyle),
          ),

          _StepIconButton(
            icon: widget.incrementIcon,
            iconColor: widget.iconColor,
            iconSize: widget.iconSize,
            onTap: widget.onIncrement == null ? null : () => _handleStep(widget.onIncrement),
          ),

        ]),
      ),
    );
  }
}

class _StepIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;
  const _StepIconButton({required this.icon, this.onTap, this.iconColor, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
        child: Icon(icon, size: iconSize, color: iconColor ?? context.iconBaseDefault),
      ),
    );
  }
}


class AddSquareButton extends StatelessWidget {
  final double size;
  final BoxDecoration decoration;

  const AddSquareButton({super.key, required this.size, required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
      alignment: Alignment.center,
      decoration: decoration,
      child: Icon(Icons.add, size: 24, color: context.iconBaseDefault),
    );
  }
}