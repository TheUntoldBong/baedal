import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/search/helper/restaurant_tag_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

enum RestaurantCardType {compact, detailed}

class RestaurantCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final double? width;
  final VoidCallback? onTap;
  final RestaurantCardType type;
  final bool isQuick;
  final bool isFeatured;
  final bool isTopPick;
  final bool isQuickDelivery;

  const RestaurantCardWidget({
    super.key, required this.restaurant, this.width, this.onTap, this.type = RestaurantCardType.compact,
    this.isQuick = false, this.isFeatured = false, this.isTopPick = false, this.isQuickDelivery = false});

  const RestaurantCardWidget.detailed({
    super.key, required this.restaurant, this.width, this.onTap,
    this.isQuick = false, this.isFeatured = false, this.isTopPick = false, this.isQuickDelivery = false
  }) : type = RestaurantCardType.detailed;

  static const double _cardRadius = 14;
  static const double _imageAspectRatio = 2;

  bool get _isDetailed => type == RestaurantCardType.detailed;

  @override
  Widget build(BuildContext context) {
    final String cleanName = (restaurant.name ?? '')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\"', '"');

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: context.outline.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: CustomInkWellWidget(
          onTap: onTap ?? (() => Get.toNamed(
            RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''),
            arguments: RestaurantScreen(restaurant: restaurant),
          )),
          radius: _cardRadius,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _ImageHeader(restaurant: restaurant, width: width, type: type),

            Padding(
              padding: _isDetailed
                  ? const EdgeInsets.fromLTRB(12, 10, 12, 12)
                  : const EdgeInsets.fromLTRB(10, 6, 10, 7),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  cleanName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: _isDetailed ? context.heading.large : context.heading.defaultSize,
                ),

                if(_isDetailed && !isFeatured && restaurant.categoryIds != null && restaurant.categoryIds!.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.padding2xSmall),
                  _CategoryTagsRow(categoryIds: restaurant.categoryIds!),
                ],

                const SizedBox(height: Dimensions.paddingOverSmall),
                _MetaRow(restaurant: restaurant, type: type, isQuickDelivery: isQuickDelivery),

                if (type != RestaurantCardType.compact) ...[
                  const SizedBox(height: Dimensions.padding2xSmall),
                  OfferTagsRow(data: restaurant),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final Restaurant restaurant;
  final double? width;
  final RestaurantCardType type;

  const _ImageHeader({required this.restaurant, required this.width, required this.type});

  bool get _isDetailed => type == RestaurantCardType.detailed;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = restaurant.open == 1 && (restaurant.active ?? true);
    final double badgeInset = _isDetailed ? Dimensions.paddingSmall : 13;

    return SizedBox(
      width: _isDetailed ? null : (width ?? double.infinity),
      child: AspectRatio(
        aspectRatio: RestaurantCardWidget._imageAspectRatio,
        child: Stack(children: [

        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(RestaurantCardWidget._cardRadius)),
            child: CustomImageWidget(image: restaurant.coverPhotoFullUrl ?? '', fit: BoxFit.cover, isRestaurant: true),
          ),
        ),

        if(!isAvailable && _isDetailed) _ClosedOverlay(data: restaurant),
          Positioned(
          top: badgeInset, left: badgeInset,
          child: Row(
            spacing: Dimensions.paddingExtraSmall,
            children: [
              if(restaurant.verifiedSeller ?? false) Container(
                padding:  EdgeInsets.symmetric(horizontal: !(restaurant.isNew ?? false) ? Dimensions.paddingSmall : Dimensions.padding2xSmall, vertical: Dimensions.padding2xSmall),
                decoration: BoxDecoration(color: context.bgInfoDefault, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                child: Row(
                  spacing: Dimensions.paddingExtraSmall, mainAxisSize: MainAxisSize.min, children: [
                  CustomAssetImageWidget(Images.verifiedIcon, height: 12, width: 12, color: context.iconInfoOn),
                  if(!(restaurant.isNew ?? false))Text(
                    'verified'.tr,
                    style: context.subHeading.small.overrideWith(color: context.textInfoOn),
                  ),
                ]),
              ),
              if(restaurant.isNew ?? false) Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                decoration: BoxDecoration(color: context.bgWarningDefault, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                child: Text(
                  'new'.tr,
                  style: context.subHeading.small.overrideWith(color: context.textInfoOn),
                ),
              ),

            ],
          ),
        ),

        if((restaurant.ad ?? false)) Positioned(
          right: badgeInset, bottom: badgeInset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.bgUtilBlanket,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child:  Text('AD', style: context.subHeading.small.strong.overrideWith(color: Colors.white))
          ),
        ),

        if(!isAvailable && !_isDetailed) NotAvailableWidget(
          isRestaurant: true, opacity: 0.6, color: context.surfaceContainer, radius: RestaurantCardWidget._cardRadius,
        ),

        Positioned(
          top: badgeInset, right: badgeInset,
          child: GetBuilder<FavouriteController>(builder: (favouriteController) {
            bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
            return CustomFavouriteWidget(isWished: isWished, isRestaurant: true, id: restaurant.id!, size: 20, widgetSize: 32, isCircular: true,);
          }),
        ),

        ]),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantCardType type;
  final bool isQuickDelivery;

  const _MetaRow({required this.restaurant, required this.type, this.isQuickDelivery = false});

  bool get _isDetailed => type == RestaurantCardType.detailed;

  @override
  Widget build(BuildContext context) {
    final double rating = restaurant.avgRating ?? 0;
    final double iconSize = 10;
    final TextStyle metaStyleFirst = context.subHeading.small;
    final TextStyle metaStyleSecond = context.subHeading.small.overrideWith(color: context.textBaseMedium);

    final int reviewCount = restaurant.ratingCount ?? restaurant.reviewsCommentsCount ?? 0;
    final String ratingLabel = _isDetailed
        ? '${rating.toStringAsFixed(1)} '
        : '${rating.toStringAsFixed(1)} ';
    final String ratingCount = _isDetailed
        ? '($reviewCount${reviewCount > 5 ? '+' : ''})'
        : '(${reviewCount > 150 ? '150+' : reviewCount})';

    final String timeLabel = restaurant.deliveryTime ?? '';
    final bool showDistance = !isQuickDelivery && (restaurant.distanceLabel?.isNotEmpty ?? false);
    final double deliveryFee = num.tryParse(restaurant.deliveryFee ?? '')?.toDouble() ?? 0;
    final bool showDeliveryFee = _isDetailed && deliveryFee > 0;

    String characteristics = '';
    if(_isDetailed && restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}${v.trim()}';
      }
    }

    final Widget row = Row(children: [
      if(rating > 0) ...[
        CustomAssetImageWidget(Images.starFill, height: iconSize, width: iconSize, color: context.primary),
        const SizedBox(width: 2),
        Text(ratingLabel, style: metaStyleFirst),
        Text(ratingCount, style: metaStyleSecond),
        const SizedBox(width: Dimensions.paddingSmall),
      ],

      ...[
        CustomAssetImageWidget(Images.timeIcon, height: iconSize, width: iconSize, color: context.iconColor),
        const SizedBox(width: 4),
        Flexible(child: Text(timeLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: metaStyleFirst)),
      ],

      if(showDistance) ...[
        const SizedBox(width: 4),
        Flexible(child: Text('(${restaurant.distanceLabel})', maxLines: 1, overflow: TextOverflow.ellipsis, style: metaStyleSecond)),
      ],

      if(showDeliveryFee) ...[
        const SizedBox(width: 6),
        CustomAssetImageWidget(Images.rideIcon, height: iconSize, width: iconSize, color: context.iconColor),
        const SizedBox(width: 4),
        Text(PriceConverter.convertPrice(deliveryFee), style: metaStyleFirst),
      ],
    ]);

    if(characteristics.isEmpty) return row;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        characteristics,
        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
      ),
      const SizedBox(height: Dimensions.padding2xSmall),
      row,
    ]);
  }
}

class _ClosedOverlay extends StatelessWidget {
  final Restaurant data;
  const _ClosedOverlay({required this.data});

  @override
  Widget build(BuildContext context) {
    final String label = data.restaurantOpeningTime == 'closed'
        ? 'closed_now'.tr
        : '${'closed_now'.tr} ${(data.active ?? false) ? '(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(data.restaurantOpeningTime!)})' : ''}'.trim();

    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(RestaurantCardWidget._cardRadius)),
          color: Colors.black54,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
          child: Text(
            label, textAlign: TextAlign.center,
            style: context.subHeading.small.overrideWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class OfferTagsRow extends StatelessWidget {
  final Restaurant data;
  final bool showDiscount;
  final int maxVisible;
  const OfferTagsRow({required this.data, super.key, this.maxVisible = 3, this.showDiscount = true});


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String?>> tags = RestaurantTagHelper.offerTags(data, showDiscount: showDiscount);
    if (tags.isEmpty) return const SizedBox.shrink();

    final List<Map<String, String?>> visible = tags.take(maxVisible).toList();
    final int overflow = tags.length - visible.length;

    return Row(
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: Dimensions.padding2xSmall,
              children: visible.map((tag) => OfferBadgeWidget(text: tag['text']!, icon: tag['icon'])).toList(),
            ),
          ),
        ),
        if (overflow > 0) Row(
          children: [
            const SizedBox(width: Dimensions.padding2xSmall,),
            _MoreTagsChip(count: overflow),
          ],
        ),
      ],
    );
  }
}

class _MoreTagsChip extends StatelessWidget {
  final int count;
  const _MoreTagsChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall,vertical: Dimensions.paddingOverSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest ,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: Text(
        '+$count',
        style: context.heading.small.overrideWith(color: context.textBaseMedium),
      ),
    );
  }
}

class _CategoryTagsRow extends StatelessWidget {
  final List<int> categoryIds;
  const _CategoryTagsRow({required this.categoryIds});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CategoryController>()) return const SizedBox.shrink();
    final CategoryController cc = Get.find<CategoryController>();
    final List<String> names = categoryIds
        .map((id) => _categoryNameById(cc, id))
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return const SizedBox.shrink();
    return Text(
      names.join(', '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.body.small,
    );
  }

  String _categoryNameById(CategoryController cc, int id) {
    final match = cc.categoryList?.where((c) => c.id == id);
    return (match != null && match.isNotEmpty) ? (match.first.name ?? '') : '';
  }
}

class RestaurantCardShimmerWidget extends StatelessWidget {
  final double? width;
  final RestaurantCardType type;

  const RestaurantCardShimmerWidget({super.key, this.width, this.type = RestaurantCardType.compact});

  const RestaurantCardShimmerWidget.detailed({super.key, this.width}) : type = RestaurantCardType.detailed;

  bool get _isDetailed => type == RestaurantCardType.detailed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RestaurantCardWidget._cardRadius),
        border: Border.all(
          color: context.outline.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RestaurantCardWidget._cardRadius),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          SizedBox(
            width: _isDetailed ? null : (width ?? double.infinity),
            child: AspectRatio(
              aspectRatio: RestaurantCardWidget._imageAspectRatio,
              child: const _ShimmerBox(height: double.infinity, width: double.infinity, radius: 0),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const _ShimmerBox(height: 16, width: 160),

            if(_isDetailed) ...[
              const SizedBox(height: Dimensions.padding2xSmall),
              const _ShimmerBox(height: 12, width: 120),
            ],

            const SizedBox(height: Dimensions.padding2xSmall),
            const Row(children: [
              _ShimmerBox(height: 12, width: 60),
              SizedBox(width: Dimensions.paddingSmall),
              _ShimmerBox(height: 12, width: 70),
              SizedBox(width: Dimensions.paddingSmall),
              _ShimmerBox(height: 12, width: 50),
            ]),

            if(_isDetailed) ...[
              const SizedBox(height: Dimensions.padding2xSmall),
              const Row(children: [
                _ShimmerBox(height: 20, width: 80, radius: Dimensions.radiusExtraSmall),
                SizedBox(width: Dimensions.padding2xSmall),
                _ShimmerBox(height: 20, width: 64, radius: Dimensions.radiusExtraSmall),
              ]),
            ],
          ]),
        ),
      ]),
    ));
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({required this.height, required this.width, this.radius = Dimensions.radiusExtraSmall});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Shimmer(
        child: Container(height: height, width: width, color: Theme.of(context).shadowColor),
      ),
    );
  }
}

class RestaurantCardShimmerListWidget extends StatelessWidget {
  final int itemCount;
  final RestaurantCardType type;

  const RestaurantCardShimmerListWidget({super.key, this.itemCount = 5, this.type = RestaurantCardType.detailed});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingExtraLarge),
      itemBuilder: (context, index) => RestaurantCardShimmerWidget(type: type),
    );
  }
}
