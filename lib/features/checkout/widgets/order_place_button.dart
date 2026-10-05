import 'package:stackfood_multivendor/common/enums/order_type.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart' as place_order_model;
import 'package:stackfood_multivendor/features/checkout/domain/models/pricing_view_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

class OrderPlaceButton extends StatelessWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? deliveryCharge;
  final double tax;
  final double? discount;
  final double total;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final List<CartModel>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final CouponController couponController;
  final double subTotal;
  final bool taxIncluded;
  final double taxPercent;
  final double extraPackagingAmount;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final TextEditingController guestAddressController;
  final TextEditingController guestStreetNumberController;
  final TextEditingController guestHouseController;
  final TextEditingController guestFloorController;
  final double proDiscount;
  final bool isDiscountCalculating;

  final bool cartHasBogoBundle;
  final DateTime? scheduleEndsAt;

  const OrderPlaceButton({
    super.key, required this.checkoutController, required this.locationController,
    required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.deliveryCharge,
    required this.tax, this.discount, required this.total, this.maxCodOrderAmount, required this.subscriptionQty,
    required this.cartList, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.fromCart, required this.guestNameController, required this.guestNumberController,
    required this.isOfflinePaymentActive, required this.couponController, required this.subTotal,
    required this.taxIncluded, required this.taxPercent, required this.guestEmailController, required this.extraPackagingAmount,
    required this.guestAddressController, required this.guestStreetNumberController, required this.guestHouseController, required this.guestFloorController,
    this.proDiscount = 0, this.isDiscountCalculating = false, this.cartHasBogoBundle = false, this.scheduleEndsAt});

  static bool isScheduleWithinOffer(DateTime scheduleAt, DateTime? endsAt) {
    return endsAt == null || !scheduleAt.isAfter(endsAt);
  }

  @override
  Widget build(BuildContext context) {
    print("############order place button : $proDiscount");
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingSmall, Dimensions.paddingLarge, Dimensions.paddingLarge),
      child: SafeArea(
        child: CustomButtonWidget(
            buttonText: 'place_order'.tr,
            radius: Dimensions.radiusDefault,
            isLoading: checkoutController.isLoading,
            onPressed: checkoutController.isDistanceLoading || isDiscountCalculating ? null : () {
          checkoutController.refreshPassedDineInScheduleTime();

          if(checkoutController.orderType == 'dine_in') {
            debugPrint('===> DINE-IN PLACE ORDER | now: ${DateTime.now()}'
                ' | schedule_at being sent: ${checkoutController.orderPlaceDineInDateTime}'
                ' | lead time: ${checkoutController.restaurant?.dineInBookingDuration} ${checkoutController.restaurant?.dineInBookingDurationTimeFormat}');
          }

          DateTime scheduleStartDate = _processScheduleStartDate();
          DateTime scheduleEndDate = _processScheduleEndDate();
          bool isAvailable = _checkAvailability(scheduleStartDate, scheduleEndDate);
          bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
          bool datePicked = _isDatePicked();

          if(checkoutController.isDmTipSave && checkoutController.selectedTips != AppConstants.tips.length - 1) {
            checkoutController.saveDmTipIndex(checkoutController.selectedTips.toString());
          }
          if(!checkoutController.isDmTipSave){
            checkoutController.saveDmTipIndex('0');
          }

          if(_showsWarningMessage(context, isGuestLogIn, datePicked, isAvailable)){
            debugPrint('Warning shows');
          } else {

            AddressModel? finalAddress = _processFinalAddress(isGuestLogIn);
            List<place_order_model.OnlineCart> carts = cartList != null ? _generateOnlineCartList() : [];
            List<place_order_model.SubscriptionDays> days = _generateSubscriptionDays();
            PlaceOrderBodyModel placeOrderBody = _preparePlaceOrderModel(carts, scheduleStartDate, finalAddress, isGuestLogIn, days);

            if(checkoutController.paymentMethodIndex == 3){

              Map<String, dynamic> data = {
                "restaurant_id": placeOrderBody.restaurantId,
                "order_type": placeOrderBody.orderType,
                "schedule_at": placeOrderBody.scheduleAt,
                "subscription_order": placeOrderBody.subscriptionOrder,
              };

              checkoutController.checkRestaurantValidation(data: data).then((response) {
                if(response) {
                  Get.toNamed(RouteHelper.getOfflinePaymentScreen(placeOrderBody: placeOrderBody, zoneId: checkoutController.restaurant!.zoneId!, total: total, maxCodOrderAmount: maxCodOrderAmount,
                    fromCart: fromCart, isCodActive: isCashOnDeliveryActive,
                    pricingView: PricingViewModel(
                      subTotal: subTotal, subscriptionQty: subscriptionQty, discount: discount!, taxIncluded: taxIncluded,
                      tax: tax, deliveryCharge: deliveryCharge!, total: total, taxPercent: taxPercent,
                    ),
                  ));
                }else{
                  showCustomSnackBar('restaurant_is_closed_now'.tr);
                }
              });
            }else{
              checkoutController.placeOrder(placeOrderBody, checkoutController.restaurant!.zoneId!, total, maxCodOrderAmount, fromCart, isCashOnDeliveryActive, proDiscount: proDiscount);
            }

          }
        }),
      ),
    );
  }

  bool _isDatePicked() {
    bool datePicked = false;
    for(DateTime? time in checkoutController.selectedDays) {
      if(time != null) {
        datePicked = true;
        break;
      }
    }
    return datePicked;
  }

  DateTime _processScheduleStartDate() {
    DateTime scheduleStartDate = DateTime.now();
    if(checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime startTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot!].startTime!;

      if(checkoutController.orderType == 'dine_in') {
        scheduleStartDate = checkoutController.orderPlaceDineInDateTime ?? DateTime.now();
      } else {
        scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute + 1);
      }
    }
    return scheduleStartDate;
  }

  DateTime _processScheduleEndDate() {
    DateTime scheduleEndDate = DateTime.now();
    if(checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime endTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot!].endTime!;
      if(checkoutController.orderType == 'dine_in') {
        scheduleEndDate = checkoutController.orderPlaceDineInDateTime?.add(const Duration(minutes: 1)) ?? DateTime.now().add(const Duration(minutes: 1));
      } else {
        scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute + 1);
      }
    }
    return scheduleEndDate;
  }

  bool _checkAvailability(DateTime scheduleStartDate, DateTime scheduleEndDate) {
    bool isAvailable = true;
    if(checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      isAvailable = false;
    } else {
      if(cartList != null) {
        for (CartModel cart in cartList!) {
          if(cart.isBogoBundle) {
            continue;
          }
          if (!DateConverter.isAvailable(
            cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
            time: checkoutController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
          ) && !DateConverter.isAvailable(
            cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
            time: checkoutController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
          )) {
            isAvailable = false;
            break;
          }
        }
      }
    }
    return isAvailable;
  }

  bool _showsWarningMessage(BuildContext context, bool isGuestLogIn, bool datePicked, bool isAvailable) {
    if(checkoutController.orderType == OrderType.dine_in.name && checkoutController.selectedDineInDate == null) {
      showCustomSnackBar('please_select_your_dine_in_date'.tr);
      return true;
    } else if(checkoutController.orderType == OrderType.dine_in.name && checkoutController.estimateDineInTime == null){
      showCustomSnackBar('please_select_your_dine_in_time'.tr);
      return true;
    } else if(isGuestLogIn && guestNameController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_name'.tr);
      return true;
    } else if(isGuestLogIn && guestNumberController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_number'.tr);
      return true;
    }  else if((isGuestLogIn && checkoutController.orderType == OrderType.delivery.name) && checkoutController.addressController.text.trim().isEmpty){
      showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
      return true;
    } else if(checkoutController.needCoverageAreaSelection && checkoutController.selectedCoverageArea == null) {
      showCustomSnackBar(checkoutController.isZipCodeWiseDelivery ? 'please_select_zip_code'.tr : 'please_select_area'.tr);
      showDeliveryAddressBottomSheet();
      return true;
    } else if(!isCashOnDeliveryActive && !isDigitalPaymentActive && !isWalletActive) {
      showCustomSnackBar('no_payment_method_is_enabled'.tr);
      return true;
    }else if(cartHasBogoBundle && !isScheduleWithinOffer(
        checkoutController.orderType == 'dine_in'
            ? (checkoutController.orderPlaceDineInDateTime ?? DateTime.now())
            : _processScheduleStartDate(),
        scheduleEndsAt)) {
      showCustomSnackBar('offer_ends_on_pick_earlier_time'.trParams({
        'date': DateConverter.dateTimeStringToDateTime(DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduleEndsAt!)),
      }));
      return true;
    }else if(!Get.find<SplashController>().configModel!.instantOrder! && !checkoutController.restaurant!.instantOrder! && checkoutController.restaurant!.scheduleOrder! && (checkoutController.preferableTime.isEmpty || checkoutController.preferableTime == 'Not Available')) {
      showCustomSnackBar('please_select_order_preference_time'.tr);
      return true;
    } else if(checkoutController.paymentMethodIndex == -1) {
      if(ResponsiveHelper.isDesktop(context)){
        Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
          isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
          isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
        )));
      }else{
        Get.bottomSheet(
          PaymentMethodBottomSheet(
            isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
            isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
          ),
          backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true,
        );
      }
      return true;
    }else if(orderAmount < checkoutController.restaurant!.minimumOrder!) {
      showCustomSnackBar('${'minimum_order_amount_is'.tr} ${checkoutController.restaurant!.minimumOrder}');
      return true;
    }else if(checkoutController.subscriptionOrder && (!Get.find<SplashController>().configModel!.homeDelivery! || !checkoutController.restaurant!.delivery!)){
      showCustomSnackBar('home_delivery_is_disable_for_subscription'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && checkoutController.subscriptionRange == null) {
      showCustomSnackBar('select_a_date_range_for_subscription'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && !datePicked && checkoutController.subscriptionType == 'daily') {
      showCustomSnackBar('choose_time'.tr);
      return true;
    }else if(checkoutController.subscriptionOrder && !datePicked) {
      showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
      return true;
    }else if(((checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed) || (checkoutController.selectedDateSlot == 2 && checkoutController.customDateRestaurantClose)) && checkoutController.orderType != 'dine_in') {
      showCustomSnackBar('restaurant_is_closed'.tr);
      return true;
    }else if(checkoutController.paymentMethodIndex == 0 && Get.find<SplashController>().configModel!.cashOnDelivery! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount!)){
      showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
      return true;
    } else if (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      if(checkoutController.restaurant!.scheduleOrder! && !checkoutController.subscriptionOrder) {
        showCustomSnackBar('select_a_time'.tr);
      }else {
        showCustomSnackBar('restaurant_is_closed'.tr);
      }
      return true;
    }else if (!isAvailable && !checkoutController.subscriptionOrder) {
      showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
      return true;
    }else if (checkoutController.orderType != 'take_away' && checkoutController.distance == -1 && deliveryCharge == -1) {
      showCustomSnackBar('delivery_fee_not_set_yet'.tr);
      return true;
    } else if(checkoutController.orderType != OrderType.take_away.name && (checkoutController.checkoutSummary == null || checkoutController.isSummaryLoading)) {
      showCustomSnackBar('preparing_your_order_summary'.tr);
      return true;
    } else if(checkoutController.paymentMethodIndex == 1 && Get.find<ProfileController>().userInfoModel
        != null && Get.find<ProfileController>().userInfoModel!.walletBalance! < total) {
      showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
      return true;
    } else {
      return false;
    }
  }

  AddressModel? _processFinalAddress(bool isGuestLogIn) {
    AddressModel? finalAddress;
    String contactName = guestNameController.text.trim();
    String contactNumber = '${checkoutController.countryDialCode ?? ''}${guestNumberController.text.trim()}';
    String contactEmail = guestEmailController.text.trim();

    if(!isGuestLogIn){
      final address = checkoutController.address;
      finalAddress = address != null ? AddressModel(
        id: address.id, addressType: address.addressType,
        contactPersonName: contactName.isNotEmpty ? contactName : address.contactPersonName,
        contactPersonNumber: guestNumberController.text.trim().isNotEmpty ? contactNumber : address.contactPersonNumber,
        address: address.address, latitude: address.latitude, longitude: address.longitude,
        zoneId: address.zoneId, zoneIds: address.zoneIds, method: address.method,
        road: address.road, house: address.house, floor: address.floor,
        zoneData: address.zoneData, email: contactEmail.isNotEmpty ? contactEmail : address.email,
        isDefault: address.isDefault,
      ) : null;

    }else if(isGuestLogIn && checkoutController.orderType == OrderType.take_away.name || checkoutController.orderType == OrderType.dine_in.name) {
      finalAddress = AddressModel(contactPersonName: contactName, contactPersonNumber: contactNumber,
        address: AddressHelper.getAddressFromSharedPref()!.address!, latitude: AddressHelper.getAddressFromSharedPref()!.latitude,
        longitude: AddressHelper.getAddressFromSharedPref()!.longitude, zoneId: AddressHelper.getAddressFromSharedPref()!.zoneId,
        email: contactEmail,
      );
    }else if(isGuestLogIn && checkoutController.orderType == OrderType.delivery.name){
      final address = checkoutController.address;
      finalAddress = AddressModel(contactPersonName: contactName, contactPersonNumber: contactNumber,
        address: checkoutController.addressController.text.trim(), email: contactEmail,
        road: checkoutController.streetNumberController.text.trim(), house: checkoutController.houseController.text.trim(), floor: checkoutController.floorController.text.trim(),
        addressType: address?.addressType ?? AddressHelper.getAddressFromSharedPref()!.addressType,
        latitude: address?.latitude ?? locationController.position.latitude.toString(),
        longitude: address?.longitude ?? locationController.position.longitude.toString(),
        zoneId: address?.zoneId ?? locationController.zoneID,
      );
    }

    if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
      finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
    }
    return finalAddress;
  }

  List<place_order_model.OnlineCart> _generateOnlineCartList() {
    List<place_order_model.OnlineCart> carts = [];
    for (int index = 0; index < cartList!.length; index++) {
      CartModel cart = cartList![index];

      if(cart.isBogoBundle) {
        continue;
      }

      List<int?> addOnIdList = [];
      List<int?> addOnQtyList = [];
      List<place_order_model.OrderVariation> variations = [];
      List<int?> optionIds = [];
      for (var addOn in cart.addOnIds!) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }
      if(cart.product!.variations != null){
        for(int i=0; i<cart.product!.variations!.length; i++) {
          if(cart.variations![i].contains(true)) {
            variations.add(place_order_model.OrderVariation(name: cart.product!.variations![i].name, values: place_order_model.OrderVariationValue(label: [])));
            for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
              if(cart.variations![i][j]!) {
                variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                if(cart.product!.variations![i].variationValues![j].optionId != null) {
                  optionIds.add(cart.product!.variations![i].variationValues![j].optionId);
                }
              }
            }
          }
        }
      }
      carts.add(place_order_model.OnlineCart(
        cart.id, cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
        cart.discountedPrice.toString(), variations,
        cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food', variationOptionIds: optionIds, itemType: !fromCart ? "AppModelsItemCampaign" : null, restaurantId: cart.product!.restaurantId,
      ));
    }
    return carts;
  }

  List<place_order_model.SubscriptionDays> _generateSubscriptionDays() {
    List<place_order_model.SubscriptionDays> days = [];
    for(int index=0; index<checkoutController.selectedDays.length; index++) {
      if(checkoutController.selectedDays[index] != null) {
        days.add(place_order_model.SubscriptionDays(
          day: checkoutController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
              : checkoutController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
          time: DateConverter.dateToTime(checkoutController.selectedDays[index]!),
        ));
      }
    }
    return days;
  }

  PlaceOrderBodyModel _preparePlaceOrderModel(List<place_order_model.OnlineCart> carts, DateTime scheduleStartDate, AddressModel? finalAddress, bool isGuestLogIn,
      List<place_order_model.SubscriptionDays> days) {
    return PlaceOrderBodyModel(
      cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
      deliveryDuration: checkoutController.deliveryDurationInSecond,
      couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
      scheduleAt: checkoutController.orderType == 'dine_in' ? checkoutController.orderPlaceDineInDateTime.toString()
          : !checkoutController.restaurant!.scheduleOrder! ? null : (checkoutController.selectedDateSlot == 0
          && checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
      orderAmount: total, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
      paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
          : checkoutController.paymentMethodIndex == 1 ? 'wallet'
          : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
      couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
          && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
      restaurantId: cartList?[0].restaurantId,
      address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
      contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
          '${Get.find<ProfileController>().userInfoModel!.lName}',
      contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
      discountAmount: discount, taxAmount: tax, cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
      road: isGuestLogIn ? finalAddress.road??'' : checkoutController.streetNumberController.text.trim(),
      house: isGuestLogIn ? finalAddress.house??'' : checkoutController.houseController.text.trim(),
      floor: isGuestLogIn ? finalAddress.floor??'' : checkoutController.floorController.text.trim(),
      dmTips: (checkoutController.orderType == 'take_away' || checkoutController.subscriptionOrder || checkoutController.selectedTips == 0) ? '0' : checkoutController.tips.toString(),
      subscriptionOrder: checkoutController.subscriptionOrder ? '1' : '0',
      subscriptionType: checkoutController.subscriptionType, subscriptionQuantity: subscriptionQty.toString(),
      subscriptionDays: days,
      subscriptionStartAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.start) : '',
      subscriptionEndAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.end) : '',
      unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
      deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
      partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
      isBuyNow: fromCart ? 0 : 1, guestEmail: finalAddress.email,
      extraPackagingAmount: extraPackagingAmount, bringChangeAmount: checkoutController.paymentMethodIndex == 0 && checkoutController.exchangeAmount > 0 ? checkoutController.exchangeAmount : null,
      saverDeliveryType: checkoutController.saverDeliveryType,
      zipCodeId: checkoutController.needCoverageAreaSelection && checkoutController.isZipCodeWiseDelivery
          ? checkoutController.selectedCoverageArea?.id : null,
      areaId: checkoutController.needCoverageAreaSelection && checkoutController.isAreaWiseDelivery
          ? checkoutController.selectedCoverageArea?.id : null,
    );
  }

}
