import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/delivery_log_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LogBottomSheetWidget extends StatefulWidget {
  final int? subscriptionID;
  final bool isDeliveryLog;
  final double? totalAmount;
  final int? orderQuantity;
  const LogBottomSheetWidget({super.key, required this.isDeliveryLog, this.subscriptionID, this.totalAmount, this.orderQuantity});

  @override
  State<LogBottomSheetWidget> createState() => _LogBottomSheetWidgetState();
}

class _LogBottomSheetWidgetState extends State<LogBottomSheetWidget> {

  @override
  void initState() {
    if(widget.isDeliveryLog) {
      Get.find<OrderController>().getDeliveryLogs(widget.subscriptionID, 1);
    }else {
      Get.find<OrderController>().getPauseLogs(widget.subscriptionID, 1);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 450 : MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isDesktop ? Dimensions.radiusDefault : Dimensions.radiusExtraLarge), topRight: Radius.circular(isDesktop ? Dimensions.radiusDefault :Dimensions.radiusExtraLarge),
          bottomLeft: Radius.circular(isDesktop ? Dimensions.radiusDefault : 0), bottomRight: Radius.circular(isDesktop ? Dimensions.radiusDefault : 0),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 40,
          decoration: BoxDecoration(
            color: context.bgNeutralMedium,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        Text(widget.isDeliveryLog ? 'delivery_log'.tr : 'pause_log'.tr, style: context.heading.defaultSize.strong),
        const SizedBox(height: Dimensions.paddingDefault),

        Flexible(
          child: GetBuilder<OrderController>(builder: (orderController) {

            bool notNull = widget.isDeliveryLog ? orderController.deliveryLogs != null : orderController.pauseLogs != null;
            int? length;
            if(notNull) {
              length = widget.isDeliveryLog ? orderController.deliveryLogs!.data!.length : orderController.pauseLogs!.data!.length;
            }

            return notNull ? length! > 0 ? ListView.builder(
              itemCount: length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {

                DeliveryLogModel? logData = widget.isDeliveryLog ? orderController.deliveryLogs!.data![index] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                  child: Row(children: [

                    Text('#${index + 1}', style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium)),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingDefault),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: widget.isDeliveryLog ? [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))] : null,
                        ),
                        child: widget.isDeliveryLog ? Column(children: [

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text('${'order_id'.tr} #${orderController.deliveryLogs!.data![index].orderId}', style: context.heading.large.strong),

                            Text(PriceConverter.convertPrice(widget.totalAmount! * widget.orderQuantity!), style: context.heading.large.strong),

                          ]),
                          const SizedBox(height: Dimensions.paddingSmall),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text(
                              DateConverter.dateTimeStringToDateTime(
                               logData!.orderStatus == 'pending' ? logData.scheduleAt! : logData.orderStatus == 'accepted' ? logData.accepted!
                               : logData.orderStatus == 'confirmed' ? logData.confirmed! : logData.orderStatus == 'processing' ? logData.processing!
                               : logData.orderStatus == 'handover' ? logData.handover!
                               : logData.orderStatus == 'picked_up' ? logData.pickedUp! : logData.orderStatus == 'delivered' ? logData.delivered!
                               : logData.orderStatus == 'canceled' ? logData.canceled! : logData.failed!
                              ),
                              style: context.body.defaultSize.regular,
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                              decoration: BoxDecoration(
                                color: logData.orderStatus == 'pending' ? Colors.blue.withValues(alpha: 0.1) : logData.orderStatus == 'delivered' ? Colors.green.withValues(alpha: 0.1)
                                  : context.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              ),
                              child: Text(
                                orderController.deliveryLogs!.data![index].orderStatus!.tr,
                                style: context.body.extraSmall.regular.overrideWith(
                                  color: logData.orderStatus == 'pending' ? Colors.blue : logData.orderStatus == 'delivered' ? Colors.green : context.primary,
                                ),
                              ),
                            ),

                          ]),

                        ]) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                          Text('${'subscription_id'.tr} #${orderController.pauseLogs!.data![index].subscriptionId}', style: context.heading.small.strong),

                          Text(
                            '${DateConverter.stringDateTimeToDate(orderController.pauseLogs!.data![index].from!)} '
                                '- ${DateConverter.stringDateTimeToDate(orderController.pauseLogs!.data![index].to!)}',
                            style: context.subHeading.small.medium,
                          ),

                        ]),
                      ),
                    ),
                  ]),
                );
              }
            ) : Center(child: Text('no_log_found'.tr)) : const Center(child: CircularProgressIndicator());
          }),
        ),

      ]),

    );
  }
}
