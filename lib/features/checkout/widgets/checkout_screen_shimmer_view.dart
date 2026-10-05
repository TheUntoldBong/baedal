import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class CheckoutScreenShimmerView extends StatelessWidget {
  const CheckoutScreenShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(children: [

      Expanded(child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: Dimensions.paddingSmall),

              const _OrderTypeToggleShimmer(),
              const SizedBox(height: Dimensions.paddingLarge),
              const SizedBox(height: Dimensions.paddingSmall),

              const _DeliveryOptionCardShimmer(),
              const SizedBox(height: Dimensions.paddingLarge),

              const _ContactInfoShimmer(),
              const SizedBox(height: Dimensions.paddingLarge),

              const _DeliveryInstructionShimmer(),
              const SizedBox(height: Dimensions.paddingDefault),

              const Divider(thickness: 2),
              const SizedBox(height: Dimensions.paddingDefault),

              const _DeliveryTipsShimmer(),
              const SizedBox(height: Dimensions.paddingDefault),

              const Divider(thickness: 2),
              const SizedBox(height: Dimensions.paddingDefault),

              const _PaymentShimmer(),
              const SizedBox(height: Dimensions.paddingDefault),

              const Divider(thickness: 2),
              const SizedBox(height: Dimensions.paddingDefault),

              const _CouponShimmer(),
              const SizedBox(height: Dimensions.paddingLarge),

              _BillingSummaryShimmer(isDesktop: isDesktop),
              const SizedBox(height: Dimensions.paddingLarge),
            ]),
          ),
        ),
      )),

      const _OrderPlaceBarShimmer(),
    ]);
  }
}

class _OrderTypeToggleShimmer extends StatelessWidget {
  const _OrderTypeToggleShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(children: const [
          Expanded(child: _ShimmerBar(height: 46, width: double.infinity, radius: Dimensions.radiusMedium)),
          SizedBox(width: Dimensions.padding2xSmall),
          Expanded(child: _ShimmerBar(height: 46, width: double.infinity, radius: Dimensions.radiusMedium)),
        ]),
      ),
    );
  }
}

class _DeliveryOptionCardShimmer extends StatelessWidget {
  const _DeliveryOptionCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeLarge),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: context.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: _ShimmerBar(height: 18, width: 160),
        ),
        SizedBox(height: Dimensions.paddingSmall),

        _ChipRow(widths: [176, 152], height: 44, radius: Dimensions.radiusMedium),
        SizedBox(height: Dimensions.paddingDefault),

        _InstantDeliveryShimmer(),
        SizedBox(height: Dimensions.paddingDefault),

        _DeliveryAddressShimmer(),
      ]),
    );
  }
}

class _InstantDeliveryShimmer extends StatelessWidget {
  const _InstantDeliveryShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      padding: const EdgeInsets.all(Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: const [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ShimmerBar(height: 18, width: 150),
            SizedBox(height: Dimensions.paddingSmall),
            _ShimmerBar(height: 12, width: double.infinity),
            SizedBox(height: Dimensions.paddingSmall),
            _ShimmerBar(height: 12, width: 190),
          ])),
          SizedBox(width: Dimensions.paddingSmall),

          _ShimmerBar(height: 20, width: 20),
        ]),
        const SizedBox(height: Dimensions.paddingDefault),

        Divider(color: context.surfaceContainerHigh),
        const SizedBox(height: Dimensions.paddingDefault),

        const _SaverOptionShimmer(titleWidth: 175, timeWidth: 110),
        const SizedBox(height: Dimensions.paddingLarge),
        const _SaverOptionShimmer(titleWidth: 165, timeWidth: 110, chargeWidth: 130),
        const SizedBox(height: Dimensions.paddingLarge),
        const _SaverOptionShimmer(titleWidth: 140, timeWidth: 110, chargeWidth: 130),
        const SizedBox(height: Dimensions.paddingSmall),
      ]),
    );
  }
}

class _SaverOptionShimmer extends StatelessWidget {
  final double titleWidth;
  final double timeWidth;
  final double? chargeWidth;

  const _SaverOptionShimmer({required this.titleWidth, required this.timeWidth, this.chargeWidth});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _ShimmerBar(height: 16, width: titleWidth),
        const SizedBox(height: Dimensions.paddingSmall),
        _ShimmerBar(height: 12, width: timeWidth),
      ])),
      const SizedBox(width: Dimensions.paddingSmall),

      if (chargeWidth != null) ...[
        _ShimmerBar(height: 24, width: chargeWidth!, radius: Dimensions.radiusLarge),
        const SizedBox(width: Dimensions.paddingSmall),
      ],

      const _ShimmerCircle(size: 20),
      const SizedBox(width: Dimensions.padding2xSmall),
    ]);
  }
}

class _DeliveryAddressShimmer extends StatelessWidget {
  const _DeliveryAddressShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      padding: const EdgeInsets.all(Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        _ShimmerCircle(size: 28),
        SizedBox(width: Dimensions.paddingMedium),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ShimmerBar(height: 16, width: 130),
          SizedBox(height: Dimensions.paddingSmall),
          _ShimmerBar(height: 12, width: double.infinity),
          SizedBox(height: Dimensions.paddingSmall),
          _ShimmerBar(height: 12, width: 180),
        ])),
      ]),
    );
  }
}

class _ContactInfoShimmer extends StatelessWidget {
  const _ContactInfoShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(children: const [
          _ShimmerCircle(size: 36),
          SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ShimmerBar(height: 14, width: 150),
            SizedBox(height: Dimensions.paddingSmall),
            _ShimmerBar(height: 12, width: 110),
          ])),
          SizedBox(width: Dimensions.paddingSmall),

          _ShimmerBar(height: 20, width: 20),
        ]),
      ),
    );
  }
}

class _DeliveryInstructionShimmer extends StatelessWidget {
  const _DeliveryInstructionShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
        child: _ShimmerBar(height: 16, width: 170),
      ),
      SizedBox(height: Dimensions.paddingMedium),

      _ChipRow(widths: [110, 140, 96], height: 34, radius: Dimensions.radiusLarge),
    ]);
  }
}

class _DeliveryTipsShimmer extends StatelessWidget {
  const _DeliveryTipsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ShimmerBar(height: 18, width: 130),
            SizedBox(height: Dimensions.paddingSmall),
            _ShimmerBar(height: 12, width: 210),
          ])),
          SizedBox(width: Dimensions.paddingLarge),

          _ShimmerBar(height: 26, width: 100, radius: Dimensions.radiusLarge),
        ]),
      ),
      SizedBox(height: Dimensions.paddingDefault),

      _ChipRow(widths: [76, 76, 76, 76], height: 44, radius: Dimensions.radiusDefault),
    ]);
  }
}

class _PaymentShimmer extends StatelessWidget {
  const _PaymentShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        _ShimmerBar(height: 18, width: 160),
        SizedBox(height: Dimensions.paddingSmall),
        _ShimmerBar(height: 12, width: 200),
        SizedBox(height: Dimensions.paddingDefault),

        _ShimmerBar(height: 48, width: double.infinity, radius: Dimensions.radiusLarge),
      ]),
    );
  }
}

class _CouponShimmer extends StatelessWidget {
  const _CouponShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ShimmerBar(height: 18, width: 120),
          SizedBox(height: Dimensions.paddingSmall),
          _ShimmerBar(height: 12, width: 220),
        ])),
        SizedBox(width: Dimensions.paddingSmall),

        _ShimmerBar(height: 20, width: 20),
      ]),
    );
  }
}

class _BillingSummaryShimmer extends StatelessWidget {
  final bool isDesktop;

  const _BillingSummaryShimmer({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: isDesktop ? context.surfaceContainer : context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: isDesktop ? [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))] : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Center(child: _ShimmerBar(height: 18, width: 150)),
          SizedBox(height: Dimensions.paddingDefault),

          _PriceRowShimmer(labelWidth: 90, valueWidth: 70),
          SizedBox(height: Dimensions.paddingMedium),
          _PriceRowShimmer(labelWidth: 110, valueWidth: 60),
          SizedBox(height: Dimensions.paddingMedium),
          _PriceRowShimmer(labelWidth: 80, valueWidth: 66),
          SizedBox(height: Dimensions.paddingMedium),
          _PriceRowShimmer(labelWidth: 130, valueWidth: 58),

          Divider(height: Dimensions.paddingOverLarge, thickness: 1),

          _PriceRowShimmer(labelWidth: 100, valueWidth: 88, height: 15),
        ]),
      ),
    );
  }
}

class _OrderPlaceBarShimmer extends StatelessWidget {
  const _OrderPlaceBarShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.shadow, offset: const Offset(0, -1))],
      ),
      child: Column(children: const [
        SizedBox(height: Dimensions.paddingMedium),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.padding2xSmall),
          child: Row(children: [
            _ShimmerBar(height: 16, width: 130),
            Spacer(),
            _ShimmerBar(height: 20, width: 110),
          ]),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingSmall, Dimensions.paddingLarge, Dimensions.paddingLarge),
          child: SafeArea(
            child: _ShimmerBar(height: 48, width: double.infinity, radius: Dimensions.radiusDefault),
          ),
        ),
      ]),
    );
  }
}

class _PriceRowShimmer extends StatelessWidget {
  final double labelWidth;
  final double valueWidth;
  final double height;

  const _PriceRowShimmer({required this.labelWidth, required this.valueWidth, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _ShimmerBar(height: height, width: labelWidth),
      _ShimmerBar(height: height, width: valueWidth),
    ]);
  }
}

class _ChipRow extends StatelessWidget {
  final List<double> widths;
  final double height;
  final double radius;

  const _ChipRow({required this.widths, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
      child: Row(children: [
        for (final double width in widths) ...[
          _ShimmerBar(height: height, width: width, radius: radius),
          const SizedBox(width: Dimensions.paddingDefault),
        ],
      ]),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Shimmer(
        child: Container(
          height: size, width: size,
          decoration: BoxDecoration(color: Theme.of(context).shadowColor, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBar({required this.height, required this.width, this.radius = Dimensions.radiusExtraSmall});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Shimmer(
        child: Container(
          height: height, width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
