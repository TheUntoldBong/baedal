import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class RestaurantScreenShimmerWidget extends StatelessWidget {
  const RestaurantScreenShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        SizedBox(
          height: 210,
          child: Stack(children: [
            const Positioned.fill(child: _ShimmerBox(height: double.infinity, width: double.infinity, radius: 0)),

            Positioned(left: 0, right: 0, bottom: 0, child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
              ),
            )),

            Padding(
              padding: EdgeInsets.only(top: topPadding + 12, left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
              child: Row(children: const [
                _ShimmerBox(height: 40, width: 40, radius: Dimensions.radiusDefault),
                Spacer(),
                _ShimmerBox(height: 40, width: 40, radius: Dimensions.radiusDefault),
                SizedBox(width: Dimensions.paddingSmall),
                _ShimmerBox(height: 40, width: 40, radius: Dimensions.radiusDefault),
              ]),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _ShimmerBox(height: 60, width: 60, radius: Dimensions.radiusDefault),
            SizedBox(width: Dimensions.paddingDefault),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _ShimmerBox(height: 18, width: 180),
              SizedBox(height: 6),
              _ShimmerBox(height: 12, width: 140),
              SizedBox(height: 6),
              _ShimmerBox(height: 12, width: 200),
            ])),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
            decoration: BoxDecoration(
              border: Border.all(color: context.outline),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Row(children: [
              const Expanded(child: _StatShimmer()),
              Container(width: 1, height: 42, color: context.outline),
              const Expanded(child: _StatShimmer()),
              Container(width: 1, height: 42, color: context.outline),
              const Expanded(child: _StatShimmer()),
            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Row(children: [
            _ShimmerBox(height: 62, width: 220, radius: Dimensions.radiusDefault),
            SizedBox(width: Dimensions.paddingDefault),
            _ShimmerBox(height: 62, width: 220, radius: Dimensions.radiusDefault),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: _ShimmerBox(height: 64, width: double.infinity, radius: Dimensions.radiusDefault),
        ),
        const SizedBox(height: Dimensions.paddingLarge),

        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Row(children: [
            _ShimmerBox(height: 30, width: 90, radius: Dimensions.radiusExtraLarge),
            SizedBox(width: Dimensions.paddingSmall),
            _ShimmerBox(height: 30, width: 70, radius: Dimensions.radiusExtraLarge),
            SizedBox(width: Dimensions.paddingSmall),
            _ShimmerBox(height: 30, width: 100, radius: Dimensions.radiusExtraLarge),
            SizedBox(width: Dimensions.paddingSmall),
            _ShimmerBox(height: 30, width: 80, radius: Dimensions.radiusExtraLarge),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSmall),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 4,
          separatorBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Divider(height: 1),
          ),
          itemBuilder: (context, index) => const _FoodRowShimmer(),
        ),
      ]),
    );
  }
}

class _StatShimmer extends StatelessWidget {
  const _StatShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(mainAxisSize: MainAxisSize.min, children: [
      _ShimmerBox(height: 14, width: 56),
      SizedBox(height: Dimensions.padding2xSmall),
      _ShimmerBox(height: 10, width: 72),
    ]);
  }
}

class _FoodRowShimmer extends StatelessWidget {
  const _FoodRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Dimensions.paddingDefault),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Padding(
          padding: EdgeInsets.only(right: Dimensions.paddingDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _ShimmerBox(height: 12, width: 50),
            SizedBox(height: 8),
            _ShimmerBox(height: 16, width: double.infinity),
            SizedBox(height: 7),
            _ShimmerBox(height: 16, width: 120),
            SizedBox(height: 12),
            _ShimmerBox(height: 18, width: 90),
            SizedBox(height: 10),
            _ShimmerBox(height: 20, width: 70, radius: Dimensions.radiusExtraSmall),
          ]),
        )),
        _ShimmerBox(height: 115, width: 115, radius: 12),
      ]),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({required this.height, required this.width, this.radius = Dimensions.radiusExtraSmall});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Shimmer(
        child: Container(height: height, width: width, color: Theme.of(context).shadowColor),
      ),
    );
  }
}
