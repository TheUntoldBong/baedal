import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_shimmer.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_stepper_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/screens/checkout_screen.dart';
import 'package:stackfood_multivendor/features/product/widgets/product_review_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/product/widgets/variation_status_chip_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/cart_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class FoodBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final bool inRestaurantPage;
  final bool? fromReview;
  final int? reelId;
  const FoodBottomSheetWidget({super.key, required this.product, this.isCampaign = false, this.cart, this.cartIndex, this.inRestaurantPage = false, this.fromReview = false, this.reelId});

  @override
  State<FoodBottomSheetWidget> createState() => _FoodBottomSheetWidgetState();
}

class _FoodBottomSheetWidgetState extends State<FoodBottomSheetWidget> {

  JustTheController tooTipController = JustTheController();

  Product? product;

  final Set<int> _collapsedVariationIndexes = <int>{};
  bool _collapsedAddon = false;

  int? _highlightedVariationIndex;
  final Map<int, GlobalKey> _variationCardKeys = {};
  Timer? _highlightTimer;
  bool _guidedFocusActive = false;
  int? _guidedFocusIndex;

  final ValueNotifier<bool> _descriptionCollapsed = ValueNotifier<bool>(true);

  double _sheetExtent = 0.95;

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final GlobalKey _sheetBodyKey = GlobalKey();
  bool _sheetFitted = false;
  bool _sheetExtentInit = false;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _descriptionCollapsed.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _fitSheetToContent(double screenHeight, double expandedHeaderHeight) {
    if (_sheetFitted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sheetFitted) return;
      final double? bodyHeight = _sheetBodyKey.currentContext?.size?.height;
      if (bodyHeight == null || bodyHeight <= 0 || !_sheetController.isAttached) return;
      _sheetFitted = true;
      final double contentHeight = expandedHeaderHeight + bodyHeight;
      final double target = (contentHeight / screenHeight).clamp(0.5, 0.95).toDouble();
      if ((target - _sheetController.size).abs() > 0.01) {
        _sheetController.animateTo(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      }
    });
  }


  double get _topRadius {
    const double fadeStart = 0.97;
    final double t = ((_sheetExtent - fadeStart) / (1.0 - fadeStart)).clamp(0.0, 1.0).toDouble();
    return Dimensions.radiusExtraLarge * (1 - t);
  }

  int? _firstUnmetRequiredIndex(ProductController c) {
    if (product?.variations == null) return null;
    for (int i = 0; i < product!.variations!.length; i++) {
      final v = product!.variations![i];
      if (v.required != true) continue;
      final int selected = c.selectedVariationLength(c.selectedVariations, i);
      final int needed = v.multiSelect == true ? (v.min ?? 1) : 1;
      if (selected < needed) return i;
    }
    return null;
  }

  void _pulseMissingVariation(int idx) {
    _collapsedVariationIndexes.remove(idx);
    final ctx = _variationCardKeys[idx]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut, alignment: 0.15);
    }
    setState(() => _highlightedVariationIndex = idx);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedVariationIndex = null);
    });
  }

  void _startGuidedFocus(int idx) {
    _guidedFocusActive = true;
    _guidedFocusIndex = idx;
    _pulseMissingVariation(idx);
  }

  void _scheduleGuidedFocusCheck(ProductController productController) {
    if (!_guidedFocusActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_guidedFocusActive) return;
      final int? next = _firstUnmetRequiredIndex(productController);
      if (next == null) {
        _guidedFocusActive = false;
        _guidedFocusIndex = null;
      } else if (next != _guidedFocusIndex) {
        _guidedFocusIndex = next;
        _pulseMissingVariation(next);
      }
    });
  }

  void _toggleVariationCollapse(int index) {
    setState(() {
      if (!_collapsedVariationIndexes.remove(index)) {
        _collapsedVariationIndexes.add(index);
      }
    });
  }

  void _toggleAddonCollapse() => setState(() => _collapsedAddon = !_collapsedAddon);

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    if(widget.fromReview ?? false) {
      product = widget.product;
    } else {
      if(widget.product?.id != null) {
        await Get.find<ProductController>().getProductDetails(widget.product!.id!, widget.cart, isCampaign: widget.isCampaign);
      }
      product = Get.find<ProductController>().product ?? widget.product;
    }

    String? warning = Get.find<ProductController>().checkOutOfStockVariationSelected(product?.variations);
    if(warning != null) {
      showCustomSnackBar(warning);
    }
    if(product != null && (product!.variations == null || product!.variations!.isEmpty)) {
      Get.find<ProductController>().setExistInCart(product!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_topRadius)),
      ),
      child: GetBuilder<ProductController>(builder: (productController) {
        product = productController.product ?? widget.product;
        if(product == null) {
          return const ProductBottomSheetShimmer();
        }
        _scheduleGuidedFocusCheck(productController);
        double price = product!.price ?? 0;
        double? discount = product!.discount;
        String? discountType = product!.discountType;
        double variationPrice = _getVariationPrice(product!, productController);
        double priceWithDiscountForView = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
        double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

        double addonsCost = _getAddonCost(product!, productController);
        List<AddOn> addOnIdList = _getAddonIdList(product!, productController);
        List<AddOns> addOnsList = _getAddonList(product!, productController);

        int qty = productController.quantity ?? 1;
        double priceWithAddonsVariationWithDiscount = addonsCost + ((PriceConverter.convertWithDiscount(variationPrice + price , discount, discountType) ?? (variationPrice + price)) * qty);
        double priceWithAddonsVariation = ((price + variationPrice) * qty) + addonsCost;
        double priceWithVariation = price + variationPrice;
        bool isAvailable = DateConverter.isAvailable(product!.availableTimeStarts, product!.availableTimeEnds);

        return _buildSheet(
          context: context, productController: productController,
          price: price, discount: discount, discountType: discountType,
          priceWithDiscount: priceWithDiscount, priceWithDiscountForView: priceWithDiscountForView,
          priceWithVariation: priceWithVariation, priceWithAddonsVariation: priceWithAddonsVariation,
          priceWithAddonsVariationWithDiscount: priceWithAddonsVariationWithDiscount,
          isAvailable: isAvailable, addOnIdList: addOnIdList, addOnsList: addOnsList,
        );
      }),
    );
  }

  Widget _buildSheet({
    required BuildContext context, required ProductController productController,
    required double price, required double? discount, required String? discountType,
    required double priceWithDiscount, required double priceWithDiscountForView,
    required double priceWithVariation, required double priceWithAddonsVariation,
    required double priceWithAddonsVariationWithDiscount, required bool isAvailable,
    required List<AddOn> addOnIdList, required List<AddOns> addOnsList,
  }) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double expandedHeaderHeight = (screenHeight * 0.32).clamp(240.0, 340.0).toDouble();

    final bool hasVariations = product!.variations != null && product!.variations!.isNotEmpty;
    final bool hasAddons = product!.addOns != null && product!.addOns!.isNotEmpty;
    final bool hasDetails = (product!.description != null && product!.description!.isNotEmpty)
        || (product!.nutritionsName != null && product!.nutritionsName!.isNotEmpty)
        || (product!.allergiesName != null && product!.allergiesName!.isNotEmpty);
    final bool showOptions = hasVariations || hasAddons;

    final double initialSheetSize = showOptions
        ? 0.95
        : ((expandedHeaderHeight + (hasDetails ? 210 : 90) + 120) / screenHeight).clamp(0.5, 0.95).toDouble();
    if (!_sheetExtentInit) {
      _sheetExtent = initialSheetSize;
      _sheetExtentInit = true;
    }

    Widget sheetChild({ScrollController? scrollController}) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_topRadius)),
        child: Stack(children: [
          CustomScrollView(controller: scrollController, slivers: [

            _buildCollapsingHeader(context, expandedHeaderHeight, discount, discountType),

            SliverToBoxAdapter(
              child: Column(key: _sheetBodyKey, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  color: context.surfaceContainer,
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingDefault),
                  child: _buildSummary(context, productController, price, priceWithDiscountForView, discount, discountType),
                ),

                if(hasDetails) Container(
                  color: context.surfaceContainer,
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, 0, Dimensions.paddingLarge, Dimensions.paddingDefault),
                  child: _buildDetails(context),
                ),


                if(showOptions) Container(
                  color: context.surfaceContainer,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if(!hasVariations) const _SectionDivider(),
                    if(hasVariations) _buildVariations(context, productController),
                    if(hasVariations && hasAddons) _SectionDivider(),
                    if(hasAddons) _buildAddons(context, productController),
                  ]),
                ),

                const SizedBox(height: 120),
              ]),
            ),
          ]),

          Positioned(left: 0, right: 0, bottom: 0, child: _buildPinnedCartBar(
            context: context, productController: productController,
            price: price, discount: discount, discountType: discountType,
            priceWithDiscount: priceWithDiscount, priceWithVariation: priceWithVariation,
            priceWithAddonsVariation: priceWithAddonsVariation,
            priceWithAddonsVariationWithDiscount: priceWithAddonsVariationWithDiscount,
            isAvailable: isAvailable, addOnIdList: addOnIdList, addOnsList: addOnsList,
          )),

        ]),
      );
    }


    _fitSheetToContent(screenHeight, expandedHeaderHeight);

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent != _sheetExtent) {
          setState(() => _sheetExtent = notification.extent);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: initialSheetSize,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => sheetChild(scrollController: scrollController),
      ),
    );
  }

  Widget _buildCollapsingHeader(BuildContext context, double expandedHeaderHeight, double? discount, String? discountType) {
    final MediaQueryData deviceMedia = MediaQueryData.fromView(View.of(context));
    final double deviceTopInset = deviceMedia.padding.top;
    final double sheetTopY = deviceMedia.size.height * (1 - _sheetExtent);
    final double statusBarHeight = (deviceTopInset - sheetTopY).clamp(0.0, deviceTopInset).toDouble();
    const double collapsedBarHeight = 64;
    final double toolbarHeight = statusBarHeight + collapsedBarHeight;
    final double totalExpandedHeight = expandedHeaderHeight + statusBarHeight;


    return SliverAppBar(
      pinned: true,
      primary: false,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      expandedHeight: totalExpandedHeight,
      automaticallyImplyLeading: false,
      backgroundColor: context.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(builder: (context, constraints) {
        final double currentHeight = constraints.biggest.height;
        final double progress = ((totalExpandedHeight - currentHeight) / (totalExpandedHeight - toolbarHeight)).clamp(0.0, 1.0).toDouble();
        final double titleOpacity = ((progress - 0.62) / 0.38).clamp(0.0, 1.0).toDouble();
        final double heroOpacity = (1 - (titleOpacity * 0.75)).clamp(0.0, 1.0).toDouble();
        final double controlsOpacity = (1 - titleOpacity).clamp(0.0, 1.0).toDouble();
        final Color controlBg = context.surface;

        return Stack(fit: StackFit.expand, children: [
          Opacity(
            opacity: heroOpacity,
            child: InkWell(
              onTap: (widget.isCampaign || product == null) ? null : () => Get.toNamed(RouteHelper.getItemImagesRoute(product!)),
              child: CustomImageWidget(image: product?.imageFullUrl ?? '', fit: BoxFit.cover),
            ),
          ),

          Positioned(
            left: Dimensions.paddingDefault,
            right: Dimensions.paddingDefault,
            bottom: Dimensions.paddingDefault,
            child: Opacity(
              opacity: controlsOpacity,
              child: _buildDiscountTags(context, discount, discountType),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            height: toolbarHeight,
            child: Container(
              padding: EdgeInsets.only(
                left: Dimensions.paddingDefault,
                right: Dimensions.paddingDefault,
                top: statusBarHeight + Dimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: context.surfaceContainer.withAlpha((255 * titleOpacity).ceil()),
                border: Border(bottom: BorderSide(
                  color: context.outline.withAlpha((255 * titleOpacity).ceil()),
                  width: 1,
                )),
              ),
              alignment: Alignment.center,
              child: Row(children: [
                _buildHeaderButton(context: context, icon: Icons.close, backgroundColor: controlBg, onTap: () => Get.back()),

                Expanded(child: Opacity(opacity: titleOpacity > 0.1 ? 1 : titleOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    child: Text( product?.name ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.heading.extraLarge,
                    ),
                  ),
                )),

                widget.isCampaign ? const SizedBox(width: 40) : GetBuilder<FavouriteController>(builder: (favouriteController) {
                  return CustomFavouriteWidget(
                    isCircular: true,
                    size: 20,
                    widgetSize: 36,
                    isWished: product?.id != null && favouriteController.wishProductIdList.contains(product!.id),
                    id: product?.id ?? 0, isRestaurant: false,
                  );
                }),
              ]),
            ),
          ),
        ]);
      }),
    );
  }


  Widget _buildHeaderButton({required BuildContext context, required IconData icon, required VoidCallback onTap, Color? backgroundColor, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 36, height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? context.bgNeutralLight,
        ),
        child: Icon(icon, size: 20, color: color ?? Theme.of(context).textTheme.bodyLarge!.color),
      ),
    );
  }

  Widget _buildDiscountTags(BuildContext context, double? discount, String? discountType) {
    final bool hasDiscount = discount != null && discount > 0;
    final bool showVeg = Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false;
    final bool showHalal = (product?.isRestaurantHalalActive ?? false) && (product?.isHalalFood ?? false);
    final bool isRightSide = Get.find<SplashController>().configModel?.currencySymbolDirection == 'right';
    final String currencySymbol = Get.find<SplashController>().configModel?.currencySymbol ?? '';

    return Row(children: [
      hasDiscount ? Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
        decoration: BoxDecoration(
          color: context.error,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Text(
          '-${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''}',
          textDirection: TextDirection.ltr,
          style: context.subHeading.small.strong.overrideWith(color: Colors.white),
        ),
      ) : const SizedBox(),

      const Spacer(),

      showVeg ? _ImageTagBadge(image: product?.veg == 1 ? Images.vegLogo : Images.nonVegLogo) : const SizedBox(),
      SizedBox(width: (showVeg && showHalal) ? Dimensions.paddingSmall : 0),

      showHalal ? CustomToolTip(
        message: 'this_is_a_halal_food'.tr,
        preferredDirection: AxisDirection.up,
        tooltipController: tooTipController,
        child: const _ImageTagBadge(image: Images.halal),
      ) : const SizedBox(),
    ]);
  }

  Widget _buildSummary(BuildContext context, ProductController productController, double price, double priceWithDiscountForView, double? discount, String? discountType) {
    final bool hasLogo = product?.restaurantLogoFullUrl != null && product!.restaurantLogoFullUrl!.isNotEmpty;
    final bool hasRating = (product?.avgRating ?? 0) > 0;
    final int qty = productController.quantity ?? 1;
    final int itemStock = product?.itemStock ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if(widget.inRestaurantPage) {
                Get.back();
              } else {
                Get.offNamed(RouteHelper.getRestaurantRoute(product?.restaurantId, slug: product?.restaurantName ?? ''));
              }
            },
            child: Row(children: [
              ClipOval(
                child: hasLogo ? CustomImageWidget(
                  image: product!.restaurantLogoFullUrl!, height: 26, width: 26, fit: BoxFit.cover,
                ) : Container(
                  height: 26, width: 26, color: context.surfaceContainer,
                  child: Icon(Icons.storefront, size: 15, color: context.textBaseMedium),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Flexible(
                child: Text(
                  product?.restaurantName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.body.defaultSize.overrideWith(color: context.textBaseDefault)
                ),
              ),
              if(product?.verifiedSeller == true)...[
                const SizedBox(width: Dimensions.padding2xSmall),
                const RestaurantVerifiedIconWidget(size: 14),
              ],
            ]),
          ),
        ),
        if(hasRating) ...[
          const SizedBox(width: Dimensions.paddingSmall),

          InkWell(
            onTap: (widget.isCampaign || (product?.reviewCount == 0)) ? null : () {
              Get.back();
              ResponsiveHelper.isMobile(context) ? showCustomBottomSheet(child: ProductReviewBottomSheet(product: product!), isDismissible: false, enableDrag: false) : Get.dialog(
                Dialog(child: ProductReviewBottomSheet(product: product!)),
              );
            },
            child: _buildReviewSummary(context),
          ),
        ],
      ]),
      const SizedBox(height: Dimensions.paddingSmall),

      Text(product?.name ?? '', style: context.heading.extraLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: Dimensions.paddingSmall),

      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(PriceConverter.convertPrice(priceWithDiscountForView), textDirection: TextDirection.ltr, style: context.heading.large),
        const SizedBox(width: Dimensions.paddingSmall),

        price > priceWithDiscountForView ? Text(
          PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
          style: context.heading.small.copyWith(color: context.textBaseMedium, decoration: TextDecoration.lineThrough),
        ) : const SizedBox(),
        SizedBox(width: price > priceWithDiscountForView ? Dimensions.padding2xSmall : 0),

        (!widget.isCampaign && product?.stockType != 'unlimited' && itemStock <= 0)
            ? Text(' (${'out_of_stock'.tr})', style: context.subHeading.small.regular.overrideWith(color: context.textDangerLight))
            : const SizedBox(),

        (!widget.isCampaign && product?.stockType != 'unlimited' && qty != 1 && qty >= itemStock)
            ? Text(' (${'only'.tr} $itemStock ${'item_available'.tr})', style: context.body.small.copyWith(color: context.textInfosMedium))
            : const SizedBox(),
      ]),
    ]);
  }

  Widget _buildReviewSummary(BuildContext context) {
    final int reviewCount = widget.isCampaign ? (product!.ratingCount ?? 0) : (product?.reviewCount ?? 0);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      CustomAssetImageWidget(Images.starFill, color: context.iconWarningLight, height: 14, width: 14,),
      SizedBox(width: Dimensions.padding2xSmall),
      Text((product!.avgRating ?? 0).toStringAsFixed(1), style: context.body.defaultSize),
      if(reviewCount > 0)...[
        const SizedBox(width: Dimensions.padding2xSmall),
        Text('($reviewCount ${'reviews'.tr})', style: context.body.defaultSize),
      ],
    ]);
  }

  Widget _buildDetails(BuildContext context) {
    final bool hasDescription = product!.description != null && product!.description!.isNotEmpty;
    final bool hasNutrition = product!.nutritionsName != null && product!.nutritionsName!.isNotEmpty;
    final bool hasAllergies = product!.allergiesName != null && product!.allergiesName!.isNotEmpty;

    final String description = product?.description ?? '';
    final TextStyle bodyStyle = context.body.defaultSize.overrideWith(color: context.textBaseMedium);

    return LayoutBuilder(builder: (context, constraints) {
      bool descriptionOverflows = false;
      if(hasDescription) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: description, style: bodyStyle),
          maxLines: 3, textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        descriptionOverflows = painter.didExceedMaxLines;
      }
      final bool hasExpandableContent = descriptionOverflows || hasNutrition || hasAllergies;

      return ValueListenableBuilder<bool>(
        valueListenable: _descriptionCollapsed,
        builder: (context, collapsed, _) {
          final bool trimmed = collapsed && descriptionOverflows;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if(hasDescription) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: Text(
                  description, style: bodyStyle,
                  maxLines: trimmed ? 3 : null,
                  overflow: trimmed ? TextOverflow.ellipsis : TextOverflow.visible,
                ),
              ),
            ],

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: (collapsed || (!hasNutrition && !hasAllergies)) ? const SizedBox(width: double.infinity) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if(hasNutrition) ...[
                  const SizedBox(height: Dimensions.paddingLarge),
                  Text('nutrition_details'.tr, style: context.heading.large),
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Text('${product!.nutritionsName!.join(', ')}.', style: bodyStyle),
                ],
                if(hasAllergies) ...[
                  const SizedBox(height: Dimensions.paddingLarge),
                  Text('allergic_ingredients'.tr, style: context.heading.large),
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Text('${product!.allergiesName!.join(', ')}.', style: bodyStyle),
                ],
              ]),
            ),

            if(hasExpandableContent) ...[
              const SizedBox(height: Dimensions.paddingDefault),
              Center(
                child: _ExpandCircleButton(
                  expanded: !collapsed,
                  onTap: () => _descriptionCollapsed.value = !collapsed,
                ),
              ),
            ],
          ]);
        },
      );
    });
  }

  Widget _buildVariations(BuildContext context, ProductController productController) {
    final variations = product?.variations ?? [];
    return ListView.separated(
      shrinkWrap: true,
      itemCount: variations.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const _SectionDivider(),
      itemBuilder: (context, index) {
        final variation = variations[index];
        final values = variation.variationValues ?? [];
        final bool isRequired = variation.required == true;
        final bool multiSelect = variation.multiSelect ?? false;
        final bool hasMore = values.length > 4;
        final bool seeMoreCollapsed = hasMore && productController.collapseVariation.length > index && productController.collapseVariation[index];
        final int visibleCount = seeMoreCollapsed ? 4 : values.length;
        final bool cardCollapsed = _collapsedVariationIndexes.contains(index);
        final int selectableCount = multiSelect ? (variation.max ?? 1) : 1;

        int selectedCount = 0;
        if (index < productController.selectedVariations.length) {
          for (var v in productController.selectedVariations[index]) {
            if (v == true) selectedCount++;
          }
        }
        final int minRequired = multiSelect ? (variation.min ?? 1) : 1;
        final bool fulfilled = isRequired && (minRequired <= selectedCount);

        final GlobalKey cardKey = _variationCardKeys.putIfAbsent(index, () => GlobalKey());
        final bool emphasised = _highlightedVariationIndex == index && isRequired && !fulfilled;

        return _OptionCard(
          cardKey: cardKey,
          emphasised: emphasised,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _OptionHeader(
              title: variation.name ?? '',
              subtitle: '${'select_any_of'.tr} $selectableCount${isRequired ? '' : ' (${'optional'.tr})'}',
              chipText: isRequired ? (fulfilled ? 'completed'.tr : 'required'.tr) : '',
              chipColor: isRequired
                  ? (fulfilled ? context.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.error.withAlpha(40))
                  : Colors.transparent,
              chipTextColor: isRequired
                  ? (fulfilled ? context.primary : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black))
                  : Colors.transparent,
              emphasised: emphasised,
              collapsed: cardCollapsed,
              onToggle: () => _toggleVariationCollapse(index),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: cardCollapsed ? const SizedBox(width: double.infinity) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingLarge),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: visibleCount,
                  separatorBuilder: (context, i) => const SizedBox(height: Dimensions.paddingDefault),
                  itemBuilder: (context, i) {
                    final value = values[i];
                    final bool selected = (index < productController.selectedVariations.length && i < productController.selectedVariations[index].length)
                        ? productController.selectedVariations[index][i] == true
                        : false;
                    final bool outOfStock = value.stockType != 'unlimited' && value.currentStock != null && value.currentStock! <= 0;
                    return InkWell(
                      onTap: () {
                        productController.setCartVariationIndex(index, i, product, multiSelect);
                        productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                      },
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Row(children: [
                              Flexible(
                                child: Text(
                                  value.level?.trim() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: selected ? context.subHeading.large.medium : context.subHeading.large,
                                ),
                              ),
                              outOfStock ? Text(' (${'out_of_stock'.tr})', style: context.subHeading.small.overrideWith(color: context.textDangerLight)) : const SizedBox(),
                            ]),

                            (value.isTopPick ?? false) ? Padding(
                              padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.bgSuccessDefault,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                ),
                                child: Text('top_pick'.tr, style: context.subHeading.small.strong.overrideWith(color: Colors.white)),
                              ),
                            ) : const SizedBox(),
                          ]),
                        ),
                        Text(
                          '+ ${PriceConverter.convertPrice(value.optionPrice)}', textDirection: TextDirection.ltr,
                          style: context.subHeading.defaultSize,
                        ),
                        const SizedBox(width: Dimensions.paddingDefault),
                        _SelectionBox(selected: selected, isRadio: !multiSelect),
                      ]),
                    );
                  },
                ),

                hasMore ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
                    child: InkWell(
                      onTap: () => productController.showMoreSpecificSection(index),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(seeMoreCollapsed ? 'see_more'.tr : 'see_less'.tr, style: context.subHeading.small.overrideWith(color: context.textInfosMedium),),
                          const SizedBox(width: Dimensions.padding2xSmall),
                          Icon(seeMoreCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: context.iconBaseDefault),
                        ]),
                      ),
                    ),
                  ),
                ) : const SizedBox(),
              ]),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildAddons(BuildContext context, ProductController productController) {
    final addOns = product?.addOns ?? [];
    if (addOns.isEmpty) return const SizedBox();
    return _OptionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _OptionHeader(
          title: 'addons'.tr,
          subtitle: '${'to_add_more_additional_items'.tr} (${'optional'.tr})',
          chipText: '',
          chipColor: Colors.transparent,
          chipTextColor: Colors.transparent,
          collapsed: _collapsedAddon,
          onToggle: _toggleAddonCollapse,
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _collapsedAddon ? const SizedBox(width: double.infinity) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: Dimensions.paddingLarge),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: addOns.length,
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingDefault),
              itemBuilder: (context, index) {
                final addon = addOns[index];
                final bool active = (productController.addOnActiveList.length > index) && productController.addOnActiveList[index];
                final int addonQty = (productController.addOnQtyList.length > index ? (productController.addOnQtyList[index] ?? 1) : 1);
                final bool outOfStock = addon.stockType != 'unlimited' && addon.addonStock != null && addon.addonStock! <= 0;
                return InkWell(
                  onTap: () {
                    if (!active) {
                      productController.addAddOn(true, index, addon.stockType, addon.addonStock);
                    } else if (addonQty == 1) {
                      productController.addAddOn(false, index, addon.stockType, addon.addonStock);
                    }
                  },
                  child: Row(children: [
                    Expanded(
                      child: Row(children: [
                        Flexible(
                          child: Text(addon.name ?? '', maxLines: 3, overflow: TextOverflow.ellipsis,
                            style: active ? context.subHeading.defaultSize.overrideWith(fontWeight: AppWeight.medium) : context.subHeading.defaultSize,
                          ),
                        ),
                        outOfStock ? Text(' (${'out_of_stock'.tr})', style: context.subHeading.small.regular.overrideWith(color: context.textDangerLight)) : const SizedBox(),
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Text(
                      (addon.price ?? 0) > 0 ? '+ ${PriceConverter.convertPrice(addon.price)}' : 'free'.tr,
                      textDirection: TextDirection.ltr, style: context.subHeading.defaultSize,
                    ),
                    const SizedBox(width: Dimensions.paddingDefault),

                    QuantityStepperWidget(
                      backgroundColor: context.surface,
                      boxShadow : [],
                      quantity: active ? addonQty : 0,
                      onAdd: () => productController.addAddOn(true, index, addon.stockType, addon.addonStock),
                      onDecrement: () {
                        if (addonQty > 1) {
                          productController.setAddOnQuantity(false, index, addon.stockType, addon.addonStock);
                        } else {
                          productController.addAddOn(false, index, addon.stockType, addon.addonStock);
                        }
                      },
                      onIncrement: () => productController.setAddOnQuantity(true, index, addon.stockType, addon.addonStock),
                    ),
                  ]),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPinnedCartBar({
    required BuildContext context, required ProductController productController,
    required double price, required double? discount, required String? discountType,
    required double priceWithDiscount, required double priceWithVariation,
    required double priceWithAddonsVariation, required double priceWithAddonsVariationWithDiscount,
    required bool isAvailable, required List<AddOn> addOnIdList, required List<AddOns> addOnsList,
  }) {
    final int qty = productController.quantity ?? 1;
    final bool isScheduleOrder = product?.scheduleOrder ?? false;
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${'total_amount'.tr}:', style: context.heading.defaultSize.overrideWith(color: context.primary)),
            const SizedBox(width: Dimensions.padding2xSmall),

            Row(children: [
              (priceWithAddonsVariation > priceWithAddonsVariationWithDiscount) ? PriceConverter.convertAnimationPrice(
                priceWithAddonsVariation,
                textStyle: context.heading.small.copyWith(color: context.textBaseMedium, fontWeight: AppWeight.regular, decoration: TextDecoration.lineThrough)) : const SizedBox(),
              const SizedBox(width: Dimensions.padding2xSmall),

              PriceConverter.convertAnimationPrice(priceWithAddonsVariationWithDiscount, textStyle: context.heading.defaultSize),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          Row(children: [
            if(!_hasUnmetRequired(productController)) ...[
              Row(children: [
                QuantityButton(
                  onTap: () {
                    if (qty > 1) {
                      productController.setQuantity(false, product?.cartQuantityLimit, product?.stockType, product?.itemStock, widget.isCampaign);
                    }
                  },
                  isIncrement: false,
                ),

                AnimatedFlipCounter(
                  duration: const Duration(milliseconds: 500),
                  value: qty.toDouble(),
                  textStyle: context.heading.large.overrideWith(fontWeight: AppWeight.medium),
                ),

                QuantityButton(
                  onTap: () => productController.setQuantity(true, product?.cartQuantityLimit, product?.stockType, product?.itemStock, widget.isCampaign),
                  isIncrement: true,
                ),
              ]),
              const SizedBox(width: Dimensions.paddingSmall),
            ],

            Expanded(
              child: GetBuilder<CartController>(builder: (cartController) {
                final bool unmetRequired = _hasUnmetRequired(productController);
                final bool outOfStock = _isOutOfStock;
                final bool disabled = ((!isScheduleOrder && !isAvailable) || (widget.isCampaign && !isAvailable))
                    || outOfStock
                    || (widget.cart != null && productController.checkOutOfStockVariationSelected(product?.variations) != null);
                return CustomButtonWidget(
                  radius: Dimensions.radiusMedium,
                  isLoading: cartController.isLoading,
                  color: unmetRequired ? context.surfaceContainerLowest : null,
                  textColor: unmetRequired ? context.onSurface : null,
                  buttonText: ((!isScheduleOrder && !isAvailable) || (widget.isCampaign && !isAvailable)) ? 'not_available_now'.tr
                      : outOfStock ? 'out_of_stock'.tr
                      : unmetRequired ? 'choose_required_option'.tr
                      : widget.isCampaign ? 'order_now'.tr : (widget.cart != null || productController.cartIndex != -1) ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                  onPressed: disabled ? null : () async {
                    final int? missing = _firstUnmetRequiredIndex(productController);
                    if (missing != null) {
                      _startGuidedFocus(missing);
                      return;
                    }
                    Get.find<CheckoutController>().updateFirstTime();
                    _onButtonPressed(productController, cartController, priceWithVariation, priceWithDiscount, price, discount, discountType, addOnIdList, addOnsList, priceWithAddonsVariation);
                  },
                );
              }),
            ),
          ]),
        ]),
      ),
    );
  }

  bool get _isOutOfStock => !widget.isCampaign
      && product?.stockType != 'unlimited'
      && (product?.itemStock ?? 0) <= 0;

  bool _hasUnmetRequired(ProductController productController) {
    if (product?.variations == null) return false;
    for (int index = 0; index < product!.variations!.length; index++) {
      final variation = product!.variations![index];
      if (variation.required != true) continue;
      int selected = 0;
      if (index < productController.selectedVariations.length) {
        for (var s in productController.selectedVariations[index]) {
          if (s == true) selected++;
        }
      }
      final int need = variation.multiSelect == true ? (variation.min ?? 1) : 1;
      if (selected < need) return true;
    }
    return false;
  }

  void _onButtonPressed(
      ProductController productController, CartController cartController, double priceWithVariation, double priceWithDiscount,
      double price, double? discount, String? discountType, List<AddOn> addOnIdList, List<AddOns> addOnsList,
      double priceWithAddonsVariation,
      ) async {

    _processVariationWarning(productController);

    if(productController.canAddToCartProduct) {
      double discountVal = (PriceConverter.convertWithDiscount(price, discount, discountType) ?? price);
      CartModel cartModel = CartModel(
        null, priceWithVariation, priceWithDiscount, (price - discountVal),
        productController.quantity ?? 1, addOnIdList, addOnsList, widget.isCampaign, product, productController.selectedVariations,
        product?.cartQuantityLimit, productController.variationsStock,
      );

      OnlineCart onlineCart = _processOnlineCart(productController, cartController, addOnIdList, addOnsList, priceWithAddonsVariation);

      if(widget.isCampaign) {
        if(AddressHelper.getAddressFromSharedPref() == null) {
          if(Get.isDialogOpen ?? false) {
            Get.back();
          }
          Get.find<SplashController>().navigateToLocationScreen('home');
          return;
        }
        Get.find<CartController>().setNeedExtraPackage(false);
        Get.back();
        Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(fromCart: false, cartList: [cartModel]));
      } else {
        await _executeActions(cartController, productController, cartModel, onlineCart);
      }
    }
  }

  void _processVariationWarning(ProductController productController) {
    if(product?.variations != null && product!.variations!.isNotEmpty){
      for(int index=0; index<product!.variations!.length; index++) {
        final variation = product!.variations![index];
        final bool isMultiSelect = variation.multiSelect ?? false;
        final bool isRequired = variation.required ?? false;
        final bool hasSelection = index < productController.selectedVariations.length && productController.selectedVariations[index].contains(true);
        if(!isMultiSelect && isRequired && !hasSelection) {
          showCustomSnackBar('${'choose_a_variation_from'.tr} ${variation.name}');
          productController.changeCanAddToCartProduct(false);
          return;
        } else if(isMultiSelect && (isRequired || hasSelection) && (variation.min ?? 1) > productController.selectedVariationLength(productController.selectedVariations, index)) {
          showCustomSnackBar('${'you_need_to_select_minimum'.tr} ${variation.min ?? 1} '
              '${'to_maximum'.tr} ${variation.max ?? 1} ${'options_from'.tr} ${variation.name} ${'variation'.tr}');
          productController.changeCanAddToCartProduct(false);
          return;
        } else {
          productController.changeCanAddToCartProduct(true);
        }
      }
    } else if( !widget.isCampaign && (product?.variations == null || product!.variations!.isEmpty) && product?.stockType != 'unlimited' && (product?.itemStock ?? 0) <= 0) {
      showCustomSnackBar('product_is_out_of_stock'.tr);
      productController.changeCanAddToCartProduct(false);
      return;
    }
  }

  OnlineCart _processOnlineCart(ProductController productController, CartController cartController, List<AddOn> addOnIdList, List<AddOns> addOnsList, double priceWithAddonsVariation) {
    List<OrderVariation> variations = CartHelper.getSelectedVariations(
      productVariations: product?.variations, selectedVariations: productController.selectedVariations,
    ).$1;
    List<int?> optionsIdList = CartHelper.getSelectedVariations(
      productVariations: product?.variations, selectedVariations: productController.selectedVariations,
    ).$2;
    List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
    List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);

    OnlineCart onlineCart = OnlineCart(
        (widget.cart != null || productController.cartIndex != -1) ? widget.cart?.id ?? cartController.cartBundleList[productController.cartBundleIndex].carts![productController.cartIndex].id : null,
        widget.isCampaign ? null : product?.id, widget.isCampaign ? product?.id : null,
        priceWithAddonsVariation.toString(), variations,
        productController.quantity ?? 1, listOfAddOnId, addOnsList, listOfAddOnQty, 'Food', variationOptionIds: optionsIdList, restaurantId: product?.restaurantId,
        reelId: widget.reelId,
    );
    return onlineCart;
  }

  Future<void> _executeActions(CartController cartController, ProductController productController, CartModel cartModel, OnlineCart onlineCart) async {
    if(AddressHelper.getAddressFromSharedPref() == null) {
      if(Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.find<SplashController>().navigateToLocationScreen('home');
      return;
    }
    if(widget.cart != null || productController.cartIndex != -1) {
      await cartController.updateCartOnline(onlineCart, existCartData: widget.cart);
    } else {
      await cartController.addToCartOnline(onlineCart, existCartData: widget.cart, popAfterAdd: true);
    }
  }

  double _getVariationPrice(Product product, ProductController productController) {
    double variationPrice = 0;
    if(product.variations != null){
      for(int index = 0; index< product.variations!.length; index++) {
        final values = product.variations![index].variationValues;
        if (values != null && index < productController.selectedVariations.length) {
          for(int i=0; i< values.length; i++) {
            if(productController.selectedVariations[index].length > i && productController.selectedVariations[index][i] == true) {
              variationPrice += PriceConverter.convertWithDiscount(values[i].optionPrice ?? 0, 0, 'none') ?? 0;
            }
          }
        }
      }
    }
    return variationPrice;
  }

  double _getAddonCost(Product product, ProductController productController) {
    double addonsCost = 0;
    if (product.addOns != null) {
      for (int index = 0; index < product.addOns!.length; index++) {
        if (productController.addOnActiveList.length > index && productController.addOnActiveList[index]) {
          final int addonQty = productController.addOnQtyList.length > index ? (productController.addOnQtyList[index] ?? 1) : 1;
          addonsCost = addonsCost + ((product.addOns![index].price ?? 0) * addonQty);
        }
      }
    }
    return addonsCost;
  }

  List<AddOn> _getAddonIdList(Product product, ProductController productController) {
    List<AddOn> addOnIdList = [];
    if (product.addOns != null) {
      for (int index = 0; index < product.addOns!.length; index++) {
        if (productController.addOnActiveList.length > index && productController.addOnActiveList[index]) {
          final int addonQty = productController.addOnQtyList.length > index ? (productController.addOnQtyList[index] ?? 1) : 1;
          addOnIdList.add(AddOn(id: product.addOns![index].id, quantity: addonQty));
        }
      }
    }
    return addOnIdList;
  }

  List<AddOns> _getAddonList(Product product, ProductController productController) {
    List<AddOns> addOnsList = [];
    if (product.addOns != null) {
      for (int index = 0; index < product.addOns!.length; index++) {
        if (productController.addOnActiveList.length > index && productController.addOnActiveList[index]) {
          addOnsList.add(product.addOns![index]);
        }
      }
    }
    return addOnsList;
  }
}

class _ImageTagBadge extends StatelessWidget {
  final String image;
  const _ImageTagBadge({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5)],
      ),
      child: CustomAssetImageWidget(image, height: 20, width: 20),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 2, thickness: 2,);
  }
}

class _OptionCard extends StatefulWidget {
  final Widget child;
  final Key? cardKey;
  final bool emphasised;
  const _OptionCard({required this.child, this.cardKey, this.emphasised = false});

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> with SingleTickerProviderStateMixin {
  static const Color _emphasisColor = Color(0xFFE0483D);

  late final AnimationController _controller;
  late final Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _borderOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.emphasised) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _OptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emphasised && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.emphasised && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderOpacity,
      builder: (context, child) {
        return Container(
          key: widget.cardKey,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            border: widget.emphasised ? Border.all(color: _emphasisColor.withValues(alpha: _borderOpacity.value), width: 1.5) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _OptionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String chipText;
  final Color chipColor;
  final Color chipTextColor;
  final bool emphasised;
  final bool collapsed;
  final VoidCallback? onToggle;
  const _OptionHeader({required this.title, required this.subtitle, required this.chipText, required this.chipColor, required this.chipTextColor,
    this.emphasised = false, this.collapsed = false, this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium))
          ]),
        ),
        const SizedBox(width: Dimensions.paddingDefault),

        VariationStatusChipWidget(chipText: chipText, chipColor: chipColor, chipTextColor: chipTextColor, emphasised: emphasised),

        if(onToggle != null) ...[
          const SizedBox(width: Dimensions.paddingSmall),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: context.bgNeutralLight, shape: BoxShape.circle),
            child: AnimatedRotation(
              turns: collapsed ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodyLarge!.color, size: 20),
            ),
          ),
        ],
      ]),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final bool selected;
  final bool isRadio;
  const _SelectionBox({required this.selected, required this.isRadio});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 20, width: 20,
      decoration: BoxDecoration(
        shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isRadio ? null : BorderRadius.circular(Dimensions.radiusExtraSmall),
        border: Border.all(color: selected ? context.primary : context.outlineVariant, width: 1),
        color: selected ? context.primary : Colors.transparent,
      ),
      child: selected ? Icon(isRadio ? Icons.circle : Icons.check, size: isRadio ? 12 : 16, color: Colors.white) : null,
    );
  }
}

class _ExpandCircleButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _ExpandCircleButton({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: context.surfaceContainerLowest, shape: BoxShape.circle),
        child: AnimatedRotation(
          turns: expanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(Icons.keyboard_arrow_down, size: 20, color: context.iconBaseDefault),
        ),
      ),
    );
  }
}
