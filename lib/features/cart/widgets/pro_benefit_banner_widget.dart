import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProBenefitBannerWidget extends StatelessWidget {
  const ProBenefitBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ProHelper.showActiveBenefitBanner) return const SizedBox();
    return GetBuilder<ProController>(builder: (proController) {
      final ProActiveBenefit? benefit = proController.activeOfferModel?.benefit;
      if (benefit == null || benefit.type == null) return const SizedBox();
      return GetBuilder<CartController>(builder: (cartController) {
        return _buildBanner(benefit, cartController.subTotal);
      });
    });
  }

  Widget _buildBanner(ProActiveBenefit benefit, double subtotal) {
    final textStyle = Get.context!.body.small.medium.overrideWith(color: Colors.white);
    final boldStyle = Get.context!.body.small.strong.overrideWith(color: Colors.white);
    const gap = SizedBox(width: Dimensions.padding2xSmall);

    Widget content;

    if (benefit.type == ProBenefitType.coupon) {
      content = Text(
        'You have a coupon as a pro member',
        style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
      );

    } else if (benefit.type == ProBenefitType.discount) {
      if (!ProHelper.meetsProMinOrder(benefit, subtotal)) {
        final remaining = ProHelper.getProMinOrderRemaining(benefit, subtotal);
        content = Row(
          children: [
            PriceConverter.convertAnimationPrice(remaining, textStyle: boldStyle),
            gap,
            Flexible(
              child: Text(
                'more to unlock pro discount',
                style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      } else {
        final double discount = ProHelper.getProDiscountPreview(benefit, subtotal);
        content = Row(
          children: [
            Text('You save', style: textStyle),
            gap,
            PriceConverter.convertAnimationPrice(discount, textStyle: boldStyle),
            gap,
            Flexible(
              child: Text(
                'as a pro member',
                style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }

    } else if (benefit.type == ProBenefitType.deliveryFee) {
      if (benefit.offerType == ProOfferType.fullFree) {
        final minOrderText = (benefit.minOrderStatus ?? false)
            ? ', minimum order amount ${PriceConverter.convertPrice(benefit.minOrderAmount)}'
            : '';
        content = Text(
          'You get free delivery as a pro member$minOrderText',
          style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
        );
      } else {
        content = Text(
          'You get ${(benefit.chargeDiscountPercentage ?? 0).toStringAsFixed(0)}% off on delivery charge as a pro member',
          style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
        );
      }

    } else {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: const Color(0xFF4B54D6),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('\u{1F451}', style: TextStyle(fontSize: 12)),
          const SizedBox(width: Dimensions.paddingSmall),
          Expanded(child: content),
        ],
      ),
    );
  }
}
