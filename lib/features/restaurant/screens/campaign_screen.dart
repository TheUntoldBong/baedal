import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CampaignScreen extends StatefulWidget {
  final BasicCampaignModel campaign;
  const CampaignScreen({super.key, required this.campaign});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<CampaignController>().getBasicCampaignDetails(widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: GetBuilder<CampaignController>(builder: (campaignController) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              toolbarHeight: 90,
              pinned: true,
              floating: false,
              backgroundColor: context.surfaceContainer,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.padding2xSmall),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.bgNeutralMedium,
                    border: Border.all(color: context.surfaceContainer),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                expandedTitleScale: 1.1,
                title: CustomizableSpaceBarWidget(
                  builder: (context, scrollingRate) {
                    return campaignController.campaign != null ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15 - (15 * scrollingRate), right: 15 - (15 * scrollingRate), bottom: 15 - (15 * scrollingRate)),
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(scrollingRate < 0.8 ? Dimensions.radiusLarge : 0),
                        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [

                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: Dimensions.paddingSmall, bottom: Dimensions.paddingDefault,
                                left: scrollingRate < 0.8 ? Dimensions.paddingDefault : 70, right: Dimensions.paddingDefault,
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                Row(children: [

                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      color: context.primary.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CustomImageWidget(
                                        image: '${campaignController.campaign!.imageFullUrl}',
                                        height: 50, width: 50, fit: BoxFit.cover,
                                        isFood: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                                      Text(
                                        campaignController.campaign!.title ?? '', style: context.heading.defaultSize.strong,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),

                                      Text(
                                        campaignController.campaign!.description ?? '', maxLines: isDesktop ? 1 : 2, overflow: TextOverflow.ellipsis,
                                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                                      ),

                                    ]),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.paddingSmall),

                                scrollingRate < 0.8 ? campaignController.campaign!.startTime != null ? Row(children: [
                                  Icon(Icons.access_time_filled, size: 20, color: context.iconBaseMedium),
                                  const SizedBox(width: Dimensions.padding2xSmall),

                                  Text('${'daily'.tr} - ', style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),

                                  Text(
                                    '${DateConverter.convertTimeToTime(campaignController.campaign!.startTime!)}'
                                        ' ${'to'.tr} ${DateConverter.convertTimeToTime(campaignController.campaign!.endTime!)}',
                                    style: context.body.extraSmall.medium.overrideWith(color: context.primary),
                                  ),

                                ]): const SizedBox() : const SizedBox(),

                              ]),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSmall),
                            margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
                            decoration: BoxDecoration(
                              color: scrollingRate < 0.8 ? context.primary.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(Dimensions.radiusExtraSmall),
                                bottomRight: Radius.circular(Dimensions.radiusExtraSmall),
                              ),
                            ),
                            child: Column(children: [
                              scrollingRate < 0.8 ? Text(
                                'end_date'.tr, style: context.body.small.medium.overrideWith(color: context.primary),
                              ) : const SizedBox(),
                              const SizedBox(height: Dimensions.padding2xSmall),

                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusExtraSmall)),
                                  image: DecorationImage(
                                    image: AssetImage(Images.calender),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  margin: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(Dimensions.radiusExtraSmall),
                                      bottomRight: Radius.circular(Dimensions.radiusExtraSmall),
                                    ),
                                  ),
                                  child: Column(children: [

                                    const SizedBox(height: Dimensions.paddingSmall),

                                    Text(
                                      DateConverter.stringToLocalDateDayOnly(campaignController.campaign!.availableDateEnds!),
                                      style: context.heading.extraLarge.strong, textAlign: TextAlign.center,
                                    ),

                                    Text(
                                      DateConverter.stringToLocalDateMonthAndYearOnly(campaignController.campaign!.availableDateEnds!),
                                      style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                                    ),

                                  ]),
                                ),

                              ),

                            ]),
                          ),

                        ]),

                      ]),
                    ) : const SizedBox();
                  },

                ),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 90),
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusLarge), bottomRight: Radius.circular(Dimensions.radiusLarge)),
                    child: CustomImageWidget(
                      fit: BoxFit.cover, placeholder: Images.restaurantCover,
                      image: '${widget.campaign.imageFullUrl}',
                      isRestaurant: true,
                    ),
                  ),
                ),
              ),
              actions: [VegFilterWidget(
                type: campaignController.vegType,
                onSelected: (VegType vegType) => campaignController.setVegType(vegType),
                iconColor: context.primary,
              )],
            ),

            SliverToBoxAdapter(child: Center(child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                ProductViewWidget(
                  isRestaurant: true, products: null,
                  restaurants: campaignController.campaignRestaurantList,
                ),

              ]),
            ))),
          ],
        );
      }),
    );
  }
}