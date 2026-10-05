import 'package:stackfood_multivendor/helper/delivery_time_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderStatusHistorySheet extends StatelessWidget {
  final OrderModel order;

  const OrderStatusHistorySheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _buildVisibleSteps(order);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingDefault,
            Dimensions.paddingSmall,
            Dimensions.paddingDefault,
            Dimensions.paddingLarge,
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                  decoration: BoxDecoration(
                    color: context.bgNeutralMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(children: [
                Expanded(
                  child: Text(
                    'order_history'.tr,
                    style: context.heading.large.strong,
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingLarge),

              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (int i = 0; i < steps.length; i++)
                      _StatusHistoryStep(
                        step: steps[i],
                        isLast: i == steps.length - 1,
                        lineActive: i < steps.length - 1 && steps[i + 1].reached,
                      ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          right: Dimensions.paddingMedium,
          top: Dimensions.paddingMedium,
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.bgNeutralLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ),
      ],
    );
  }

  List<_HistoryStep> _buildVisibleSteps(OrderModel order) {
    String? ts(String? v) => (v != null && v.trim().isNotEmpty) ? v : null;

    final List<_HistoryStep> forward = [
      _HistoryStep(label: 'order_placed'.tr, description: 'order_place_successfully'.tr, timestamp: ts(order.pending) ?? ts(order.createdAt)),
      _HistoryStep(label: 'order_accepted'.tr, description: 'we_have_accepted_your_order'.tr, timestamp: ts(order.accepted) ?? ts(order.confirmed)),
      _HistoryStep(label: 'processing_item'.tr, description: 'your_item_are_processing'.tr, timestamp: ts(order.processing)),
      _HistoryStep(label: 'order_handover'.tr, description: 'rider_has_picked_up_your_order'.tr, timestamp: ts(order.handover)),
      _HistoryStep(label: 'picked_up'.tr, description: 'rider_now_delivering_your_order'.tr, timestamp: ts(order.pickedUp)),
      _HistoryStep(label: 'delivered'.tr, description: 'order_delivered'.tr, timestamp: ts(order.delivered), isDelivered: true),
    ];

    final _HistoryStep? terminal = _terminalStep(order, ts);
    if (terminal != null) {
      return [
        ...forward.where((s) => s.isCompleted).map((s) => s.copyWith(reached: true)),
        terminal.copyWith(reached: true),
      ];
    }

    int lastReached = -1;
    for (int i = 0; i < forward.length; i++) {
      if (forward[i].isCompleted) lastReached = i;
    }
    final bool delivered = forward.last.isCompleted;

    for (int i = 0; i < forward.length; i++) {
      final bool reached = i <= lastReached;
      final bool isCurrent = !delivered && i == lastReached && !forward[i].isDelivered;
      forward[i] = forward[i].copyWith(reached: reached, isCurrent: isCurrent);
    }

    if (!delivered && order.orderType != 'dine_in') {
      final String? range = _estimatedRange(order);
      if (range != null) {
        forward[forward.length - 1] = forward.last.copyWith(estimatedTime: range);
      }
    }

    return forward;
  }

  _HistoryStep? _terminalStep(OrderModel order, String? Function(String?) ts) {
    if (ts(order.canceled) != null) {
      return _HistoryStep(label: 'cancelled'.tr, description: 'order_was_cancelled'.tr, timestamp: ts(order.canceled), isTerminal: true);
    }
    if (ts(order.refunded) != null) {
      return _HistoryStep(label: 'refunded'.tr, description: 'refund_completed'.tr, timestamp: ts(order.refunded), isTerminal: true);
    }
    if (ts(order.refundRequested) != null) {
      return _HistoryStep(label: 'refund_requested'.tr, description: 'refund_requested_description'.tr, timestamp: ts(order.refundRequested), isTerminal: true);
    }
    final String? failedTs = ts(order.failed) ?? (order.orderStatus == 'failed' ? ts(order.updatedAt) : null);
    if (failedTs != null) {
      return _HistoryStep(label: 'failed'.tr, description: 'payment_failed_description'.tr, timestamp: failedTs, isTerminal: true);
    }
    return null;
  }

  String? _estimatedRange(OrderModel order) {
    if (order.eta?.fromAt != null && order.eta?.toAt != null) {
      try {
        final DateTime fromAt = DateTime.parse(order.eta!.fromAt!).toLocal();
        final DateTime toAt = DateTime.parse(order.eta!.toAt!).toLocal();
        final DateTime now = DateTime.now();

        if (!toAt.isBefore(now.subtract(const Duration(minutes: 2)))) {
          return DateConverter.timeRange(fromAt, toAt);
        }
      } catch (_) {}
    }

    final List<int> mins = _durationMinutes(order);
    final String? baseStr = order.scheduleAt ?? order.createdAt;
    try {
      DateTime base = baseStr != null ? DateTime.parse(baseStr).toLocal() : DateTime.now();
      int minMin = mins.isNotEmpty ? mins[0] : (order.eta?.min ?? 25);
      int maxMin = mins.length >= 2 ? mins[1] : (order.eta?.max ?? 35);
      if (base.add(Duration(minutes: maxMin)).isBefore(DateTime.now())) {
        base = DateTime.now();
        minMin = 5;
        maxMin = 15;
      }
      final List<DateTime> window = DeliveryTimeHelper.arrivalWindow(base, minMin, maxMin);
      return DateConverter.timeRange(window[0], window[1]);
    } catch (_) {
      final List<DateTime> window = DeliveryTimeHelper.arrivalWindow(DateTime.now(), 5, 15);
      return DateConverter.timeRange(window[0], window[1]);
    }
  }

  List<int> _durationMinutes(OrderModel order) {
    final Iterable<RegExpMatch> matches = RegExp(r'\d+').allMatches(order.restaurant?.deliveryTime ?? '');
    final List<int> nums = matches.map((m) => int.parse(m.group(0)!)).toList();
    if (nums.isNotEmpty) {
      return nums.length >= 2 ? [nums[0], nums[1]] : [nums[0], nums[0]];
    }
    if (order.processingTime != null) return [order.processingTime!, order.processingTime!];
    return const [];
  }
}

class _HistoryStep {
  final String label;
  final String description;
  final String? timestamp;
  final bool isDelivered;
  final bool isCurrent;
  final bool isTerminal;
  final bool reached;
  final String? estimatedTime;

  const _HistoryStep({
    required this.label,
    required this.description,
    required this.timestamp,
    this.isDelivered = false,
    this.isCurrent = false,
    this.isTerminal = false,
    this.reached = false,
    this.estimatedTime,
  });

  bool get isCompleted => timestamp != null && timestamp!.trim().isNotEmpty;

  _HistoryStep copyWith({bool? isCurrent, bool? reached, String? estimatedTime}) => _HistoryStep(
        label: label,
        description: description,
        timestamp: timestamp,
        isDelivered: isDelivered,
        isCurrent: isCurrent ?? this.isCurrent,
        isTerminal: isTerminal,
        reached: reached ?? this.reached,
        estimatedTime: estimatedTime ?? this.estimatedTime,
      );
}

class _StatusHistoryStep extends StatelessWidget {
  final _HistoryStep step;
  final bool isLast;
  final bool lineActive;

  const _StatusHistoryStep({required this.step, required this.isLast, required this.lineActive});

  static const Color _green = Color(0xFF1FA24A);

  String _dateTime(String raw) {
    try {
      final DateTime dt = DateTime.parse(raw).toLocal();
      return '${DateFormat('d MMM').format(dt)}, ${DateConverter.dateTimeStringToFormattedTime(raw)}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = context.outline;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        SizedBox(
          width: 28,
          child: Column(children: [
            _buildDot(context),
            if (!isLast)
              Expanded(
                child: CustomPaint(
                  painter: _DashedLinePainter(color: lineActive ? _green : disabled.withValues(alpha: 0.6)),
                  size: const Size(2, double.infinity),
                ),
              ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.paddingLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                step.label,
                style: context.heading.defaultSize.strong,
              ),
              const SizedBox(height: 2),
              _buildSubtitle(context, disabled),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildDot(BuildContext context) {
    if (step.isTerminal) {
      return _CircleDot(color: Theme.of(context).colorScheme.error, icon: Icons.close);
    }
    if (step.isCurrent) {
      return const _RippleDot(color: _green);
    }
    if (step.reached) {
      return const _CircleDot(color: _green, icon: Icons.check);
    }
    return _CircleDot(color: context.bgNeutralLight);
  }

  Widget _buildSubtitle(BuildContext context, Color disabled) {
    if (step.isDelivered && !step.isCompleted && step.estimatedTime != null) {
      return RichText(
        text: TextSpan(
          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
          children: [
            TextSpan(text: '${'est_delivery_time'.tr} '),
            TextSpan(
              text: step.estimatedTime!,
              style: context.body.small.strong.overrideWith(color: context.textBaseMedium),
            ),
          ],
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        step.description,
        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
      ),
      if (step.isCompleted) ...[
        const SizedBox(height: 2),
        Text(
          _dateTime(step.timestamp!),
          style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
        ),
      ],
    ]);
  }
}

class _CircleDot extends StatelessWidget {
  final Color color;
  final IconData? icon;

  const _CircleDot({required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: icon == null ? null : Icon(icon, color: context.surfaceContainer, size: 15),
    );
  }
}

class _RippleDot extends StatefulWidget {
  final Color color;

  const _RippleDot({required this.color});

  @override
  State<_RippleDot> createState() => _RippleDotState();
}

class _RippleDotState extends State<_RippleDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double t = _controller.value;
          return Stack(alignment: Alignment.center, children: [
            Container(
              width: 12 + (12 * t),
              height: 12 + (12 * t),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: (1 - t) * 0.35),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
          ]);
        },
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}
