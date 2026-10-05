import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/coupon_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class CouponSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double price, discount, addOns, deliveryCharge, charge, total;
  const CouponSection({super.key, required this.checkoutController, required this.price, required this.discount, required this.addOns, required this.deliveryCharge, required this.total, required this.charge});

  void _openCouponSheet(BuildContext context) {
    if(ResponsiveHelper.isDesktop(context)){
      Get.dialog(Dialog(child: CouponBottomSheet(checkoutController: checkoutController, price: price, discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, charge: charge, total: total))).then((value) {
        if(value != null) {
          checkoutController.couponController.text = value.toString();
        }
      });
    }else{
      Get.bottomSheet(
        CouponBottomSheet(checkoutController: checkoutController, price: price, discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, charge: charge, total: total),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(
      builder: (couponController) {
        bool hasCouponApplied = couponController.discount! > 0 || couponController.freeDelivery;

        return Container(
          color: context.surfaceContainer,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('add_coupon'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  'to_save_more_use_available_coupons'.tr,
                  style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                ),
              ])),
              const SizedBox(width: Dimensions.paddingSmall),

              InkWell(
                onTap: couponController.isLoading ? null : () => _openCouponSheet(context),
                child: couponController.isLoading ? const SizedBox.shrink() : hasCouponApplied ? CustomAssetImageWidget(Images.editBtn, width:20) : Icon(Icons.add, size: 24, color: context.iconBaseDefault),
              ),
            ]),

            !hasCouponApplied && !couponController.isLoading ? const SizedBox() : Column(children: [
              const SizedBox(height: Dimensions.paddingDefault),

              couponController.isLoading ? const CouponCardShimmer() : CouponCard(
                title: couponController.coupon?.title ?? checkoutController.couponController.text,
                subtitle: couponController.coupon?.minPurchase != null && couponController.coupon!.minPurchase! > 0
                    ? '${'min_purchase'.tr} ${PriceConverter.convertPrice(couponController.coupon!.minPurchase)}'
                    : '',
                validityText: couponController.coupon?.expireDate != null
                    ? '${'valid_till'.tr}: ${DateConverter.stringDateTimeToDate(couponController.coupon!.expireDate!)}'
                    : '',
                discountText: couponController.coupon != null
                    ? (couponController.coupon!.discountType == 'percent'
                        ? '${couponController.coupon!.discount!.toStringAsFixed(0)}% ${'off'.tr}'
                        : '${PriceConverter.convertPrice(couponController.coupon!.discount)} ${'off'.tr}')
                    : '',
                codeText: checkoutController.couponController.text,
                onCancel: () {
                  couponController.removeCouponData(true);
                  checkoutController.couponController.text = '';
                  if (checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
                    checkoutController.checkBalanceStatus((total + charge));
                  }
                },
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class CouponCard extends StatelessWidget {
  final String title, subtitle, validityText, discountText, codeText;
  final VoidCallback onCancel;

  const CouponCard({super.key, required this.title, required this.subtitle, required this.validityText, required this.discountText, required this.codeText, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    const double cutoutHeightRatio = 0.62;

    return ClipPath(
      clipper: CouponClipper(cutoutHeightRatio: cutoutHeightRatio),
      child: Container(
        color: context.surface,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title,
                      style: context.heading.defaultSize.medium,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: Dimensions.padding2xSmall),
                      Text(subtitle,
                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      ),
                    ],
                    if (validityText.isNotEmpty)
                      Text(validityText,
                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      ),
                  ]),
                ),
                if (discountText.isNotEmpty)
                  Text(discountText,
                    style: context.heading.extraLarge.strong,
                  ),
              ]),

              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
                child: CustomPaint(size: Size(constraints.maxWidth, 2),
                  painter: DashedLinePainter(color: context.surfaceContainer, strokeWidth: 2.5),
                ),
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(codeText, style: context.heading.large.strong)),
                ElevatedButton(onPressed: onCancel,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white, elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                  ),
                  child: Text('cancel'.tr,
                    style: context.heading.small.semiBold.overrideWith(color: Colors.white),
                  ),
                ),
              ]),
            ]);
          },
        ),
      ),
    );
  }
}

class CouponCardShimmer extends StatelessWidget {
  const CouponCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    const double cutoutHeightRatio = 0.62;

    return ClipPath(
      clipper: CouponClipper(cutoutHeightRatio: cutoutHeightRatio),
      child: Container(
        color: context.surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
        child: Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        height: 16, width: 140,
                        decoration: BoxDecoration(
                          color: context.bgNeutralLight,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSmall),

                      Container(
                        height: 12, width: 100,
                        decoration: BoxDecoration(
                          color: context.bgNeutralLight,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        ),
                      ),
                    ]),
                  ),

                  Container(
                    height: 16, width: 60,
                    decoration: BoxDecoration(
                      color: context.bgNeutralLight,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
                  child: CustomPaint(size: Size(constraints.maxWidth, 2),
                    painter: DashedLinePainter(color: context.surfaceContainer, strokeWidth: 2.5),
                  ),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    height: 16, width: 120,
                    decoration: BoxDecoration(
                      color: context.bgNeutralLight,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                  ),

                  Container(
                    height: 32, width: 80,
                    decoration: BoxDecoration(
                      color: context.bgNeutralLight,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault + 4),
                    ),
                  ),
                ]),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color; final double dashWidth, dashSpace, strokeWidth;
  DashedLinePainter({this.color = Colors.white, this.dashWidth = 6.0, this.dashSpace = 4.0, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


class CouponClipper extends CustomClipper<Path> {
  final double cutoutRadius; final double cutoutHeightRatio; final double borderRadius;
  CouponClipper({this.cutoutRadius = 12.0, this.cutoutHeightRatio = 0.62, this.borderRadius = 24.0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    final double w = size.width, h = size.height, cutoutY = h * cutoutHeightRatio;
    path.moveTo(borderRadius, 0);
    path.lineTo(w - borderRadius, 0);
    path.quadraticBezierTo(w, 0, w, borderRadius);
    path.lineTo(w, cutoutY - cutoutRadius);
    path.arcToPoint(Offset(w, cutoutY + cutoutRadius), radius: Radius.circular(cutoutRadius), clockwise: false);
    path.lineTo(w, h - borderRadius);
    path.quadraticBezierTo(w, h, w - borderRadius, h);
    path.lineTo(borderRadius, h);
    path.quadraticBezierTo(0, h, 0, h - borderRadius);
    path.lineTo(0, cutoutY + cutoutRadius);
    path.arcToPoint(Offset(0, cutoutY - cutoutRadius), radius: Radius.circular(cutoutRadius), clockwise: false);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
