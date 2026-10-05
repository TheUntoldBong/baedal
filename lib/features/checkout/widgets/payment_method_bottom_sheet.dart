import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/offline_payment_button.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double totalPrice;
  final bool isSubscriptionPackage;
  const PaymentMethodBottomSheet({super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.totalPrice, this.isSubscriptionPackage = false, required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  bool notHideOffline = true;
  final JustTheController tooltipController = JustTheController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    CheckoutController checkoutController = Get.find<CheckoutController>();

    if(checkoutController.exchangeAmount > 0) {
      _amountController.text = checkoutController.exchangeAmount.toString();
    }

    configurePartialPayment();
  }

  void configurePartialPayment() {
    if(!widget.isSubscriptionPackage && !Get.find<AuthController>().isGuestLoggedIn()){
      double walletBalance = Get.find<ProfileController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
        if(Get.find<CheckoutController>().isPartialPay){
          notHideWallet = false;
          notHideCod = Get.find<SplashController>().configModel!.partialPaymentMethod!.contains('cash_on_delivery');
          notHideDigital = Get.find<SplashController>().configModel!.partialPaymentMethod!.contains('digital_payment');
          notHideOffline = Get.find<SplashController>().configModel!.partialPaymentMethod!.contains('offline_payment');
        } else {
        notHideWallet = false;
        notHideCod = true;
        notHideDigital = true;
        notHideOffline = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550,
      child: GetBuilder<CheckoutController>(builder: (checkoutController) {
        return GetBuilder<BusinessController>(builder: (businessController) {
          bool disablePayments = checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay;
          bool isDineInSelect = checkoutController.orderType == 'dine_in';
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: const Radius.circular(Dimensions.radiusLarge), bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              ResponsiveHelper.isDesktop(context) ? Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 30, width: 30,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                    decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.clear),
                  ),
                ),
              ) : Align(
                alignment: Alignment.center,
                child: Container(
                  height: 5, width: 40,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                  decoration: BoxDecoration(color: context.bgNeutralMedium, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: Dimensions.padding2xSmall),

              Text('choose_payment_method'.tr, style: context.heading.defaultSize.strong),
              const SizedBox(height: Dimensions.paddingSmall),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                  child: Column(
                    children: [

                      Text('total_bill'.tr, style: context.body.defaultSize.medium.overrideWith(color: Colors.grey.shade700)),
                      const SizedBox(height: Dimensions.padding2xSmall),

                      Text(PriceConverter.convertPrice(widget.totalPrice), style: context.heading.overLarge.medium.overrideWith(color: context.primary)),
                      const SizedBox(height: Dimensions.paddingLarge),

                      walletView(checkoutController),

                      !widget.isSubscriptionPackage && widget.isCashOnDeliveryActive && notHideCod ? paymentButtonView(
                        padding: EdgeInsets.only(bottom: Dimensions.paddingDefault),
                        title: isDineInSelect ? 'pay_after_service'.tr : 'cash_on_delivery'.tr,
                        isSelected: checkoutController.paymentMethodIndex == 0,
                        disablePayments: disablePayments,
                        onTap: disablePayments ? null : (){
                          checkoutController.setPaymentMethod(0);
                        },
                      ) : const SizedBox(),

                      checkoutController.subscriptionOrder || !notHideCod ? SizedBox() : changeAmountView(checkoutController),

                      widget.isDigitalPaymentActive && notHideDigital && !checkoutController.subscriptionOrder && Get.find<SplashController>().configModel!.activePaymentMethodList!.isNotEmpty ? Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                          border: Border.all(color: context.outline, width: 0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('pay_via_online'.tr, style: context.subHeading.defaultSize.semiBold.overrideWith(color: disablePayments ? context.textBaseMedium : context.textBaseDefault)),
                            const SizedBox(height: Dimensions.paddingSmall),

                            ListView.builder(
                              itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index){
                                bool isSelected;
                                if(widget.isSubscriptionPackage) {
                                  isSelected = businessController.paymentIndex == 1 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == businessController.digitalPaymentName;
                                } else {
                                  isSelected = checkoutController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == checkoutController.digitalPaymentName;
                                }
                                return paymentButtonView(
                                  padding: EdgeInsets.only(bottom: index == Get.find<SplashController>().configModel!.activePaymentMethodList!.length - 1 ? 0 : Dimensions.paddingSmall),
                                  disablePayments: disablePayments,
                                  isDigitalPayment: true,
                                  onTap: disablePayments ? null : (){
                                    if(widget.isSubscriptionPackage) {
                                      businessController.setPaymentIndex(1);
                                      businessController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                    } else {
                                      checkoutController.setPaymentMethod(2);
                                      checkoutController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                    }
                                  },
                                  title: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                  isSelected: isSelected,
                                  image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl,
                                );
                              }),
                          ],
                        ),
                      ) : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingDefault),

                      widget.isOfflinePaymentActive && notHideOffline && !checkoutController.subscriptionOrder ? OfflinePaymentButton(
                        isSelected: checkoutController.paymentMethodIndex == 3,
                        offlineMethodList: checkoutController.offlineMethodList,
                        isOfflinePaymentActive: widget.isOfflinePaymentActive,
                        onTap: disablePayments ? null : () {
                          checkoutController.setPaymentMethod(3);
                        },
                        checkoutController: checkoutController, tooltipController: tooltipController,
                        disablePayment: disablePayments,
                      ) : const SizedBox(),

                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(Dimensions.paddingDefault),
                  decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
                    color: context.surfaceContainer,
                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: CustomButtonWidget(
                    buttonText: 'select'.tr,
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

            ]),
          );
        });
      }),
    );
  }

  Widget paymentButtonView({required String title, String? image, required bool isSelected, required Function? onTap, bool disablePayments = false, bool isDigitalPayment = false, required EdgeInsetsGeometry padding}) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: image != null ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            border: Border.all(color: isSelected && isDigitalPayment ? context.primary.withValues(alpha: 0.2) : context.outlineVariant),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Row(children: [

            image != null ? CustomImageWidget(
              height: 32, width: 36, fit: BoxFit.contain,
              image: image, color: disablePayments ? context.iconBaseMedium : null,
            ) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: Text(
                title,
                style: isDigitalPayment ? context.subHeading.small.medium.overrideWith(color: disablePayments ? context.textBaseMedium : context.textBaseDefault) :
                context.subHeading.defaultSize.semiBold.overrideWith(color: disablePayments ? context.textBaseMedium : context.textBaseDefault),
              ),
            ),

            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 24,
              color: isSelected ? context.primary : context.iconDisabledDefault,
            ),

          ]),
        ),
      ),
    );
  }

  Widget changeAmountView(CheckoutController checkoutController) {
    return Column(
      children: [
        checkoutController.showChangeAmount ? Container(
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            border: Border.all(color: context.outline),
          ),
          padding: EdgeInsets.all(Dimensions.paddingSmall),
          margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.padding2xSmall, children: [

            Text('${'change_amount'.tr} (${Get.find<SplashController>().configModel?.currencySymbol})', style: context.subHeading.defaultSize.strong),

            Text('add_cash_amount_for_charge'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
            const SizedBox(height: Dimensions.padding2xSmall),

            CustomTextFieldWidget(
              hintText: 'amount'.tr,
              showLabelText: false,
              inputType: TextInputType.number,
              isAmount: true,
              inputAction: TextInputAction.done,
              controller: _amountController,
              isEnabled: checkoutController.paymentMethodIndex == 0 ? true : false,
              onChanged: (String value){
                checkoutController.setExchangeAmount(double.tryParse(value)??0);
              },
            ),
          ]),
        ) : const SizedBox(),

        CustomInkWellWidget(
          onTap: (){
            checkoutController.setShowChangeAmount(!checkoutController.showChangeAmount);
          },
          radius: Dimensions.radiusExtraSmall,
          padding: EdgeInsets.all(Dimensions.padding2xSmall),
          child: Text(checkoutController.showChangeAmount ? 'see_less'.tr : 'see_more'.tr , style: context.subHeading.defaultSize.strong.overrideWith(color: Colors.blue)),
        ),
        const SizedBox(height: Dimensions.paddingSmall),
      ],
    );
  }

  void _setPartialPay(CheckoutController checkoutController, bool value) {
    if(checkoutController.isPartialPay != value) {
      checkoutController.changePartialPayment();
    }
  }

  Widget walletView(CheckoutController checkoutController) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance??0;
    double balance = 0;
    if(walletBalance <= 0) {
      return const SizedBox();
    }
    if(walletBalance > widget.totalPrice && checkoutController.paymentMethodIndex == 1) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected = checkoutController.paymentMethodIndex == 1 || checkoutController.isPartialPay;

    bool coversTotal = walletBalance >= widget.totalPrice;
    bool walletUsable = coversTotal || (Get.find<SplashController>().configModel!.partialPaymentStatus ?? false);

    return !checkoutController.subscriptionOrder
      && Get.find<SplashController>().configModel!.customerWalletStatus!
      && Get.find<ProfileController>().userInfoModel != null && (checkoutController.distance != -1)
      && walletUsable ? Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.outline, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr, style: context.body.small.medium.overrideWith(color: Colors.grey.shade700)),

            Row(children: [
              Text(
                PriceConverter.convertPrice(isWalletSelected ? balance : walletBalance),
                style: context.heading.extraLarge.medium,
              ),

              Text(
                isWalletSelected ? ' (${'applied'.tr})' : '',
                style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary),
              ),
            ])
          ]),

          CustomInkWellWidget(
            onTap: () {
              if(isWalletSelected) {
                checkoutController.setPaymentMethod(-1);
                _setPartialPay(checkoutController, false);
              } else {
                checkoutController.setPaymentMethod(1);
                _setPartialPay(checkoutController, !coversTotal);
              }
              configurePartialPayment();
            },
            radius: 5,
            child: isWalletSelected ? const Icon(Icons.clear, color: Colors.red) : Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: context.primary, width: 1)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('apply'.tr, style: context.subHeading.small.medium.overrideWith(color: context.primary)),
            ),
          ),
        ]),
      ),

      if(isWalletSelected && !checkoutController.isPartialPay)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
          decoration: BoxDecoration(
            color: context.bgNeutralLight,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('paid_by_wallet'.tr, style: context.subHeading.defaultSize.strong),
            Text(PriceConverter.convertPrice(widget.totalPrice), style: context.heading.large.medium)

          ]),
        ),


      if(isWalletSelected && checkoutController.isPartialPay)
        Column(children: [
          Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
            decoration: BoxDecoration(
              color: context.bgNeutralLight,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('paid_by_wallet'.tr, style: context.body.defaultSize.medium.overrideWith(color: Colors.grey.shade700)),
                Text(PriceConverter.convertPrice(walletBalance), style: context.body.defaultSize.medium.overrideWith(color: Colors.grey.shade700))

              ]),
              const SizedBox(height: 5),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('remaining_bill'.tr, style: context.subHeading.defaultSize.medium),
                Text(PriceConverter.convertPrice(widget.totalPrice - walletBalance), style: context.heading.large.strong),

              ])
            ]),
          ),

          if(checkoutController.paymentMethodIndex == 1)
            Text('* ${'please_select_a_option_to_pay_remain_billing_amount'.tr}', style: context.body.small.regular.overrideWith(color: const Color(0xFFE74B4B))),
          const SizedBox(height: Dimensions.paddingSmall),
        ]),

    ]) : const SizedBox();
  }
}

