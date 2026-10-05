import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/common/enums/order_type.dart';
import 'package:stackfood_multivendor/common/enums/payment_type.dart';
import 'package:stackfood_multivendor/common/models/review_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/log_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/offline_info_edit_dialog.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_product_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/review_dialog_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/widgets/image_dialog_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class OrderInfoSection extends StatelessWidget {
  final OrderModel order;
  final OrderController orderController;
  final List<String> schedules;
  final bool showChatPermission;
  final String? contactNumber;
  final double? totalAmount;
  const OrderInfoSection({super.key, required this.order, required this.orderController, required this.schedules, required this.showChatPermission,
    this.contactNumber, this.totalAmount});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();

    bool pending = order.orderStatus == OrderStatus.pending.name;
    bool accepted = order.orderStatus == OrderStatus.accepted.name;
    bool confirmed = order.orderStatus == OrderStatus.confirmed.name;
    bool processing = order.orderStatus == OrderStatus.processing.name;
    bool pickedUp = order.orderStatus == OrderStatus.picked_up.name;
    bool delivered = order.orderStatus == OrderStatus.delivered.name;
    bool cancelled = order.orderStatus == OrderStatus.canceled.name;
    bool handover = order.orderStatus == OrderStatus.handover.name;
    bool failed = order.orderStatus == OrderStatus.failed.name;
    bool refunded = order.orderStatus == OrderStatus.refunded.name;
    bool refundRequested = order.orderStatus == OrderStatus.refund_requested.name;
    bool refundRequestCanceled = order.orderStatus == OrderStatus.refund_request_canceled.name;

    bool takeAway = order.orderType == OrderType.take_away.name;
    bool isDineIn = order.orderType == OrderType.dine_in.name;
    bool subscription = order.subscription != null;
    bool cod = order.paymentMethod == PaymentType.cash_on_delivery.name;

    bool ongoing = ((isDineIn ? true : !delivered) && !failed && !refundRequested && !refunded && !refundRequestCanceled && !cancelled);

    bool pastOrder = ((isDineIn ? false : delivered) || failed || refundRequested || refunded || refundRequestCanceled || cancelled);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        decoration: isDesktop ? BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(isDesktop ? Dimensions.radiusDefault : 0),
          boxShadow: [BoxShadow(color: isDesktop ? Colors.black.withValues(alpha: 0.05) : context.primary.withValues(alpha: 0.05), blurRadius: 10)],
        ) : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DateConverter.isBeforeTime(order.scheduleAt) || isDineIn ? (!cancelled && ongoing && !subscription) ?
          isDineIn ? Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

            isDesktop ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: Dimensions.paddingSmall, left: Dimensions.paddingLarge, bottom: Dimensions.paddingSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(subscription ? 'subscription_details'.tr : 'general_info'.tr, style: context.subHeading.defaultSize.medium),

                    (order.isPos ?? false) ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      ),
                      child: Text('pos_order'.tr, style: context.subHeading.small.medium),
                    ) : const SizedBox(),
                  ]),
                ),
              ),

              Text('${'order'.tr} # ${order.id.toString()}', style: context.heading.large.strong),
              const SizedBox(height: Dimensions.padding2xSmall),

              Text(
                (order.orderStatus == 'pending' || order.orderStatus == 'confirmed') ? '${'your_order_is'.tr} ${order.orderStatus?.tr}'
                : order.orderStatus == 'processing' ? 'your_food_is_cooking'.tr
                : order.orderStatus == 'handover' ? 'your_food_is_ready'.tr
                : order.orderStatus == 'canceled' ? 'your_order_is_canceled'.tr
                : 'your_food_is_served'.tr,
                style: context.body.defaultSize.regular.overrideWith(color: context.primary),
              ),

            ]) : const SizedBox(),

            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomAssetImageWidget(
                          pending ? Images.pendingDineIn :
                          confirmed ? Images.confirmDineIn
                              : processing ? Images.cookingDineIn
                              : handover ? Images.preparingFoodOrderDetails
                              : Images.servedDineIn,
                        height: 100, width: 100,),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingLarge),
                      child: order.orderStatus == 'pending' ? Text(
                        'your_order_is_pending_please_wait_for_restaurant_confirmation'.tr,
                         style: context.body.large.regular,
                      ) : order.orderStatus == 'processing' ? Column(children: [
                        Text(
                          'your_food_is_almost_ready'.tr,
                          textAlign: TextAlign.center, style: context.body.large.regular,
                        ),

                        Row(mainAxisSize: MainAxisSize.min, children: [

                          Text(
                            DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt, fromDineIn: true, processing: order.processing) < 5 ? '1 - 5'
                                : '${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt, fromDineIn: true, processing: order.processing)-5} '
                                '- ${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt, fromDineIn: true, processing: order.processing)}',
                            style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(width: Dimensions.padding2xSmall),

                          Text('min'.tr, style: context.subHeading.large.medium.overrideWith(color: context.textBaseDefault)),
                        ]),

                      ]) : order.orderStatus == 'confirmed' ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(text: 'your_dine_in_order_is_confirmed_please_make_sure_to_arrive_on_time'.tr, style: context.body.large.regular.overrideWith(color: context.textBaseDefault).copyWith(fontSize: Dimensions.fontSizeLarge - 1)),
                          TextSpan(text: ' - ', style: context.heading.defaultSize.strong.overrideWith(color: context.textBaseDefault)),
                          TextSpan(
                            text: DateConverter.dateTimeStringToDateTime(order.scheduleAt!),
                            style: context.subHeading.large.medium.overrideWith(color: context.textBaseDefault).copyWith(fontSize: Dimensions.fontSizeLarge - 1),
                          ),
                        ]),
                      ) : order.orderStatus == 'handover' ? DateConverter.differenceInMinute(null, order.createdAt, null, order.scheduleAt) > 0 ? Column(children: [
                        Text(
                          'your_food_is_ready_to_serve_you_are'.tr,
                          textAlign: TextAlign.center, style: context.body.large.regular,
                        ),

                        Row(mainAxisSize: MainAxisSize.min, children: [

                          Text(
                            DateConverter.differenceInMinute(null, order.createdAt, null, order.scheduleAt) < 5 ? '1 - 5 ${'min'.tr}'
                                : DateConverter.convertMinutesToDayHourMinute(DateConverter.differenceInMinute(null, order.createdAt, null, order.scheduleAt)),
                            style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr,
                          ),
                        ]),

                        Text(
                          'away_from_restaurant_hurry_up'.tr,
                          textAlign: TextAlign.center, style: context.body.large.regular,
                        ),

                      ]) : Text(
                        'your_food_is_ready_to_serve_hurry_up'.tr,
                        textAlign: TextAlign.center, style: context.body.large.regular,
                      ) : Text(
                        'enjoy_your_meal'.tr,
                        textAlign: TextAlign.center, style: context.body.large.regular,
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ]) : CustomCard(
            isBorder: false,
            borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
            child: isDesktop ? Column(children: [
              SizedBox(height: Dimensions.paddingSmall),

              Text('${subscription ? 'subscription'.tr : 'order'.tr} # ${order.id.toString()}', style: context.heading.defaultSize.strong),

              Text('${'your_order_is'.tr} ${order.orderStatus?.tr}', style: context.subHeading.small.medium.overrideWith(color: context.primary)),
              SizedBox(height: Dimensions.paddingLarge),

              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomAssetImageWidget(
                  pending ? Images.pendingOrderDetails : (confirmed || processing || handover) ? Images.preparingFoodOrderDetails : Images.animateDeliveryMan,
                  height: 100, width: 100,
                ),
              ),
              SizedBox(height: Dimensions.paddingDefault),

              Text('your_food_will_delivered_within'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
              const SizedBox(height: Dimensions.padding2xSmall),

              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) < 5 ? '1 - 5'
                      : '${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)-5} '
                      '- ${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                  style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr,
                ),
                const SizedBox(width: Dimensions.padding2xSmall),

                Text('min'.tr, style: context.subHeading.large.medium.overrideWith(color: context.primary)),
              ]),
              SizedBox(height: Dimensions.paddingSmall),
            ]) : Row(children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomAssetImageWidget(
                  pending ? Images.pendingOrderDetails : (confirmed || processing || handover) ? Images.preparingFoodOrderDetails : Images.animateDeliveryMan,
                  height: 100, width: 100,
                ),
              ),
              const SizedBox(width: Dimensions.paddingDefault),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('your_food_will_delivered_within'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) < 5 ? '1 - 5'
                    : '${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)-5} '
                    '- ${DateConverter.differenceInMinute(order.restaurant!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                    style: context.heading.extraLarge.strong, textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(width: Dimensions.padding2xSmall),

                  Text('min'.tr, style: context.subHeading.large.medium.overrideWith(color: context.primary)),
                ]),
              ]),
            ]),
          ) : const SizedBox() : const SizedBox(),
          SizedBox(height: DateConverter.isBeforeTime(order.scheduleAt) || isDineIn ? (!cancelled && ongoing && !subscription) ?
          isDineIn ? Dimensions.paddingDefault : Dimensions.paddingDefault : 0 : 0),

          pastOrder ? CustomCard(
            isBorder: false,
            borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: '${order.restaurant!.coverPhotoFullUrl}',
                height: 160, width: double.infinity,
                isRestaurant: true,
              ),
            ),
          ): const SizedBox(),
          SizedBox(height: pastOrder ? Dimensions.paddingDefault : 0),

          CustomCard(
            isBorder: false,
            borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(subscription ? 'subscription_details'.tr : 'general_info'.tr, style: context.subHeading.defaultSize.semiBold),

                (order.isPos ?? false) ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text('pos_order'.tr, style: context.subHeading.small.medium),
                ) : const SizedBox(),
              ]),
              SizedBox(height: Dimensions.paddingLarge),

              subscription ? Row(children: [
                Text('order_created'.tr, style: context.body.defaultSize.regular),
                const SizedBox(width: Dimensions.padding2xSmall),
                const Expanded(child: SizedBox()),

                Text(DateConverter.dateTimeStringToDateTime(order.createdAt!), style: context.body.defaultSize.regular),

              ]) : Row(children: [
                Text('${'order_id'.tr}:', style: context.body.defaultSize.regular),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text(order.id.toString(), style: context.subHeading.defaultSize.medium),
                const Expanded(child: SizedBox()),

                !isDineIn ? Row(children: [
                  const Icon(Icons.watch_later, size: 17),
                  const SizedBox(width: Dimensions.padding2xSmall),
                  Text(
                    DateConverter.dateTimeStringToDateTime(order.createdAt!),
                    style: context.body.defaultSize.regular,
                  ),
                ]) : const SizedBox(),
              ]),
              const Divider(height: Dimensions.paddingLarge),

              subscription ? Row(children: [
                Text('status'.tr, style: context.body.defaultSize.regular),
                const SizedBox(width: Dimensions.padding2xSmall),
                const Expanded(child: SizedBox()),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
                  decoration: BoxDecoration(
                    color: (subscription ? order.subscription!.status == 'canceled' || order.subscription!.status == 'expired' : (order.orderStatus == 'failed' || cancelled || order.orderStatus == 'refund_request_canceled'))
                      ? Colors.red.withValues(alpha: 0.1) : order.orderStatus == 'refund_requested' ? context.primary.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text(
                    delivered ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(order.delivered!)}'
                        : subscription ? order.subscription!.status!.tr : order.orderStatus!.tr,
                    style: context.heading.small.strong.overrideWith(
                      color: (subscription ? order.subscription!.status == 'canceled' || order.subscription!.status == 'expired' : (order.orderStatus == 'failed' || cancelled || order.orderStatus == 'refund_request_canceled'))
                        ? Colors.red : order.orderStatus == 'refund_requested' ? context.primary : Colors.green,
                    ),
                  ),
                ),

              ]) : const SizedBox(),

              isDineIn ? Row(children: [
                Text('${'order_date'.tr} :', style: context.body.defaultSize.regular),
                Spacer(),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text(DateConverter.dateTimeStringToDateTime(order.createdAt!), style: context.subHeading.defaultSize.medium),
              ]) : const SizedBox(),
              isDineIn ? const Divider(height: Dimensions.paddingExtraLarge) : const SizedBox(),

              isDineIn ? Row(children: [
                Text('${'dine_in_date'.tr}:', style: context.body.defaultSize.regular),
                Spacer(),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: context.subHeading.defaultSize.medium),
              ]) : const SizedBox(),
              isDineIn ? const Divider(height: Dimensions.paddingExtraLarge) : const SizedBox(),

              subscription ? const Divider(height: Dimensions.paddingExtraLarge) : const SizedBox(),

              order.scheduled == 1 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${'scheduled_at'.tr} :', style: context.body.defaultSize.regular),
                const SizedBox(width: Dimensions.padding2xSmall),

                Text(DateConverter.dateTimeStringToDateTime(order.createdAt!), style: context.body.defaultSize.regular),
              ]) : SizedBox.shrink(),
              order.scheduled == 1 ? const Divider(height: Dimensions.paddingLarge) : const SizedBox(),

              Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(children: [
                Text('${order.orderType == 'delivery' ? 'delivery_verification_code'.tr : 'order_verification_code'.tr} :', style: context.body.defaultSize.regular),
                const Expanded(child: SizedBox()),
                Text(order.otp!, style: context.subHeading.defaultSize.medium),
              ]) : const SizedBox(),
              Get.find<SplashController>().configModel!.orderDeliveryVerification! ?const Divider(height: Dimensions.paddingLarge) : const SizedBox(),

              Row(children: [
                Text(order.orderType!.tr, style: context.body.defaultSize.regular),
                const Expanded(child: SizedBox()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Text(
                    cod ? 'cash_on_delivery'.tr
                        : order.paymentMethod == 'wallet' ? 'wallet_payment'.tr
                        : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr
                        : order.paymentMethod == 'offline_payment' ? 'offline_payment'.tr : 'digital_payment'.tr,
                    style: context.subHeading.extraSmall.medium.overrideWith(color: context.primary),
                  ),
                ),
              ]),

              const Divider(height: Dimensions.paddingLarge),

              order.deliveryType != null ? Column(
                children: [
                  Row(children: [
                    Text('delivery_type'.tr, style: context.body.defaultSize.regular),
                    const Expanded(child: SizedBox()),

                    Text(order.deliveryType?.replaceAll('_', ' ').capitalize??'', style: context.body.defaultSize.regular.overrideWith(color: context.primary)),
                  ]),

                  const Divider(height: Dimensions.paddingLarge),
                ],
              ) : const SizedBox(),

              subscription ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(children: [
                  Text('type'.tr, style: context.body.defaultSize.regular),
                  const SizedBox(width: Dimensions.padding2xSmall),
                  const Expanded(child: SizedBox()),

                  Text(order.subscription!.type!.tr, style: context.body.defaultSize.regular),

                  Text(' (${DateConverter.dateTimeToMonth(order.subscription!.startAt!)} ''- ${DateConverter.dateTimeToMonth(order.subscription!.endAt!)})',
                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ]),
                const Divider(height: Dimensions.paddingExtraLarge),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingDefault),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('${'subscription_schedule'.tr}:', style: context.subHeading.defaultSize.medium),
                        const SizedBox(height: Dimensions.padding2xSmall),

                        Text('you_will_get_your_order_daily_at'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),

                      ]),

                      schedules.length > 1 ? const SizedBox() : SizedBox(height: 35, width: 88, child: ListView.builder(
                        itemCount: schedules.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(Dimensions.radiusExtraSmall),
                              dashPattern: const [3, 3],
                              color: context.outline,
                              padding: EdgeInsets.zero,
                              strokeWidth: 1,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  schedules[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.body.defaultSize.regular,
                                ),
                              ]),
                            ),
                          );
                        },
                      )),

                    ]),
                    SizedBox(height: schedules.length > 1 ? Dimensions.paddingDefault : 0),

                    schedules.length > 1 ? SizedBox(height: ResponsiveHelper.isDesktop(context) ? 50 : 45, child: ListView.builder(
                      itemCount: schedules.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {

                        String schedulesDay = schedules[index].split(' ')[0];
                        String schedulesTime = '${schedules[index].split(' ')[1].replaceAll('(', '')} ${schedules[index].split(' ')[2].replaceAll(')', '')}';

                        return Padding(
                          padding: EdgeInsets.only(right: index == schedules.length - 1 ? 0 : Dimensions.paddingSmall),
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(Dimensions.radiusExtraSmall),
                              dashPattern: const [3, 3],
                              color: context.outline,
                              padding: EdgeInsets.zero,
                              strokeWidth: 1,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(schedulesDay, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.body.defaultSize.regular),
                                Text(schedulesTime, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.body.defaultSize.regular),
                              ]),
                            ),
                          ),
                        );
                      },
                    )) : const SizedBox(),

                  ]),
                ),
                const SizedBox(height: Dimensions.paddingExtraLarge),

                Row(children: [

                  Expanded(child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                        ),
                        builder: (context) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                            child: LogBottomSheetWidget(isDeliveryLog: true, subscriptionID: order.subscriptionId, totalAmount: totalAmount, orderQuantity: order.subscription!.quantity),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSmall),
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        border: Border.all(color: context.primary, width: 1),
                      ),
                      child: Text('delivery_log'.tr, textAlign: TextAlign.center, style: context.subHeading.defaultSize.regular.overrideWith(color: context.primary)),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingLarge),

                  Expanded(child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                        ),
                        builder: (context) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                            child: LogBottomSheetWidget(isDeliveryLog: false, subscriptionID: order.subscriptionId),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSmall),
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        border: Border.all(color: context.textBaseMedium, width: 1),
                      ),
                      child: Text('pause_log'.tr, textAlign: TextAlign.center, style: context.subHeading.defaultSize.regular),
                    ),
                  )),

                ]),

                const SizedBox(height: Dimensions.padding2xSmall),
                const Divider(height: Dimensions.paddingLarge),
              ]) : const SizedBox(),

              subscription ? const SizedBox() : Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                child: Row(children: [
                  Text('${'item'.tr} :', style: context.body.defaultSize.regular),
                  const SizedBox(width: Dimensions.padding2xSmall),
                  Text(
                    orderController.orderDetails!.length.toString(),
                    style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(height: 7, width: 7, decoration: BoxDecoration(
                    color: (subscription ? order.subscription!.status == 'canceled' : (order.orderStatus == 'failed' || cancelled || order.orderStatus == 'refund_request_canceled'))
                        ? Colors.red : order.orderStatus == 'refund_requested' ? context.primary : Colors.green ,
                    shape: BoxShape.circle,
                  )),
                  const SizedBox(width: Dimensions.padding2xSmall),
                  Text(
                    delivered ? '${isDineIn ? 'served_at'.tr : 'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(order.delivered!)}'
                        : subscription ? order.subscription!.status!.tr
                        : isDineIn ? order.orderStatus == 'processing' ? 'cooking'.tr
                        : order.orderStatus == 'handover' ? 'ready_to_serve'.tr
                        : order.orderStatus == 'pending' ? 'pending'.tr
                        : order.orderStatus == 'canceled' ? 'canceled'.tr
                        : order.orderStatus == 'confirmed' ? 'confirmed'.tr
                        : 'served'.tr : order.orderStatus!.tr,
                    style: context.body.small.regular,
                  ),
                ]),
              ),

              !isDineIn ? Column(children: [
                subscription ? const SizedBox() : const Divider(height: Dimensions.paddingLarge),

                Row(children: [
                  Text('${'cutlery'.tr} : ', style: context.body.defaultSize.regular),
                  const Expanded(child: SizedBox()),

                  Text(
                    order.cutlery! ? 'yes'.tr : 'no'.tr,
                    style: context.body.small.regular,
                  ),
                ]),
              ]) : const SizedBox(),

              order.bringChangeAmount != null && order.bringChangeAmount! > 0 ? Column(
                children: [
                  const Divider(height: Dimensions.paddingLarge),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: const Color(0XFF009AF1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'please_bring'.tr, style: context.subHeading.defaultSize.regular),
                        TextSpan(text: ' ${PriceConverter.convertPrice(order.bringChangeAmount)}', style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseDefault)),
                        TextSpan(text: ' ${'in_change_when_making_the_delivery'.tr}', style: context.subHeading.defaultSize.regular),
                      ]),
                    ),
                  ),
                ],
              ) : const SizedBox(),

              order.unavailableItemNote != null && order.unavailableItemNote != '' && order.orderType == 'delivery' ? Column(
                children: [
                  const Divider(height: Dimensions.paddingLarge),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                    child: Row(children: [
                      Text('${'if_item_is_not_available'.tr} : ', style: context.subHeading.defaultSize.medium),
                      Text(order.unavailableItemNote!.tr, style: context.body.defaultSize.regular),
                    ]),
                  ),
                ],
              ) : const SizedBox(),

              order.deliveryInstruction != null && order.deliveryInstruction != '' && order.orderType == 'delivery' ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                ),
                child: Column(children: [
                  order.unavailableItemNote != null && order.unavailableItemNote != '' ? const Divider(height: Dimensions.paddingLarge) : SizedBox.shrink(),

                  Row(children: [
                    Text('${'delivery_instruction'.tr} : ', style: context.subHeading.defaultSize.medium),
                    Text(order.deliveryInstruction!.tr, style: context.body.defaultSize.regular),
                  ]),

                  SizedBox(height: Dimensions.paddingSmall),
                ]),
              ) : const SizedBox(),

              cancelled && order.cancellationReason != null && order.cancellationReason != '' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(height: Dimensions.paddingLarge),
                Text('${'cancellation_reason'.tr} :', style: context.subHeading.defaultSize.medium),
                const SizedBox(height: Dimensions.paddingSmall),

                InkWell(
                  onTap: () => showCustomDialog(child: ReviewDialogWidget(review: ReviewModel(comment: order.cancellationReason), fromOrderDetails: true)),
                  child: Text(
                    order.cancellationReason ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ),

              ]) : const SizedBox(),

              cancelled && order.cancellationNote != null && order.cancellationNote != '' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(height: Dimensions.paddingLarge),

                Text('${'cancellation_note'.tr}:', style: context.subHeading.defaultSize.medium),
                const SizedBox(height: Dimensions.paddingSmall),

                InkWell(
                  onTap: () => showCustomDialog(child: ReviewDialogWidget(review: ReviewModel(comment: order.cancellationNote), fromOrderDetails: true)),
                  child: Text(
                    order.cancellationNote ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ),

              ]) : const SizedBox(),

              (order.orderStatus == 'refund_requested' || order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const Divider(height: Dimensions.paddingLarge),
                order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  RichText(text: TextSpan(children: [
                    TextSpan(text: '${'refund_note'.tr}:', style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseDefault)),
                    TextSpan(text: '(${(order.refund != null) ? order.refund!.customerReason : ''})', style: context.subHeading.defaultSize.regular),
                  ])),
                  const SizedBox(height: Dimensions.paddingSmall),

                  (order.refund != null && order.refund!.customerNote != null) ? InkWell(
                    onTap: () => showCustomDialog(child: ReviewDialogWidget(review: ReviewModel(comment: order.refund!.customerNote), fromOrderDetails: true)),
                    child: Text(
                      '${order.refund!.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ) : const SizedBox(),
                  SizedBox(height: (order.refund != null && order.refund!.imageFullUrl != null) ? Dimensions.paddingSmall : 0),

                  (order.refund != null && order.refund!.imageFullUrl != null && order.refund!.imageFullUrl!.isNotEmpty) ? InkWell(
                    onTap: () => showCustomDialog(
                      child: ImageDialogWidget(imageUrl: order.refund!.imageFullUrl!.isNotEmpty ? order.refund!.imageFullUrl![0] : ''),
                    ),
                    child: CustomImageWidget(
                      height: 40, width: 40, fit: BoxFit.cover,
                      image: order.refund != null ? order.refund!.imageFullUrl!.isNotEmpty ? order.refund!.imageFullUrl![0] : '' : '',
                    ),
                  ) : const SizedBox(),
                ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Divider(height: Dimensions.paddingLarge),

                  Text('${'refund_cancellation_note'.tr}:', style: context.subHeading.defaultSize.medium),
                  const SizedBox(height: Dimensions.paddingSmall),

                  InkWell(
                    onTap: () => showCustomDialog(child: ReviewDialogWidget(review: ReviewModel(comment: order.refund!.adminNote), fromOrderDetails: true)),
                    child: Text(
                      '${order.refund != null ? order.refund!.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ),

                ]),
              ]) : const SizedBox(),

              (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(height: Dimensions.paddingLarge),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${'additional_note'.tr}: ", style: context.body.defaultSize.regular),
                      const SizedBox(height: Dimensions.paddingSmall),

                      Text(
                        order.orderNote ?? '',
                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSmall),

              ]) : const SizedBox(),

              (order.orderReference != null && (order.orderReference!.tableNumber != null || order.orderReference!.tokenNumber != null) && !isDesktop) ? Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  border: Border.all(width: 0.5, color: context.primary),
                  boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)]
                ),
                child: Wrap(runAlignment: WrapAlignment.spaceBetween, children: [

                  (order.orderReference!.tokenNumber != null && order.orderReference!.tokenNumber!.isNotEmpty) ? Row(mainAxisSize: MainAxisSize.min, children: [
                    CustomAssetImageWidget(Images.couponIcon, height: 20, width: 20, color: context.primary),
                    const SizedBox(width: Dimensions.padding2xSmall),

                    Text(order.orderReference!.tokenNumber??'', style: context.heading.defaultSize.strong),
                    const SizedBox(width: Dimensions.padding2xSmall),

                    Text('(${'token_no'.tr})', style: context.body.defaultSize.regular.overrideWith(color: context.primary)),
                  ]) : const SizedBox(),

                  (order.orderReference!.tableNumber != null && order.orderReference!.tableNumber!.isNotEmpty) ? Text('${'table_no'.tr} - ${order.orderReference!.tableNumber}',
                    style: context.body.defaultSize.regular.overrideWith(color: Colors.blue),
                  ) : SizedBox(),

                ]),
              ) : const SizedBox(),

              (order.orderStatus == 'delivered' && order.orderProofFullUrl != null && order.orderProofFullUrl!.isNotEmpty) ? Container(
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  boxShadow: [BoxShadow(color: context.primary.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('order_proof'.tr, style: context.body.defaultSize.regular),
                  const SizedBox(height: Dimensions.paddingSmall),

                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1.5,
                      crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 5,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.orderProofFullUrl!.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => openDialog(context, order.orderProofFullUrl![index]),
                          child: Center(child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                            child: CustomImageWidget(
                              image: order.orderProofFullUrl![index],
                              width: 100, height: 100,
                            ),
                          )),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: Dimensions.paddingLarge),
                ]),
              ) : const SizedBox(),
            ]),
          ),
        ]),
      ),

      (order.orderReference != null && (order.orderReference!.tableNumber != null || order.orderReference!.tokenNumber != null) && isDesktop) ? Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
        margin: const EdgeInsets.only(top: Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          (order.orderReference!.tokenNumber != null && order.orderReference!.tokenNumber!.isNotEmpty) ? Expanded(
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                CustomAssetImageWidget(Images.couponIcon, height: 20, width: 20, color: context.primary),
                const SizedBox(width: Dimensions.padding2xSmall),
                Text('(${'token_no'.tr}) - ', style: context.body.defaultSize.regular.overrideWith(color: context.primary)),
                Text(order.orderReference!.tokenNumber??'', style: context.heading.defaultSize.strong),
              ]),
            ),
          ) : SizedBox(),
          (order.orderReference!.tableNumber != null && order.orderReference!.tableNumber!.isNotEmpty) &&
          (order.orderReference!.tokenNumber != null && order.orderReference!.tokenNumber!.isNotEmpty) ?
          Container(height: 40, width: 1, color: context.outline) : SizedBox(),

          (order.orderReference!.tableNumber != null && order.orderReference!.tableNumber!.isNotEmpty) ? Expanded(
            child: Center(
              child: Text('${'table_no'.tr} - ${order.orderReference!.tableNumber}',
                style: context.body.defaultSize.regular.overrideWith(color: Colors.blue),
              ),
            ),
          ) : SizedBox(),

        ]),
      ) : const SizedBox(),
      const SizedBox(height: Dimensions.paddingDefault),

      isDineIn ? SizedBox() : CustomCard(
        isBorder: false,
        borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('delivery_information'.tr, style: context.subHeading.defaultSize.semiBold),
          Divider(height: 25),

          RichText(
            text: TextSpan(children: [
              TextSpan(text: '${'name'.tr} : ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
              TextSpan(
                text: order.deliveryAddress?.contactPersonName ?? '',
                style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseDefault),
              ),
              TextSpan(text: ' (${order.deliveryAddress?.contactPersonNumber})', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSmall),

          Wrap(children: [

            (order.deliveryAddress?.road != null && order.deliveryAddress!.road!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'street_number'.tr} : ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                TextSpan(
                  text: order.deliveryAddress?.road ?? '',
                  style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseDefault),
                ),
              ]),
            ) : const SizedBox(),

            (order.deliveryAddress?.road != null && order.deliveryAddress!.road!.isNotEmpty) ? Container(
              height: 12, width: 1, color: context.textBaseMedium,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
            ) : const SizedBox(),

            (order.deliveryAddress?.house != null && order.deliveryAddress!.house!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'house'.tr} : ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                TextSpan(
                  text: order.deliveryAddress?.house ?? '',
                  style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseDefault),
                ),
              ]),
            ) : const SizedBox(),

            (order.deliveryAddress?.house != null && order.deliveryAddress!.house!.isNotEmpty) ? Container(
              height: 12, width: 1, color: context.textBaseMedium,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
            ) : const SizedBox(),

            (order.deliveryAddress?.floor != null && order.deliveryAddress!.floor!.isNotEmpty) ? RichText(
              text: TextSpan(children: [
                TextSpan(text: '${'floor'.tr} : ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                TextSpan(
                  text: order.deliveryAddress?.floor ?? '',
                  style: context.subHeading.small.semiBold.overrideWith(color: context.textBaseDefault),
                ),
              ]),
            ) : const SizedBox(),

          ]),
          SizedBox(
            height: (order.deliveryAddress?.road != null && order.deliveryAddress!.road!.isNotEmpty) || (order.deliveryAddress?.house != null && order.deliveryAddress!.house!.isNotEmpty)
                || (order.deliveryAddress?.floor != null && order.deliveryAddress!.floor!.isNotEmpty) ? Dimensions.paddingSmall : 0,
          ),

          Row(children: [

            Icon(Icons.location_on, size: 20, color: context.textBaseMedium),
            const SizedBox(width: Dimensions.padding2xSmall),

            Expanded(
              child: Text(
                order.deliveryAddress?.address ?? '',
                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),

          ]),

        ]),
      ),
      const SizedBox(height: Dimensions.paddingSmall),

      !isDesktop ? Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          title: Row(
            children: [
              Text(
                'item_info'.tr,
                style: context.subHeading.defaultSize.semiBold,
              ),
              SizedBox(width: Dimensions.padding2xSmall),

              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(orderController.orderDetails!.length.toString(), style: context.body.defaultSize.regular.overrideWith(color: context.primary)),
              ),
            ],
          ),
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderController.orderDetails!.length,
              itemBuilder: (context, index) {
                return Column(children: [
                  OrderProductWidget(order: order, orderDetails: orderController.orderDetails![index], itemLength: orderController.orderDetails!.length, index: index),

                  index == orderController.orderDetails!.length - 1 ? const SizedBox() : const Divider(height: Dimensions.paddingLarge),
                ]);
              },
            ),
          ],
        ),
      ) : const SizedBox(),
      const SizedBox(height: Dimensions.paddingDefault),

      CustomCard(
        isBorder: false,
        borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: Text('restaurant_details'.tr, style: context.subHeading.defaultSize.semiBold),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge), child: Divider()),

          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(order.restaurant?.id, slug: order.restaurant?.slug ?? '')),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                order.restaurant != null ? Row(children: [

                  ClipOval(child: CustomImageWidget(
                    image: '${order.restaurant!.logoFullUrl}',
                    height: 50, width: 50, fit: BoxFit.cover, isRestaurant: true,
                  )),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(
                        child: Text(
                          order.restaurant!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: context.subHeading.defaultSize.medium,
                        ),
                      ),
                      if(order.restaurant!.verifiedSeller == true) ...[
                        const SizedBox(width: Dimensions.padding2xSmall),
                        const RestaurantVerifiedIconWidget(),
                      ],
                    ]),
                    const SizedBox(height: Dimensions.padding2xSmall),

                    Text(
                      order.restaurant!.address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                    ),

                  ])),

                  (takeAway && !isDineIn && (pending || accepted || confirmed || processing || order.orderStatus == 'handover'
                  || pickedUp)) ? TextButton.icon(
                    onPressed: () async {
                      String url ='https://www.google.com/maps/dir/?api=1&destination=${order.restaurant!.latitude}'
                          ',${order.restaurant!.longitude}&travelmode=driving';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('unable_to_launch_google_map'.tr);
                      }
                    },
                    icon: const Icon(Icons.directions), label: Text('direction'.tr),
                  ) : const SizedBox(),

                  isDineIn ? InkWell(
                    onTap: ()=> Get.toNamed(RouteHelper.getMapRoute(
                      AddressModel(
                        id: order.restaurant!.id, address: order.restaurant!.address, latitude: order.restaurant!.latitude,
                        longitude: order.restaurant!.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
                      ), 'order',
                      restaurantName: order.restaurant!.name, restaurant: order.restaurant, isDineOrder: isDineIn,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomAssetImageWidget(Images.restaurantIconMarker, height: 25, width: 25, fit: BoxFit.cover),
                    ),
                  ) : const SizedBox(),

                  (showChatPermission && !delivered && order.orderStatus != 'failed' && !cancelled && order.orderStatus != 'refunded' && !isGuestLoggedIn) ? InkWell(
                    onTap: () async {
                      orderController.cancelTimer();
                      await Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBodyModel(orderId: order.id, restaurantId: order.restaurant!.vendorId),
                        user: User(id: order.restaurant!.vendorId, fName: order.restaurant!.name, lName: '', imageFullUrl: order.restaurant!.logoFullUrl, phone: order.restaurant!.phone),
                      ));
                      orderController.callTrackOrderApi(orderModel: order, orderId: order.id.toString());
                    },
                    child: CustomAssetImageWidget(Images.chatImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                  ) : const SizedBox(),

                  SizedBox(width: order.restaurant!.phone != null ? Dimensions.paddingDefault : 0),

                  order.restaurant!.phone != null ? InkWell(
                    onTap: () async {
                      if(await canLaunchUrlString('tel:${order.restaurant!.phone}')) {
                        launchUrlString('tel:${order.restaurant!.phone}', mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('${'can_not_launch'.tr} ${order.restaurant!.phone}');
                      }
                    },
                    child: CustomAssetImageWidget(Images.callImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                  ) : const SizedBox(),

                  SizedBox(width: (!subscription && Get.find<SplashController>().configModel!.refundStatus! && delivered && orderController.orderDetails![0].itemCampaignId == null && !isGuestLoggedIn)
                      ? Dimensions.paddingDefault : 0),

                  (!subscription && Get.find<SplashController>().configModel!.refundStatus! && delivered && orderController.orderDetails![0].itemCampaignId == null && !isGuestLoggedIn) ? InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(order.id.toString())),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: context.primary, width: 1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall, vertical: Dimensions.paddingSmall),
                      child: Text('request_for_refund'.tr, style: context.subHeading.small.medium.overrideWith(color: context.primary)),
                    ),
                  ) : const SizedBox(),

                ]) : Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                  child: Text(
                    'no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: context.body.small.regular,
                  ),
                )),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingDefault),

      order.deliveryMan != null ? CustomCard(
        isBorder: false,
        borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: Text('delivery_man_details'.tr, style: context.subHeading.defaultSize.semiBold),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge), child: Divider()),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                ClipOval(child: CustomImageWidget(
                  image: '${order.deliveryMan!.imageFullUrl}',
                  height: 35, width: 35, fit: BoxFit.cover, placeholder: Images.profilePlaceholder,
                )),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.subHeading.defaultSize.medium,
                  ),
                  RatingBarWidget(
                    rating: order.deliveryMan!.avgRating, size: 10,
                    ratingCount: order.deliveryMan!.ratingCount,
                  ),
                ])),

                !isGuestLoggedIn ? InkWell(
                  onTap: () async {
                    orderController.cancelTimer();
                    await Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(deliverymanId: order.deliveryMan!.id, orderId: int.parse(order.id.toString())),
                      user: User(id: order.deliveryMan!.id, fName: order.deliveryMan!.fName, lName: order.deliveryMan!.lName, imageFullUrl: order.deliveryMan!.imageFullUrl),
                    ));
                    orderController.callTrackOrderApi(orderModel: order, orderId: order.id.toString());
                  },
                  child: CustomAssetImageWidget(Images.chatImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                ) : const SizedBox(),
                const SizedBox(width: Dimensions.paddingDefault),

                InkWell(
                  onTap: () async {
                    if(await canLaunchUrlString('tel:${order.deliveryMan!.phone}')) {
                      launchUrlString('tel:${order.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                    }else {
                      showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                    }

                  },
                  child: CustomAssetImageWidget(Images.callImageOrderDetails, height: 25, width: 25, fit: BoxFit.cover),
                ),

              ]),

              order.deliveryMan!.restaurantId != null ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  color: context.bgNeutralLight,
                ),
                padding: EdgeInsets.all(Dimensions.padding2xSmall),
                margin: EdgeInsets.only(top: Dimensions.paddingSmall),
                child: Text(
                    'this_delivery_man_is_restaurant_delivery_man'.tr,
                    style: context.body.small.regular,
                ),
              ) : const SizedBox(),

            ]),
          ),
        ]),
      ) : const SizedBox(),
      SizedBox(height: order.deliveryMan != null ? Dimensions.paddingLarge : 0),

      CustomCard(
        isBorder: false,
        borderRadius: isDesktop ? Dimensions.radiusDefault : 0,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('payment_method'.tr, style: context.subHeading.defaultSize.semiBold),

              Text(order.paymentStatus!.tr, style: context.body.defaultSize.regular.overrideWith(color: order.paymentStatus == 'paid' ? Colors.green : Colors.red)),
            ],
          ),
          Divider(),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            !isDesktop ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              order.paymentMethod == 'offline_payment' || (order.paymentMethod == 'partial_payment' && orderController.trackModel!.offlinePayment != null) ? Text(
                orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status!.tr : '',
                style: context.subHeading.defaultSize.medium.overrideWith(color: (orderController.trackModel!.offlinePayment != null ? orderController.trackModel!.offlinePayment!.data!.status.toString() == 'denied' : false) ? Colors.red : context.primary),
              ) : const SizedBox(),
            ]) : const SizedBox(),
            SizedBox(height: (!isDesktop && order.paymentMethod != 'offline_payment') ? Dimensions.paddingSmall : 0),

            order.paymentMethod == 'offline_payment'  || (order.paymentMethod == 'partial_payment' && orderController.trackModel!.offlinePayment != null)
            ? offlineView(context, orderController, ongoing, contactNumber) :  Row(children: [

              CustomAssetImageWidget(
                order.paymentMethod == 'cash_on_delivery' ? Images.cash : order.paymentMethod == 'wallet' ? Images.wallet
                : order.paymentMethod == 'partial_payment' ? Images.partialWallet : Images.digitalPayment,
                width: 24, height: 24,
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(
                child: Text(
                  order.paymentMethod == 'cash_on_delivery' ? 'cash'.tr : order.paymentMethod == 'wallet' ? 'wallet'.tr
                  : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr : 'digital'.tr,
                  style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                ),
              ),

            ]),
          ]),
        ]),
      ),
    ]);
  }
}

Widget offlineView(BuildContext context, OrderController orderController, bool ongoing, String? contactNumber) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(0),
    dense: true,
    horizontalTitleGap: 5.0,
    minLeadingWidth: 0,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: CustomAssetImageWidget(
          Images.cash, width: 20, height: 20,
        ),
        title: Text(
          'offline_payment'.tr,
          style: context.subHeading.small.medium.overrideWith(color: context.textBaseMedium),
        ),
        trailing: Icon(orderController.isExpanded ? Icons.expand_more : Icons.expand_less, size: 18),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        onExpansionChanged: (value) => orderController.expandedUpdate(value),

        children: [
          const Divider(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('seller_payment_info'.tr, style: context.subHeading.defaultSize.medium),
            const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingDefault),

          orderController.trackModel!.offlinePayment != null ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.trackModel!.offlinePayment!.methodFields!.length,
            itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.padding2xSmall),
                child: Row(children: [
                  Text('${orderController.trackModel!.offlinePayment!.methodFields![index].inputName.toString().replaceAll('_', ' ')} : ', style: context.body.defaultSize.regular),
                  Text('${orderController.trackModel!.offlinePayment!.methodFields![index].inputData}', style: context.body.defaultSize.regular),
                ]),
              );
            },
          ) : Text('no_data_found'.tr),
          const Divider(),

          orderController.trackModel!.offlinePayment != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('my_payment_info'.tr, style: context.subHeading.defaultSize.medium),

            (ongoing && orderController.trackModel!.offlinePayment!.data!.status != 'verified') ? InkWell(
              onTap: (){
                showCustomDialog(
                  child: OfflineInfoEditDialog(offlinePayment: orderController.trackModel!.offlinePayment!, orderId: orderController.trackModel!.id!, contactNumber: contactNumber),
                  isDismissible: true,
                );
              },
              child: Text('edit_details'.tr, style: context.heading.defaultSize.strong.overrideWith(color: Colors.blue)),
            ) : const SizedBox(),
          ]) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingDefault),

          orderController.trackModel!.offlinePayment != null ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.trackModel!.offlinePayment!.input!.length,
            itemBuilder: (context, index){
              Input data = orderController.trackModel!.offlinePayment!.input![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.padding2xSmall),
                child: Row(children: [
                  Text('${data.userInput.toString().replaceAll('_', ' ')}: ', style: context.body.defaultSize.regular),
                  Text(data.userData.toString(), style: context.body.defaultSize.regular),
                ]),
              );
            },
          ) : const SizedBox(),
        ],
      ),
    ),
  );
}

void openDialog(BuildContext context, String imageUrl) => showCustomDialog(
  child: DialogSheetBody(
    child: Stack(children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: PhotoView(
          tightMode: true,
          imageProvider: NetworkImage(imageUrl),
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
        ),
      ),

      Positioned(top: 0, right: 0, child: IconButton(
        splashRadius: 5,
        onPressed: () => Get.back(),
        icon: const Icon(Icons.cancel, color: Colors.red),
      )),

    ]),
  ),
);
