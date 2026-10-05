import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class TodayTrendsViewWidget extends StatefulWidget {
  const TodayTrendsViewWidget({super.key});

  @override
  State<TodayTrendsViewWidget> createState() => _TodayTrendsViewWidgetState();
}

class _TodayTrendsViewWidgetState extends State<TodayTrendsViewWidget> {

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      final campaigns = campaignController.itemCampaignList;
      if (campaigns != null && campaigns.isEmpty) {
        return const SizedBox.shrink();
      }

      final bool isDesktop = ResponsiveHelper.isDesktop(context);
      final double screenWidth = MediaQuery.of(context).size.width;
      final double cardWidth = isDesktop ? 360 : (screenWidth * 0.85).clamp(280.0, 380.0);
      final double textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.25);
      final double cardListHeight = 125 * textScale;

      return Column(
        children: [
          Container(
            width: Dimensions.webMaxWidth,
            color: context.surfaceContainer,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
              HomeSectionHeaderWidget(name: 'trending_dishes'.tr,),
              const SizedBox(height: Dimensions.paddingMedium),
          
              campaigns != null ? SizedBox(
                height: cardListHeight,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                  itemCount: campaigns.length + 1,
                  itemBuilder: (context, index) {
                    if (index == campaigns.length) {
                      return SectionViewAllTile(
                        onTap: () => Get.toNamed(RouteHelper.getItemCampaignRoute()),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(right: index == campaigns.length - 1 ? 0 : Dimensions.paddingMedium),
                      child: Container(
                        width: cardWidth,
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                          border: Border.all(color: context.outline),
                        ),
                        child: HorizontalFoodCardWidget(
                          product: campaigns[index],
                          restaurant: null,
                          isCampaign: true,
                          showStoreInfo: true,
                        ),
                      ),
                    );
                  },
                ),
              ) : const ItemCardShimmer(isPopularNearbyItem: false),
          
            ]),
          ),
          const SizedBox(height: Dimensions.paddingLarge),
        ],
      );
    });
  }
}