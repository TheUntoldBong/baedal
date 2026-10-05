import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/controllers/wallet_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AddFundDialogueWidget extends StatefulWidget {
  const AddFundDialogueWidget({super.key});

  @override
  State<AddFundDialogueWidget> createState() => _AddFundDialogueWidgetState();
}

class _AddFundDialogueWidgetState extends State<AddFundDialogueWidget> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);

    if(Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1){
      Get.find<WalletController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList!.first.getWay!, isUpdate: false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return Container(
        padding: EdgeInsets.all(Dimensions.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: context.surfaceContainer,
        ),
        constraints: BoxConstraints(minHeight: context.height * 0.34, maxHeight: context.height * 0.7),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: Dimensions.paddingLarge),

              Text('add_fund_to_wallet'.tr, style: context.heading.large.strong),
              const SizedBox(height: Dimensions.paddingSmall),

              Text('add_fund_form_secured_digital_payment_gateways'.tr, style: context.body.small.regular, textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingLarge),

              Container(
                padding: EdgeInsets.all(Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: context.surfaceContainer,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${'enter_amount'.tr} (${Get.find<SplashController>().configModel?.currencySymbol!})', style: context.subHeading.defaultSize.regular),
                  SizedBox(height: Dimensions.paddingDefault),

                  CustomTextFieldWidget(
                    hintText: 'ex_100'.tr,
                    showLabelText: false,
                    isAmount: true,
                    inputType: TextInputType.number,
                    focusNode: focusNode,
                    inputAction: TextInputAction.done,
                    controller: inputAmountController,
                    textAlign: TextAlign.center,
                    onChanged: (String value){
                      try{
                        if(double.parse(value) > 0){
                          walletController.isTextFieldEmpty(value);
                        }
                      }catch(e) {
                        walletController.isTextFieldEmpty('');
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  (double.tryParse(inputAmountController.text) ?? 0) < 20 && inputAmountController.text != '' ?
                   Text('${'deposit_limit_min'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel?.customerAddFundMinAmount ?? 0)}',
                       style: context.body.small.regular.overrideWith(color: Colors.red)) : SizedBox.shrink(),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.outline),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'choose_payment_method'.tr, style: context.subHeading.defaultSize.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: 'faster_and_secure_way_to_add_bill'.tr,
                          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Flexible(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index){
                            bool isSelected = Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == walletController.digitalPaymentName;
                            return InkWell(
                              onTap: (){
                                walletController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? context.primary.withValues(alpha: 0.05) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingLarge),
                                child: Row(children: [
                                  Container(
                                    height: 20, width: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: isSelected ? Colors.green : context.surfaceContainer,
                                      border: Border.all(color: context.outline),
                                    ),
                                    child: Icon(Icons.check, color: context.surfaceContainer, size: 16),
                                  ),
                                  const SizedBox(width: Dimensions.paddingDefault),

                                  CustomImageWidget(
                                    height: 20, width: 40, fit: BoxFit.contain,
                                    image: '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                                  ),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  Text(
                                    Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                    style: context.subHeading.defaultSize.medium,
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),

          SizedBox(height: Dimensions.paddingExtraLarge,),
          CustomButtonWidget(
            buttonText: 'add_fund'.tr,
            isLoading: walletController.isLoading,
            onPressed: () => _onAddFundButtonClicked(walletController),
          ),
        ]),
      );
    });
  }

  void _onAddFundButtonClicked(WalletController walletController) {
    if(inputAmountController.text.isEmpty){
      showCustomSnackBar('please_provide_transfer_amount'.tr);
    }else if(inputAmountController.text == '0'){
      showCustomSnackBar('you_can_not_add_zero_amount_in_wallet'.tr);
    }else if((Get.find<SplashController>().configModel?.customerAddFundMinAmount ?? 0) > double.parse(inputAmountController.text)){
      showCustomSnackBar('${'you_can_not_add_less_than'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel?.customerAddFundMinAmount ?? 0)}'.tr);
    }else if(walletController.digitalPaymentName == ''){
      showCustomSnackBar('please_select_payment_method'.tr);
    }else{
      double amount = double.parse(inputAmountController.text.replaceAll(Get.find<SplashController>().configModel!.currencySymbol!, ''));
      walletController.addFundToWallet(amount, walletController.digitalPaymentName!);
    }
  }

}
