import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/coupon/widgets/coupon_card_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class CouponBottomSheet extends StatefulWidget {
  final CheckoutController checkoutController;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double charge;
  final double total;
  const CouponBottomSheet({super.key, required this.checkoutController, required this.price, required this.discount, required this.addOns, required this.deliveryCharge, required this.total, required this.charge});

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  List<Coupon>? _availableCouponList;
  List<Coupon>? _unavailableCouponList;
  List<JustTheController>? _availableToolTipControllerList;
  List<JustTheController>? _unavailableToolTipControllerList;

  @override
  void initState() {
    super.initState();

    if(Get.find<CouponController>().customerCouponModel?.available != null && Get.find<CouponController>().customerCouponModel!.available!.isNotEmpty) {
      _availableCouponList = [];
      _availableToolTipControllerList = [];
      for (var coupon in Get.find<CouponController>().customerCouponModel!.available!) {
        if(widget.deliveryCharge == 0 && coupon.couponType != 'free_delivery') {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        } else if(widget.deliveryCharge != 0) {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        }
      }
    }

    if(Get.find<CouponController>().customerCouponModel?.unavailable != null && Get.find<CouponController>().customerCouponModel!.unavailable!.isNotEmpty) {
      _unavailableCouponList = [];
      _unavailableToolTipControllerList = [];
      for (var coupon in Get.find<CouponController>().customerCouponModel!.unavailable!) {
        if(widget.deliveryCharge == 0 && coupon.couponType != 'free_delivery') {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        } else if(widget.deliveryCharge != 0) {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        }
      }
    }

  }

  @override
  void dispose() {
    super.dispose();

    if(_availableToolTipControllerList != null) {
      for (var toolTip in _availableToolTipControllerList!) {
        toolTip.dispose();
      }
    }

    if(_unavailableToolTipControllerList != null) {
      for (var toolTip in _unavailableToolTipControllerList!) {
        toolTip.dispose();
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.total;
    return Container(
      width: 500,
      height: context.height * 0.7 ,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<CouponController>(
        builder: (couponController) {
          return Column(
            children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                const SizedBox(width: 30),

                !ResponsiveHelper.isDesktop(context) ? Container(
                  height: 4, width: 35,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(10)),
                ) : const SizedBox(),

                IconButton(
                  onPressed: ()=> Get.back(),
                  icon: Icon(Icons.clear, color: context.iconBaseMedium),
                ),
              ]),


              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: context.primary, width: 0.3),
                ),
                padding: const EdgeInsets.only(left: Dimensions.padding2xSmall),
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                child: Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: widget.checkoutController.couponController,
                        style: context.body.defaultSize.regular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                        decoration: InputDecoration(
                            hintText: 'enter_promo_code'.tr,
                            hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                            isDense: true,
                            filled: true,
                            enabled: couponController.discount == 0,
                            fillColor: context.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.local_offer_outlined, color: context.primary)
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      String couponCode = widget.checkoutController.couponController.text.trim();
                      if(couponController.discount! < 1 && !couponController.freeDelivery) {
                        if(couponCode.isNotEmpty && !couponController.isLoading) {
                          couponController.applyCoupon(couponCode, (widget.price-widget.discount)+widget.addOns, widget.deliveryCharge,
                              widget.charge, totalPrice, Get.find<RestaurantController>().restaurant!.id, hideBottomSheet: true).then((discount) {
                            if (discount! > 0) {
                              showCustomSnackBar(
                                '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                isError: false,
                              );
                              if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                                totalPrice = totalPrice - discount;
                                widget.checkoutController.checkBalanceStatus(totalPrice);
                              }
                            } else{showCustomSnackBar('invalid_coupon_code'.tr, isError: false);}
                          });
                        } else if(couponCode.isEmpty) {
                          showCustomSnackBar('enter_a_coupon_code'.tr);
                        }
                      } else {
                        totalPrice = totalPrice + couponController.discount!;
                        couponController.removeCouponData(true);
                        widget.checkoutController.couponController.text = '';
                        if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1){
                          widget.checkoutController.checkBalanceStatus(totalPrice);
                        }
                      }
                    },
                    child: Container(
                      height: 45, width: (couponController.discount! <= 0 && !couponController.freeDelivery) ? 100 : 50,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(Dimensions.padding2xSmall),
                      decoration: BoxDecoration(
                        color: (couponController.discount! <= 0 && !couponController.freeDelivery) ? context.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                        'apply'.tr,
                        style: context.subHeading.defaultSize.medium.overrideWith(color: context.onPrimary),
                      ) : const SizedBox(
                        height: 30, width: 30,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      ) : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ]),
              ),

              Expanded(
                child: _availableCouponList != null && _availableCouponList!.isNotEmpty ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                  child: Column(children: [

                    Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault, top: Dimensions.paddingDefault, bottom: Dimensions.paddingSmall),
                      child: Align(alignment: Alignment.centerLeft, child: Text('available_promo'.tr, style: context.subHeading.defaultSize.strong)),
                    ),

                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: Dimensions.paddingSmall, crossAxisSpacing: Dimensions.paddingSmall,
                        childAspectRatio: 3,
                      ),
                      itemCount: _availableCouponList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if(_availableCouponList![index].code != null) {
                              widget.checkoutController.couponController.text = _availableCouponList![index].code.toString();
                            }
                            if(widget.checkoutController.couponController.text.isNotEmpty){
                              if(couponController.discount! < 1 && !couponController.freeDelivery) {
                                if(widget.checkoutController.couponController.text.isNotEmpty && !couponController.isLoading) {
                                  couponController.applyCoupon(widget.checkoutController.couponController.text, (widget.price-widget.discount)+widget.addOns, widget.deliveryCharge,
                                    widget.charge, totalPrice, Get.find<RestaurantController>().restaurant!.id, hideBottomSheet: true).then((discount) {

                                    widget.checkoutController.couponController.text = '${widget.checkoutController.couponController.text}(${couponController.freeDelivery ? 'free_delivery'.tr : PriceConverter.convertPrice(couponController.discount)})';
                                    if (discount! > 0) {
                                      showCustomSnackBar(
                                        '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                        isError: false,
                                      );
                                      if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                                        widget.checkoutController.checkBalanceStatus(totalPrice, discount: discount);
                                      }
                                    } else if (couponController.coupon?.couponType == 'free_delivery'){
                                      showCustomSnackBar(
                                        '${'you_got'.tr} ${'free_delivery'.tr}',
                                        isError: false,
                                      );
                                    } else{
                                      if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                                        widget.checkoutController.checkBalanceStatus(totalPrice);
                                      }
                                    }
                                  });
                                } else if(widget.checkoutController.couponController.text.isEmpty) {
                                  showCustomSnackBar('enter_a_coupon_code'.tr);
                                }
                              } else {
                                totalPrice = totalPrice + couponController.discount!;
                                couponController.removeCouponData(true);
                                widget.checkoutController.couponController.text = '';
                                if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1){
                                  widget.checkoutController.checkBalanceStatus(totalPrice);
                                }
                              }
                            }
                          },
                          child: CouponCardWidget(
                            toolTipController: _availableToolTipControllerList, couponList: _availableCouponList, index: index,
                            onCopyClick: () {
                              if(_availableCouponList![index].code != null) {
                                widget.checkoutController.couponController.text = _availableCouponList![index].code.toString();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    _unavailableCouponList != null && _unavailableCouponList!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                      child: Align(alignment: Alignment.centerLeft, child: Text('unavailable_promo'.tr, style: context.subHeading.defaultSize.strong)),
                    ) : const SizedBox(),

                    _unavailableCouponList != null && _unavailableCouponList!.isNotEmpty ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: Dimensions.paddingSmall, crossAxisSpacing: Dimensions.paddingSmall,
                        childAspectRatio: 3,
                      ),
                      itemCount: _unavailableCouponList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      itemBuilder: (context, index) {
                        return CouponCardWidget(
                          unavailable: true,
                          toolTipController: _unavailableToolTipControllerList, couponList: _unavailableCouponList, index: index,
                          onCopyClick: () {},
                        );
                      },
                    ) : const SizedBox(),
                  ]),
                ): Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CustomAssetImageWidget(Images.noCoupon, height: 70),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Text('no_promo_available'.tr, style: context.subHeading.defaultSize.medium),
                    const SizedBox(height: Dimensions.padding2xSmall),

                    Text(
                      '${'please_add_manually_or_collect_promo_from'.tr} ${'your_business_name'.tr}',
                      style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
                    ),
                    const SizedBox(height: 50),

                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
