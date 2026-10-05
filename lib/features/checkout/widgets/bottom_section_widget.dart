import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/condition_check_box.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/coupon_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/order_place_button.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BottomSectionWidget extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double total;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final double charge;
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final double taxPercent;
  final bool fromCart;
  final List<CartModel>? cartList;
  final double price;
  final double addOns;
  final ExpansibleController expansionTileController;
  final JustTheController serviceFeeTooltipController;
  final double referralDiscount;
  final double extraPackagingAmount;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final TextEditingController guestAddressController;
  final TextEditingController guestStreetNumberController;
  final TextEditingController guestHouseController;
  final TextEditingController guestFloorController;
  final double proDiscount;
  final double proDeliveryDiscount;

  final double storeDiscount;
  final DiscountEligibilityModel? storeDiscountEligibility;

  const BottomSectionWidget({
    super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.total,
    required this.subTotal, required this.discount, required this.couponController,
    required this.taxIncluded, required this.tax, required this.deliveryCharge, required this.checkoutController,
    required this.locationController, required this.todayClosed, required this.tomorrowClosed,
    required this.orderAmount, this.maxCodOrderAmount, required this.subscriptionQty, required this.taxPercent,
    required this.fromCart, required this.cartList, required this.price, required this.addOns, required this.charge, required this.guestNameController,
    required this.guestNumberController, required this.isOfflinePaymentActive, required this.guestEmailController,
    required this.expansionTileController, required this.serviceFeeTooltipController, required this.referralDiscount, required this.extraPackagingAmount,
    required this.guestAddressController, required this.guestStreetNumberController, required this.guestHouseController, required this.guestFloorController,
    required this.proDiscount, required this.proDeliveryDiscount,
    this.storeDiscount = 0, this.storeDiscountEligibility,
  });

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    return Container(
      decoration: isDesktop ? BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],

      ) : null,
      padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        SizedBox(height: isDesktop ? 0 : Dimensions.paddingSmall),

        if (isDesktop && !isGuestLoggedIn) CouponSection(
          checkoutController: checkoutController, price: price, charge: charge,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, total: total,
        ),
        if (!isDesktop) SizedBox(height: Dimensions.padding2xSmall),

         if (isDesktop)  Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: pricingView(context, isDesktop),
        ) else pricingView(context, isDesktop),

        if(isDesktop) const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: CheckoutCondition(),
        ),

        if(isDesktop) Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'total_amount'.tr,
                    style: context.heading.large.medium.overrideWith(color: context.primary),
                  ),
                  PriceConverter.convertAnimationPrice(
                    total,
                    textStyle: context.heading.large.medium.overrideWith(color: context.primary),
                  ),
                ]),
              ),

              OrderPlaceButton(
                checkoutController: checkoutController, locationController: locationController,
                todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, deliveryCharge: deliveryCharge,
                tax: tax, discount: discount, total: total, maxCodOrderAmount: maxCodOrderAmount, subscriptionQty: subscriptionQty,
                cartList: cartList, isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                isWalletActive: isWalletActive, fromCart: fromCart, isOfflinePaymentActive: isOfflinePaymentActive, proDiscount: proDiscount + proDeliveryDiscount,
                couponController: couponController, subTotal: subTotal, taxIncluded: taxIncluded, taxPercent: taxPercent, extraPackagingAmount: extraPackagingAmount,
                guestNameController: guestNameController, guestNumberController: guestNumberController,
                guestEmailController: guestEmailController, guestAddressController: guestAddressController,
                guestStreetNumberController: guestStreetNumberController, guestHouseController: guestHouseController, guestFloorController: guestFloorController,
              ),
            ],
          ),

        ),
      ]),
    );
  }

  Widget pricingView(BuildContext context, bool isDesktop) {
    final ProActiveBenefit? proBenefit = Get.find<ProController>().activeOfferModel?.benefit;
    final SummaryProModel? summaryPro = checkoutController.summaryPro;
    final ProBenefitType? proBenefitType = summaryPro?.type ?? proBenefit?.type;
    final bool isPro = summaryPro?.status ?? (Get.find<ProfileController>().userInfoModel?.proStatus ?? false);
    final double deliveryDiscountPercent = proBenefit?.offerType == ProOfferType.fullFree ? 100 : (proBenefit?.chargeDiscountPercentage ?? 0);

    final selectedSaverDeliveryOption = checkoutController.selectedSaverDeliveryOption;
    final String? saverDeliveryType = selectedSaverDeliveryOption?.deliveryType;
    final bool hasSaverDeliveryType = checkoutController.orderType != 'take_away'
        && checkoutController.orderType != 'dine_in'
        && (saverDeliveryType == 'express' || saverDeliveryType == 'slightly_delay');

    final double saverDeliveryAdjustment = checkoutController.getSaverDeliveryChargeAdjustment(
      deliveryOption: selectedSaverDeliveryOption,
    ).abs();
    final bool showSaverDeliveryOption = hasSaverDeliveryType && saverDeliveryAdjustment > 0;

    final String? discountNote = _discountSourceNote();

    final bool showTax = checkoutController.taxIncluded != null && !taxIncluded && checkoutController.orderTax != 0 && tax > 0;
    final bool showTips = checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in'
        && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !checkoutController.subscriptionOrder
        && checkoutController.tips > 0;
    final double additionCharge = Get.find<SplashController>().configModel!.additionCharge ?? 0;
    final bool showAdditionalCharge = (Get.find<SplashController>().configModel!.additionalChargeStatus ?? false) && additionCharge > 0;

    return Container(
      decoration: !isDesktop ? BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ) : null,
      padding: !isDesktop ? const EdgeInsets.fromLTRB(Dimensions.paddingLarge, 0, Dimensions.paddingLarge, Dimensions.paddingLarge) : EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: !isDesktop ? Dimensions.paddingLarge : 0),
        Align(alignment: Alignment.center,
        child: Text('billing_summary'.tr, style: context.heading.extraLarge.strong)),
      
        SizedBox(height: !isDesktop ? Dimensions.paddingDefault : 0),
      
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(!checkoutController.subscriptionOrder ? 'subtotal'.tr : 'item_price'.tr, style: context.body.defaultSize.regular),
          Text(PriceConverter.convertPrice(subTotal), style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr),
        ]),
        const SizedBox(height: Dimensions.paddingSmall),

        if(discount > 0) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text('discount'.tr, style: context.body.defaultSize.regular),
              if(discountNote != null) ...[
                const SizedBox(width: Dimensions.padding2xSmall),
                CustomToolTip(
                  message: discountNote,
                  child: Icon(Icons.info_outline, size: 16, color: context.iconInfoMedium),
                ),
              ],
            ]),
            Row(children: [
              Text('(-) ', style: context.subHeading.defaultSize.regular),
              PriceConverter.convertAnimationPrice(discount, textStyle: context.subHeading.defaultSize.regular)
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
        ],

        (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(couponController.coupon?.couponType == 'pro_customer' ? 'coupon_discount_pro'.tr : 'coupon_discount'.tr, style: context.body.defaultSize.regular),
            (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
              'free_delivery'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.primary),
            ) : Row(children: [
              Text('(-) ', style: context.subHeading.defaultSize.regular),
              Text(
                PriceConverter.convertPrice(couponController.discount),
                style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr,
              )
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
        ]) : const SizedBox(),
      
        (isPro && proBenefitType == ProBenefitType.discount && proDiscount > 0) ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('discount_pro'.tr, style: context.body.defaultSize.regular),
            Row(children: [
              Text('(-) ', style: context.subHeading.defaultSize.regular),
              PriceConverter.convertAnimationPrice(proDiscount, textStyle: context.subHeading.defaultSize.regular),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
        ]) : const SizedBox(),
      
        
        referralDiscount > 0 ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('referral_discount'.tr, style: context.body.defaultSize.regular),

            Text(
              '(-) ${PriceConverter.convertPrice(referralDiscount)}',
              style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr,
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
        ]) : const SizedBox(),
      
        showTax ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('vat_tax'.tr, style: context.body.defaultSize.regular),
          Text(('(+) ') + PriceConverter.convertPrice(tax), style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr),
        ]) : const SizedBox(),
        SizedBox(height: showTax ? Dimensions.paddingSmall : 0),
      
        showTips ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('delivery_man_tips'.tr, style: context.body.defaultSize.regular),
            Row(children: [
              Text('(+) ', style: context.subHeading.defaultSize.regular),
              PriceConverter.convertAnimationPrice(checkoutController.tips, textStyle: context.subHeading.defaultSize.regular)
            ]),
          ],
        ) : const SizedBox.shrink(),
        SizedBox(height: showTips ? Dimensions.paddingSmall : 0.0),
      
        (extraPackagingAmount > 0) ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('extra_packaging'.tr, style: context.body.defaultSize.regular),
            Text('(+) ${PriceConverter.convertPrice(checkoutController.restaurant!.extraPackagingAmount!)}', style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr),
          ],
        ) : const SizedBox.shrink(),
        SizedBox(height: extraPackagingAmount > 0 ? Dimensions.paddingSmall : 0),
      
        checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in'
            ? _deliveryFeeRow(context, checkoutController) : const SizedBox(),
        SizedBox(height: checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in' ? Dimensions.paddingSmall : 0),
      
        (isPro && proBenefitType == ProBenefitType.deliveryFee && proDeliveryDiscount > 0.0
            && checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in') ? Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text('delivery_fee_discount_pro'.tr, style: context.body.defaultSize.regular),
              const SizedBox(width: Dimensions.padding2xSmall),
              CustomToolTip(
                message: '${deliveryDiscountPercent.toStringAsFixed(0)}% ${'discount_applied'.tr}',
                child: Icon(Icons.info_outline, size: 16, color: context.textBaseMedium),
              ),
            ]),
            Row(children: [
              Text('(-) ', style: context.subHeading.defaultSize.regular),
              Text(PriceConverter.convertPrice(proDeliveryDiscount), style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr),
            ]),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
        ]) : const SizedBox(),
      
        showSaverDeliveryOption ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${saverDeliveryType!.replaceAll('_', ' ').capitalize} ${'delivery'.tr}', style: context.body.defaultSize.regular),
            Text(
              '${saverDeliveryType == 'express' ? '(+) ' : '(-) '}${PriceConverter.convertPrice(saverDeliveryAdjustment)}',
              style: context.subHeading.defaultSize.regular,
              textDirection: TextDirection.ltr,
            ),
          ],
        ) : const SizedBox(),
        SizedBox(height: showSaverDeliveryOption ? Dimensions.paddingSmall : 0),
      
        showAdditionalCharge ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
      
            Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: context.body.defaultSize.regular),
            const SizedBox(width: Dimensions.padding2xSmall),


          ]),
          Text(
            '(+) ${PriceConverter.convertPrice(additionCharge)}',
            style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr,
          ),
        ]) : const SizedBox(),
        SizedBox(height: showAdditionalCharge ? Dimensions.paddingSmall : 0),
      
        (isDesktop || checkoutController.isPartialPay) && checkoutController.subscriptionOrder ? Column(
          children: [
            Divider(thickness: 1, color: context.outlineVariant),
      
            Row(children: [
              Text(
                checkoutController.subscriptionOrder ? 'subtotal'.tr : 'total_amount'.tr,
                style: context.heading.large.medium.overrideWith(color: checkoutController.isPartialPay ? context.textBaseDefault : context.primary),
              ),

              (checkoutController.taxIncluded == 1) ? Text(' ${'vat_tax_inc'.tr}', style: context.subHeading.extraSmall.medium.overrideWith(
                color: context.primary,
              )) : const SizedBox(),

              const Expanded(child: SizedBox()),

              PriceConverter.convertAnimationPrice(
                total,
                textStyle: context.heading.large.medium.overrideWith(color: checkoutController.isPartialPay ? context.textBaseDefault : context.primary),
              ),
            ]),
          ],
        ) : const SizedBox(),
      
        !isDesktop && checkoutController.subscriptionOrder ? Column(
          children: [
            Divider(thickness: 1, color: context.outlineVariant),
      
            Row(children: [
              Text(
                'subtotal'.tr,
                style: context.heading.large.medium.overrideWith(color: checkoutController.isPartialPay ? context.textBaseDefault : context.primary),
              ),
              const Expanded(child: SizedBox()),

              PriceConverter.convertAnimationPrice(
                total,
                textStyle: context.heading.large.medium.overrideWith(color: checkoutController.isPartialPay ? context.textBaseMedium : context.primary),
              ),
            ]),
          ],
        ) : const SizedBox(),
      
        checkoutController.subscriptionOrder ? Column(children: [
          const SizedBox(height: Dimensions.paddingSmall),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('subscription_order_count'.tr, style: context.subHeading.defaultSize.medium),
            Text(subscriptionQty.toString(), style: context.subHeading.defaultSize.medium),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
            child: Divider(thickness: 1, color: context.outlineVariant),
          ),
      
        ]) : const SizedBox(),
        SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSmall : 0),
      
        checkoutController.isPartialPay && !checkoutController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('paid_by_wallet'.tr, style: context.body.defaultSize.regular),
          Text('(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}', style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr),
        ]) : const SizedBox(),
        SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSmall : 0),
      
        checkoutController.isPartialPay && !checkoutController.subscriptionOrder ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'due_payment'.tr,
            style: context.heading.large.medium.overrideWith(color: !isDesktop ? context.textBaseMedium : context.primary),
          ),
          PriceConverter.convertAnimationPrice(
            checkoutController.viewTotalPrice,
            textStyle: context.heading.large.medium.overrideWith(color: !isDesktop ? context.textBaseMedium : context.primary),
          )
        ]) : const SizedBox(),
      
        isDesktop && !checkoutController.subscriptionOrder ? Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          child: Divider(thickness: 1),
        ) : const SizedBox(),

        SizedBox(height: Dimensions.fontSizeLarge),
        const CheckoutCondition(),
        SizedBox(height: Dimensions.fontSizeLarge),
      ]),
    );
  }

  String? _discountSourceNote() {
    final DiscountSource? source = storeDiscountEligibility?.source;
    if(source == null || storeDiscount <= 0) {
      return null;
    }
    return source.labelKey.tr;
  }

  Widget _deliveryFeeRow(BuildContext context, CheckoutController checkoutController) {
    bool isCalculating = checkoutController.distance == -1 || deliveryCharge < 0;
    bool isFree = deliveryCharge == 0
        || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery');
    String? breakdown = (isCalculating || isFree) ? null : _deliveryFeeBreakdown(checkoutController);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text('delivery_fee'.tr, style: context.body.defaultSize.regular),
        if(breakdown != null) ...[
          const SizedBox(width: Dimensions.padding2xSmall),
          CustomToolTip(
            message: breakdown,
            child: Icon(Icons.info_outline, size: 16, color: context.iconInfoMedium),
          ),
        ],
      ]),

      isCalculating ? Text(
        'calculating'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.error),
      ) : isFree ? Text(
        'free'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.primary),
      ) : Row(children: [
        Text('(+) ', style: context.subHeading.defaultSize.regular),
        Text(
          PriceConverter.convertPrice(deliveryCharge+proDeliveryDiscount), style: context.subHeading.defaultSize.regular, textDirection: TextDirection.ltr,
        )
      ]),
    ]);
  }

  String? _deliveryFeeBreakdown(CheckoutController checkoutController) {
    double vehicleCharge = checkoutController.restaurant?.selfDeliverySystem == 0
        ? (checkoutController.extraCharge ?? 0) : 0;
    double surgeCharge = checkoutController.surgeAmount;

    List<String> parts = [];
    if(vehicleCharge > 0) {
      parts.add('${'extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(vehicleCharge)}');
    }
    if(surgeCharge > 0) {
      parts.add('${'surge_charge'.tr} ${PriceConverter.convertPrice(surgeCharge)}');
    }
    if(parts.isEmpty) {
      return null;
    }

    String message = '${'this_charge_includes'.tr} ${parts.join(' ${'and'.tr} ')}';
    String note = _surgeNote(checkoutController);
    return note.isEmpty ? message : '$message \u2014 $note';
  }

  String _surgeNote(CheckoutController checkoutController) {
    if(checkoutController.summarySurge?.customerNoteStatus != 1) {
      return '';
    }
    String note = checkoutController.surgeCustomerNote ?? '';
    return note.isNotEmpty ? note : (checkoutController.summarySurge?.title?.trim() ?? '');
  }
}
