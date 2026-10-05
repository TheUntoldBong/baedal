import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DateWheelPicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final bool showPreviousDay;
  final ValueChanged<DateTime>? onDateChanged;
  final double itemExtent;
  final int visibleItemCount;
  final Color? fadeColor;

  const DateWheelPicker({super.key, required this.firstDate, this.initialDate, this.lastDate, this.showPreviousDay = true,
    this.onDateChanged, this.itemExtent = 44, this.visibleItemCount = 3, this.fadeColor,
  }) : assert(visibleItemCount % 2 == 1, 'visibleItemCount must be odd');

  @override
  State<DateWheelPicker> createState() => _DateWheelPickerState();
}

class _DateWheelPickerState extends State<DateWheelPicker> {
  late FixedExtentScrollController _controller;
  late DateTime _displayStart;

  int get _minIndex => widget.showPreviousDay ? 1 : 0;

  int? get _maxIndex => widget.lastDate == null ? null : _dateOnly(widget.lastDate!).difference(_displayStart).inDays;

  @override
  void initState() {
    super.initState();
    DateTime first = _dateOnly(widget.firstDate);
    _displayStart = widget.showPreviousDay ? first.subtract(const Duration(days: 1)) : first;

    int initialIndex = _minIndex;
    if(widget.initialDate != null) {
      initialIndex = _dateOnly(widget.initialDate!).difference(_displayStart).inDays;
      initialIndex = initialIndex.clamp(_minIndex, _maxIndex ?? initialIndex);
    }
    _controller = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _dateAt(int index) => _displayStart.add(Duration(days: index));

  String _labelFor(DateTime date) {
    DateTime today = _dateOnly(DateTime.now());
    if(date == today.subtract(const Duration(days: 1))) {
      return 'yesterday'.tr;
    }
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  void _onScrollEnd() {
    if(!_controller.hasClients) {
      return;
    }
    if(_controller.selectedItem < _minIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted && _controller.hasClients) {
          _controller.animateToItem(_minIndex, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = widget.itemExtent * widget.visibleItemCount;
    Color activeColor = Theme.of(context).textTheme.bodyLarge!.color!;
    Color inactiveColor = context.textBaseMedium;
    Color surfaceColor = widget.fadeColor ?? Color.alphaBlend(
      context.surfaceContainer,
      context.surfaceContainer,
    );

    return SizedBox(height: height,
      child: Stack(children: [
        NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            _onScrollEnd();
            return false;
          },
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: widget.itemExtent,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 10,
            perspective: 0.0001,
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              if(index >= _minIndex) {
                widget.onDateChanged?.call(_dateAt(index));
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if(index < 0 || (_maxIndex != null && index > _maxIndex!)) {
                  return null;
                }
                return _DateWheelItem(
                  controller: _controller,
                  index: index,
                  itemExtent: widget.itemExtent,
                  label: _labelFor(_dateAt(index)),
                  selectable: index >= _minIndex,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                );
              },
            ),
          ),
        ),

        Positioned(
          top: 0, left: 0, right: 0,
          child: IgnorePointer(
            child: Container(
              height: widget.itemExtent,
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [surfaceColor, surfaceColor.withValues(alpha: 0)],
              )),
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: IgnorePointer(
            child: Container(
              height: widget.itemExtent,
            ),
          ),
        ),
      ]),
    );
  }
}

class _DateWheelItem extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int index;
  final double itemExtent;
  final String label;
  final bool selectable;
  final Color activeColor;
  final Color inactiveColor;

  const _DateWheelItem({required this.controller, required this.index, required this.itemExtent, required this.label,
    required this.selectable, required this.activeColor, required this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double centerPosition = controller.hasClients && controller.position.hasContentDimensions
            ? controller.offset / itemExtent : controller.initialItem.toDouble();
        
        double distance = (index - centerPosition).abs().clamp(0.0, 1.0);
        bool isCenter = distance < 0.5;

        return Transform.scale(
          scale: 1 - (1 - Dimensions.fontSizeDefault / Dimensions.fontSizeExtraLarge) * distance,
          child: Center(child: Text(
            label,
            style: (isCenter && selectable ? context.subHeading.defaultSize.strong : context.subHeading.defaultSize).overrideWith(
              color: selectable ? Color.lerp(activeColor, inactiveColor, distance) : inactiveColor.withValues(alpha: 0.6),
            ),
          )),
        );
      },
    );
  }
}