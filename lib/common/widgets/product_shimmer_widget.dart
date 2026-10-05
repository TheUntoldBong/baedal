import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class ProductShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isRestaurant;
  final bool hasDivider;
  const ProductShimmer({super.key, required this.isEnabled, required this.hasDivider, this.isRestaurant = false});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: EdgeInsets.only(bottom: desktop ? 0 :Dimensions.paddingDefault),
      child: Container(
        padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSmall) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          color: context.surfaceContainer.withValues(alpha: 0.5),
          border: Border.all(color: context.outline, width: 1),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(desktop ? 0 : Dimensions.paddingSmall),
              child: Row(children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  child: Shimmer(
                    child: Container(
                      height: desktop ? 120 : 120, width: desktop ? 120 : 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    Shimmer(child: Container(height: desktop ? 20 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor)),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Shimmer(
                      child: Container(
                        height: desktop ? 15 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor,
                        margin: const EdgeInsets.only(right: Dimensions.paddingLarge),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Row(children: [
                      Icon(Icons.star, size: 16, color: Theme.of(context).shadowColor),
                      const SizedBox(width: Dimensions.padding2xSmall),

                      Container(
                        height: desktop ? 15 : 10, width: 50, color: Theme.of(context).shadowColor,
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Shimmer(child: Container(height: desktop ? 20 : 12, width: 120, color: Theme.of(context).shadowColor)),

                  ]),
                ),

                Column(mainAxisAlignment: isRestaurant ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSmall : 0),
                    child: Icon(
                      Icons.favorite_border,  size: desktop ? 30 : 25,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),

                  !isRestaurant ? Padding(
                    padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSmall : 0),
                    child: Icon(Icons.add, size: desktop ? 30 : 25, color: Theme.of(context).shadowColor),
                  ) : const SizedBox(),
                ]),

              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
