import 'package:stackfood_multivendor/helper/order_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeliveryManSection extends StatelessWidget {
  final OrderModel order;

  const DeliveryManSection({super.key, required this.order});

  Future<void> _call() async {
    final phone = order.deliveryMan?.phone;
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
    final dm = order.deliveryMan;
    if (dm == null) return;
    await Get.toNamed(RouteHelper.getChatRoute(
      notificationBody: NotificationBodyModel(deliverymanId: dm.id, orderId: int.tryParse(order.id.toString())),
      user: User(id: dm.id, fName: dm.fName, lName: dm.lName, imageFullUrl: dm.imageFullUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final deliveryMan = order.deliveryMan!;
    final name = '${deliveryMan.fName ?? ''} ${deliveryMan.lName ?? ''}'.trim();
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Icon(Icons.directions_bike, color: Theme.of(context).textTheme.bodyLarge?.color, size: 22),

        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(name.isEmpty ? '-' : name.capitalize!, style: context.heading.large, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),

            Row(children: [
               Icon(Icons.star, color: context.primary, size: Dimensions.fontSizeSmall),
              const SizedBox(width: 2),
              Text(
                (deliveryMan.avgRating ?? 0).toStringAsFixed(1),
                style: context.body.small.medium,
              ),
              const SizedBox(width: 6),
              Text(
                '(${deliveryMan.ratingCount ?? 0})',
                style:  context.body.small.regular.overrideWith(color: context.textBaseMedium),
              ),
            ]),
          ]),
        ),

        const SizedBox(width: Dimensions.paddingSmall),
        if (OrderHelper.canContact(order.orderStatus)) ...[
          _ContactAction(icon: Images.phoneCallOrderDetails, onTap: _call),
          const SizedBox(width: Dimensions.paddingDefault),
          _ContactAction(icon: Images.chattingOrderDetails, onTap: _chat),
        ],
      ]),
    );
  }
}

class _ContactAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _ContactAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: CustomAssetImageWidget(icon, color: context.textBaseDefault, width: 22, height: 22),
      ),
    );
  }
}
