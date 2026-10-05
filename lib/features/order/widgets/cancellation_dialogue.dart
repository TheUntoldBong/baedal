import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class CancellationDialogue extends StatefulWidget {
  final int? orderId;
  final String? contactNumber;
  const CancellationDialogue({super.key, required this.orderId, this.contactNumber});

  @override
  State<CancellationDialogue> createState() => _CancellationDialogueState();
}

class _CancellationDialogueState extends State<CancellationDialogue> {


  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getOrderCancelReasons();
  }

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.cancel_outlined, size: 25, color: context.iconBaseMedium),
                ),
              ),
            ),

            Text('select_cancellation_reasons'.tr, style: context.heading.large.semiBold),

            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  orderController.orderCancelReasons != null ? orderController.orderCancelReasons!.isNotEmpty ? Flexible(
                    child: ListView.builder(
                      itemCount: orderController.orderCancelReasons!.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: Dimensions.paddingLarge, bottom: Dimensions.paddingSmall),
                      itemBuilder: (context, index){
                        return Container(
                          margin: EdgeInsets.only(bottom: Dimensions.paddingSmall),
                          padding: EdgeInsets.all(Dimensions.paddingDefault),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                            boxShadow: orderController.orderCancelReasons![index].reason == orderController.cancelReason ? [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)] : [],
                            border: Border.all(color: context.outline),
                          ),
                          child: InkWell(
                            onTap: (){
                              orderController.setOrderCancelReason(orderController.orderCancelReasons![index].reason);
                            },
                            child: Row(
                              children: [
                                Icon(orderController.orderCancelReasons![index].reason == orderController.cancelReason ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: orderController.orderCancelReasons![index].reason == orderController.cancelReason ? context.primary : context.iconBaseMedium, size: 18),
                                const SizedBox(width: Dimensions.padding2xSmall),

                                Flexible(child: Text(orderController.orderCancelReasons![index].reason!, style: context.subHeading.defaultSize.regular, maxLines: 3, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ) : SizedBox() : const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.paddingDefault), child: CircularProgressIndicator())),

                  Text(
                    'comments'.tr,
                    style: context.heading.large.strong,
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  CustomTextFieldWidget(
                    controller: commentController,
                    titleText: 'type_here'.tr,
                    showLabelText: false,
                    maxLines: 2,
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.done,
                    capitalization: TextCapitalization.sentences,
                    maxLength: 100,
                  ),

                ]),
              ),
            ),
            SizedBox(height: Dimensions.paddingSmall),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
              child: !orderController.isCancelLoading ? Row(children: [
                Expanded(child: CustomButtonWidget(
                  buttonText: 'cancel'.tr, color: context.bgNeutralLight,
                  textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  onPressed: () => Get.back(),
                )),
                const SizedBox(width: Dimensions.paddingSmall),

                Expanded(child: CustomButtonWidget(
                  buttonText: 'submit'.tr,
                  onPressed: (){
                    if((orderController.cancelReason != '' && orderController.cancelReason != null) || commentController.text.isNotEmpty){

                      orderController.cancelOrder(widget.orderId, orderController.cancelReason, comment: commentController.text).then((success) {
                        if(success){
                          orderController.trackOrder(widget.orderId.toString(), null, true, contactNumber: widget.contactNumber);
                        }
                      });

                    }else{
                      if(orderController.cancelReason == '' || orderController.cancelReason == null){
                        showCustomSnackBar('you_did_not_select_any_reason'.tr);
                      }else if(commentController.text.isEmpty){
                        showCustomSnackBar('you_did_not_write_any_comment'.tr);
                      }
                    }
                  },
                )),
              ]) : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }));
  }
}
