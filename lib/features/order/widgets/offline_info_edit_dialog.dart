import 'dart:convert';

import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
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
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class OfflineInfoEditDialog extends StatefulWidget {
  final OfflinePayment offlinePayment;
  final int orderId;
  final String? contactNumber;
  const OfflineInfoEditDialog({super.key, required this.offlinePayment, required this.orderId, required this.contactNumber});

  @override
  State<OfflineInfoEditDialog> createState() => _OfflineInfoEditDialogState();
}

class _OfflineInfoEditDialogState extends State<OfflineInfoEditDialog> {

  @override
  void initState() {
    super.initState();

    Get.find<CheckoutController>().informationControllerList = [];
    Get.find<CheckoutController>().informationFocusList = [];
    for (int i=0; i<widget.offlinePayment.input!.length ; i++) {
      Get.find<CheckoutController>().informationControllerList.add(TextEditingController(text: widget.offlinePayment.input![i].userData));
      Get.find<CheckoutController>().informationFocusList.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          child: GetBuilder<CheckoutController>(
              builder: (checkoutController) {
                return SingleChildScrollView(
                  child: Column(children: [

                    CustomAssetImageWidget(Images.offlinePaymentIcon, height: 100),
                    const SizedBox(height: Dimensions.paddingDefault),

                    Text('update_payment_info'.tr, textAlign: TextAlign.center, style: context.body.large.regular.overrideWith(
                      color: context.textBaseMedium,
                    )),
                    const SizedBox(height: Dimensions.paddingLarge),

                    ListView.builder(
                      itemCount: checkoutController.informationControllerList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                          child: CustomTextFieldWidget(
                            hintText: widget.offlinePayment.input![i].userInput.toString().replaceAll('_', ' '),
                            labelText: widget.offlinePayment.input![i].userInput.toString().replaceAll('_', ' '),
                            controller: checkoutController.informationControllerList[i],
                            focusNode: checkoutController.informationFocusList[i],
                            nextFocus: i != checkoutController.informationControllerList.length-1 ? checkoutController.informationFocusList[i+1] : null,
                            inputAction: i != checkoutController.informationControllerList.length-1 ? TextInputAction.next : TextInputAction.done,
                          ),
                        );
                      },
                    ),

                    Row(children: [
                      const Spacer(),

                      CustomButtonWidget(
                        width: 100,
                        color: context.bgNeutralDefault,
                        textColor: context.textBaseDefault,
                        buttonText: 'cancel'.tr,
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: Dimensions.paddingLarge),

                      CustomButtonWidget(
                        width: 100,
                        buttonText: 'update'.tr,
                        isLoading: checkoutController.isLoadingUpdate,
                        onPressed: () {

                          for(int i=0; i<checkoutController.informationControllerList.length; i++){
                            if(checkoutController.informationControllerList[i].text.isEmpty) {
                              showCustomSnackBar('please_provide_every_information'.tr);
                              break;
                            }else {
                              Map<String, String> data = {
                                "_method": "put",
                                "order_id": widget.orderId.toString(),
                                "method_id": widget.offlinePayment.data!.methodId.toString(),
                              };

                              for(int i=0; i<checkoutController.informationControllerList.length; i++){
                                data.addAll({
                                  widget.offlinePayment.input![i].userInput.toString() : checkoutController.informationControllerList[i].text,
                                });
                              }
                              if(Get.find<AuthController>().isGuestLoggedIn()) {
                                data.addAll({'guest_id': Get.find<AuthController>().getGuestId()});
                              }

                              checkoutController.updateOfflineInfo(jsonEncode(data)).then((success) {
                                if(success) {
                                  Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber).then((success) {
                                    if(success) {
                                      if(Get.isDialogOpen!) {
                                        Get.back();
                                      }
                                    }
                                  });
                                }
                              });
                            }
                          }

                        },
                      ),

                    ])
                  ]),
                );
              }
          ),
        ),
      ));
  }
}
