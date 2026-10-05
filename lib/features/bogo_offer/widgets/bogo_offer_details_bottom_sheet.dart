import 'package:flutter/material.dart';
import 'package:full_screen_bottom_sheet/full_screen_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_quantity_button.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoOfferDetailsBottomSheet extends StatefulWidget {
  final BogoBundleModel bundle;
  final String? offerLabel;
  final String? validUntil;
  final int? remainingUses;
  const BogoOfferDetailsBottomSheet({super.key, required this.bundle, this.offerLabel, this.validUntil, this.remainingUses});

  static Future<void> show(BuildContext context, {required BogoBundleModel bundle, String? offerLabel, String? validUntil, int? remainingUses}) {
    return FullScreenBottomSheet.show(context, builder: (_) => BogoOfferDetailsBottomSheet(
      bundle: bundle, offerLabel: offerLabel, validUntil: validUntil, remainingUses: remainingUses,
    ));
  }

  @override
  State<BogoOfferDetailsBottomSheet> createState() => _BogoOfferDetailsBottomSheetState();
}

class _BogoOfferDetailsBottomSheetState extends State<BogoOfferDetailsBottomSheet> {
  static const double _dragHandleHeight = Dimensions.paddingLarge;

  int? _pickedQuantity;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) {
        return;
      }
      final CartController cartController = Get.find<CartController>();
      if(cartController.cartBundleList.isEmpty) {
        cartController.getCartBundleList();
      }
    });
  }

  CartModel? get _cartItem => Get.find<CartController>().findBogoBundleInCart(
    widget.bundle.bundleId, restaurantId: widget.bundle.restaurant?.id,
  );

  int _quantityOf(CartModel? cartItem) => _pickedQuantity ?? cartItem?.quantity ?? 1;

  void _increment(CartModel? cartItem) {
    final int quantity = _quantityOf(cartItem);
    final int? limit = widget.remainingUses;
    if(limit != null && quantity >= limit) {
      showCustomSnackBar('you_can_only_use_this_offer_more_times'.trParams({'limit': '$limit'}));
      return;
    }
    setState(() => _pickedQuantity = quantity + 1);
  }

  void _decrement(CartModel? cartItem) {
    final int quantity = _quantityOf(cartItem);
    if(quantity > 1) {
      setState(() => _pickedQuantity = quantity - 1);
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

  Future<void> _addToCart(int quantity) async {
    if(widget.bundle.bundleId == null || _isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);

    bool isSuccess = await Get.find<CartController>().addBogoToCartOnline(widget.bundle.bundleId!, quantity);
    if(!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if(isSuccess) {
      Get.back();
      final int? restaurantId = widget.bundle.restaurant?.id;
      if(restaurantId != null) {
        Get.toNamed(RouteHelper.getCartRoute(restaurantId: restaurantId));
      }
      showCustomSnackBar('item_added_to_cart'.tr, isError: false);
    }
  }

  Future<void> _updateCart(CartModel cartItem, int quantity) async {
    final int? restaurantId = cartItem.restaurantId ?? widget.bundle.restaurant?.id;
    if(restaurantId == null || _isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);

    final bool isSuccess = await Get.find<CartController>().setBogoBundleQuantity(cartItem, quantity, restaurantId: restaurantId);
    if(!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if(isSuccess) {
      Get.back();
      showCustomSnackBar('cart_updated'.tr, isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BogoBundleModel offer = widget.bundle;
    final int buyCount = offer.buyCount ?? offer.buyItems.length;
    final int getCount = offer.getCount ?? offer.freeItems.length;
    final String offerLabel = widget.offerLabel ?? 'BUY $buyCount GET $getCount FREE';
    final double price = offer.finalPrice ?? offer.bundlePrice ?? 0;
    final String? distance = offer.restaurant?.distanceLabel;

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
        title: Text(offerLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.heading.extraLarge.overrideWith(color: context.onSurface)),
        dragHandle: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: context.bgNeutralLight, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
        ),
        sheetTrailing: const _SheetCloseButton(),
        pageBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Row(children: [
            Expanded(child: Text(offerLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
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
                Text(offer.restaurant?.name ?? '', style: context.heading.extraLarge.strong),
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
                        Text(offerLabel, style: context.heading.large.strong.overrideWith(color: context.textInfosMedium)),
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
                  ClipOval(child: CustomImageWidget(image: offer.restaurant?.logoFullUrl ?? '', height: 40, width: 40, fit: BoxFit.cover)),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(offer.restaurant?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
                        const SizedBox(height: Dimensions.padding2xSmall),

                        Row(children: [
                          if(offer.restaurant?.deliveryTime != null && offer.restaurant!.deliveryTime!.isNotEmpty) ...[
                            Icon(Icons.access_time, size: 16, color: context.iconBaseMedium),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Text(offer.restaurant!.deliveryTime!, style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium)),
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
                for (final BogoOfferItemModel item in offer.buyItems)
                  HorizontalFoodCardWidget(
                    product: item.product, restaurant: null,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                    isBogoOfferItem: true, bogoQuantity: item.quantity, bogoVariationText: item.variationText,
                    bogoAddOnText: item.addOnText,
                  ),

                Divider(color: context.outline),
                const SizedBox(height: Dimensions.paddingSmall),

                Text('you_will_get'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.paddingMedium),
                for (final BogoOfferItemModel item in offer.freeItems)
                  HorizontalFoodCardWidget(
                    product: item.product, restaurant: null,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                    isBogoOfferItem: true, bogoQuantity: item.quantity, bogoVariationText: item.variationText,
                    bogoAddOnText: item.addOnText,
                  ),
              ],
            ),
          ),
        ),
      ],
      footerBuilder: (context, metrics) => GetBuilder<CartController>(builder: (cartController) {
        final CartModel? cartItem = _cartItem;
        final int quantity = _quantityOf(cartItem);
        final bool isInCart = cartItem != null;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(color: context.surfaceContainer, border: Border(top: BorderSide(color: context.outline))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('total'.tr, style: context.heading.large.strong),
                      const SizedBox(width: Dimensions.padding2xSmall),
                      Text('vat_tax_inc'.tr, style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),
                    ],
                  ),
                  Text(PriceConverter.convertPrice(price * quantity), style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: Dimensions.paddingDefault),

                Row(children: [
                  BogoQuantityButton(icon: Icons.remove, onTap: quantity > 1 ? () => _decrement(cartItem) : null),
                  Expanded(child: Center(child: Text('$quantity', style: context.heading.large.strong))),
                  BogoQuantityButton(icon: Icons.add, onTap: () => _increment(cartItem)),
                  const SizedBox(width: Dimensions.paddingDefault),

                  Expanded(
                    flex: 3,
                    child: CustomButtonWidget(
                      buttonText: isInCart ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                      height: 45,
                      isLoading: _isSubmitting,
                      onPressed: offer.bundleId == null ? null
                          : isInCart
                              ? (quantity == cartItem.quantity ? null : () => _updateCart(cartItem, quantity))
                              : () => _addToCart(quantity),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
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

