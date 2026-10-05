import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final double progress;
  const HomeSearchBarWidget({super.key, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    final double t = progress.clamp(0.0, 1.0);
    final Color shadowColor = context.shadow;
    final double shadowOpacity = (1 - t).clamp(0.0, 1.0);
    const double searchbarHeight = 44;
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      height: double.infinity,
      width: Dimensions.webMaxWidth,
      decoration: BoxDecoration(
        color: Color.lerp(context.surface, context.surfaceContainer, t),
      ),
      child: Center(
        child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: searchbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: 8),
            decoration: BoxDecoration(
              color: Color.lerp(context.surfaceContainer, Theme.of(context).colorScheme.surface, t),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.outline.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: shadowOpacity == 0 ? null : [
                BoxShadow(
                  color: shadowColor.withValues(alpha: shadowColor.a * shadowOpacity * 0.7),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search icon with micro circle
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomAssetImageWidget(
                    Images.search,
                    height: 15,
                    width: 15,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 10),

                Text(
                  "${'search_for'.tr} ",
                  style: context.body.defaultSize.overrideWith(color: context.textBaseLight).copyWith(fontSize: 13),
                ),

                Expanded(
                  child: GetBuilder<HomeController>(id: 'search_hint', builder: (homeController) {
                    return Text(
                      "'${homeController.currentSearchHint}'",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseDefault).copyWith(fontSize: 13),
                    );
                  }),
                ),

                // Trailing Mic / Speech Icon
                Container(
                  height: 18,
                  width: 1,
                  color: context.outline.withValues(alpha: 0.4),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                Icon(Icons.mic_none_rounded, size: 20, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
