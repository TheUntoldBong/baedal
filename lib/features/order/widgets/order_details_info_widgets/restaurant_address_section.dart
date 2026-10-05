import 'package:stackfood_multivendor/helper/order_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RestaurantUserAddressBlock extends StatelessWidget {
  final OrderModel order;

  const RestaurantUserAddressBlock({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String topName = order.restaurant?.name?.trim() ?? '';
    final String topAddress = order.restaurant?.address?.trim() ?? '';

    final AddressModel? bottom = order.deliveryAddress;
    final String bottomName = bottom?.contactPersonName?.trim() ?? '';
    final String bottomAddress = bottom?.address?.trim() ?? '';
    final String? bottomPhone = bottom?.contactPersonNumber?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddressTimeline(lineHeight: 52),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox( height: 66,
              child: _AddressEntryRow(
                title: topName,
                address: topAddress,
                trailing: _AddressActionSlot(order: order),
              ),
            ),
            const SizedBox(height: Dimensions.paddingDefault),
            _AddressEntryRow(
              title: bottomName,
              address: bottomAddress,
              phone: bottomPhone,
            ),
          ]),
        ),
      ],
    );
  }
}

class _AddressEntryRow extends StatelessWidget {
  final String title;
  final String? phone;
  final String address;
  final Widget? trailing;

  const _AddressEntryRow({
    required this.title,
    required this.address,
    this.phone,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone != null && phone!.trim().isNotEmpty;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: context.heading.large,
                children: [
                  TextSpan(text: title),
                  if (hasPhone)
                    TextSpan(
                      text: ' ($phone)',
                      style: context.heading.large.regular,
                    ),
                ],
              ),
            ),
            Text(
              address, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: context.heading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            ),
          ],
        ),
      ),
      const SizedBox(width: Dimensions.padding2xSmall),
      ?trailing,
    ]);
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dashHeight = 3.0;
    const dashSpace = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

class AddressTimeline extends StatelessWidget {
  final double lineHeight;
  final double iconSize;
  final double circleSize;
  final IconData topIcon;
  final IconData bottomIcon;
  final Color? color;

  const AddressTimeline({
    super.key,
    required this.lineHeight,
    this.iconSize = 16,
    this.circleSize = 28,
    this.topIcon = Icons.storefront_outlined,
    this.bottomIcon = Icons.near_me_outlined,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? context.iconBaseMedium;
    final lineColor = color ?? context.outline;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _TimelineIcon(icon: topIcon, color: iconColor, circleSize: circleSize, iconSize: iconSize),
      SizedBox(
        width: 2,
        height: lineHeight,
        child: CustomPaint(painter: _DashedLinePainter(color: lineColor)),
      ),
      _TimelineIcon(icon: bottomIcon, color: iconColor, circleSize: circleSize, iconSize: iconSize),
    ]);
  }
}

class _TimelineIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double circleSize;
  final double iconSize;

  const _TimelineIcon({
    required this.icon,
    required this.color,
    required this.circleSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

class _AddressActionSlot extends StatelessWidget {
  final OrderModel order;

  const _AddressActionSlot({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool subscription = order.subscription != null;
    final bool delivered = order.orderStatus == 'delivered';
    final bool refundActive = Get.find<SplashController>().configModel?.refundStatus ?? false;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (refundActive && delivered && !subscription) ...[
        _RefundOrderPill(orderId: order.id),
        const SizedBox(width: Dimensions.paddingSmall),
      ],
      _RestaurantContactActions(order: order),
    ]);
  }
}

class _RestaurantContactActions extends StatelessWidget {
  final OrderModel order;

  const _RestaurantContactActions({required this.order});

  Future<void> _call(BuildContext context) async {
    final phone = order.restaurant?.phone;
    if (phone == null || phone.isEmpty) {
      showCustomSnackBar('${'can_not_launch'.tr} -');
      return;
    }
    if (await canLaunchUrlString('tel:$phone')) {
      await launchUrlString('tel:$phone', mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'can_not_launch'.tr} $phone');
    }
  }

  Future<void> _chat() async {
    final restaurant = order.restaurant;
    if (restaurant == null) return;
    await Get.toNamed(RouteHelper.getChatRoute(
      user: User(fName: restaurant.name, lName: '', imageFullUrl: restaurant.logoFullUrl),
      notificationBody: NotificationBodyModel(restaurantId: restaurant.id, name:restaurant.name, orderId: int.tryParse(order.id.toString())),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final canContact = order.restaurant != null && OrderHelper.canContact(order.orderStatus);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (canContact) ...[
        _SoftCircleAction(icon: Images.phoneCallOrderDetails, onTap: () => _call(context)),
        const SizedBox(width: Dimensions.paddingDefault),
        _SoftCircleAction(icon: Images.chattingOrderDetails, onTap: () => _chat()),
        const SizedBox(width: Dimensions.padding2xSmall),
      ],
    ]);
  }
}

class _SoftCircleAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _SoftCircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomAssetImageWidget(icon, color: context.textBaseDefault, width: 22, height: 22),
    );
  }
}

class _RefundOrderPill extends StatelessWidget {
  final int? orderId;

  const _RefundOrderPill({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final Color errorColor = Theme.of(context).colorScheme.error;
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(orderId.toString())),
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSmall,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: errorColor.withAlpha(20),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          border: Border.all(color: errorColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.currency_exchange_rounded, size: 12, color: errorColor),
          const SizedBox(width: Dimensions.padding2xSmall),

          Text(
            'refund_order'.tr,
            style: context.body.extraSmall.regular.overrideWith(color: errorColor),
          ),
        ]),
      ),
    );
  }
}
