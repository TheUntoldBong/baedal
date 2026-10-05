import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_offer_item_card.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_offer_item_shimmer_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoOfferScreen extends StatefulWidget {
  const BogoOfferScreen({super.key});

  @override
  State<BogoOfferScreen> createState() => _BogoOfferScreenState();
}

class _BogoOfferScreenState extends State<BogoOfferScreen> {
  static const int _shimmerItemCount = 4;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BogoOfferController>().getBogoHomeData();
      Get.find<BogoOfferController>().getBogoOfferList();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final BogoOfferController bogoOfferController = Get.find<BogoOfferController>();
    await Future.wait([
      bogoOfferController.getBogoHomeData(),
      bogoOfferController.getBogoOfferList(showLoader: false),
    ]);
  }

  void _onScroll() {
    if(_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    Get.find<BogoOfferController>().loadMoreBogoOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'bogo_offer'.tr),
      backgroundColor: context.surface,
      body: GetBuilder<BogoOfferController>(builder: (bogoOfferController) {
        final List<BogoOfferCardModel> offers = bogoOfferController.bogoOfferList ?? [];
        final bool isLoading = bogoOfferController.isLoading;
        final bool paginate = bogoOfferController.bogoOfferPaginate;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(controller: _scrollController, physics: const AlwaysScrollableScrollPhysics(), slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingExtraLarge),
                child: Column(children: [
                  const CustomAssetImageWidget(Images.bogoOffers, height: 80, width: 80),
                  const SizedBox(height: Dimensions.paddingDefault),

                  Text('hurry_up_bogo_offer_is_live'.tr, textAlign: TextAlign.center, style: context.heading.extraLarge.strong),
                  const SizedBox(height: Dimensions.paddingExtraSmall),

                  Text('get_best_value_from_order_with_exclusive_bogo_deals'.tr, textAlign: TextAlign.center, style: context.body.small.regular),
                ]),
              ),
            ),

            DecoratedSliver(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge),
                ),
              ),
              sliver: SliverPadding(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                sliver: isLoading ? SliverList.separated(
                  itemCount: _shimmerItemCount,
                  separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingLarge),
                  itemBuilder: (context, index) => const BogoOfferItemShimmerWidget(),
                ) : offers.isEmpty ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: NoDataScreen(title: 'no_offer_found'.tr)),
                ) : SliverList.separated(
                  itemCount: offers.length + (paginate ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingLarge),
                  itemBuilder: (context, index) => index < offers.length
                    ? BogoOfferItemCard(offer: offers[index])
                    : const Padding(
                        padding: EdgeInsets.only(top: Dimensions.paddingSmall),
                        child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      ),
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
