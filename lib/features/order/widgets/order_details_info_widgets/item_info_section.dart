import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/collapsible_header.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class ItemInfoSection extends StatefulWidget {
  final OrderModel order;
  final List<OrderDetailsModel> orderDetails;

  const ItemInfoSection({super.key, required this.order, required this.orderDetails});

  @override
  State<ItemInfoSection> createState() => _ItemInfoSectionState();
}

class _ItemInfoSectionState extends State<ItemInfoSection> {
  bool _expanded = true;

  String _typeSuffix() {
    final order = widget.order;
    if(order.subscription != null) return '';
    final String typeLabel = order.orderType == 'delivery' ? 'home_delivery'.tr : (order.orderType ?? '').tr;
    if (order.orderType != 'delivery') return typeLabel;

    final String deliveryType = order.deliveryType ?? 'standard';
    const known = ['standard', 'express', 'slightly_delay'];
    final String deliveryLabel = known.contains(deliveryType)
        ? deliveryType.tr
        : (deliveryType.replaceAll('_', ' ').capitalizeFirst ?? deliveryType);
    return '$deliveryLabel - $typeLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CollapsibleSectionHeader(
        title: 'your_order'.tr,
        titleSuffix: _typeSuffix(),
        subscriptionStatus: widget.order.subscription?.status,
        id: widget.order.id ?? 0,
        itemCount: widget.orderDetails.length,
        expanded: _expanded,
        onTap: () => setState(() => _expanded = !_expanded),
      ),

      AnimatedCrossFade(
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            _OrderMetaCard(order: widget.order),

            for (int i = 0; i < widget.orderDetails.length; i++) ...[
              _OrderItemRow(orderDetails: widget.orderDetails[i]),
              if (i != widget.orderDetails.length - 1)
                const SizedBox(height: Dimensions.paddingExtraLarge),
            ],
          ]),
        ),
        crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    ]);
  }
}

class _OrderItemRow extends StatefulWidget {
  final OrderDetailsModel orderDetails;

  const _OrderItemRow({required this.orderDetails});

  @override
  State<_OrderItemRow> createState() => _OrderItemRowState();
}

class _OrderItemRowState extends State<_OrderItemRow> {
  bool _additionalExpanded = false;

  String _buildVariationText() {
    final od = widget.orderDetails;
    String text = '';

    if (od.variation != null && od.variation!.isNotEmpty) {
      for (final variation in od.variation!) {
        text += '${text.isNotEmpty ? ', ' : ''}${variation.name} (';
        for (final value in variation.variationValues ?? []) {
          text += '${text.endsWith('(') ? '' : ', '}${value.level}';
        }
        text += ')';
      }
    } else if (od.oldVariation != null && od.oldVariation!.isNotEmpty) {
      final types = od.oldVariation![0].type?.split('-') ?? const <String>[];
      final choices = od.foodDetails?.choiceOptions;
      if (choices != null && types.length == choices.length) {
        for (int i = 0; i < choices.length; i++) {
          text += '${i == 0 ? '' : ',  '}${choices[i].title} - ${types[i]}';
        }
      } else {
        text = od.oldVariation![0].type ?? '';
      }
    }

    return text;
  }

  String _buildAddOnText() {
    final od = widget.orderDetails;
    if (od.addOns == null || od.addOns!.isEmpty) return '';
    return od.addOns!.map((a) => '${a.name} (${a.quantity})').join(',  ');
  }

  Widget _buildAdditionalInfo(Color color, String variationText, String addOnText) {
    final labelStyle = context.body.defaultSize.regular.overrideWith(color: color);
    final TextSpan textSpan = TextSpan(children: [
      if (variationText.isNotEmpty) ...[
        TextSpan(text: '${'variations'.tr}: ', style: labelStyle),
        TextSpan(text: variationText, style: labelStyle),
      ],
      if (variationText.isNotEmpty && addOnText.isNotEmpty)
        TextSpan(text: '   ', style: labelStyle),
      if (addOnText.isNotEmpty) ...[
        TextSpan(text: '${'addons'.tr}: ', style: labelStyle),
        TextSpan(text: addOnText, style: labelStyle),
      ],
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      const double arrowSpace = 26;
      final TextPainter painter = TextPainter(
        text: textSpan,
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: (constraints.maxWidth - arrowSpace).clamp(0, double.infinity));
      final bool overflows = painter.didExceedMaxLines;

      final Widget richText = Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          maxLines: overflows && !_additionalExpanded ? 1 : null,
          overflow: overflows && !_additionalExpanded ? TextOverflow.ellipsis : TextOverflow.visible,
          text: textSpan,
        ),
      );

      if (!overflows) return richText;

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: richText),
        InkWell(
          onTap: () => setState(() => _additionalExpanded = !_additionalExpanded),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: AnimatedRotation(
              turns: _additionalExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, size: 18),
            ),
          ),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final od = widget.orderDetails;
    if (od.isBogoBundle) {
      return _BogoBundleItemRow(orderDetails: od);
    }

    final imageUrl = od.foodDetails?.imageFullUrl ?? '';
    final discountedPrice = od.price ?? 0;
    final originalPrice = od.foodDetails?.price;
    final hasDiscount = originalPrice != null && originalPrice > discountedPrice;
    final variationText = _buildVariationText();
    final addOnText = _buildAddOnText();
    final hasAdditional = variationText.isNotEmpty || addOnText.isNotEmpty;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: imageUrl.isEmpty
        ? Container(width: 52, height: 52,
            color: context.surface,
            child: Icon(Icons.fastfood, color: context.iconBaseMedium),
          )
        : Image.network(imageUrl, width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(width: 52, height: 52,
              color: context.surface,
              child: Icon(Icons.fastfood, color: context.iconBaseMedium),
            ),
          ),
      ),
      const SizedBox(width: Dimensions.paddingDefault),

      Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      od.foodDetails?.name ?? '',
                      style: context.heading.defaultSize.regular,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text(
                        PriceConverter.convertPrice(discountedPrice),
                        style: context.heading.large,
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          PriceConverter.convertPrice(originalPrice),
                          style: context.heading.defaultSize.regular.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ]),

                  ]),
                ),

                const SizedBox(width: Dimensions.padding2xSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Text(
                    '${'qty'.tr} : ${od.quantity ?? 0}',
                    style: context.heading.defaultSize.medium,
                  ),
                ),
              ],
            ),

            if (hasAdditional) ...[
              const SizedBox(height: 6),
              _buildAdditionalInfo(context.textBaseMedium, variationText, addOnText),
            ],
          ],
        ),
      ),
    ]);
  }
}

class _BogoBundleItemRow extends StatelessWidget {
  final OrderDetailsModel orderDetails;
  const _BogoBundleItemRow({required this.orderDetails});

  static List<String> _thumbnailsOf(List<OrderBogoItemModel>? items) {
    return (items ?? const []).map((item) => item.imageFullUrl ?? '').where((url) => url.isNotEmpty).toList();}

  @override
  Widget build(BuildContext context) {
    final OrderBogoDetailsModel bogo = orderDetails.bogoDetails!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(
            bogo.offerTitle ?? 'bogo_offer'.tr,
            style: context.heading.defaultSize.regular,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Dimensions.padding2xSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Text(
            '${'qty'.tr} : ${orderDetails.quantity ?? bogo.quantity ?? 0}',
            style: context.heading.defaultSize.medium,
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.padding2xSmall),

      Text(
        PriceConverter.convertPrice(bogo.totalPrice ?? 0),
        style: context.heading.large, textDirection: TextDirection.ltr,
      ),
      const SizedBox(height: Dimensions.paddingSmall),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _BundleThumbnailGroup(label: 'buying_item'.tr, thumbnails: _thumbnailsOf(bogo.buyItems)),
        const SizedBox(width: Dimensions.paddingExtraLarge),
        _BundleThumbnailGroup(label: 'free_item'.tr, thumbnails: _thumbnailsOf(bogo.freeItems)),
      ]),
    ]);
  }
}

class _BundleThumbnailGroup extends StatelessWidget {
  final String label;
  final List<String> thumbnails;
  const _BundleThumbnailGroup({required this.label, required this.thumbnails});

  static const double _size = 44;
  static const double _overlap = 26;

  @override
  Widget build(BuildContext context) {
    final List<String> visible = thumbnails.take(2).toList();
    final int overflow = thumbnails.length - visible.length;
    final int cardCount = visible.length + (overflow > 0 ? 1 : 0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: context.body.small.overrideWith(color: context.textBaseMedium)),
      const SizedBox(height: Dimensions.paddingSmall),

      visible.isEmpty ? const SizedBox() : SizedBox(
        height: _size,
        width: _size + (cardCount - 1) * _overlap,
        child: Stack(
          children: [
            ...List.generate(visible.length, (index) => Positioned(
              left: index * _overlap,
              child: Container(
                width: _size, height: _size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: context.surfaceContainer, width: 2),
                ),
                child: CustomImageWidget(image: visible[index], height: _size, width: _size, fit: BoxFit.cover, isFood: true),
              ),
            )),

            if(overflow > 0) Positioned(
              left: visible.length * _overlap,
              child: Container(
                height: _size, width: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: context.surfaceContainer, width: 2),
                ),
                child: Text('+$overflow', style: context.body.small.strong),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _OrderMetaCard extends StatelessWidget {
  final OrderModel order;
  const _OrderMetaCard({required this.order});

  String? _subscriptionText() {
    final sub = order.subscription;
    if (sub == null) return null;
    final String type = (sub.type ?? '').tr;
    if (sub.startAt != null && sub.endAt != null) {
      return '$type (${DateConverter.dateTimeToMonth(sub.startAt!)} - ${DateConverter.dateTimeToMonth(sub.endAt!)})';
    }
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDineIn = order.orderType == 'dine_in';
    final bool scheduled = order.scheduled == 1 && order.scheduleAt != null;
    final bool hasExtraPacking = (order.extraPackagingAmount ?? 0) > 0;
    final bool hasCutlery = order.cutlery != null;
    final bool hasProof = order.orderStatus == 'delivered' && order.orderProofFullUrl != null && order.orderProofFullUrl!.isNotEmpty;
    final bool isPos = order.isPos ?? false;
    final String? subscriptionText = _subscriptionText();

    final List<Widget> rows = [
      if (subscriptionText != null)
        _MetaRow(label: 'type'.tr, value: subscriptionText),
      if (order.createdAt != null)
        _MetaRow(label: 'order_placed'.tr, value: DateConverter.dateTimeStringToDateTime(order.createdAt!)),
      if (isDineIn && order.scheduleAt != null)
        _MetaRow(label: 'dine_in_date'.tr, value: DateConverter.dateTimeStringToDateTime(order.scheduleAt!)),
      if (scheduled && !isDineIn)
        _MetaRow(label: 'scheduled_at'.tr, value: DateConverter.dateTimeStringToDateTime(order.scheduleAt!)),
      if (hasExtraPacking)
        _MetaRow(label: 'extra_packaging'.tr, value: PriceConverter.convertPrice(order.extraPackagingAmount)),
      if (hasCutlery)
        _MetaRow(label: 'cutlery'.tr, value: (order.cutlery! ? 'yes' : 'no').tr),
      if(isPos)
        _MetaRow(label: 'POS', value: 'yes'.tr),
      if(true)
        _MetaRow(label: order.orderType == 'delivery' ? 'delivery_verification_code'.tr : 'order_verification_code'.tr, value: order
            .otp.toString())
    ];

    if (rows.isEmpty && !hasProof) return const SizedBox();


    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i != rows.length - 1 || hasProof)
            Divider(height: 1),
        ],
        if (hasProof) _DeliveryProofRow(imageUrls: order.orderProofFullUrl!),
      ]),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall + 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: context.heading.small.medium.overrideWith(color: context.textBaseMedium)),
        const SizedBox(width: Dimensions.paddingDefault),
        Expanded(
          child: Text(
            value, textAlign: TextAlign.end,
            style: context.heading.small.medium,
          ),
        ),
      ]),
    );
  }
}

class _DeliveryProofRow extends StatelessWidget {
  final List<String> imageUrls;

  const _DeliveryProofRow({required this.imageUrls});

  void _openImage(BuildContext context, String url) {
    showCustomDialog(
      child: DialogSheetBody(
        child: Stack(alignment: Alignment.topRight, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: InteractiveViewer(child: CustomImageWidget(image: url, fit: BoxFit.contain)),
          ),
          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.cancel, color: Colors.white)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall + 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('order_proof'.tr, style: context.heading.small.medium.overrideWith(color: context.textBaseMedium)),
        const SizedBox(height: Dimensions.paddingSmall),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
            itemBuilder: (context, index) => InkWell(
              onTap: () => _openImage(context, imageUrls[index]),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImageWidget(image: imageUrls[index], width: 56, height: 56, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}