import 'dart:async';

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_message_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/cuisine/domain/models/cuisine_model.dart' as cuisine_model;
import 'package:stackfood_multivendor/features/happy_hour/domain/models/happy_hour_model.dart';
import 'package:stackfood_multivendor/features/happy_hour/screens/happy_hour_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatMetadataViewWidget extends StatelessWidget {
  final AiChatMetadata metadata;
  const AiChatMetadataViewWidget({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = [];

    if (metadata.hasProducts) {
      sections.add(_SectionTitle(title: 'recommended_products'.tr));
      sections.add(SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            left: Dimensions.padding2xSmall,
            top: Dimensions.padding2xSmall,
            right: Dimensions.padding2xSmall,
          ),
          itemCount: metadata.products!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) {
            return _ProductCard(product: metadata.products![index]);
          },
        ),
      ));
    }

    if (metadata.hasCategories) {
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_SectionTitle(title: 'categories'.tr));
      sections.add(SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: metadata.categories!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) {
            return _CategoryCard(category: metadata.categories![index]);
          },
        ),
      ));
    }

    if (metadata.hasRestaurants) {
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_SectionTitle(title: 'recommended_restaurants'.tr));
      sections.add(SizedBox(
        height: 215,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding2xSmall,
            vertical: Dimensions.padding2xSmall,
          ),
          itemCount: metadata.restaurants!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) {
            return _AiChatRestaurantCard(restaurant: metadata.restaurants![index]);
          },
        ),
      ));
    }

    if (metadata.hasCuisines) {
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_SectionTitle(title: 'cuisines'.tr));
      sections.add(SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: metadata.cuisines!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) => _CuisineCard(cuisine: metadata.cuisines![index]),
        ),
      ));
    }

    if (metadata.hasHappyHours) {
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_SectionTitle(title: 'happy_hour_running'.tr));
      for (final HappyHourModel happyHour in metadata.happyHours!) {
        sections.add(Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingExtraSmall),
          child: _HappyHourCard(happyHour: happyHour),
        ));
      }
    }

    if (metadata.hasBogoOffers) {
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_SectionTitle(title: 'bogo_offers'.tr));
      sections.add(SizedBox(
        height: 172,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
          itemCount: metadata.bogoOffers!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) => _BogoOfferCard(offer: metadata.bogoOffers![index]),
        ),
      ));
    }

    if (metadata.hasCart) {
      final AiChatCart cart = metadata.cart!;
      sections.add(const SizedBox(height: Dimensions.paddingSmall));
      sections.add(_CartSectionTitle(title: 'in_your_cart'.tr, itemCount: cart.totalItems ?? 0));
      sections.add(_CartSection(cart: cart));
    }

    if (sections.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding2xSmall),
      child: Text(
        title,
        style: context.subHeading.small.medium.overrideWith(color: context.textBaseMedium),
      ),
    );
  }
}

class _CartSectionTitle extends StatelessWidget {
  final String title;
  final int itemCount;
  const _CartSectionTitle({required this.title, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingExtraSmall),
      child: Row(children: [
        Icon(Icons.shopping_cart_outlined, size: 15, color: context.textBaseMedium),
        const SizedBox(width: 4),
        Text(
          itemCount > 0 ? '$title · $itemCount ${'items'.tr}' : title,
          style: context.subHeading.small.medium.overrideWith(color: context.textBaseMedium),
        ),
      ]),
    );
  }
}

class _CartSection extends StatelessWidget {
  final AiChatCart cart;
  const _CartSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final bool anyStoreScrolls = cart.stores.any((g) => g.items.length > _CartStoreItemList.maxVisibleItems);
    final double maxWidth = MediaQuery.of(context).size.width * 0.78;

    final List<Widget> children = [];
    for (int i = 0; i < cart.stores.length; i++) {
      if (i != 0) {
        children.add(const SizedBox(height: Dimensions.paddingSmall));
      }
      children.add(_CartStoreGroupSection(storeGroup: cart.stores[i]));
    }
    if (cart.grandTotal != null) {
      children.add(const SizedBox(height: Dimensions.paddingSmall));
      children.add(_CartGrandTotalBar(grandTotal: cart.grandTotal!));
    }

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getCartBundleListRoute()),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: anyStoreScrolls ? column : IntrinsicWidth(child: column),
      ),
    );
  }
}

class _CartStoreGroupSection extends StatelessWidget {
  final AiChatCartStoreGroup storeGroup;
  const _CartStoreGroupSection({required this.storeGroup});

  @override
  Widget build(BuildContext context) {
    final String storeName = storeGroup.storeName ?? '';
    final double subtotal = storeGroup.storeSubtotal ?? 0;
    final Color dividerColor = context.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: context.outlineVariant,
          width: 0.6,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSmall, Dimensions.paddingSmall,
            Dimensions.paddingSmall, Dimensions.paddingExtraSmall,
          ),
          child: Text(
            storeName,
            style: context.subHeading.small.medium,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),

        Divider(height: 1, thickness: 1, color: dividerColor),

        _CartStoreItemList(items: storeGroup.items),

        Divider(height: 1, thickness: 1, color: dividerColor),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Row(children: [
            const Spacer(),
            Text(
              'subtotal'.tr,
              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
            ),
            const SizedBox(width: Dimensions.paddingExtraSmall),
            Text(
              PriceConverter.convertPrice(subtotal),
              style: context.heading.small.strong.overrideWith(color: context.primary),
            ),
          ]),
        ),

      ]),
    );
  }
}

class _CartStoreItemList extends StatelessWidget {
  final List<AiChatCartItem> items;
  const _CartStoreItemList({required this.items});

  static const int maxVisibleItems = 4;
  static const double _rowHeight = 56;

  @override
  Widget build(BuildContext context) {
    final bool needsScroll = items.length > maxVisibleItems;
    final Color separatorColor = context.outlineVariant;

    if (!needsScroll) {
      final List<Widget> rows = [];
      for (int i = 0; i < items.length; i++) {
        if (i != 0) {
          rows.add(Divider(height: Dimensions.paddingSmall, thickness: 0.6, color: separatorColor));
        }
        rows.add(_CartItemRow(cartItem: items[i]));
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: rows),
      );
    }

    return SizedBox(
      height: (_rowHeight * maxVisibleItems) + (Dimensions.paddingSmall * (maxVisibleItems - 1)),
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(height: Dimensions.paddingSmall, thickness: 0.6, color: separatorColor),
        itemBuilder: (context, index) => SizedBox(
          height: _rowHeight,
          child: _CartItemRow(cartItem: items[index]),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final AiChatCartItem cartItem;
  const _CartItemRow({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    if (cartItem.isBogoBundle) {
      return _CartBundleRow(cartItem: cartItem, details: cartItem.bogoDetails!);
    }
    final String name = cartItem.name ?? '';
    final String image = cartItem.imageFullUrl ?? '';
    final int qty = cartItem.quantity ?? 0;
    final double lineTotal = cartItem.lineTotal ?? ((cartItem.unitPrice ?? 0) * qty);
    final String variation = cartItem.variation ?? '';

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: CustomImageWidget(
          image: image, isFood: true,
          height: 40, width: 40, fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

          Text(
            name,
            style: context.subHeading.small.medium,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Row(children: [
            if (variation.isNotEmpty) ...[
              Flexible(child: _VariationPill(variation: variation)),
              const SizedBox(width: Dimensions.paddingExtraSmall),
            ],
            Text(
              '${'qty'.tr}: $qty',
              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
            ),
          ]),

        ]),
      ),

      const SizedBox(width: Dimensions.paddingSmall),
      SizedBox(
        width: 70,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            PriceConverter.convertPrice(lineTotal),
            style: context.heading.small.regular,
          ),
        ),
      ),
    ]);
  }
}

class _CartBundleRow extends StatelessWidget {
  final AiChatCartItem cartItem;
  final AiChatCartBogoDetails details;
  const _CartBundleRow({required this.cartItem, required this.details});

  @override
  Widget build(BuildContext context) {
    String name = details.offerTitle ?? cartItem.name ?? '';
    String image = cartItem.imageFullUrl ?? '';
    int qty = details.quantity ?? cartItem.quantity ?? 0;
    double lineTotal = details.totalFinalPrice ?? details.totalPrice ?? cartItem.lineTotal ?? 0;
    double savings = details.savings;
    int freeCount = details.freeItems.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: CustomImageWidget(
            image: image, isFood: true,
            height: 40, width: 40, fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

            Row(children: [
              Flexible(
                child: Text(
                  name,
                  style: context.subHeading.small.medium,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Dimensions.paddingExtraSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: 1),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  'bogo'.tr,
                  style: context.body.extraSmall.medium.overrideWith(color: context.primary),
                ),
              ),
            ]),
            const SizedBox(height: 2),

            Row(children: [
              Text(
                '${'qty'.tr}: $qty',
                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
              ),
              if (freeCount > 0) ...[
                const SizedBox(width: Dimensions.paddingExtraSmall),
                Flexible(
                  child: Text(
                    '· $freeCount ${'free_item'.tr}',
                    style: context.body.extraSmall.regular.overrideWith(color: context.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ]),

          ]),
        ),

        const SizedBox(width: Dimensions.paddingSmall),
        SizedBox(
          width: 70,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(PriceConverter.convertPrice(lineTotal), style: context.heading.small.regular),
            ),
            if (savings > 0) FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                PriceConverter.convertPrice(details.originalPrice ?? 0),
                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
            ),
          ]),
        ),
      ]),

      if (savings > 0) Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '${'you_save'.tr} ${PriceConverter.convertPrice(savings)}',
          style: context.body.extraSmall.medium.overrideWith(color: context.primary),
        ),
      ),

      if (!details.isAvailable) Padding(
        padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.error_outline, size: 13, color: context.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              details.unavailableReason ?? 'not_available_now'.tr,
              style: context.body.extraSmall.regular.overrideWith(color: context.error),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _VariationPill extends StatelessWidget {
  final String variation;
  const _VariationPill({required this.variation});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: variation,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: 1),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          variation,
          style: context.body.extraSmall.regular.overrideWith(color: context.primary),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CartGrandTotalBar extends StatelessWidget {
  final double grandTotal;
  const _CartGrandTotalBar({required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSmall,
        vertical: Dimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Text(
          'grand_total'.tr,
          style: context.subHeading.small.medium.overrideWith(color: context.primary),
        ),
        const Spacer(),
        Text(
          PriceConverter.convertPrice(grandTotal),
          style: context.heading.small.strong.overrideWith(color: context.primary),
        ),
      ]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: category.id == null ? null : () => Get.toNamed(RouteHelper.getCategoryProductRoute(
        category.id, category.name ?? '',
      )),
      child: SizedBox(
        width: 90,
        child: Column(children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: category.imageFullUrl ?? '',
                height: 60, width: 60, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.padding2xSmall),

          Text(
            category.name ?? '',
            style: context.subHeading.extraSmall.medium,
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}

class _CuisineCard extends StatelessWidget {
  final cuisine_model.Cuisines cuisine;
  const _CuisineCard({required this.cuisine});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: cuisine.id == null ? null : () => Get.toNamed(
        RouteHelper.getCuisineRestaurantRoute(cuisine.id, cuisine.name),
      ),
      child: SizedBox(
        width: 90,
        child: Column(children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: cuisine.imageFullUrl ?? '',
                height: 60, width: 60, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.padding2xSmall),

          Text(
            cuisine.name ?? '',
            style: context.subHeading.extraSmall.medium,
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}

class _BogoOfferCard extends StatelessWidget {
  final BogoOfferCardModel offer;
  const _BogoOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    String? idOrSlug = (offer.slug != null && offer.slug!.isNotEmpty) ? offer.slug : offer.id?.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: idOrSlug == null ? null : () => Get.toNamed(RouteHelper.getBogoOfferDetailsRoute(idOrSlug)),
      child: Container(
        width: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.outlineVariant, width: 0.6),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          SizedBox(
            height: 90, width: double.infinity,
            child: CustomImageWidget(
              image: offer.imageFullUrl ?? '',
              fit: BoxFit.cover,
              placeholderBgColor: context.surfaceContainerLowest,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

              if (offer.offerLabel != null && offer.offerLabel!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: 1),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    offer.offerLabel!,
                    style: context.body.extraSmall.medium.overrideWith(color: context.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 2),

              Text(
                offer.title ?? '',
                style: context.subHeading.small.medium,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),

              if (offer.validUntil != null && offer.validUntil!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '${'valid_until'.tr} : ${offer.validUntil}',
                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],

            ]),
          ),

        ]),
      ),
    );
  }
}

class _HappyHourCard extends StatefulWidget {
  final HappyHourModel happyHour;
  const _HappyHourCard({required this.happyHour});

  @override
  State<_HappyHourCard> createState() => _HappyHourCardState();
}

class _HappyHourCardState extends State<_HappyHourCard> {
  late int _remaining;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = widget.happyHour.remainingSeconds ?? 0;
    if (_remaining > 0) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _remaining = _remaining > 0 ? _remaining - 1 : 0);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _countdown {
    int hours = _remaining ~/ 3600;
    int minutes = (_remaining % 3600) ~/ 60;
    int seconds = _remaining % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return hours > 0 ? '${two(hours)}:${two(minutes)}:${two(seconds)}' : '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    double discount = widget.happyHour.discount ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: () => HappyHourScreen.show(context),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.primary.withValues(alpha: 0.4), width: 0.6),
        ),
        child: Row(children: [
          Icon(Icons.local_fire_department_outlined, size: 20, color: context.primary),
          const SizedBox(width: Dimensions.paddingExtraSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(
                widget.happyHour.title ?? '',
                style: context.subHeading.small.medium,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              if (discount > 0) Text(
                '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% ${'off'.tr}',
                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
              ),
            ]),
          ),

          if (_remaining > 0) Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraSmall, vertical: 2),
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(_countdown, style: context.body.extraSmall.medium.overrideWith(color: context.onPrimary)),
          ),
        ]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final double price = product.price ?? 0;
    final double discount = product.discount ?? 0;
    final String? discountType = product.discountType;
    final double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    final bool hasDiscount = discount > 0 && discountedPrice < price;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: context.outlineVariant,
          width: 0.6,
        ),
      ),
      child: CustomInkWellWidget(
        radius: Dimensions.radiusDefault,
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            FoodBottomSheetWidget(product: product),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: FoodBottomSheetWidget(product: product)),
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              child: CustomImageWidget(
                image: product.imageFullUrl ?? '', isFood: true,
                height: 90, width: double.infinity, fit: BoxFit.cover,
              ),
            ),
            if (hasDiscount)
              Positioned(
                top: Dimensions.padding2xSmall,
                left: Dimensions.padding2xSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.padding2xSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text(
                    discountType == 'percent'
                        ? '${discount.toStringAsFixed(0)}% ${'off'.tr}'
                        : '${PriceConverter.convertPrice(discount)} ${'off'.tr}',
                    style: context.body.extraSmall.medium.overrideWith(color: context.onPrimary),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          Text(
            product.name ?? '',
            style: context.subHeading.small.medium,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Flexible(
              child: Text(
                PriceConverter.convertPrice(discountedPrice),
                style: context.heading.small.strong.overrideWith(color: context.primary),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),

            if (hasDiscount) ...[
              const SizedBox(width: Dimensions.padding2xSmall),
              Flexible(
                child: Text(
                  PriceConverter.convertPrice(price),
                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium).copyWith(decoration: TextDecoration.lineThrough),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

          ]),

        ]),
      ),
      ),
    );
  }
}

class _AiChatRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _AiChatRestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final bool isOpen = restaurant.open == 1;
    final double rating = restaurant.avgRating ?? 0;
    final int ratingCount = restaurant.ratingCount ?? 0;
    final bool hasDistance = restaurant.distanceLabel?.isNotEmpty ?? false;
    final bool freeDelivery = restaurant.freeDelivery == true;
    final String deliveryTime = restaurant.deliveryTime ?? '';

    final double discountAmount = restaurant.discount?.discount ?? 0;
    final bool isPercentDiscount = restaurant.discount?.discountType == 'percent';
    final bool hasDiscount = discountAmount > 0;
    final String discountText = hasDiscount
        ? (isPercentDiscount
            ? '${discountAmount.toStringAsFixed(0)}% ${'off'.tr}'
            : '${PriceConverter.convertPrice(discountAmount)} ${'off'.tr}')
        : '';

    final Color openColor = const Color(0xff1FA84B);
    final Color closedColor = Theme.of(context).colorScheme.error;

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: context.outlineVariant,
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadow,
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: restaurant.id == null ? null : () => Get.toNamed(
          RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
              child: CustomImageWidget(
                image: restaurant.coverPhotoFullUrl ?? '', isRestaurant: true,
                height: 90, width: 230, fit: BoxFit.cover,
              ),
            ),

            if (hasDiscount)
              Positioned(
                top: Dimensions.padding2xSmall,
                left: Dimensions.padding2xSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.padding2xSmall, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text(
                    discountText,
                    style: context.body.extraSmall.medium.overrideWith(color: context.onPrimary),
                  ),
                ),
              ),

            Positioned(
              top: Dimensions.padding2xSmall,
              right: Dimensions.padding2xSmall,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.padding2xSmall, vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (isOpen ? openColor : closedColor).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                ),
                child: Text(
                  isOpen ? 'open_now'.tr : 'closed_now'.tr,
                  style: context.body.extraSmall.medium.overrideWith(color: Colors.white),
                ),
              ),
            ),

            Positioned(
              bottom: -18, left: Dimensions.paddingSmall,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.outlineVariant,
                    width: 0.6,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    image: restaurant.logoFullUrl ?? '', isRestaurant: true,
                    height: 45, width: 45, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSmall,
              Dimensions.paddingLarge + 2,
              Dimensions.paddingSmall,
              Dimensions.paddingSmall,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Flexible(
                  child: Text(
                    restaurant.name ?? '',
                    style: context.subHeading.small.medium,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (restaurant.verifiedSeller == true) ...[
                  const SizedBox(width: Dimensions.padding2xSmall),
                  const RestaurantVerifiedIconWidget(size: 14),
                ],
              ]),
              const SizedBox(height: 2),

              if(rating > 0)
                Row(children: [
                  Icon(Icons.star_rounded, size: 14, color: context.primary),
                  const SizedBox(width: 2),
                  Text(
                    rating > 0 ? rating.toStringAsFixed(1) : '-',
                    style: context.subHeading.extraSmall.medium,
                  ),
                  if (ratingCount > 0) ...[
                    const SizedBox(width: 2),
                    Text(
                      '($ratingCount)',
                      style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ],
                ]),
              const SizedBox(height: Dimensions.padding2xSmall),

              if (deliveryTime.isNotEmpty)
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 13, color: context.textBaseMedium),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deliveryTime,
                      style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              if (deliveryTime.isNotEmpty) const SizedBox(height: 2),

              if (hasDistance)
                Row(children: [
                  Icon(Icons.place_outlined, size: 13, color: context.textBaseMedium),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant.distanceLabel!,
                      style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              if (hasDistance) const SizedBox(height: Dimensions.padding2xSmall),

              if (freeDelivery)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.padding2xSmall, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text(
                    'free_delivery'.tr,
                    style: context.body.extraSmall.medium.overrideWith(color: context.primary),
                  ),
                ),

            ]),
          ),

        ]),
      ),
    );
  }
}
