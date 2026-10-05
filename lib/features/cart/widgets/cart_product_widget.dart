import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/bogo_item_group_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_stepper_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_bundle_details_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/helper/cart_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  final bool isRestaurantOpen;
  const CartProductWidget({super.key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns, required this.isRestaurantOpen});

  void _openProduct(BuildContext context) {
    ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => FoodBottomSheetWidget(product: cart.product, cartIndex: cartIndex, cart: cart),
    ).then((value) => Get.find<CartController>().getCartDataOnline(cart.product!.restaurantId!),
    ) : showDialog(context: context, builder: (con) => Dialog(
      child: FoodBottomSheetWidget(product: cart.product, cartIndex: cartIndex, cart: cart),
    )).then((value) => Get.find<CartController>().getCartDataOnline(cart.product!.restaurantId!));
  }

  @override
  Widget build(BuildContext context) {
    if(cart.isBogoBundle) {
      return _BogoBundleCartTile(cart: cart, cartIndex: cartIndex, isAvailable: isAvailable, isRestaurantOpen: isRestaurantOpen);
    }

    final String addOnText = CartHelper.setupAddonsText(cart: cart) ?? '';
    final String variationText = CartHelper.setupVariationText(cart: cart).$1;
    final String subtitle = [variationText, addOnText].where((e) => e.isNotEmpty).join('  •  ');

    final double discount = cart.product!.discount ?? 0;
    final String? discountType = cart.product!.discountType;
    final bool hasDiscount = discount > 0;
    final bool showHalal = cart.product!.isRestaurantHalalActive! && cart.product!.isHalalFood!;

    return GetBuilder<CartController>(builder: (cartController) {
      return Column(children: [

        Stack(children: [
          Slidable(
            key: ValueKey('cart_item_${cart.product!.id}_$cartIndex'),
            enabled: !cartController.isLoading,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.2,
              children: [
                SlidableAction(
                  onPressed: (context) => cartController.removeFromCart(
                   cartIndex: cartIndex, restaurantId: cart.product!.restaurantId!,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.trash,
                ),
              ],
            ),
            child: CustomInkWellWidget(
              onTap: () => _openProduct(context),
              radius: Dimensions.radiusDefault,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                        Row(children: [
                          Flexible(
                            child: Text(
                              cart.product!.name!,
                              style: context.heading.defaultSize.overrideWith(fontWeight: AppWeight.medium),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Dimensions.padding2xSmall),

                          CustomAssetImageWidget(
                            cart.product!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                            height: 11, width: 11,
                          ),
                          SizedBox(width: showHalal ? Dimensions.padding2xSmall : 0),

                          showHalal ? const CustomAssetImageWidget(Images.halal, height: 13, width: 13) : const SizedBox(),
                        ]),
                        const SizedBox(height: Dimensions.paddingSmall),

                        Row(children: [
                          Text(
                            PriceConverter.convertPrice(cart.product!.price, discount: discount, discountType: discountType),
                            style: context.heading.large, textDirection: TextDirection.ltr,
                          ),
                          SizedBox(width: hasDiscount ? Dimensions.padding2xSmall : 0),

                          hasDiscount ? Flexible(child: Text(
                            PriceConverter.convertPrice(cart.product!.price), textDirection: TextDirection.ltr,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: context.subHeading.small.copyWith(color: context.textBaseMedium, decoration: TextDecoration.lineThrough),
                          )) : const SizedBox(),
                        ]),

                        if(subtitle.isNotEmpty) ...[
                          const SizedBox(height: Dimensions.padding2xSmall),
                          _ExpandableVariationText(text: subtitle),
                        ],
                      ]),
                    ),
                  ),
                  SizedBox(width: 100, height: 100, child: Stack(clipBehavior: Clip.none, children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                            child: CustomImageWidget(
                              image: '${cart.product!.imageFullUrl}',
                              height: 100, width: 100, fit: BoxFit.cover, isFood: true,
                            ),
                          ),

                          isAvailable ? const SizedBox() : Positioned.fill(child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMedium), color: Colors.black.withValues(alpha: 0.6)),
                            child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: context.subHeading.extraSmall.overrideWith(color: Colors.white,)),
                          )),

                          Positioned(right: 5, bottom: 5, child: QuantityStepperWidget(
                            quantity: cart.quantity!,
                            onDecrement: cartController.isLoading ? null : () {
                              if (cart.quantity! > 1) {
                                cartController.setQuantity(false, cart, cartIndex: cartIndex, restaurantId: cart.product!.restaurantId!);
                              } else {
                                cartController.removeFromCart(cartIndex: cartIndex, restaurantId: cart.product!.restaurantId!);
                              }
                            },
                            onIncrement: cartController.isLoading ? null : () => cartController.setQuantity(true, cart, cartIndex: cartIndex, restaurantId: cart.product!.restaurantId!),
                          )),
                        ])),
                ]),
              ),
            ),
          ),

        ]),


      ]);
    });
  }
}

class _BogoBundleCartTile extends StatefulWidget {
  final CartModel cart;
  final int cartIndex;
  final bool isAvailable;
  final bool isRestaurantOpen;
  const _BogoBundleCartTile({required this.cart, required this.cartIndex, required this.isAvailable, required this.isRestaurantOpen});

  @override
  State<_BogoBundleCartTile> createState() => _BogoBundleCartTileState();
}

class _BogoBundleCartTileState extends State<_BogoBundleCartTile> {
  Future<BogoOfferDetailsResponseModel?>? _offerDetailsFuture;

  @override
  void initState() {
    super.initState();
    final BogoCartDetails details = widget.cart.bogoDetails!;
    final String? idOrSlug = details.offerSlug ?? details.bogoOfferId?.toString();
    if(idOrSlug != null) {
      _offerDetailsFuture = Get.find<BogoOfferController>().getCachedOfferDetails(idOrSlug);
    }
  }

  Future<void> _openBogoDetails(BuildContext context, BogoCartDetails details) async {
    if(_offerDetailsFuture == null) {
      return;
    }

    final BogoOfferDetailsResponseModel? offerDetails = await _offerDetailsFuture;
    final BogoBundleModel? bundle = _resolveBundle(offerDetails?.bundles, details);
    if(bundle == null || !context.mounted) {
      return;
    }

    BogoBundleDetailsBottomSheet.show(
      context, bundle: bundle, offerLabel: offerDetails?.offerLabel, validUntil: offerDetails?.validUntil,
      cartItem: widget.cart, restaurantId: widget.cart.restaurantId, remainingUses: offerDetails?.remainingUses,
    );
  }

  BogoBundleModel? _resolveBundle(List<BogoBundleModel>? bundles, BogoCartDetails details) {
    if(bundles == null || bundles.isEmpty) {
      return null;
    }
    return bundles.firstWhereOrNull((bundle) => details.bundleId != null && bundle.bundleId == details.bundleId)
        ?? bundles.firstWhereOrNull((bundle) => bundle.restaurant?.id != null && bundle.restaurant!.id == widget.cart.restaurantId)
        ?? (bundles.length == 1 ? bundles.first : null);
  }

  @override
  Widget build(BuildContext context) {
    final CartModel cart = widget.cart;
    final bool isAvailable = widget.isAvailable;
    final bool isRestaurantOpen = widget.isRestaurantOpen;
    final BogoCartDetails details = cart.bogoDetails!;
    final int restaurantId = cart.restaurantId!;

    return GetBuilder<CartController>(builder: (cartController) {
      return Stack(children: [
        Slidable(
          key: ValueKey('cart_bogo_${details.bogoGroupId}_${widget.cartIndex}'),
          enabled: !cartController.isLoading,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                onPressed: (context) => cartController.removeBogoBundle(cart, restaurantId: restaurantId),
                backgroundColor: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                foregroundColor: Colors.white,
                icon: CupertinoIcons.trash,
              ),
            ],
          ),
          child: CustomInkWellWidget(
          onTap: () => _openBogoDetails(context, details),
          radius: Dimensions.radiusDefault,
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall, vertical: Dimensions.paddingSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    details.offerTitle ?? 'bogo_offer'.tr,
                    style: context.heading.defaultSize.overrideWith(fontWeight: AppWeight.medium),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    PriceConverter.convertPrice(details.bundlePrice),
                    style: context.heading.large, textDirection: TextDirection.ltr,
                  ),
                ]),
              ),
              const SizedBox(width: Dimensions.paddingSmall),


              QuantityStepperWidget(
              backgroundColor : context.surface,
                boxShadow: [],
                quantity: cart.quantity!,
                decrementIcon: cart.quantity == 1 ? CupertinoIcons.trash : Icons.remove,
                onDecrement: cartController.isLoading ? null : () {
                  if (cart.quantity! > 1) {
                    cartController.updateBogoBundleQuantity(false, cart, restaurantId: restaurantId);
                  } else {
                    cartController.removeBogoBundle(cart, restaurantId: restaurantId);
                  }
                },
                onIncrement: cartController.isLoading ? null : () => cartController.updateBogoBundleQuantity(true, cart, restaurantId: restaurantId),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSmall),
          
            if(!isAvailable && details.unavailableReason != null) ...[
              const SizedBox(height: Dimensions.padding2xSmall),
              Text(details.unavailableReason!, style: context.body.small.overrideWith(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: Dimensions.padding2xSmall),

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BogoItemGroupWidget(label: 'buying_item'.tr, thumbnails: details.buyItemThumbnails),
              const SizedBox(width: Dimensions.paddingExtraLarge),
              BogoItemGroupWidget(label: 'free_item'.tr, thumbnails: details.freeItemThumbnails),
            ]),
          ]),
          ),
          ),
        ),

        isRestaurantOpen ? const SizedBox() : Positioned.fill(child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: ResponsiveHelper.isDesktop(context) ? context.surfaceContainer : context.bgNeutralMedium,
          ),
        )),
      ]);
    });
  }
}


class _ExpandableVariationText extends StatefulWidget {
  final String text;
  const _ExpandableVariationText({required this.text});

  @override
  State<_ExpandableVariationText> createState() => _ExpandableVariationTextState();
}

class _ExpandableVariationTextState extends State<_ExpandableVariationText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.body.small;

    return LayoutBuilder(builder: (context, constraints) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: constraints.maxWidth);
      final bool isOverflowing = painter.didExceedMaxLines;

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(
            widget.text, style: style,
            maxLines: _expanded ? null : 1,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),

        if(isOverflowing) InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: context.primary),
          ),
        ),
      ]);
    });
  }
}
