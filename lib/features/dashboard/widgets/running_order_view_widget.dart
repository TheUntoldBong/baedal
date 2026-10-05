import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/helper/color_coverter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class RunningOrderViewWidget extends StatelessWidget {
  final List<MyOrderModel> reversOrder;
  final Function() onMoreClick;
  const RunningOrderViewWidget({super.key, required this.reversOrder, required this.onMoreClick});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {

      return Container(
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius : const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingExtraLarge),
            topRight : Radius.circular(Dimensions.paddingExtraLarge),
          ),
          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        child: Column(children: [

          Center(
            child: Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingDefault),
              height: 3, width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.padding2xSmall)
              ),
            ),
          ),

          ListView.builder(
              itemCount: reversOrder.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index){

                bool isFirstOrder =  index == 0;

                String? orderStatus = reversOrder[index].orderStatus ?? '';
                final Color statusColor = ColorConverter.getStatusColor(orderStatus);
                int status = 0;

                if(orderStatus == OrderStatus.pending.name){
                  status = 1;
                }else if(orderStatus == OrderStatus.accepted.name || orderStatus == OrderStatus.processing.name || orderStatus == OrderStatus.confirmed.name){
                  status = 2;
                }else if(orderStatus == OrderStatus.handover.name || orderStatus == OrderStatus.picked_up.name){
                  status = 3;
                }

                return InkWell(
                  onTap: () async {
                    await Get.toNamed(
                      RouteHelper.getOrderDetailsRoute(reversOrder[index].id),
                      arguments: OrderDetailsScreen(
                        orderId: reversOrder[index].id,
                        orderModel: null,
                      ),
                    );
                    if(orderController.showBottomSheet){
                      orderController.showRunningOrders();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Dimensions.padding2xSmall, top: Dimensions.paddingSmall),

                    child:  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                      child: Row( crossAxisAlignment: CrossAxisAlignment.center, children: [

                        Center(
                          child: SizedBox(
                            height: orderStatus == OrderStatus.pending.name ? 50 : 60, width: orderStatus == OrderStatus.pending.name ? 50 : 60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomAssetImageWidget( status == 2 ? orderStatus == OrderStatus.confirmed.name || orderStatus == OrderStatus.accepted.name ? Images.processingGif
                                  : Images.cookingGif : status == 3
                                  ? orderStatus == OrderStatus.handover.name ? Images.handoverGif : Images.onTheWayGif : Images.pendingGif,
                                  height: 60, width: 60, fit: BoxFit.fill),
                            ),
                          ),
                        ),

                        SizedBox(width: isFirstOrder ? 0 : Dimensions.paddingSmall),

                        Expanded(
                          child: Column(mainAxisAlignment: isFirstOrder ? MainAxisAlignment.center : MainAxisAlignment.start,
                              crossAxisAlignment: isFirstOrder ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
                                Row( mainAxisAlignment: isFirstOrder ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

                                  Text('${'your_order_is'.tr} ', style: context.heading.defaultSize.strong),
                                  Text(reversOrder[index].orderStatus!.tr, style: context.heading.defaultSize.strong.overrideWith(color: statusColor)),
                                ]) ,
                                const SizedBox(height: Dimensions.padding2xSmall),

                                Text(
                                  '${'order'.tr} #${reversOrder[index].id}',
                                  style: context.body.small.regular, maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),

                                isFirstOrder ? SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,
                                        vertical: Dimensions.paddingSmall),
                                    child: Row(children: [
                                      Expanded(child: trackView(context, status: status >= 1 ? true : false)),
                                      const SizedBox(width: Dimensions.padding2xSmall),

                                      Expanded(child: trackView(context, status: status >= 2 ? true : false)),
                                      const SizedBox(width: Dimensions.padding2xSmall),

                                      Expanded(child: trackView(context, status: status >= 3 ? true : false)),
                                      const SizedBox(width: Dimensions.padding2xSmall),

                                      Expanded(child: trackView(context, status: status >= 4 ? true : false)),
                                    ]),
                                  ),
                                ) : const SizedBox()

                              ]),
                        ),

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingDefault),
                          decoration: BoxDecoration(color: context.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: isFirstOrder ? !(reversOrder.length < 2) ? InkWell(
                            onTap: onMoreClick,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('+${reversOrder.length - 1}', style: context.heading.large.strong.overrideWith(color: context.primary)),
                              Text('more'.tr, style: context.subHeading.extraSmall.strong.overrideWith(color: context.primary)),
                            ]),
                          ) : Icon(Icons.arrow_forward, size: 18, color: context.primary)
                              : Icon(Icons.arrow_forward, size: 18, color: context.primary),
                        ),

                      ]),
                    ) ,
                  ),
                );
              }),
        ]),
      );
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(height: 5, decoration: BoxDecoration(color: status ? context.primary
        : context.bgNeutralMedium, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}
