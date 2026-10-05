import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class TimeSlotSection extends StatelessWidget {
  final bool fromCart;
  final CheckoutController checkoutController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final JustTheController tooltipController2;
  const TimeSlotSection({super.key, required this.fromCart, required this.checkoutController, required this.tomorrowClosed, required this.todayClosed, required this.tooltipController2, });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool isDineIn = checkoutController.orderType == 'dine_in';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      (!isGuestLoggedIn && fromCart && !checkoutController.subscriptionOrder && checkoutController.restaurant!.scheduleOrder! && !isDineIn) 
      ?  Container(
          color: context.surfaceContainer,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('preference_time'.tr, style: context.heading.defaultSize.strong),
              const SizedBox(width: Dimensions.padding2xSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController2,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('schedule_time_tool_tip'.tr,style: context.body.defaultSize.regular.overrideWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController2.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSmall),

            InkWell(
            onTap: (){
              if(ResponsiveHelper.isDesktop(context)){
                if(checkoutController.canShowTimeSlot){
                  checkoutController.showHideTimeSlot();
                } else {
                  checkoutController.showHideTimeSlot();
                }
              }else{
                showModalBottomSheet(
                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (con) => TimeSlotBottomSheet(
                    tomorrowClosed: tomorrowClosed,
                    todayClosed: todayClosed,
                    restaurant: checkoutController.restaurant!,
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.outline, width: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingLarge),

                Builder(
                  builder: (context) {
                    return Expanded(child: Text(
                      (checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed) || (checkoutController.selectedDateSlot == 2 && checkoutController.customDateRestaurantClose)
                          ? 'restaurant_is_closed'.tr
                          : checkoutController.preferableTime.isNotEmpty ? checkoutController.preferableTime
                          : (Get.find<SplashController>().configModel!.instantOrder! && checkoutController.restaurant!.instantOrder!) ? 'now'.tr : 'select_preference_time'.tr,
                      style: context.subHeading.defaultSize.regular.overrideWith(
                          color: (checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed) || (checkoutController.selectedDateSlot == 2 && checkoutController.customDateRestaurantClose)
                              ? context.error
                              : context.textBaseDefault),
                    ));
                  }
                ),

                Icon(Icons.access_time_filled_outlined, color: context.primary),
                const SizedBox(width: Dimensions.paddingSmall),
              ]),
            ),
          ),

            isDesktop && checkoutController.canShowTimeSlot ? Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingLarge),
            child: TimeSlotBottomSheet(tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, restaurant: checkoutController.restaurant!),
          ) : const SizedBox(),

            const SizedBox(height: Dimensions.paddingLarge),
          ]),
        ) : const SizedBox(),

      SizedBox(height: (fromCart && !checkoutController.subscriptionOrder && checkoutController.restaurant!.scheduleOrder! && !isDineIn) ? Dimensions.paddingSmall : 0),

    ]);
  }

  Widget tobView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? context.subHeading.defaultSize.strong.overrideWith(color: context.primary) : context.subHeading.defaultSize.medium),
          Divider(color: isSelected ? context.primary : null, thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }
}
