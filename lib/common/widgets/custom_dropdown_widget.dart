import 'package:flutter/material.dart';


class CustomDropdown<T> extends StatefulWidget {
  final Widget child;

  final void Function(T, int)? onChange;

  final List<DropdownItem<T>> items;
  final DropdownStyle dropdownStyle;

  final DropdownButtonStyle dropdownButtonStyle;

  final Icon? icon;
  final bool hideIcon;
  final Color? iconColor;

  final bool leadingIcon;
  final bool canAddValue;
  final bool indexZeroNotSelected;

  /// When provided the selection is owned by the caller, so a change made
  /// outside the dropdown stays reflected on the button.
  final int? selectedIndex;
  const CustomDropdown({
    super.key,
    this.hideIcon = false,
    required this.child,
    required this.items,
    this.dropdownStyle = const DropdownStyle(),
    this.dropdownButtonStyle = const DropdownButtonStyle(),
    this.icon,
    this.leadingIcon = false,
    this.onChange,
    this.canAddValue = true,
    this.indexZeroNotSelected = false,
    this.iconColor = Colors.black,
    this.selectedIndex,
  });

  @override
  CustomDropdownState<T> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T?>>
    with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late OverlayEntry _overlayEntry;
  bool _isOpen = false;
  int _currentIndex = -1;
  AnimationController? _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex ?? -1;

    _animationController?.dispose();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant CustomDropdown<T?> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.selectedIndex != null && widget.selectedIndex != _currentIndex) {
      _currentIndex = widget.selectedIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.dropdownButtonStyle;
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: style.width,
        height: style.height,
        child: InkWell(
          onTap: toggleDropdown,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: style.mainAxisAlignment ?? MainAxisAlignment.center,
              textDirection: widget.leadingIcon ? TextDirection.rtl : TextDirection.ltr,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (_currentIndex == -1 || _currentIndex >= widget.items.length) ...[
                  Expanded(child: widget.child),
                ] else ...[
                  Expanded(child: widget.items[_currentIndex]),
                ],
                if (!widget.hideIcon)
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: widget.icon ?? Icon(Icons.expand_more, color: widget.iconColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    var offset = renderBox.localToGlobal(Offset.zero);
    var topOffset = offset.dy + size.height + 5;
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => toggleDropdown(close: true),
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: topOffset,
                width: widget.dropdownStyle.width ?? size.width,
                child: CompositedTransformFollower(
                  offset: widget.dropdownStyle.offset ?? Offset(0, size.height + 5),
                  link: _layerLink,
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: widget.dropdownStyle.elevation ?? 0,
                    borderRadius: widget.dropdownStyle.borderRadius ?? BorderRadius.zero,
                    color: widget.dropdownStyle.color,
                    child: SizeTransition(
                      axisAlignment: 1,
                      sizeFactor: _expandAnimation,
                      child: ConstrainedBox(
                        constraints: widget.dropdownStyle.constraints ??
                            BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height -
                                  topOffset -
                                  15,
                            ),
                        child: ListView(
                          padding: widget.dropdownStyle.padding ?? EdgeInsets.zero,
                          shrinkWrap: true,
                          children: widget.items.asMap().entries.map((item) {
                            return InkWell(
                              onTap: () {
                                if(widget.indexZeroNotSelected) {
                                  if(item.key != 0) {
                                    setState(() => _currentIndex = item.key);
                                    widget.onChange!(item.value.value, item.key);
                                    toggleDropdown();
                                  }
                                } else {
                                  if(widget.canAddValue) {
                                    setState(() => _currentIndex = item.key);
                                  }
                                  widget.onChange!(item.value.value, item.key);
                                  toggleDropdown();
                                }
                              },
                              child: item.value,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleDropdown({bool close = false}) async {
    if (_isOpen || close) {
      await _animationController!.reverse();
      _overlayEntry.remove();
      setState(() {
        _isOpen = false;
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() => _isOpen = true);
      _animationController!.forward();
    }
  }
}

class DropdownItem<T> extends StatelessWidget {
  final T? value;
  final Widget? child;

  const DropdownItem({super.key, this.value, this.child});
  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

class DropdownButtonStyle {
  final MainAxisAlignment? mainAxisAlignment;
  final ShapeBorder? shape;
  final double? elevation;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Color? primaryColor;
  const DropdownButtonStyle({
    this.mainAxisAlignment,
    this.backgroundColor,
    this.primaryColor,
    this.constraints,
    this.height,
    this.width,
    this.elevation,
    this.padding,
    this.shape,
  });
}

class DropdownStyle {
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? color;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  final Offset? offset;

  final double? width;

  const DropdownStyle({
    this.constraints,
    this.offset,
    this.width,
    this.elevation,
    this.color,
    this.padding,
    this.borderRadius,
  });
}