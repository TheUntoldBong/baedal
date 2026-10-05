import 'package:flutter/material.dart';

import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ReelsShimmerWidget extends StatelessWidget {
  const ReelsShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    const double reelRatio = 266 / 150;
    final double cardWidth = isDesktop ? 160 : (MediaQuery.of(context).size.width / 2.4).clamp(140.0, 160.0);
    final double cardHeight = isDesktop ? 280 : cardWidth * reelRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Row(
              children: <Widget>[
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingDefault),
          SizedBox(
            height: cardHeight,
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                itemCount: 4,
                separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSmall),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
