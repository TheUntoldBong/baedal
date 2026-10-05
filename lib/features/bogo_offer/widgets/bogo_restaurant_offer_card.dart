import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_offer_details_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoRestaurantOfferCard extends StatelessWidget {
  final BogoBundleModel bundle;
  final String? offerLabel;
  final String? validUntil;
  final int? remainingUses;
  const BogoRestaurantOfferCard({super.key, required this.bundle, this.offerLabel, this.validUntil, this.remainingUses});

  void _openDetailsBottomSheet(BuildContext context) {
    BogoOfferDetailsBottomSheet.show(context, bundle: bundle, offerLabel: offerLabel, validUntil: validUntil, remainingUses: remainingUses);
  }

  @override
  Widget build(BuildContext context) {
    final int buyCount = bundle.buyCount ?? bundle.buyItems.length;
    final int getCount = bundle.getCount ?? bundle.freeItems.length;

    final double price = bundle.finalPrice ?? 0;
    final double? originalPrice = bundle.bundlePrice;
    final bool hasDiscount = originalPrice != null && originalPrice > price;
    final double discountPercentage = bundle.discountPercentage ?? 0;

    final String? distance = bundle.restaurant?.distanceLabel;

    return Container(
    padding: const EdgeInsets.all(Dimensions.paddingOverSmall),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      color: context.outline,
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _openDetailsBottomSheet(context),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: context.surfaceContainer,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PairedImages(
                  buyCount: buyCount,
                  buyItems: bundle.buyItems,
                  getCount: getCount,
                  getItems: bundle.freeItems,
                ),
              
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('only_at'.tr, style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                      const SizedBox(height: Dimensions.padding2xSmall),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Dimensions.paddingExtraSmall,
                        runSpacing: Dimensions.padding2xSmall,
                        children: [
                          Text(PriceConverter.convertPrice(price), style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr),
              
                          if(hasDiscount) Text(
                            PriceConverter.convertPrice(originalPrice),
                            textDirection: TextDirection.ltr,
                            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium).copyWith(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: context.textBaseMedium,
                            ),
                          ),
                        ],
                      ),
              
                      if(discountPercentage > 0) ...[
                        const SizedBox(height: Dimensions.padding2xSmall),
                        OfferBadgeWidget(
                          text: '${discountPercentage.toStringAsFixed(discountPercentage % 1 == 0 ? 0 : 1)}% ${'off'.tr}',
                          icon: Images.percentTag,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    
        GestureDetector(
          onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(bundle.restaurant?.id, slug: 'store_${bundle.restaurant?.id}')),
          child: Container(
            width: double.infinity,
            color: context.surface,
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.surfaceContainer, width: 2),
                ),
                child: ClipOval(
                  child: CustomImageWidget(image: bundle.restaurant?.logoFullUrl ?? '', height: 40, width: 40, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(bundle.restaurant?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
                    const SizedBox(height: Dimensions.padding2xSmall),
              
                    Row(children: [
                      if(bundle.restaurant?.deliveryTime != null && bundle.restaurant!.deliveryTime!.isNotEmpty) ...[
                        Icon(Icons.access_time, size: 16, color: context.iconBaseMedium),
                        const SizedBox(width: Dimensions.padding2xSmall),
                        Text(bundle.restaurant!.deliveryTime!, style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium)),
                        const SizedBox(width: Dimensions.padding2xSmall),
                      ],
                      if(distance != null)
                        Text('($distance)', style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                    ]),
                  ],
                ),
              ),
              
              Icon(
                Get.find<LocalizationController>().isLtr ? Icons.arrow_forward : Icons.arrow_back,
                size: 20,
                color: context.iconBaseDefault,
              ),
            ]),
          ),
        ),
      ],
    ),
    );
  }
}

class _PairedImages extends StatelessWidget {
  final int buyCount;
  final List<BogoOfferItemModel> buyItems;
  final int getCount;
  final List<BogoOfferItemModel> getItems;

  const _PairedImages({
    required this.buyCount,
    required this.buyItems,
    required this.getCount,
    required this.getItems,
  });

  static const double _clusterHeight = 90;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DynamicImageGrid(
              count: buyCount,
              items: buyItems,
              height: _clusterHeight,
            ),
            const SizedBox(width: Dimensions.paddingSmall),
            _DynamicImageGrid(
              count: getCount,
              items: getItems,
              height: _clusterHeight,
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: Dimensions.paddingSmall),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text('$buyCount + $getCount', style: context.heading.small.strong),
        ),
      ],
    );
  }
}

class _DynamicImageGrid extends StatelessWidget {
  final int count;
  final List<BogoOfferItemModel> items;
  final double height;

  const _DynamicImageGrid({
    required this.count,
    required this.items,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: AspectRatio(
        aspectRatio: count > 2 ? 0.8 : 1.0,
        child: _buildLayout(context),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    if (count <= 1 || items.length == 1) {
      return _buildImage(context, items.first.product.imageFullUrl ?? '');
    }

    if (count == 2 || items.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildImage(context, items[0].product.imageFullUrl ?? '')),
          const SizedBox(width: Dimensions.padding2xSmall),
          Expanded(child: _buildImage(context, items[1].product.imageFullUrl ?? '')),
        ],
      );
    }

    if (count == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(context, items[0].product.imageFullUrl ?? '')),
                const SizedBox(width: Dimensions.padding2xSmall),
                Expanded(child: _buildImage(context, items.length > 1 ? items[1].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? '')),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.padding2xSmall),
          Expanded(child: _buildImage(context, items.length > 2 ? items[2].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? '')),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(context, items[0].product.imageFullUrl ?? '')),
              const SizedBox(width: Dimensions.padding2xSmall),
              Expanded(child: _buildImage(context, items.length > 1 ? items[1].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? '')),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.padding2xSmall),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(context, items.length > 2 ? items[2].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? '')),
              const SizedBox(width: Dimensions.padding2xSmall),
              Expanded(
                child: count > 4
                  ? _buildImage(context, items.length > 3 ? items[3].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? '', overflowCount: count - 3)
                  : _buildImage(context, items.length > 3 ? items[3].product.imageFullUrl ?? '' : items[0].product.imageFullUrl ?? ''),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String url, {int? overflowCount}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            image: url,
            fit: BoxFit.cover,
          ),
          if (overflowCount != null)
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
              child: Center(
                child: Text(
                  '+$overflowCount',
                  style: TextStyle(color: context.surfaceContainer, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}