import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/features/category/screens/category_product_screen.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/category_cuisine_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CategoryCuisineScreen extends StatefulWidget {
  const CategoryCuisineScreen({super.key});

  @override
  State<CategoryCuisineScreen> createState() => _CategoryCuisineScreenState();
}

class _CategoryCuisineScreenState extends State<CategoryCuisineScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<HomeController>().getExploreCategoryCuisineList(false);
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        Get.find<HomeController>().loadMoreExploreCategoryCuisine();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'what_on_your_mind'.tr),
      body: GetBuilder<HomeController>(builder: (homeController) {

        final bool loading = homeController.exploreCategoryCuisineList == null;
        final List<CategoryCuisineItem> items = homeController.exploreCategoryCuisineList ?? [];

        return SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: loading
                    ? GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: _gridDelegate(context),
                        padding: const EdgeInsets.all(Dimensions.paddingDefault),
                        itemCount: 12,
                        itemBuilder: (context, index) => const _ExploreGridShimmer(),
                      )
                    : items.isEmpty
                        ? NoDataScreen(title: 'no_category_found'.tr)
                        : Column(children: [

                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: _gridDelegate(context),
                              padding: const EdgeInsets.all(Dimensions.paddingDefault),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final CategoryCuisineItem item = items[index];
                                return _ExploreGridCard(
                                  image: item.imageFullUrl ?? '',
                                  name: item.name ?? '',
                                  isCategory: !item.isCuisine,
                                  onTap: () => _onTapItem(item),
                                );
                              },
                            ),

                            if(homeController.exploreCategoryCuisinePaginate) Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                              child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(context.primary))),
                            ),

                          ]),
              )),
            ),
          ),
        );
      }),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: ResponsiveHelper.isTab(context) ? 4 : 3,
      childAspectRatio: 0.78,
      mainAxisSpacing: Dimensions.paddingDefault,
      crossAxisSpacing: Dimensions.paddingDefault,
    );
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
}

class _ExploreGridCard extends StatelessWidget {
  final String image;
  final String name;
  final bool isCategory;
  final VoidCallback onTap;
  const _ExploreGridCard({required this.image, required this.name, required this.isCategory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double imageSize = 58;
    final Color primary = context.primary;

    return CustomInkWellWidget(
      onTap: onTap,
      radius: Dimensions.radiusLarge,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: context.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.06),
                    border: Border.all(color: primary.withValues(alpha: 0.12)),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      image: image,
                      height: imageSize, width: imageSize, fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  right: -2, bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.surfaceContainer,
                      border: Border.all(color: primary.withValues(alpha: 0.15)),
                    ),
                    child: Icon(
                      isCategory ? Icons.category_rounded : Icons.restaurant_rounded,
                      size: 12, color: primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSmall),

            Flexible(child: Text(
              name.trim(),
              style: context.heading.small.medium,
              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            )),

          ],
        ),
      ),
    );
  }
}

class _ExploreGridShimmer extends StatelessWidget {
  const _ExploreGridShimmer();

  @override
  Widget build(BuildContext context) {
    final double imageSize = 58;
    final Color base = Theme.of(context).shadowColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: context.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(child: Shimmer(child: Container(
            height: imageSize + 6, width: imageSize + 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: base),
          ))),
          const SizedBox(height: Dimensions.paddingSmall),

          Shimmer(child: Container(
            height: 10, width: imageSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: base),
          )),
          const SizedBox(height: Dimensions.padding2xSmall),

          Shimmer(child: Container(
            height: 10, width: imageSize * 0.6,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: base),
          )),
        ],
      ),
    );
  }
}
