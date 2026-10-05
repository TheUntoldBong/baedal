import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HomeLastOrderCardWidget extends StatelessWidget {
  final LatestOrderModel order;
  final double width;
  const HomeLastOrderCardWidget({super.key, required this.order, this.width = 220});

  static const double _imageSize = 36;

  static double preferredHeight() {
    final double textLine = Dimensions.fontSizeLarge * 1.5;
    return (_imageSize / 2)
        + ((_imageSize / 2) + Dimensions.paddingDefault)
        + (2 * textLine)
        + Dimensions.padding2xSmall;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final bool isReordering = orderController.isLoading && orderController.reorderingOrderId == order.id;
      final bool disabled = order.campaign == true;

      return Padding(
        padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
        child: Opacity(
          opacity: disabled ? 0.6 : 1,
          child: InkWell(
            onTap: (isReordering || disabled) ? null : _onReorderTap,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            child: SizedBox(
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  Container(
                    margin: const EdgeInsets.only(top: _imageSize / 2),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingDefault, (_imageSize / 2) + Dimensions.paddingDefault,
                      Dimensions.paddingDefault, Dimensions.paddingDefault,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                      Text(
                        order.restaurant?.name ?? '',
                        style: context.heading.small.overrideWith(fontWeight: AppWeight.medium),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.padding2xSmall),

                      Text(
                        PriceConverter.convertPrice(order.orderAmount),
                        style: context.heading.small.overrideWith(fontWeight: AppWeight.regular, color: context.textBaseMedium),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),

                    ]),
                  ),

                  Align(
                    alignment: Alignment.topCenter,
                    child: _StackedItemImages(
                      imageUrls: order.itemImages ?? const [],
                      totalCount: order.totalItemCount ?? (order.itemImages?.length ?? 0),
                    ),
                  ),

                  if (isReordering)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.only(top: _imageSize / 2),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.primary),
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _onReorderTap() async {
    if (order.campaign == true) return;
    await Get.find<OrderController>().reorderFromLastOrder(order.id);
  }
}

class _StackedItemImages extends StatelessWidget {
  final List<String> imageUrls;
  final int totalCount;
  const _StackedItemImages({required this.imageUrls, required this.totalCount});

  static const double _size = HomeLastOrderCardWidget._imageSize;
  static const double _overlap = 15;

  static const int _maxImages = 3;

  @override
  Widget build(BuildContext context) {
    final int itemCount = totalCount > 0 ? totalCount : imageUrls.length;
    final int slots = itemCount < 1 ? 1 : itemCount;

    final int padCount = (slots - imageUrls.length) < 0 ? 0 : (slots - imageUrls.length);
    final List<String> allImages = [...imageUrls, ...List.generate(padCount, (_) => 'X')];

    final List<String> visible = allImages.take(_maxImages).toList();
    final int remaining = slots - visible.length;
    final double step = _size - _overlap;

    final List<Widget> circles = [];
    for (int i = 0; i < visible.length; i++) {
      circles.add(Positioned(
        left: i * step,
        child: _circle(context, child: CustomImageWidget(
          image: visible[i], height: _size, width: _size, isFood: true,
          placeholderBgColor: context.surfaceContainer,
        )),
      ));
    }
    if (remaining > 0) {
      circles.add(Positioned(
        left: visible.length * step,
        child: _circle(context,
          color: context.bgNeutralLight,
          child: Center(child: Text('+$remaining', style: context.heading.small.overrideWith(color: context.textBaseMedium))),
        ),
      ));
    }

    final int count = visible.length + (remaining > 0 ? 1 : 0);
    return SizedBox(
      height: _size,
      width: (count - 1) * step + _size,
      child: Stack(clipBehavior: Clip.none, children: circles),
    );
  }

  Widget _circle(BuildContext context, {required Widget child, Color? color}) {
    return Container(
      height: _size, width: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? context.surfaceContainer,
        border: Border.all(color: context.surfaceContainer, width: 2),
      ),
      child: ClipOval(child: child),
    );
  }
}
