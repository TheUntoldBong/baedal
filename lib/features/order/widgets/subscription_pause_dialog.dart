import 'package:stackfood_multivendor/features/checkout/widgets/custom_date_picker.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_cancellation_body.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class SubscriptionPauseDialog extends StatefulWidget {
  final int? subscriptionID;
  final bool isPause;
  final String? orderId;
  final String? contactNumber;
  const SubscriptionPauseDialog({super.key, required this.subscriptionID, required this.isPause, this.orderId, this.contactNumber});

  @override
  State<SubscriptionPauseDialog> createState() => _SubscriptionPauseDialogState();
}

class _SubscriptionPauseDialogState extends State<SubscriptionPauseDialog> {
  DateTimeRange? _range;
  final TextEditingController _noteController = TextEditingController();
  final List<CancellationData> _reasons = [];

  @override
  void initState() {
    super.initState();

    final List<CancellationData>? cancelReasons = Get.find<OrderController>().orderCancelReasons;
    if(cancelReasons != null && cancelReasons.isNotEmpty){
      _reasons.add(CancellationData(reason: 'select_cancel_reason'.tr));
      _reasons.addAll(cancelReasons);
    }
  }

  List<DropdownMenuItem<int>> _reasonItems(BuildContext context) {
    return [
      for(int index = 0; index < _reasons.length; index++) DropdownMenuItem<int>(
        value: index,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _reasons[index].reason!, textAlign: TextAlign.left, maxLines: 1,
                overflow: TextOverflow.ellipsis, style: context.subHeading.large.medium,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          child: SingleChildScrollView(
            child: GetBuilder<OrderController>(
              builder: (orderController) {
                return Column(mainAxisSize: MainAxisSize.min, children: [

                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingLarge),
                    child: CustomAssetImageWidget(Images.warning, width: 50, height: 50, color: context.primary),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingLarge),
                    child: Text(
                      widget.isPause ? 'are_you_sure_to_pause_subscription'.tr : 'are_you_sure_to_cancel_subscription'.tr,
                      style: context.subHeading.large.medium, textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  !widget.isPause
                      ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyLarge!.color!, width: 0.5,
                       )
                    ),
                        child: DropdownButton(
                          value: orderController.cancellationIndex,
                            items: _reasonItems(context),
                            itemHeight: 50,
                            isExpanded: true,
                            underline: const SizedBox(),
                            onChanged: (int? index){
                              orderController.setCancelIndex(index);
                              orderController.setOrderCancelReason(_reasons[index!].reason);
                            },
                        ),
                      ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingLarge),

                  widget.isPause ? CustomDatePicker(
                    hint: 'choose_subscription_pause_date'.tr,
                    range: _range,
                    isPause: widget.isPause,
                    onDatePicked: (DateTimeRange range) {
                      setState(() {
                        _range = range;
                      });
                    },
                  ) : CustomTextFieldWidget(
                    hintText: 'write_cancellation_reason'.tr,
                    showLabelText: false,
                    controller: _noteController,
                    maxLines: 3,
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  GetBuilder<OrderController>(builder: (orderController) {
                    return !orderController.subscriveLoading ? Row(children: [
                      Expanded(child: CustomButtonWidget(
                        onPressed: () => Get.back(),
                        buttonText: 'no'.tr,
                        textColor: context.textBaseDefault,
                        color: context.surface,
                      )),
                      const SizedBox(width: Dimensions.paddingLarge),

                      Expanded(child: CustomButtonWidget(
                        buttonText: 'yes'.tr,
                        onPressed: () {
                          if(widget.isPause && _range == null) {
                            showCustomSnackBar('choose_subscription_pause_date'.tr);
                          }else if(!widget.isPause && orderController.cancellationIndex == 0) {
                            showCustomSnackBar('please_select_cancellation_reason_first'.tr);
                          }else {
                            orderController.updateSubscriptionStatus(
                              widget.subscriptionID, _range?.start, _range?.end,
                              widget.isPause ? 'paused' : 'canceled', _noteController.text.trim(), _reasons[orderController.cancellationIndex!].reason,
                              widget.orderId, widget.contactNumber,
                            );
                          }
                        },
                        radius: Dimensions.radiusExtraSmall,
                      )),
                    ]) : const Center(child: CircularProgressIndicator());
                  }),

                ]);
              }
            ),
          ),
        )),
      ));
  }
}
