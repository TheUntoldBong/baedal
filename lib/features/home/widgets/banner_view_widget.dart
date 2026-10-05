import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';

class BannerViewWidget extends StatelessWidget {
  static const double _viewportFraction = 0.8;
  static const double _maxBannerHeight = 300;

  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {
      return (homeController.bannerImageList != null && homeController.bannerImageList!.isEmpty) ? const SizedBox() : LayoutBuilder(builder: (context, constraints) {
      const double gap = Dimensions.padding2xSmall * 2;
      final double bannerWidth = ResponsiveHelper.isMobile(context)
          ? (constraints.maxWidth - (Dimensions.paddingLarge * 2)).clamp(0.0, double.infinity)
          : ((constraints.maxWidth * _viewportFraction) - gap).clamp(0.0, _maxBannerHeight * 2);
      final double bannerHeight = bannerWidth / 2;
      final double viewportFraction = constraints.maxWidth > 0 ? ((bannerWidth + gap) / constraints.maxWidth).clamp(0.0, 1.0) : _viewportFraction;

      return SizedBox(
        width: constraints.maxWidth,
        child: homeController.bannerImageList != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: bannerHeight,
                viewportFraction: viewportFraction,
                autoPlay: true,
                enlargeCenterPage: false,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  homeController.setCurrentIndex(index, true);
                },
              ),
              itemCount: homeController.bannerImageList!.isEmpty ? 1 : homeController.bannerImageList!.length,
              itemBuilder: (context, index, _) {
                return InkWell(
                  onTap: () {
                    if(homeController.bannerDataList![index] is Product) {
                      Product? product = homeController.bannerDataList![index];
                      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
                        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                        builder: (con) => FoodBottomSheetWidget(product: product),
                      ) : showDialog(context: context, builder: (con) => Dialog(
                          child: FoodBottomSheetWidget(product: product)),
                      );
                    }else if(homeController.bannerDataList![index] is Restaurant) {
                      Restaurant restaurant = homeController.bannerDataList![index];
                      Get.toNamed(
                        RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''),
                        arguments: RestaurantScreen(restaurant: restaurant),
                      );
                    }else if(homeController.bannerDataList![index] is BasicCampaignModel) {
                      BasicCampaignModel campaign = homeController.bannerDataList![index];
                      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                    height: bannerHeight,
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      child: GetBuilder<SplashController>(builder: (splashController) {
                        return CustomImageWidget(
                          image: '${homeController.bannerImageList![index]}',
                          fit: BoxFit.fill,
                        );
                      },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(homeController.bannerImageList!.length, (index) {
                bool isActive = index == homeController.currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  height: 5,
                  width: isActive ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? context.primary : context.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                );
              }),
            ),
            SizedBox(height: Dimensions.padding2xSmall,)
          ],
        ) : Center(child: SizedBox(
          width: bannerWidth, height: bannerHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Container(decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: context.shadow,
              )),
            ),
          ),
        )),
      );
      });
    });
  }
}
