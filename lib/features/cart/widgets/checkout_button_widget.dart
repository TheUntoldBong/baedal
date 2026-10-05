import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class CheckoutButtonWidget extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  final int restaurantId;
  const CheckoutButtonWidget({super.key, required this.cartController, required this.availableList, required this.isRestaurantOpen, this.fromDineIn = false, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
      decoration: isDesktop ? null : BoxDecoration(
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.shadow, offset: const Offset(0, -1))]
      ),
      child: SafeArea(
        child: GetBuilder<RestaurantController>(builder: (restaurantController) {
          if(restaurantController.restaurant != null && restaurantController.restaurant!.freeDelivery != null && !restaurantController.restaurant!.freeDelivery!
              && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null))){
            percentage = cartController.subTotal/Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver!;
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [

            GetBuilder<HappyHourController>(builder: (happyHourController) {
              final bool? isHappyHourRunning = restaurantController.restaurant?.isHappyHourRunning;
              if(!happyHourController.showRestaurantBanner(isHappyHourRunning)) {
                return const SizedBox();
              }
              return HappyHourMilestoneBannerWidget(
                borderRadius: 0,
                subtotal: cartController.subTotal, isHappyHourRunning: isHappyHourRunning,
              );
            }),

            (restaurantController.restaurant != null && restaurantController.restaurant!.freeDelivery != null && !restaurantController.restaurant!.freeDelivery!
                && (Get.find<SplashController>().configModel?.adminFreeDelivery?.status == true && (Get.find<SplashController>().configModel?.adminFreeDelivery?.type != null && Get.find<SplashController>().configModel?.adminFreeDelivery?.type == 'free_delivery_by_specific_criteria') && (Get.find<SplashController>().configModel!.adminFreeDelivery?.freeDeliveryOver != null)))
                ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.bgWarningMedium,
                  ),
                  child: Column(children: [

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CustomAssetImageWidget(Images.percentTag, height: 18, width: 18, color: context.iconWarningLight,),
                      const SizedBox(width: Dimensions.padding2xSmall),

                      Flexible(child: percentage < 1 ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: context.body.small.strong,
                          children: [
                            TextSpan(text: '${'add'.tr} '),
                            TextSpan(
                              text: PriceConverter.convertPrice(Get.find<SplashController>().configModel!.adminFreeDelivery!.freeDeliveryOver! - cartController.subTotal),
                              style: TextStyle(color: context.textBaseDefault),
                            ),
                            TextSpan(text: ' ${'more_for_free_delivery'.tr}'),
                          ],
                        ),
                      ): RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: ' ${'enjoy_free_delivery'.tr}',
                              style: context.heading.defaultSize,
                            ),

                          ],
                        ),
                      ) ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSmall),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        value: percentage,
                        backgroundColor: context.bgWarningLight,
                        valueColor: AlwaysStoppedAnimation<Color>(context.onPrimaryContainer),
                      ),
                    ),

                  ]),
                ) : const SizedBox(),


            !isDesktop ? GetBuilder<CartController>(builder: (cartController) {
              final bool isDiscountResolved = cartController.isDiscountEligibilityResolved(restaurantId);
              final double totalDiscount = cartController.itemDiscountPrice + cartController.restaurantDiscountPrice;
              final bool hasDiscount = totalDiscount > 0;
              return Column(children: [

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.bottomCenter,
                  child: cartController.isExpanded ? Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                    child: Column(children: [

                      _breakdownRow(context, 'item_price'.tr, '(+)', cartController.itemPrice),

                      if(cartController.variationPrice > 0) ...[
                        const SizedBox(height: Dimensions.paddingSmall),
                        _breakdownRow(context, 'variations'.tr, '(+)', cartController.variationPrice),
                      ],

                      const SizedBox(height: Dimensions.paddingSmall),
                      _breakdownRow(context, 'addons'.tr, '(+)', cartController.addOns),

                      if(hasDiscount) ...[
                        const SizedBox(height: Dimensions.paddingSmall),
                        _breakdownRow(context, 'discount'.tr, '(-)', totalDiscount),
                      ],

                    ]),
                  ) : const SizedBox(width: double.infinity),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    InkWell(
                      onTap: () => cartController.setExpanded(!cartController.isExpanded),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('subtotal'.tr, style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium)),
                        const SizedBox(width: Dimensions.padding2xSmall),

                        Container(
                          height: 24, width: 24,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: context.surfaceContainerLowest),
                          alignment: Alignment.center,
                          child: AnimatedRotation(
                            turns: cartController.isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ),
                      ]),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: isDiscountResolved ? [
                        PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: context.heading.extraLarge.strong.overrideWith(color: context.textNeutralDefault)),
                        if(hasDiscount)  Text(
                          PriceConverter.convertPrice(cartController.subTotal + totalDiscount), textDirection: TextDirection.ltr,
                          style: context.subHeading.small.regular.copyWith(color: context.textBaseMedium, decoration: TextDecoration.lineThrough),
                        ),
                      ] : [
                        Text(
                          '${'calculating'.tr}...',
                          style: context.heading.extraLarge.strong.overrideWith(color: context.textBaseMedium),
                        ),
                      ],
                    )
                  ]),
                ),

              ]);
            }) : const SizedBox(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: GetBuilder<CartController>(builder: (cartController) {
                return CustomButtonWidget(
                  radius: 10,
                  buttonText: 'continue_checkout'.tr,
                  onPressed: cartController.isLoading || restaurantController.restaurant == null ? null : () {
                    Get.find<CheckoutController>().updateFirstTime();
                    _processToCheckoutButtonPressed(restaurantController);
                  },
                );
              }),
            ),
            SizedBox(height: isDesktop ? Dimensions.paddingExtraLarge : 0),
          ]);
        }),
      ),
    );
  }

  Widget _breakdownRow(BuildContext context, String label, String sign, double amount) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: context.heading.defaultSize.overrideWith(fontWeight: AppWeight.regular, color: context.textBaseMedium)),
      Row(children: [
        Text('$sign ', style: context.heading.defaultSize.regular, textDirection: TextDirection.ltr),
        PriceConverter.convertAnimationPrice(amount, textStyle: context.heading.defaultSize.overrideWith(fontWeight: AppWeight.regular)),
      ]),
    ]);
  }

  void _processToCheckoutButtonPressed(RestaurantController restaurantController) {
    if(!(restaurantController.restaurant?.scheduleOrder ?? false) && cartController.availableList.contains(false)) {
      showCustomSnackBar('one_or_more_product_unavailable'.tr);
    } else if(restaurantController.restaurant!.freeDelivery == null || restaurantController.restaurant!.cutlery == null) {
      showCustomSnackBar('restaurant_is_unavailable'.tr);
    }else {
      Get.find<CouponController>().removeCouponData(false);
      Get.toNamed(RouteHelper.getCheckoutRoute('cart', fromDineIn: fromDineIn, restaurantId: restaurantId));
    }
  }

}

class UnderlinedTextButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const UnderlinedTextButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = const Color(0xFF9B4FD8),
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  State<UnderlinedTextButton> createState() => _UnderlinedTextButtonState();
}

class _UnderlinedTextButtonState extends State<UnderlinedTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isHovered ? 0.7 : 1.0,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              decoration: TextDecoration.underline,
              decorationColor: widget.color,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
