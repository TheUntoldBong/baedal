import 'dart:convert';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offline_method_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/pricing_view_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final PlaceOrderBodyModel placeOrderBodyModel;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final PricingViewModel pricingView;

  const OfflinePaymentScreen({super.key, required this.placeOrderBodyModel, required this.zoneId, required this.total, required this.maxCodOrderAmount,
    required this.fromCart, required this.isCashOnDeliveryActive, required this.pricingView});

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  final TextEditingController _customerNoteController = TextEditingController();
  final FocusNode _customerNoteNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    if(Get.find<CheckoutController>().offlineMethodList == null){
      await Get.find<CheckoutController>().getOfflineMethodList();
    }
    Get.find<CheckoutController>().informationControllerList = [];
    Get.find<CheckoutController>().informationFocusList = [];
    if(Get.find<CheckoutController>().offlineMethodList != null && Get.find<CheckoutController>().offlineMethodList!.isNotEmpty) {
      for(int index=0; index<Get.find<CheckoutController>().offlineMethodList![Get.find<CheckoutController>().selectedOfflineBankIndex].methodInformations!.length; index++) {
        Get.find<CheckoutController>().informationControllerList.add(TextEditingController());
        Get.find<CheckoutController>().informationFocusList.add(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'offline_payment'.tr),
      body: GetBuilder<CheckoutController>(builder: (checkoutController) {
        List<MethodInformations>? methodInformation;
        List<MethodFields>? methodFields;
        if(checkoutController.offlineMethodList != null){
          methodInformation = checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodInformations;
          methodFields = checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodFields;
        }

        return methodFields != null ? Column(children: [
          Expanded(child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: Dimensions.paddingLarge),

                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: context.shadow, blurRadius: 2, spreadRadius: 1)],
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          trailing: Icon(Icons.arrow_drop_down_sharp, size: 35 , color: context.textBaseDefault),
                          title: Text('select_payment_information'.tr, style: context.subHeading.large.strong.overrideWith(color: context.textBaseDefault)),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(Dimensions.paddingSmall),
                              margin: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: context.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: context.primary.withValues(alpha: 0.2), width: 1),
                              ),
                              child: Column(children: [

                                Row(children: [

                                  CustomAssetImageWidget(Images.bankInfoIcon, width: 25, height: 25, color: context.primary),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  Text('${'bank_information'.tr} (${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})', style: context.subHeading.defaultSize.medium),

                                ]),
                                const SizedBox(height: Dimensions.paddingDefault),

                                ListView.builder(
                                  itemCount: methodFields.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                                      child: InfoTextRowWidget(
                                        title: methodFields![index].inputName!.toString().replaceAll('_', ' '),
                                        value: methodFields[index].inputData!,
                                      ),
                                    );
                                  },
                                ),

                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),

                    Text(
                      '${'amount'.tr} '' ${PriceConverter.convertPrice(checkoutController.isPartialPay ? checkoutController.viewTotalPrice : widget.total)}',
                      style: context.heading.large.strong,
                    ),
                    const SizedBox(height: Dimensions.paddingExtraLarge),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'payment_info'.tr,
                            style: context.subHeading.defaultSize.strong,
                          ),
                        ),

                        ListView.builder(
                          itemCount: checkoutController.informationControllerList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                              child: CustomTextFieldWidget(
                                titleText: methodInformation![i].customerPlaceholder!,
                                labelText: methodInformation[i].customerPlaceholder!,
                                controller: checkoutController.informationControllerList[i],
                                focusNode: checkoutController.informationFocusList[i],
                                nextFocus: i != checkoutController.informationControllerList.length-1 ? checkoutController.informationFocusList[i+1] : _customerNoteNode,
                                required: methodInformation[i].isRequired!,
                                validator: (value) => ValidateCheck.validateEmptyText(value, null),
                              ),
                            );
                          },
                        ),

                        CustomTextFieldWidget(
                          titleText: 'write_your_note'.tr,
                          labelText: 'note'.tr,
                          controller: _customerNoteController,
                          focusNode: _customerNoteNode,
                          inputAction: TextInputAction.done,
                          maxLines: 3,
                        ),

                      ]),
                    ),

                    ResponsiveHelper.isDesktop(context) ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
                          margin: const EdgeInsets.only(top: Dimensions.paddingLarge),
                          child: CustomButtonWidget(
                            width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                            buttonText: 'complete'.tr,
                            isLoading: checkoutController.isLoading,
                            onPressed: () async {
                              bool complete = _completelyProvideInput(methodInformation, checkoutController);
                              String text = _setMessageText(methodInformation, checkoutController);

                              if(complete) {
                                await _saveOfflineInformation(checkoutController, methodInformation);
                              } else {
                                showCustomSnackBar(text);
                              }
                            },
                          ),
                        ),
                      ],
                    ) : const SizedBox(),

                  ]),
                ),
              ),
            ),
          )),

          ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              boxShadow: [BoxShadow(color: context.primary.withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: SafeArea(
              child: CustomButtonWidget(
                buttonText: 'complete'.tr,
                isLoading: checkoutController.isLoading,
                onPressed: () async {
                  bool complete = _completelyProvideInput(methodInformation, checkoutController);
                  String text = _setMessageText(methodInformation, checkoutController);

                    if(complete) {
                      await _saveOfflineInformation(checkoutController, methodInformation);
                    } else {
                      showCustomSnackBar(text);
                    }
                },
              ),
            ),
          ),

        ]) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  bool _completelyProvideInput(List<MethodInformations>? methodInformation, CheckoutController checkoutController) {
    bool complete = false;
    for(int i = 0; i<methodInformation!.length; i++){
      if(methodInformation[i].isRequired!) {
        if(checkoutController.informationControllerList[i].text.isEmpty){
          complete = false;
          break;
        } else {
          complete = true;
        }
      } else {
        complete = true;
      }
    }
    return complete;
  }

  String _setMessageText(List<MethodInformations>? methodInformation, CheckoutController checkoutController) {
    String text = '';
    for(int i = 0; i<methodInformation!.length; i++){
      if(methodInformation[i].isRequired!) {
        if(checkoutController.informationControllerList[i].text.isEmpty){
          text = methodInformation[i].customerPlaceholder!;
          break;
        }
      }
    }
    return text;
  }

  Future<void> _saveOfflineInformation(CheckoutController checkoutController, List<MethodInformations>? methodInformation) async {
    String methodId = checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].id.toString();
    String? orderId = await checkoutController.placeOrder(widget.placeOrderBodyModel, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive, isOfflinePay: true, restaurantId: widget.placeOrderBodyModel.restaurantId);

    if(orderId.isNotEmpty) {
      Map<String, String> data = {
        "_method": "put",
        "order_id": orderId,
        "method_id": methodId,
        "customer_note": _customerNoteController.text,
      };

      for(int i = 0; i<methodInformation!.length; i++){
        data.addAll({
          methodInformation[i].customerInput! : checkoutController.informationControllerList[i].text,
        });
      }

      checkoutController.saveOfflineInfo(jsonEncode(data)).then((success) {
        if(success){
          Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: true, contactNumber: widget.placeOrderBodyModel.contactPersonNumber));
        }
      });
    }
  }

}

class InfoTextRowWidget extends StatelessWidget {
  final String title;
  final String value;
  const InfoTextRowWidget({super.key, required this.title, required this.value,});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      
      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 1 : 1,
        child: Text(title, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
      ),

      Text(':', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(
        flex: ResponsiveHelper.isDesktop(context) ? 4 : 1,
        child: Text(value, style: context.subHeading.small.medium),
      ),
      
    ]);
  }
}

