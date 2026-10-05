import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/category/screens/category_product_screen.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/category_cuisine_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/explore_circle_card_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CategoryCuisineRowWidget extends StatelessWidget {
  const CategoryCuisineRowWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {

      final List<CategoryCuisineItem> items = homeController.categoryCuisineList ?? [];

      return SizedBox(
        height: 105,
        child: homeController.categoryCuisineList == null
            ? const _CategoryCuisineShimmer()
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: Dimensions.paddingLarge),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _viewAllTile(context);
                  }
                  final CategoryCuisineItem item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                    child: ExploreCircleCardWidget(
                      image: item.imageFullUrl ?? '',
                      name: item.name ?? '',
                      onTap: () => _onTapItem(item),
                    ),
                  );
                },
              ),
      );
    });
  }

  void _onTapItem(CategoryCuisineItem item) {
    if (item.isCuisine) {
      Get.toNamed(RouteHelper.getCuisineRestaurantRoute(item.id, item.name));
    } else {
      if (GetPlatform.isWeb) {
        Get.toNamed(RouteHelper.getCategoryProductRoute(item.id, item.name ?? ''));
      } else {
        Get.to(CategoryProductScreen(categoryID: '${item.id}', categoryName: item.name ?? ''));
      }
    }
  }

  Widget _viewAllTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
      child: Container(
        width: 68,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: CustomInkWellWidget(
          onTap: () => Get.toNamed(RouteHelper.getCategoryCuisineRoute()),
          radius: Dimensions.radiusSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.arrow_forward_rounded, color: context.primary, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                'view_all'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: context.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCuisineShimmer extends StatelessWidget {
  const _CategoryCuisineShimmer();

  @override
  Widget build(BuildContext context) {
    final double size = !ResponsiveHelper.isDesktop(context) ? 70 : 100;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 10,
      padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall, right: Dimensions.paddingDefault, top: Dimensions.paddingSmall),
          child: Column(children: [
            ClipOval(
              child: Shimmer(
                child: Container(
                  height: size, width: size,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).shadowColor),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSmall),

            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              child: Shimmer(
                child: Container(
                  height: 10, width: size,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
