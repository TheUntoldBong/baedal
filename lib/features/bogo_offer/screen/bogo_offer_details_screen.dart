import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/controllers/bogo_offer_details_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_restaurant_offer_card.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_restaurant_offer_card_shimmer.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoOfferDetailsScreen extends StatefulWidget {
  final String? offerIdOrSlug;
  const BogoOfferDetailsScreen({super.key, this.offerIdOrSlug});

  @override
  State<BogoOfferDetailsScreen> createState() => _BogoOfferDetailsScreenState();
}

class _BogoOfferDetailsScreenState extends State<BogoOfferDetailsScreen> {
  static const int _shimmerItemCount = 3;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.offerIdOrSlug != null && widget.offerIdOrSlug!.isNotEmpty) {
        Get.find<BogoOfferDetailsController>().getBogoOfferDetails(widget.offerIdOrSlug!);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if(_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    Get.find<BogoOfferDetailsController>().loadMoreBundles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'bogo_offer_details'.tr),
      backgroundColor: context.surfaceContainer,
      body: GetBuilder<BogoOfferDetailsController>(builder: (bogoOfferDetailsController) {
        final BogoOfferDetailsResponseModel? details = bogoOfferDetailsController.bogoOfferDetailsModel;
        final bool isLoading = bogoOfferDetailsController.isLoading;
        final bool paginate = bogoOfferDetailsController.bundlePaginate;
        final List<BogoBundleModel> bundles = details?.bundles ?? [];

        return details == null && !isLoading ? const _OfferUnavailableView() : CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 2.5,
              child: isLoading
                ? Shimmer(child: Container(color: Theme.of(context).shadowColor))
                : CustomImageWidget(image: details?.imageFullUrl ?? '', fit: BoxFit.fill),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: isLoading ? const _HeaderShimmer() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingMedium),
                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(details?.offerLabel ?? '', style: context.heading.large.strong.overrideWith(color: context.textInfosMedium)),
                    if(details?.validUntil != null)
                      Text('${'valid_until'.tr} : ${details!.validUntil}', style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),
                  ]),
                ),

                if(details?.title != null && details!.title!.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingMedium),
                  Text(details.title!, style: context.heading.extraLarge.strong),
                ],

                if(details?.description != null && details!.description!.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingExtraSmall),
                  Text(details.description!, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                ],
              ]),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, 0, Dimensions.paddingDefault, Dimensions.paddingDefault),
            sliver: isLoading ? SliverList.separated(
              itemCount: _shimmerItemCount,
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingLarge),
              itemBuilder: (context, index) => const BogoRestaurantOfferCardShimmer(),
            ) : bundles.isEmpty ? SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: NoDataScreen(title: 'no_offer_found'.tr)),
            ) : SliverList.separated(
              itemCount: bundles.length + (paginate ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingLarge),
              itemBuilder: (context, index) => index < bundles.length
                ? BogoRestaurantOfferCard(bundle: bundles[index], offerLabel: details?.offerLabel, validUntil: details?.validUntil, remainingUses: details?.remainingUses)
                : const Padding(
                    padding: EdgeInsets.only(top: Dimensions.paddingSmall),
                    child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _OfferUnavailableView extends StatelessWidget {
  const _OfferUnavailableView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.paddingLarge),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [


        Text('This offer is currently unavailable!', style: context.heading.large.semiBold,),
        Text('Please tap the button below to explore other available offers.', style: context.body.small.regular, textAlign: TextAlign.center,),
        SizedBox(height: 40,),
        IconButton(onPressed: () => Get.offNamed(RouteHelper.getBogoOfferRoute()), icon: Icon(Icons.arrow_circle_right_outlined, color: context.primary, size: 40,))
      ]),
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).shadowColor;

    return Shimmer(
      child: Container(
        width: double.infinity, height: 44,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      ),
    );
  }
}
