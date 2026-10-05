import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/contact_info_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/coupon_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_instruction_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_man_tips_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_option_button.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/dine_in_schedule_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/guest_login_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/order_type_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_section.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/saver_delivery_time_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/schedule_info_card.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/subscription_type_button.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/subscription_view.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class TopSectionWidget extends StatelessWidget {
  final double charge;
  final double deliveryCharge;
  final double originalDeliveryCharge;
  final LocationController locationController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final double price;
  final double discount;
  final double addOns;
  final bool restaurantSubscriptionActive;

  final DateTime? scheduleEndsAt;
  final bool showTips;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final double total;
  final JustTheController tooltipController3;
  final JustTheController tooltipController2;
  final JustTheController loginTooltipController;
  final Function() callBack;
  final String deliveryChargeForView;
  final JustTheController deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final ScrollController deliveryOptionScrollController;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final TextEditingController guestAddressController;
  final TextEditingController guestStreetNumberController;
  final TextEditingController guestHouseController;
  final TextEditingController guestFloorController;
  final FocusNode guestNameNode;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final FocusNode guestAddressNode;
  final FocusNode guestStreetNumberNode;
  final FocusNode guestHouseNode;
  final FocusNode guestFloorNode;

  const TopSectionWidget({
    super.key, required this.charge, required this.deliveryCharge, required this.originalDeliveryCharge, required this.locationController,
    required this.tomorrowClosed, required this.todayClosed, required this.price, required this.discount,
    required this.addOns, required this.restaurantSubscriptionActive, this.scheduleEndsAt, required this.showTips,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive,
    required this.fromCart, required this.total, required this.tooltipController3, required this.tooltipController2,
    required this.guestNameController, required this.guestNumberController, required this.guestNumberNode,
    required this.isOfflinePaymentActive, required this.guestEmailController, required this.guestEmailNode,
    required this.loginTooltipController, required this.callBack, required this.deliveryChargeForView,
    required this.deliveryFeeTooltipController, required this.badWeatherCharge, required this.extraChargeForToolTip, required this.deliveryOptionScrollController,
    required this.guestAddressController, required this.guestStreetNumberController, required this.guestHouseController, required this.guestFloorController,
    required this.guestNameNode, required this.guestAddressNode, required this.guestStreetNumberNode, required this.guestHouseNode, required this.guestFloorNode});

  static bool canScheduleDeliveryFor(CheckoutController checkoutController) {
    return checkoutController.orderType == 'delivery'
        && !checkoutController.subscriptionOrder
        && (checkoutController.restaurant?.scheduleOrder ?? false);
  }

  @override
  Widget build(BuildContext context) {
    bool takeAway = false;
    bool dineIn = false;
    bool homeDelivery = false;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      takeAway = (checkoutController.orderType == 'take_away');
      dineIn = (checkoutController.orderType == 'dine_in');
      homeDelivery = (checkoutController.orderType == 'delivery');
      bool hasScheduledDeliveryTime = checkoutController.preferableTime.isNotEmpty && checkoutController.preferableTime != 'instant_delivery'.tr;
      final bool canShowSaverOptions = checkoutController.restaurant != null
          && checkoutController.restaurant!.selfDeliverySystem != 1
          && SaverDeliveryTimeWidget.canShow(checkoutController, deliveryCharge, originalDeliveryCharge);
      final bool canScheduleDelivery = canScheduleDeliveryFor(checkoutController);
      if(homeDelivery && hasScheduledDeliveryTime && checkoutController.saverDeliveryType != 'standard') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(checkoutController.saverDeliveryType != 'standard') {
            checkoutController.setSaverDeliveryType('standard');
          }
        });
      }
      return Column(children: [

        SizedBox(height: isGuestLoggedIn && !isDesktop ? Dimensions.paddingSmall : 0),

        isGuestLoggedIn ? GuestLoginWidget(
          loginTooltipController: loginTooltipController,
          onTap: () async {
            await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))!.then((value) {
              if(AuthHelper.isLoggedIn()) {
                callBack();
              }
            });
          },
        ) : const SizedBox(),
        SizedBox(height: isGuestLoggedIn ? Dimensions.paddingSmall : 0),

        SizedBox(height: !isDesktop && isCashOnDeliveryActive && restaurantSubscriptionActive ? Dimensions.paddingSmall : 0),

        isCashOnDeliveryActive && restaurantSubscriptionActive ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(children: [
                Expanded(child: OrderTypeWidget(
                  title: 'regular_order'.tr,
                  isSelected: !checkoutController.subscriptionOrder,
                  onTap: () {
                    checkoutController.setSubscription(false);
                    if(checkoutController.isPartialPay){
                      checkoutController.changePartialPayment();
                    } else {
                      checkoutController.setPaymentMethod(-1);
                    }
                    checkoutController.updateTips(
                      checkoutController.getDmTipIndex().isNotEmpty ? int.parse(checkoutController.getDmTipIndex()) : 1, notify: false,
                    );
                  },
                )),

                SizedBox(width: Dimensions.padding2xSmall),
                    
                Expanded(child: OrderTypeWidget(
                  title: 'repeat_order'.tr,
                  isSelected: checkoutController.subscriptionOrder,
                  onTap: () {
                    checkoutController.setSubscription(true);
                    checkoutController.addTips(0);
                    if(checkoutController.isPartialPay){
                      checkoutController.changePartialPayment();
                    } else {
                      checkoutController.setPaymentMethod(-1);
                    }
                  },
                )),
              
              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),
        ]) : const SizedBox(),
        SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSmall : isCashOnDeliveryActive && restaurantSubscriptionActive ? Dimensions.paddingSmall : 0),

        checkoutController.restaurant != null ? Container(
          width: context.width,
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: context.outline)
          ),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeLarge),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault,),
              child: Text(!checkoutController.subscriptionOrder ? 'delivery_option'.tr : 'repeat_order_type'.tr, style: context.subHeading.large.strong),
            ),
            const SizedBox(height: Dimensions.paddingSmall),

            checkoutController.subscriptionOrder ? SingleChildScrollView(controller: deliveryOptionScrollController, scrollDirection: Axis.horizontal, child: Row(children: [
              SizedBox(width: Dimensions.paddingDefault),
              for(int index = 0; index < SubscriptionView.typeList.length; index++) ...[
                SubscriptionTypeButton(checkoutController: checkoutController, type: SubscriptionView.typeList[index], index: index),
                SizedBox(width: index != SubscriptionView.typeList.length - 1 ? Dimensions.paddingDefault : Dimensions.paddingDefault),
              ],
            ])) : SingleChildScrollView(controller: deliveryOptionScrollController, scrollDirection: Axis.horizontal, child: Row(children: [
              SizedBox(width: Dimensions.paddingDefault),
              (Get.find<SplashController>().configModel!.homeDelivery! && checkoutController.restaurant!.delivery!) ? DeliveryOptionButton(
                value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                isFree: checkoutController.restaurant!.freeDelivery, total: total,
                chargeForView: deliveryChargeForView, deliveryFeeTooltipController: deliveryFeeTooltipController,
                badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
              ) : const SizedBox(),
              SizedBox(width: (Get.find<SplashController>().configModel!.homeDelivery! && checkoutController.restaurant!.delivery!) ? Dimensions.paddingDefault : 0),

              (Get.find<SplashController>().configModel!.takeAway! && checkoutController.restaurant!.takeAway! && !checkoutController.subscriptionOrder) ? DeliveryOptionButton(
                value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true, total: total,
                badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip,
              ) : const SizedBox(),
              SizedBox(width: (Get.find<SplashController>().configModel!.takeAway! && checkoutController.restaurant!.takeAway! && !checkoutController.subscriptionOrder) ? Dimensions.paddingDefault : 0),

              (Get.find<SplashController>().configModel!.dineInOrderOption! && checkoutController.restaurant!.isActiveDineIn! && !checkoutController.subscriptionOrder) ? DeliveryOptionButton(
                value: 'dine_in', title: 'dine_in'.tr, charge: deliveryCharge, isFree: true, total: total,
                badWeatherCharge: badWeatherCharge, extraChargeForToolTip: extraChargeForToolTip, guestNameTextEditingController: guestNameController,
                guestNumberTextEditingController: guestNumberController, guestEmailController: guestEmailController,
              ) : const SizedBox(),
              SizedBox(width: Dimensions.paddingDefault),
            ])),
            SizedBox(height: Dimensions.paddingDefault),

            checkoutController.subscriptionOrder ? Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault,),
                child: SubscriptionView.dateTimeCard(context, checkoutController, checkoutController.subscriptionType ?? 'daily'),
              ),
              const SizedBox(height: Dimensions.paddingDefault),
            ]) : (canShowSaverOptions || canScheduleDelivery) ? Column(children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault,),
                padding: EdgeInsets.all(Dimensions.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  color: context.surface,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('instant_delivery'.tr, style: context.subHeading.large.strong),
                      const SizedBox(height: Dimensions.padding2xSmall),

                      Text(
                        'you_can_have_it_delivered_now_or_pick_a_time_for_scheduled_delivery'.tr,
                        style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                      ),
                    ])),
                    const SizedBox(width: Dimensions.paddingSmall),

                    InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)) {
                          checkoutController.showHideTimeSlot();
                        } else {
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (con) => TimeSlotBottomSheet(
                              tomorrowClosed: tomorrowClosed,
                              todayClosed: todayClosed,
                              restaurant: checkoutController.restaurant!,
                              scheduleEndsAt: scheduleEndsAt,
                            ),
                          );
                        }
                      },
                      child: CustomAssetImageWidget(Images.editBtn, width: 20),
                    ),
                  ]),

                  if(hasScheduledDeliveryTime) Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
                    child: _scheduledTimeValue(context, checkoutController),
                  ) else if(canShowSaverOptions) ...[
                    const SizedBox(height: Dimensions.paddingDefault),
                    Divider(color: context.surfaceContainerHigh),
                    SaverDeliveryTimeWidget(
                      checkoutController: checkoutController,
                      deliveryCharge: deliveryCharge,
                      originalDeliveryCharge: originalDeliveryCharge,
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: Dimensions.paddingDefault),
            ]) : (takeAway || dineIn) ? Column(children: [
              _pickupScheduleCard(context, checkoutController, dineIn, isDesktop),
              const SizedBox(height: Dimensions.paddingDefault),
            ]) : const SizedBox(),
            DeliverySection(
              checkoutController: checkoutController, locationController: locationController,
              guestNameController: guestNameController, guestNumberController: guestNumberController, guestEmailController: guestEmailController,
              guestAddressController: guestAddressController, guestStreetNumberController: guestStreetNumberController,
              guestStreetNumberNode: guestStreetNumberNode, guestFloorController: guestFloorController, guestHouseController: guestHouseController,
              guestNameNode: guestNameNode, guestNumberNode: guestNumberNode, guestEmailNode: guestEmailNode,
              guestAddressNode: guestAddressNode, guestFloorNode: guestFloorNode, guestHouseNode: guestHouseNode,
            )
          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingLarge),
        ContactInfoWidget(
          checkoutController: checkoutController, guestNameController: guestNameController,
          guestNumberController: guestNumberController, guestNameNode: guestNameNode, guestNumberNode: guestNumberNode,
          guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
        ),

        const SizedBox(height: Dimensions.paddingLarge),
        if(takeAway || dineIn) Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: 'additional_note'.tr,
                  style: context.subHeading.defaultSize.regular,
                  children: [
                    TextSpan(
                      text: ' (${ 'optional'.tr })',
                      style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: CustomTextFieldWidget(
              controller: checkoutController.noteController,
              hintText: 'share_any_specific_delivery_details_here'.tr,
              showLabelText: false,
              maxLines: 2,
              inputType: TextInputType.multiline,
              inputAction: TextInputAction.done,
              capitalization: TextCapitalization.sentences,
            ),
          ),
         const SizedBox(height: Dimensions.paddingLarge),
        ]),

        if(homeDelivery) Column( children: [
          const DeliveryInstructionSection(),
          SizedBox(height: Dimensions.paddingDefault),
          (!checkoutController.subscriptionOrder && !takeAway && !dineIn && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Divider(thickness: 2) : SizedBox.shrink(),
          (!checkoutController.subscriptionOrder && !takeAway && !dineIn && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ?SizedBox(height: Dimensions.paddingDefault) : SizedBox.shrink(),

          DeliveryManTipsSection(
            takeAway: takeAway, tooltipController3: tooltipController3, checkoutController: checkoutController,
            totalPrice: total, onTotalChange: (double price) => total + price,
          ),
        ]),

        PaymentSection(
          isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
          isWalletActive: isWalletActive, total: total, checkoutController: checkoutController, isOfflinePaymentActive: isOfflinePaymentActive,
        ),
       
        !ResponsiveHelper.isDesktop(context) && !isGuestLoggedIn ? Column(children: [
          SizedBox(height: Dimensions.paddingDefault),
          Divider(thickness: 2),
          SizedBox(height: Dimensions.paddingDefault),
          CouponSection(
            charge: charge, checkoutController: checkoutController, price: price,
            discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, total: total,
          )
        ]) : const SizedBox(),
      ]);
    });
  }

  Widget _pickupScheduleCard(BuildContext context, CheckoutController checkoutController, bool isDineIn, bool isDesktop) {
    Widget valueDisplay;
    bool hasValue;

    if(isDineIn) {
      bool hasSchedule = checkoutController.selectedDineInDate != null && checkoutController.estimateDineInTime != null;
      hasValue = hasSchedule;
      if(hasSchedule) {
        String dayName = DateConverter.isToday(checkoutController.selectedDineInDate!) ? 'today'.tr
            : DateConverter.isTomorrow(checkoutController.selectedDineInDate!) ? 'tomorrow'.tr
            : DateFormat('dd MMM').format(checkoutController.selectedDineInDate!);

        valueDisplay = RichText(text: TextSpan(children: [
          TextSpan(
            text: '$dayName, ${checkoutController.estimateDineInTime} ',
            style: context.subHeading.defaultSize.strong.copyWith(color: Colors.blueAccent),
          ),
          TextSpan(
            text: '(${'estd'.tr})',
            style: context.subHeading.defaultSize.regular.overrideWith(color: Colors.blueAccent),
          ),
        ]));
      } else {
        valueDisplay = SizedBox.shrink();
      }
    } else {
      bool isClosed = (checkoutController.selectedDateSlot == 0 && todayClosed)
          || (checkoutController.selectedDateSlot == 1 && tomorrowClosed)
          || (checkoutController.selectedDateSlot == 2 && checkoutController.customDateRestaurantClose);

      bool hasPicked = checkoutController.preferableTime.isNotEmpty;
      hasValue = isClosed || hasPicked;

      if(!hasValue) {
        valueDisplay = SizedBox.shrink();
      } else if(isClosed) {
        valueDisplay = Text(
          'restaurant_is_closed'.tr,
          style: context.subHeading.large.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.error),
        );
      } else {
        valueDisplay = _scheduledTimeValue( context, checkoutController);
      }
    }

    return ScheduleInfoCard(
      isDesktop: isDesktop,
      title: isDineIn ? 'arrival_time'.tr : 'pickup_your_food'.tr,
      subtitle: isDineIn ? 'you_must_arrive_at_the_restaurant_by'.tr : 'you_must_collect_your_food_from_restaurant_at'.tr,
      valueDisplay: valueDisplay,
      hasValue: hasValue,
      onEditTap: () {
        if(isDineIn) {
          showCustomBottomSheet(child: DineInScheduleBottomSheet(restaurant: checkoutController.restaurant!, scheduleEndsAt: scheduleEndsAt));
        } else {
          showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (con) => TimeSlotBottomSheet(
              tomorrowClosed: tomorrowClosed,
              todayClosed: todayClosed,
              restaurant: checkoutController.restaurant!,
              scheduleEndsAt: scheduleEndsAt,
            ),
          );
        }
      },
    );
  }

  Widget _scheduledTimeValue(BuildContext context, CheckoutController checkoutController) {
    String dateLabel = checkoutController.selectedDateSlot == 0 ? 'today'.tr
        : checkoutController.selectedDateSlot == 1 ? 'tomorrow'.tr
        : DateFormat('dd MMM').format(checkoutController.selectedCustomDate ?? DateTime.now());

    return RichText(text: TextSpan(children: [
      TextSpan(
        text: '$dateLabel, ${checkoutController.preferableTime} ',
        style: context.subHeading.defaultSize.strong.overrideWith(color: Colors.blueAccent),
      ),
      TextSpan(
        text: '(${'estd'.tr})',
        style: context.subHeading.defaultSize.regular.overrideWith(color: Colors.blueAccent),
      ),
    ]));
  }
}
