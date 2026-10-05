import 'package:flutter/material.dart';
import 'package:full_screen_bottom_sheet/full_screen_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_quantity_button.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoBundleDetailsBottomSheet extends StatefulWidget {
  final BogoBundleModel bundle;
  final String? offerLabel;
  final String? validUntil;

  final CartModel? cartItem;
  final int? restaurantId;

  final int? remainingUses;

  const BogoBundleDetailsBottomSheet({super.key, required this.bundle, this.offerLabel, this.validUntil, this.cartItem,
    this.restaurantId, this.remainingUses});

  static Future<void> show(BuildContext context, {required BogoBundleModel bundle, String? offerLabel, String? validUntil,
      CartModel? cartItem, int? restaurantId, int? remainingUses}) {
    return FullScreenBottomSheet.show(context, builder: (_) => BogoBundleDetailsBottomSheet(
      bundle: bundle, offerLabel: offerLabel, validUntil: validUntil, cartItem: cartItem,
      restaurantId: restaurantId, remainingUses: remainingUses,
    ));
  }

  @override
  State<BogoBundleDetailsBottomSheet> createState() => _BogoBundleDetailsBottomSheetState();
}

class _BogoBundleDetailsBottomSheetState extends State<BogoBundleDetailsBottomSheet> {
  static const double _dragHandleHeight = Dimensions.paddingLarge;

  late int _quantity = widget.cartItem?.quantity ?? 1;
  bool _isUpdating = false;

  bool get _isEditingCartItem => widget.cartItem != null && widget.restaurantId != null;

  void _increment() {
    final int? limit = widget.remainingUses;
    if(limit != null && _quantity >= limit) {
      showCustomSnackBar('you_can_only_use_this_offer_more_times'.trParams({'limit': '$limit'}));
      return;
    }
    setState(() => _quantity++);
  }
  void _decrement() {
    if(_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _updateCart() async {
    if(!_isEditingCartItem || _isUpdating) {
      return;
    }
    setState(() => _isUpdating = true);

    final bool isSuccess = await Get.find<CartController>().setBogoBundleQuantity(
      widget.cartItem!, _quantity, restaurantId: widget.restaurantId!,
    );

    if(!mounted) {
      return;
    }
    setState(() => _isUpdating = false);
    if(isSuccess) {
      Get.back();
      showCustomSnackBar('cart_updated'.tr, isError: false);
    }
  }

  void _openRestaurant(BuildContext context) {
    final Restaurant? restaurant = widget.bundle.restaurant;
    if(restaurant?.id == null) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    Get.toNamed(
      RouteHelper.getRestaurantRoute(restaurant!.id, slug: restaurant.slug ?? ''),
      arguments: RestaurantScreen(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int buyCount = widget.bundle.buyCount ?? widget.bundle.buyItems.length;
    final int getCount = widget.bundle.getCount ?? widget.bundle.freeItems.length;
    final String label = widget.offerLabel ?? 'BUY $buyCount GET $getCount FREE';
    final double price = widget.bundle.finalPrice ?? widget.bundle.bundlePrice ?? 0;
    final String? distance = widget.bundle.restaurant?.distanceLabel;

    return FullScreenBottomSheet(
      initialExtent: 1,
      backgroundColor: context.surfaceContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      headerExtent: (metrics) => FullScreenBottomSheetBar.heightOf(metrics, dragHandleHeight: _dragHandleHeight),
      headerBuilder: (context, metrics) => FullScreenBottomSheetBar(
        metrics: metrics,
        dragHandleHeight: _dragHandleHeight,
        backgroundColor: context.surfaceContainer,
        border: Border(bottom: BorderSide(color: context.outline)),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.heading.extraLarge.overrideWith(color: context.onSurface)),
        dragHandle: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: context.bgNeutralLight, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
        ),
        sheetTrailing: const _SheetCloseButton(),
        pageBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Row(children: [
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.heading.extraLarge.strong.overrideWith(color: context.onSurface))),
            const SizedBox(width: Dimensions.paddingSmall),

            const _SheetCloseButton(),
          ]),
        ),
      ),
      slivers: (context, scrollController) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.bundle.restaurant?.name ?? '', style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.paddingDefault),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingMedium),
                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: context.heading.large.strong.overrideWith(color: context.textInfosMedium)),
                        if(widget.validUntil != null) ...[
                          const SizedBox(height: Dimensions.padding2xSmall),
                          Text('${'valid_until'.tr} : ${widget.validUntil}', style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),
                        ],
                      ],
                    ),
                    Text(PriceConverter.convertPrice(price), style: context.heading.extraLarge.strong),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingDefault),

                Row(children: [
                  ClipOval(child: CustomImageWidget(image: widget.bundle.restaurant?.logoFullUrl ?? '', height: 40, width: 40, fit: BoxFit.cover)),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.bundle.restaurant?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
                        const SizedBox(height: Dimensions.padding2xSmall),

                        Row(children: [
                          if(widget.bundle.restaurant?.deliveryTime != null && widget.bundle.restaurant!.deliveryTime!.isNotEmpty) ...[
                            Icon(Icons.access_time, size: 16, color: context.iconBaseMedium),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Text(widget.bundle.restaurant!.deliveryTime!, style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium)),
                            const SizedBox(width: Dimensions.padding2xSmall),
                          ],
                          if(distance != null)
                            Text('($distance)', style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                        ]),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () => _openRestaurant(context),
                    borderRadius: BorderRadius.circular(30),
                    child: CircleAvatar(radius: 20, backgroundColor: context.surface,
                      child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: context.iconBaseDefault),
                    ),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingDefault),
                Divider(color: context.outline),
                const SizedBox(height: Dimensions.paddingMedium),

                Text('buy_these'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.paddingMedium),
                for (final BogoOfferItemModel item in widget.bundle.buyItems)
                  HorizontalFoodCardWidget(
                    product: item.product, restaurant: null,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                    isBogoOfferItem: true, bogoQuantity: item.quantity, bogoVariationText: item.variationText,
                  ),

                Divider(color: context.outline),
                const SizedBox(height: Dimensions.paddingSmall),

                Text('you_will_get'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.paddingMedium),
                for (final BogoOfferItemModel item in widget.bundle.freeItems)
                  HorizontalFoodCardWidget(
                    product: item.product, restaurant: null,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                    isBogoOfferItem: true, bogoQuantity: item.quantity, bogoVariationText: item.variationText,
                  ),
              ],
            ),
          ),
        ),
      ],
      footerBuilder: !_isEditingCartItem ? null : (context, metrics) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(color: context.surfaceContainer, border: Border(top: BorderSide(color: context.outline))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('total'.tr, style: context.heading.large.strong),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text('vat_tax_inc'.tr, style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),
              ]),
              Text(PriceConverter.convertPrice(price * _quantity), style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr),
            ]),
            const SizedBox(height: Dimensions.paddingDefault),

            Row(children: [
              BogoQuantityButton(icon: Icons.remove, onTap: _quantity > 1 ? _decrement : null),
              Expanded(child: Center(child: Text('$_quantity', style: context.heading.large.strong))),
              BogoQuantityButton(icon: Icons.add, onTap: _increment),
              const SizedBox(width: Dimensions.paddingDefault),

              Expanded(
                flex: 3,
                child: CustomButtonWidget(
                  buttonText: 'update_in_cart'.tr,
                  height: 45,
                  isLoading: _isUpdating,
                  onPressed: _quantity == (widget.cartItem?.quantity ?? 1) ? null : _updateCart,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.surface),
        child: Icon(Icons.close, size: 18, color: context.iconBaseDefault),
      ),
    );
  }
}
