import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/cancellation_dialogue.dart';
import 'package:stackfood_multivendor/features/order/widgets/subscription_pause_dialog.dart';
import 'package:stackfood_multivendor/features/review/domain/models/rate_review_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_order_savings_banner_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class BottomViewWidget extends StatelessWidget {
  final OrderController orderController;
  final OrderModel order;
  final int? orderId;
  final double total;
  final String? contactNumber;
  final bool showTrackButton;
  const BottomViewWidget({super.key, required this.orderController, required this.order, this.orderId, required this.total, this.contactNumber, this.showTrackButton = true });

  @override
  Widget build(BuildContext context) {
    bool subscription = order.subscription != null;
    bool pending = order.orderStatus == OrderStatus.pending.name;
    bool accepted = order.orderStatus == OrderStatus.accepted.name;
    bool confirmed = order.orderStatus == OrderStatus.confirmed.name;
    bool processing = order.orderStatus == OrderStatus.processing.name;
    bool pickedUp = order.orderStatus == OrderStatus.picked_up.name;
    bool delivered = order.orderStatus == OrderStatus.delivered.name;
    bool cancelled = order.orderStatus == OrderStatus.canceled.name;
    bool cod = order.paymentMethod == 'cash_on_delivery';
    bool digitalPay = order.paymentMethod == 'digital_payment';
    bool offlinePay = order.paymentMethod == 'offline_payment';
    bool canReorder = !(order.isBogo ?? false) && !(order.isItemCampaign ?? false) && (cancelled || delivered);

    final buttonList = [
      if( showTrackButton && ((!subscription || (order.subscription!.status != 'canceled' && order.subscription!.status != 'completed')) && ((pending && !digitalPay) || accepted || confirmed
          || processing || order.orderStatus == 'handover'|| pickedUp)) && order.orderType == 'delivery') Expanded(
        child: CustomButtonWidget(
          buttonText: subscription ? 'track_subscription'.tr : 'track_order'.tr,
          onPressed: () async {
            orderController.cancelTimer();
            await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, contactNumber));
            orderController.callTrackOrderApi(orderModel: order, orderId: orderId.toString(), contactNumber: contactNumber);
          },
        ),
      ),

      if(!offlinePay && pending && order.paymentStatus == 'unpaid' && digitalPay && Get.find<SplashController>().configModel!.cashOnDelivery!)  Expanded(
        child: CustomButtonWidget(
          buttonText: 'switch_to_cash_on_delivery'.tr,
          onPressed: () {
            showCustomDialog(
              child: ConfirmationDialogWidget(
                icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                onYesPressed: () {
                  double maxCodOrderAmount = AddressHelper.getAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == order.restaurant!.zoneId).maxCodOrderAmount ?? 0;

                  if(maxCodOrderAmount > total){
                    orderController.switchToCOD(order.id.toString(), null).then((isSuccess) {
                      Get.back();
                      if(isSuccess) {
                        Get.back();
                      }
                    });
                  }else{
                    if(Get.isDialogOpen!) {
                      Get.back();
                    }
                    showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                  }
                }
            ),
            );
          },
        ),
      ),

      if(subscription ? (order.subscription!.status == 'active' || order.subscription!.status == 'paused') : pending)  Expanded(child: CustomButtonWidget(
        buttonText: subscription ? 'cancel_repeat_order'.tr : 'cancel_order'.tr,
        color: context.bgErrorLight,
        textColor: context.textDangerMedium,
        onPressed: () {
          if(subscription) {
            showCustomDialog(child: SubscriptionPauseDialog(subscriptionID: order.subscriptionId, isPause: false, orderId: orderId.toString(), contactNumber: contactNumber));
          }else {
            orderController.setOrderCancelReason('');
            showCustomDialog(child: CancellationDialogue(orderId: order.id, contactNumber: contactNumber));
          }
        },
      )),

      if(!orderController.showCancelled && subscription && (order.subscription!.status == 'active' || order.subscription!.status == 'paused')) Expanded(
        child: CustomButtonWidget(
          buttonText: 'pause_repeat_order'.tr,
          onPressed: () async {
            showCustomDialog(child: SubscriptionPauseDialog(subscriptionID: order.subscriptionId, isPause: true, orderId: orderId.toString(), contactNumber: contactNumber));
          },
        ),
      ),
    ];

    return Container(
      padding: EdgeInsets.only(
        left: Dimensions.paddingDefault, right: Dimensions.paddingDefault,
        top: Dimensions.paddingSmall
      ),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.shadow, offset: Offset(0, -1), blurRadius: 2)]
      ),
      child: Column(children: [
        if(ProOrderSavingsBannerWidget.showProBanner(order)) ...[
          ProOrderSavingsBannerWidget(order: order),
          SizedBox(height: Dimensions.paddingSmall,),
        ],

        (!orderController.showCancelled) ?
        Center(child: SizedBox(
          width: Dimensions.webMaxWidth + 20,
          child: Column(
            children: [
              Row(spacing: Dimensions.paddingMedium, children: [
                ...buttonList,
              ]),
              if(buttonList.isNotEmpty) SizedBox(height: Dimensions.paddingSmall,),
            ],
          ),
        )) : Column(children: [
         Center(child: Container(
            width: Dimensions.webMaxWidth,
            height: 50,
            margin: const EdgeInsets.all(Dimensions.paddingSmall),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: context.primary),
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ),
            child: Text('order_cancelled'.tr, style: context.heading.defaultSize.copyWith(color: context.primary)),
         )),
          SizedBox(height: Dimensions.paddingSmall,),
        ]),

        if(((!subscription && delivered && orderController.orderDetails![0].itemCampaignId == null) || !subscription && Get.find<SplashController>().configModel!.repeatOrderOption! && (delivered || cancelled || order.orderStatus == 'failed' || order.orderStatus == 'refund_request_canceled')) && orderController.orderDetails![0].itemCampaignId == null) ...[
          Center(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: !orderController.isLoading ? Get.find<AuthController>().isLoggedIn() ? Row(
              children: [
                (!subscription && delivered && orderController.orderDetails![0].itemCampaignId == null) ? Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'review'.tr,
                    onPressed: () async {
                      List<OrderDetailsModel> orderDetailsList = [];
                      List<int?> orderDetailsIdList = [];
                      for (var orderDetail in orderController.orderDetails!) {
                        if(orderDetail.isBogoBundle) {
                          continue;
                        }
                        if(!orderDetailsIdList.contains(orderDetail.foodDetails!.id)) {
                          orderDetailsList.add(orderDetail);
                          orderDetailsIdList.add(orderDetail.foodDetails!.id);
                        }
                      }
                      orderController.cancelTimer();
                      RateReviewModel rateReviewModel = RateReviewModel(orderDetailsList: orderDetailsList, deliveryMan: order.deliveryMan);
                      await Get.toNamed(RouteHelper.getReviewRoute(rateReviewModel));
                      orderController.callTrackOrderApi(orderModel: order, orderId: orderId.toString(), contactNumber: contactNumber);
                    },
                  ),
                ) : const SizedBox(),
                SizedBox(width: cancelled || order.orderStatus == 'failed' ? 0 : Dimensions.paddingMedium),

                !subscription && Get.find<SplashController>().configModel!.repeatOrderOption! && (delivered || cancelled || order.orderStatus == 'failed' || order.orderStatus == 'refund_request_canceled')
                ? canReorder ? Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'reorder'.tr,
                    onPressed: () => orderController.reOrder(orderController.orderDetails!, order.restaurant!.zoneId),
                  ),
                ) : const SizedBox() : const SizedBox(),
              ],
            ) : const SizedBox() : const Center(child: CircularProgressIndicator()),
          ),
        ),

          SizedBox(height: Dimensions.paddingSmall,),
        ],


        if(!offlinePay && (order.orderStatus == 'failed' || cancelled) && !cod && Get.find<SplashController>().configModel!.cashOnDelivery!) ...[
          Center(
          child: CustomButtonWidget(
            buttonText: 'switch_to_cash_on_delivery'.tr,
            onPressed: () {
              showCustomDialog(
                child: ConfirmationDialogWidget(
                  icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                  onYesPressed: () {
                    double? maxCodOrderAmount = AddressHelper.getAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == order.restaurant!.zoneId).maxCodOrderAmount;

                    if(maxCodOrderAmount == null || maxCodOrderAmount > total){
                      orderController.switchToCOD(order.id.toString(), null).then((isSuccess) {
                        Get.back();
                        if(isSuccess) {
                          Get.back();
                        }
                      });
                    }else{
                      if(Get.isDialogOpen!) {
                        Get.back();
                      }
                      showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                    }
                  }
              ),
              );
            },
          ),
        ),

          SizedBox(height: Dimensions.paddingSmall,),
        ],
      ]),
    );
  }
}
