import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/checkout_summary_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/bottom_section_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/guest_login_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/order_place_button.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/top_section_widget.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final bool fromCart;
  final int? restaurantId;
  final bool fromDineInPage;
  const CheckoutScreen({super.key, required this.fromCart, this.restaurantId, required this.cartList, this.fromDineInPage = false});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  double? taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  bool _isWalletActive = false;
  List<CartModel>? _cartList;
  double _announcedCashBackAmount = 0;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool firstTime = true;
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();
  final loginTooltipController = JustTheController();
  final serviceFeeTooltipController = JustTheController();
  final deliveryFeeTooltipController = JustTheController();

  final ExpansibleController expansionTileController = ExpansibleController();

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestAddressController = TextEditingController();
  final TextEditingController guestStreetNumberController = TextEditingController();
  final TextEditingController guestHouseController = TextEditingController();
  final TextEditingController guestFloorController = TextEditingController();

  final FocusNode guestNameNode = FocusNode();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode guestAddressNode = FocusNode();
  final FocusNode guestStreetNumberNode = FocusNode();
  final FocusNode guestHouseNode = FocusNode();
  final FocusNode guestFloorNode = FocusNode();

  final TextEditingController estimateArrivalDateController = TextEditingController();
  final TextEditingController estimateArrivalTimeController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  final ScrollController deliveryOptionScrollController = ScrollController();

  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;


  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    CheckoutController checkoutController = Get.find<CheckoutController>();

    checkoutController.streetNumberController.text = AddressHelper.getAddressFromSharedPref()!.road ?? '';
    checkoutController.houseController.text = AddressHelper.getAddressFromSharedPref()!.house ?? '';
    checkoutController.floorController.text = AddressHelper.getAddressFromSharedPref()!.floor ?? '';
    checkoutController.couponController.text = '';

    checkoutController.clearPrevData();
    checkoutController.getDmTipMostTapped();
    checkoutController.setPreferenceTimeForView('', false, isUpdate: false);
    checkoutController.setCustomDate(null, false, canUpdate: false);

    checkoutController.getOfflineMethodList();
    checkoutController.initDineInSetup();
    checkoutController.setExchangeAmount(0);

    Get.find<LocationController>().getZone(
      AddressHelper.getAddressFromSharedPref()!.latitude,
      AddressHelper.getAddressFromSharedPref()!.longitude, false, updateInAddress: true,
    );

    _cartList = [];

    if(widget.fromCart){
      await Get.find<CartController>().getCartDataOnline(widget.restaurantId!);
    }
    widget.fromCart ? _cartList!.addAll(Get.find<CartController>().cartList(widget.restaurantId!)) : _cartList!.addAll(widget.cartList!);

    if(isLoggedIn){
      if(Get.find<ProfileController>().userInfoModel == null && Get.find<ProfileController>().userInfoModel?.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }
      Get.find<AddressController>().getAddressList(canInsertAddress: true);
      Get.find<ProController>().getProActiveOffer();
    }

    checkoutController.setRestaurantDetails(restaurantId: _cartList![0].restaurantId);

    checkoutController.initCheckoutData(_cartList![0].restaurantId);

    checkoutController.getDeliveryCoverageList(restaurantId: _cartList![0].restaurantId);


    Get.find<CouponController>().setCoupon('', isUpdate: false);

    checkoutController.stopLoader(isUpdate: false);
    checkoutController.updateTimeSlot(0, false, notify: false);

    _isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
    _isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
    _isOfflinePaymentActive = Get.find<SplashController>().configModel!.offlinePaymentStatus!;
    _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus!;

    if(_isDigitalPaymentActive ?? false) {
      checkoutController.setPaymentMethod(2, willUpdate: false);
      var activeList = Get.find<SplashController>().configModel!.activePaymentMethodList;
      if(activeList != null && activeList.isNotEmpty) {
        String gateway = activeList[0].getWay!;
        for (var method in activeList) {
          if (method.getWay == 'easebuzz') {
            gateway = 'easebuzz';
            break;
          }
        }
        checkoutController.changeDigitalPaymentName(gateway);
      }
    } else if(_isCashOnDeliveryActive ?? false) {
      checkoutController.setPaymentMethod(0, willUpdate: false);
    }


    checkoutController.updateTips(
      checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 0, notify: false,
    );
    checkoutController.tipController.text = checkoutController.selectedTips != -1 ? AppConstants.tips[checkoutController.selectedTips] : '';

    setSinglePaymentActive();

    Future.delayed(const Duration(milliseconds: 500), () {

      if(!Get.find<SplashController>().configModel!.homeDelivery! && Get.find<SplashController>().configModel!.takeAway!) {
        checkoutController.setOrderType('take_away', notify: true);
      }

      if(checkoutController.isPartialPay){
        checkoutController.changePartialPayment(isUpdate: false);
      }

      if(widget.fromDineInPage) {
        _selectDineIn();
      }
    });

    if(AuthHelper.isLoggedIn()) {
      String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');

      guestContactPersonNameController.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.lName ?? ''}';
      guestContactPersonNumberController.text = phone;
      guestEmailController.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
    }

    if(!AuthHelper.isLoggedIn() && AuthHelper.isGuestLoggedIn() && checkoutController.isFirstTime){
      Future.delayed(const Duration(milliseconds: 300), () {
        showCustomBottomSheet(child: GuestLoginBottomSheet(callBack: () => initCall()));
      });
    }
  }

  Future<void> _selectDineIn() async {

    Future.delayed(Duration(milliseconds: 800), () {
      Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
      Future.delayed(Duration(milliseconds: 500), () {
        if(Get.find<CheckoutController>().restaurant != null && Get.find<CheckoutController>().distance != null) {
          Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
          _animateDeliverySection();
        } else {
          Future.delayed(Duration(seconds: 3), () {
            Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
            _animateDeliverySection();
          });
        }
      });
    });

  }

  void _animateDeliverySection() {
    if(deliveryOptionScrollController.hasClients) {
      deliveryOptionScrollController.animateTo(
        deliveryOptionScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode = '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }

  void setSinglePaymentActive() {
    if(!_isCashOnDeliveryActive! && _isDigitalPaymentActive! && Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1 && !_isWalletActive) {
      Get.find<CheckoutController>().setPaymentMethod(2, willUpdate: false);
      Get.find<CheckoutController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![0].getWay!);
    }
  }

  @override
  Widget build(BuildContext context) {

    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() && Get.find<SplashController>().configModel!.guestCheckoutStatus!;
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      backgroundColor: context.surfaceContainer,
      appBar: CustomAppBarWidget(title: 'checkout'.tr),
      body: guestCheckoutPermission || AuthHelper.isLoggedIn() ? GetBuilder<CheckoutController>(builder: (checkoutController) {
        return (checkoutController.distance != null && checkoutController.restaurant != null) ? GetBuilder<LocationController>(builder: (locationController) {

          bool todayClosed = false;
          bool tomorrowClosed = false;

          if(checkoutController.restaurant != null) {
            todayClosed = checkoutController.isRestaurantClosed(DateTime.now(), checkoutController.restaurant!.active!, checkoutController.restaurant!.schedules);
            tomorrowClosed = checkoutController.isRestaurantClosed(DateTime.now().add(const Duration(days: 1)), checkoutController.restaurant!.active!, checkoutController.restaurant!.schedules);
            taxPercent = checkoutController.restaurant!.tax;
          }
          return GetBuilder<CartController>(builder: (cartController) {
            if(widget.fromCart){
              _cartList!.clear();
              _cartList!.addAll(Get.find<CartController>().cartList(widget.restaurantId!));
            }
            return GetBuilder<CouponController>(builder: (couponController) {
            bool showTips = checkoutController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !checkoutController.subscriptionOrder;
            final bool isDiscountCalculating = _isDiscountCalculating;
            double deliveryCharge = -1;
            double originalDeliveryCharge = -1;
            double charge = -1;
            double? maxCodOrderAmount;

            double price = _cartList != null ? _calculatePrice(_cartList) : 0;
            double addOnsPrice = _cartList != null ? _calculateAddonsPrice(_cartList) : 0;

            double? discount = _calculateDiscountPrice(cartList: _cartList, price: price, addOns: addOnsPrice);

            double storeDiscount = _appliedStoreDiscount(
              itemDiscount: _calculateItemDiscount(_cartList), price: price, addOns: addOnsPrice,
            );

            double? couponDiscount = PriceConverter.toFixed(couponController.discount!);

            double subTotal = _calculateSubTotal(price, addOnsPrice);

            double referralDiscount = _calculateReferralDiscount(subTotal, discount, couponDiscount, checkoutController.subscriptionOrder);

            double orderAmount = _calculateOrderAmount(subTotal, discount, couponDiscount, referralDiscount);

            if(checkoutController.restaurant != null && checkoutController.distance != null && checkoutController.distance != -1 ) {

              checkoutController.updateCheckoutSummary(
                restaurantId: _cartList?[0].restaurantId, orderAmount: orderAmount,
              );

              SummaryDeliveryModel? summaryDelivery = checkoutController.summaryDelivery;
    
              if(summaryDelivery?.deliveryCharge != null) {
                deliveryCharge = summaryDelivery!.deliveryCharge!;
                originalDeliveryCharge = summaryDelivery.originalDeliveryCharge ?? deliveryCharge;
                charge = summaryDelivery.baseDeliveryCharge ?? deliveryCharge;
              }

              maxCodOrderAmount = _getMaxCodOrderAmount(restaurant: checkoutController.restaurant, checkoutController: checkoutController, orderAmount: orderAmount);

              if(checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in') {
                bool freeDelivery = checkoutController.orderType == 'delivery'
                    ? (checkoutController.restaurant!.freeDelivery! || deliveryCharge == 0) : true;

                _deliveryChargeForView = freeDelivery ? 'free'.tr
                    : deliveryCharge != -1 ? PriceConverter.convertPrice(deliveryCharge) : 'calculating'.tr;
              }
            }
            bool restaurantSubscriptionActive = false;
            final DateTime? scheduleEndsAt = bundleOfferEndsAt(_cartList);
            int subscriptionQty = checkoutController.subscriptionOrder ? 0 : 1;
            double additionalCharge =  Get.find<SplashController>().configModel!.additionalChargeStatus! ? Get.find<SplashController>().configModel!.additionCharge! : 0;

            if(checkoutController.restaurant != null) {

              restaurantSubscriptionActive = canOfferRepeatOrder(
                restaurant: checkoutController.restaurant, fromCart: widget.fromCart, cartList: _cartList,
              );

              if(!restaurantSubscriptionActive && checkoutController.subscriptionOrder) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(checkoutController.subscriptionOrder) {
                    checkoutController.setSubscription(false);
                  }
                });
              }

              subscriptionQty = _getSubscriptionQty(checkoutController: checkoutController, restaurantSubscriptionActive: restaurantSubscriptionActive);

              if (checkoutController.orderType == 'take_away' || checkoutController.orderType == 'dine_in' || checkoutController.restaurant!.freeDelivery!
                  || couponController.freeDelivery) {
                deliveryCharge = 0;
              }
            }

            deliveryCharge = PriceConverter.toFixed(deliveryCharge);

            final SummaryProModel? summaryPro = checkoutController.summaryPro;
            double proDiscount = summaryPro?.discount ?? 0;
            double proDeliveryDiscount = summaryPro?.deliverySavings ?? 0;

            double extraPackagingCharge = _calculateExtraPackagingCharge(checkoutController);
            double saverDeliveryAdjustment = checkoutController.orderType == 'delivery'
                ? checkoutController.getSaverDeliveryChargeAdjustment(deliveryOption: checkoutController.selectedSaverDeliveryOption)
                : 0;

            double payableDeliveryCharge = deliveryCharge < 0 ? 0 : deliveryCharge;

            double total = _calculateTotal(
              subTotal, payableDeliveryCharge, discount, couponDiscount, (checkoutController.taxIncluded == 1),
              checkoutController.orderTax!, showTips, checkoutController.tips, additionalCharge, extraPackagingCharge, saverDeliveryAdjustment,
              proDiscount, 0,
            );

            total = total - referralDiscount;

            Future.delayed(const Duration(milliseconds: 500), () {
              checkoutController.setTotalAmount(total - (checkoutController.isPartialPay ? Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0 : 0));
            });

            _showCashBackSnackBarIfNeeded(checkoutController);

            if(isLoggedIn && firstTime && (price > 0.0)){
              couponController.getCouponList(orderRestaurantId: _cartList![0].restaurantId, orderAmount: price);
              firstTime = false;
            }

            return Column(
              children: [

                Expanded(child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: Dimensions.paddingSmall),

                          TopSectionWidget(
                            charge: charge, deliveryCharge: deliveryCharge, originalDeliveryCharge: originalDeliveryCharge,
                            locationController: locationController, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                            price: price, discount: discount, addOns: addOnsPrice, restaurantSubscriptionActive: restaurantSubscriptionActive,
                              scheduleEndsAt: scheduleEndsAt,
                            showTips: showTips, isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                            isWalletActive: _isWalletActive, fromCart: widget.fromCart, total: total, tooltipController3: tooltipController3, tooltipController2: tooltipController2,
                            isOfflinePaymentActive: _isOfflinePaymentActive, loginTooltipController: loginTooltipController,
                            callBack: () => initCall(), deliveryChargeForView: _deliveryChargeForView, deliveryFeeTooltipController: deliveryFeeTooltipController,
                            badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip, deliveryOptionScrollController: deliveryOptionScrollController,
                            guestNameController: guestContactPersonNameController, guestNumberController: guestContactPersonNumberController,
                            guestEmailController: guestEmailController, guestAddressController: guestAddressController,
                            guestStreetNumberController: guestStreetNumberController, guestHouseController: guestHouseController, guestFloorController: guestFloorController,
                            guestNameNode: guestNameNode, guestEmailNode: guestEmailNode, guestNumberNode: guestNumberNode, guestAddressNode: guestAddressNode,
                            guestStreetNumberNode: guestStreetNumberNode, guestHouseNode: guestHouseNode, guestFloorNode: guestFloorNode,
                          ),

                          BottomSectionWidget(
                            isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive,
                            total: total, subTotal: subTotal, discount: discount, couponController: couponController,
                            taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax!, deliveryCharge: deliveryCharge, checkoutController: checkoutController, locationController: locationController,
                            todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount,
                            subscriptionQty: subscriptionQty, taxPercent: taxPercent!, fromCart: widget.fromCart, cartList: _cartList,
                            price: price, addOns: addOnsPrice, charge: charge, isOfflinePaymentActive: _isOfflinePaymentActive, expansionTileController: expansionTileController,
                            serviceFeeTooltipController: serviceFeeTooltipController, referralDiscount: referralDiscount, extraPackagingAmount: extraPackagingCharge,
                            guestNameController: guestContactPersonNameController, guestNumberController: guestContactPersonNumberController,
                            guestEmailController: guestEmailController, guestAddressController: guestAddressController,
                            guestStreetNumberController: guestStreetNumberController, guestHouseController: guestHouseController, guestFloorController: guestFloorController,
                            proDiscount: proDiscount, proDeliveryDiscount: proDeliveryDiscount,
                            storeDiscount: storeDiscount, storeDiscountEligibility: _storeDiscountEligibility,
                          ),
                        ]),
                      ),
                    ),
                  ),
                )),

                GetBuilder<HappyHourController>(builder: (happyHourController){
                  final bool showHappyHourBanner = happyHourController.showRestaurantBanner(checkoutController.restaurant?.isHappyHourRunning);
                  return Column(
                    children: [
                      Column(
                        children: [

                         if(showHappyHourBanner) HappyHourMilestoneBannerWidget(subtotal: subTotal, isHappyHourRunning: checkoutController.restaurant?.isHappyHourRunning),

                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.surfaceContainer,
                              boxShadow: showHappyHourBanner ? [] : [BoxShadow(color: context.shadow, offset: Offset(0, -1))],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: Dimensions.paddingMedium),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.padding2xSmall),
                                  child: Row(children: [
                                    Text(
                                      'total_amount'.tr,
                                      style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                                    ),

                                    if(checkoutController.taxIncluded == 1) Text(' ${'vat_tax_inc'.tr}', style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium)),

                                    const Spacer(),

                                    isDiscountCalculating ? Text(
                                      '${'calculating'.tr}...',
                                      style: context.subHeading.large.strong.overrideWith(color: context.textBaseMedium),
                                    ) : PriceConverter.convertAnimationPrice(
                                      total * (checkoutController.subscriptionOrder ? (subscriptionQty == 0 ? 1 : subscriptionQty) : 1),
                                      textStyle: context.subHeading.large.strong,
                                    ),
                                  ]),
                                ),

                                OrderPlaceButton(
                                  checkoutController: checkoutController, locationController: locationController,
                                  todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount, deliveryCharge: deliveryCharge,
                                  discount: discount, total: total, maxCodOrderAmount: maxCodOrderAmount, subscriptionQty: subscriptionQty,
                                  cartList: _cartList!, isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                                  isWalletActive: _isWalletActive, fromCart: widget.fromCart, proDiscount: proDiscount + proDeliveryDiscount,
                                  isOfflinePaymentActive: _isOfflinePaymentActive, subTotal: subTotal, couponController: couponController,
                                  taxPercent: taxPercent!, extraPackagingAmount: extraPackagingCharge,
                                  taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax!,
                                  scheduleEndsAt: scheduleEndsAt,
                                  guestNameController: guestContactPersonNameController, guestNumberController: guestContactPersonNumberController,
                                  guestEmailController: guestEmailController, guestAddressController: guestAddressController,
                                  guestStreetNumberController: guestStreetNumberController, guestHouseController: guestHouseController, guestFloorController: guestFloorController,
                                  isDiscountCalculating: isDiscountCalculating,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                })

              ],
            );
          });
          });
        }) : const CheckoutScreenShimmerView();
      }) : NotLoggedInScreen(callBack: (value) {
        initCall();
        setState(() {});
      }),
    );
  }

  static bool cartHasBogoBundle(List<CartModel>? cartList) {
    return cartList?.any((CartModel cart) => cart.isBogoBundle) ?? false;
  }

  static DateTime? bundleOfferEndsAt(List<CartModel>? cartList) {
    DateTime? endsAt;
    for(final CartModel cart in cartList ?? const <CartModel>[]) {
      final String? offerEnd = cart.bogoDetails?.offerEndDate;
      if(offerEnd == null || offerEnd.isEmpty) {
        continue;
      }
      final DateTime? parsed = DateTime.tryParse(offerEnd);
      if(parsed != null && (endsAt == null || parsed.isBefore(endsAt))) {
        endsAt = parsed;
      }
    }
    return endsAt;
  }


  static bool canOfferRepeatOrder({required Restaurant? restaurant, required bool fromCart, required List<CartModel>? cartList}) {
    if(!AuthHelper.isLoggedIn()) {
      return false;
    }
    if(restaurant == null || !(restaurant.orderSubscriptionActive ?? false) || !fromCart) {
      return false;
    }
    if(!_homeDeliveryAvailable(restaurant)) {
      return false;
    }
    return !cartHasBogoBundle(cartList);
  }


  static bool _homeDeliveryAvailable(Restaurant restaurant) {
    bool configAllowsDelivery = Get.find<SplashController>().configModel?.homeDelivery ?? true;
    bool restaurantAllowsDelivery = restaurant.delivery ?? true;
    return configAllowsDelivery && restaurantAllowsDelivery;
  }

  double? _getMaxCodOrderAmount({required Restaurant? restaurant, required CheckoutController checkoutController, required double orderAmount}) {
    extraChargeForToolTip = restaurant!.selfDeliverySystem == 0 && checkoutController.extraCharge != null ? checkoutController.extraCharge! : 0;
    badWeatherChargeForToolTip = checkoutController.surgeAmount;

    return checkoutController.getCalculatedDeliveryCharge(
      restaurant: restaurant,
      returnMaxCodOrderAmount: true,
      orderAmount: orderAmount,
    );
  }

  double _calculatePrice(List<CartModel>? cartList) {
    double price = 0;
    double variationPrice = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {

        if(cartModel.isBogoBundle) {
          price += cartModel.bogoDetails!.totalPrice;
          continue;
        }

        price = price + (cartModel.product!.price! * cartModel.quantity!);

        for(int index = 0; index< cartModel.product!.variations!.length; index++) {
          for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
            if(cartModel.variations![index][i]!) {
              variationPrice += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
            }
          }
        }
      }
    }
    return PriceConverter.toFixed(price + variationPrice);
  }

  double _calculateAddonsPrice(List<CartModel>? cartList) {
    double addonPrice = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        if(cartModel.isBogoBundle) {
          continue;
        }

        List<AddOns> addOnList = [];
        for (var addOnId in cartModel.addOnIds!) {
          for (AddOns addOns in cartModel.product!.addOns!) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          addonPrice = addonPrice + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
        }
      }
    }
    return PriceConverter.toFixed(addonPrice);
  }


  double _calculateDiscountPrice({List<CartModel>? cartList, required double price, required double addOns}) {
    final double itemDiscount = _calculateItemDiscount(cartList);
    return PriceConverter.toFixed(itemDiscount + _appliedStoreDiscount(itemDiscount: itemDiscount, price: price, addOns: addOns));
  }

  double _appliedStoreDiscount({required double itemDiscount, required double price, required double addOns}) {
    if(!widget.fromCart) {
      return 0;
    }
    final double discountedSubTotal = (price + addOns) - itemDiscount;
    return _serverStoreDiscount().clamp(0, discountedSubTotal > 0 ? discountedSubTotal : 0).toDouble();
  }

  double _calculateItemDiscount(List<CartModel>? cartList) {
    double discount = 0;
    if(cartList == null) {
      return discount;
    }
    for (var cartModel in cartList) {
      if(cartModel.isBogoBundle) {
        continue;
      }

      double? dis = cartModel.product!.discount;
      String? disType = cartModel.product!.discountType;

      discount += ((cartModel.product!.price! - PriceConverter.convertWithDiscount(cartModel.product!.price!, dis, disType)!) * cartModel.quantity!);
      discount += _calculateVariationDiscount(cartModel: cartModel, discount: dis, discountType: disType);
    }
    return discount;
  }

  double _serverStoreDiscount() => _storeDiscountEligibility?.discountAmount ?? 0;

  DiscountEligibilityModel? get _storeDiscountEligibility {
    if(widget.restaurantId == null) {
      return null;
    }
    final DiscountEligibilityModel? eligibility = Get.find<CartController>().discountEligibility(widget.restaurantId!);
    return (eligibility != null && eligibility.isQualified) ? eligibility : null;
  }

  bool get _isDiscountCalculating =>
      widget.fromCart && widget.restaurantId != null
      && !Get.find<CartController>().isDiscountEligibilityResolved(widget.restaurantId!);

  double _calculateVariationDiscount({required CartModel? cartModel, required double? discount, required String? discountType}) {
    double discountedTotal = 0;
    double grossTotal = 0;
    if(cartModel != null && !cartModel.isBogoBundle) {
      for(int index = 0; index< cartModel.product!.variations!.length; index++) {
        for(int i=0; i<cartModel.product!.variations![index].variationValues!.length; i++) {
          if(cartModel.variations![index][i]!) {
            discountedTotal += (PriceConverter.convertWithDiscount(cartModel.product!.variations![index].variationValues![i].optionPrice!, discount, discountType, isVariation: true)! * cartModel.quantity!);
            grossTotal += (cartModel.product!.variations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }

    return grossTotal - discountedTotal;
  }

  double _calculateSubTotal(double price, double addOnsPrice) {
    double subTotal = price + addOnsPrice;
    return PriceConverter.toFixed(subTotal);
  }

  double _calculateOrderAmount(double subTotal, double discount, double couponDiscount, double referralDiscount) {
    double orderAmount = subTotal - discount - couponDiscount - referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  int _getSubscriptionQty({required CheckoutController checkoutController, required bool restaurantSubscriptionActive}) {
    int subscriptionQty = checkoutController.subscriptionOrder ? 0 : 1;
    if(restaurantSubscriptionActive){
      if(checkoutController.subscriptionOrder && checkoutController.subscriptionRange != null) {
        if(checkoutController.subscriptionType == 'weekly') {
          List<int> weekDays = [];
          for(int index=0; index<checkoutController.selectedDays.length; index++) {
            if(checkoutController.selectedDays[index] != null) {
              weekDays.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getWeekDaysCount(checkoutController.subscriptionRange!, weekDays);
        }else if(checkoutController.subscriptionType == 'monthly') {
          List<int> days = [];
          for(int index=0; index<checkoutController.selectedDays.length; index++) {
            if(checkoutController.selectedDays[index] != null) {
              days.add(index + 1);
            }
          }
          subscriptionQty = DateConverter.getMonthDaysCount(checkoutController.subscriptionRange!, days);
        }else {
          subscriptionQty = checkoutController.subscriptionRange!.duration.inDays + 1;
        }
      }
    }
    return subscriptionQty;
  }

  double _calculateTotal(double subTotal, double deliveryCharge, double discount, double couponDiscount,
      bool taxIncluded, double tax, bool showTips, double tips, double additionalCharge, double extraPackagingCharge,
      [double saverDeliveryAdjustment = 0, double proDiscount = 0, double proDeliveryDiscount = 0]) {

    double total = subTotal + deliveryCharge - discount - couponDiscount + (taxIncluded ? 0 : tax)
        + (showTips ? tips : 0) + additionalCharge + extraPackagingCharge + saverDeliveryAdjustment
        - proDiscount - proDeliveryDiscount;

    return PriceConverter.toFixed(total);
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    if(((checkoutController.restaurant != null && checkoutController.restaurant!.isExtraPackagingActive! && !checkoutController.restaurant!.extraPackagingStatusIsMandatory! && Get.find<CartController>().needExtraPackage)
        || (checkoutController.restaurant != null && checkoutController.restaurant!.isExtraPackagingActive! && checkoutController.restaurant!.extraPackagingStatusIsMandatory!)) && checkoutController.orderType != 'dine_in') {
      return checkoutController.restaurant?.extraPackagingAmount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(double subTotal, double discount, double couponDiscount, bool isSubscriptionOrder) {
    double referralDiscount = 0;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount! && !isSubscriptionOrder) {
      if (Get.find<ProfileController>().userInfoModel!.discountAmountType! == "percentage") {
        referralDiscount = (Get.find<ProfileController>().userInfoModel!.discountAmount! / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = Get.find<ProfileController>().userInfoModel!.discountAmount!;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }


  void _showCashBackSnackBarIfNeeded(CheckoutController checkoutController) {
    SummaryCashbackModel? cashBack = checkoutController.summaryCashback;
    double cashBackAmount = cashBack?.calculatedAmount ?? 0;

    if(cashBackAmount <= 0 || cashBackAmount == _announcedCashBackAmount) {
      return;
    }
    _announcedCashBackAmount = cashBackAmount;

    String cashBackType = cashBack?.cashbackType ?? '';
    String cashBackForView = cashBackType == 'amount'
        ? PriceConverter.convertPrice(cashBackAmount)
        : '${(cashBack?.cashbackAmount ?? 0).toStringAsFixed(0)}%';

    checkoutController.makeFalseCashBackFirstTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar('${'you_will_get'.tr} $cashBackForView ${'cash_back_after_completing_order'.tr}', isError: false);
    });
  }

}
