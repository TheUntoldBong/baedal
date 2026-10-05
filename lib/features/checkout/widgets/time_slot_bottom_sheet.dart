import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/timeslote_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/date_wheel_picker.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/slot_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class TimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Restaurant restaurant;

  final DateTime? scheduleEndsAt;

  const TimeSlotBottomSheet({super.key, required this.tomorrowClosed, required this.todayClosed, required this.restaurant,
    this.scheduleEndsAt});

  static bool isDayWithinLimit(DateTime day, DateTime? limit) {
    if(limit == null) {
      return true;
    }
    return !DateTime(day.year, day.month, day.day).isAfter(DateTime(limit.year, limit.month, limit.day));
  }

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {
  bool _instanceOrder = false;
  int? selectedTimeSlotIndex;
  int selectedDateSlotIndex = 0;
  String selectedTimeSlot = '';
  DateTime? selectCustomDate;

  @override
  void initState() {
    super.initState();
    _instanceOrder = (Get.find<SplashController>().configModel!.instantOrder! && widget.restaurant.instantOrder!);

    final checkoutController = Get.find<CheckoutController>();
    selectedDateSlotIndex = checkoutController.selectedDateSlot;
    selectedTimeSlot = checkoutController.preferableTime;
    selectedTimeSlotIndex = selectedTimeSlot.isNotEmpty ? checkoutController.selectedTimeSlot : null;
    selectCustomDate = checkoutController.selectedCustomDate;

    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if(selectCustomDate != null && selectCustomDate!.isBefore(today)) {
      selectCustomDate = today;
    }

    initializeTimeSlots(true);
  }

  Future<void> initializeTimeSlots(bool willDelay) async {
    if(willDelay) {
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      selectedTimeSlotIndex = null;
      selectedTimeSlot = '';
    }

    if(selectedDateSlotIndex == 0) {
      Get.find<CheckoutController>().updateDateSlot(DateTime.now(), _instanceOrder);
      if(selectedTimeSlotIndex != null) selectedTimeSlot = _createTime(selectedTimeSlotIndex!);

    } else if (selectedDateSlotIndex == 1) {
      Get.find<CheckoutController>().updateDateSlot(DateTime.now().add(const Duration(days: 1)), true);
      if(selectedTimeSlotIndex != null) selectedTimeSlot = _createTime(selectedTimeSlotIndex!);

    } else if (selectedDateSlotIndex == 2) {
      Get.find<CheckoutController>().updateDateSlot(selectCustomDate ?? DateTime.now(), _instanceOrder);
      Get.find<CheckoutController>().setDateCloseRestaurant(Get.find<RestaurantController>().isRestaurantClosed(
        DateTime.now(), Get.find<CheckoutController>().restaurant!.active!,
        Get.find<CheckoutController>().restaurant!.schedules,
      ));
      if(selectedTimeSlotIndex != null) selectedTimeSlot = _createCustomTime(selectedTimeSlotIndex!);
    }
  }

  bool _isSlotWithinLimit(int index) {
    final DateTime? limit = widget.scheduleEndsAt;
    final List<TimeSlotModel>? slots = Get.find<CheckoutController>().timeSlots;
    if(limit == null || slots == null || index >= slots.length) {
      return true;
    }
    final DateTime? start = slots[index].startTime;
    return start == null || !start.isAfter(limit);
  }

  void _refuseSlotPastOfferEnd() {
    showCustomSnackBar('offer_ends_on_pick_earlier_time'.trParams({
      'date': DateConverter.dateTimeStringToDateTime(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.scheduleEndsAt!),
      ),
    }));
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isRestaurantSelfDeliveryOn = widget.restaurant.selfDeliverySystem == 1;

    return Container(
      width: context.width,
      constraints: BoxConstraints(maxHeight: context.height, minHeight: context.height),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
         : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: GetBuilder<CheckoutController>(builder: (checkoutController) {
          return GetBuilder<RestaurantController>(builder: (restaurantController) {
            return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              !isDesktop ? Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingLarge, 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: Dimensions.paddingDefault),
                    Text('select_your_time_slot'.tr, style: context.heading.extraLarge.strong),
                    const SizedBox(height: Dimensions.padding2xSmall),

                    Text(
                      'choose_preferable_time_when_you_want_delivery'.tr,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ])),
                  const SizedBox(width: Dimensions.paddingSmall),

                  InkWell(
                    onTap: () => Get.back(),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: context.surfaceContainer,
                      child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ]),
              ) : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSmall),
              Divider(height: Dimensions.paddingLarge,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault+1),
                child: Row(children: [
                  Expanded(
                    child: tabView(context:context, title: 'today'.tr, isSelected: selectedDateSlotIndex == 0, onTap: (){
                      setState(() {
                        selectedDateSlotIndex = 0;
                      });
                      initializeTimeSlots(false);
                    }),
                  ),

                  if(TimeSlotBottomSheet.isDayWithinLimit(DateTime.now().add(const Duration(days: 1)), widget.scheduleEndsAt)) Expanded(
                    child: tabView(context:context, title: 'tomorrow'.tr, isSelected: selectedDateSlotIndex == 1, onTap: (){
                      setState(() {
                        selectedDateSlotIndex = 1;
                      });
                      initializeTimeSlots(false);
                    }),
                  ),

                  (isRestaurantSelfDeliveryOn ? widget.restaurant.customerDateOrderStatus! : Get.find<SplashController>().configModel!.customerDateOrderStatus!) ? Expanded(
                    child: tabView(context: context, title: 'custom_date'.tr, isSelected: selectedDateSlotIndex == 2, onTap: (){
                      setState(() {
                        selectedDateSlotIndex = 2;
                      });
                      initializeTimeSlots(false);
                    }),
                  ) : const SizedBox(),
                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault+1),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                    selectedDateSlotIndex == 2 ? Builder(builder: (context) {
                      return Column(children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: DateWheelPicker(
                            firstDate: DateTime.now(),
                            lastDate: widget.scheduleEndsAt,
                            initialDate: selectCustomDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectCustomDate = date;
                              });
                              initializeTimeSlots(false);
                            },
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingDefault),

                        (selectedDateSlotIndex == 2 && checkoutController.customDateRestaurantClose) ? Center(
                          child: Text('restaurant_is_closed'.tr ),
                        ) : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 5 : 2,
                              mainAxisSpacing: Dimensions.paddingSmall,
                              crossAxisSpacing: Dimensions.paddingSmall,
                              childAspectRatio: isDesktop ? 3.5 : 3,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: checkoutController.timeSlots!.length,
                            itemBuilder: (context, index) {
                              String time = _createCustomTime(index);
                              final bool withinLimit = _isSlotWithinLimit(index);
                              return SlotWidget(
                                title: time,
                                isSelected: selectedTimeSlotIndex == index,
                                isEnabled: withinLimit,
                                onTap: () {
                                  if(!withinLimit) {
                                    _refuseSlotPastOfferEnd();
                                    return;
                                  }
                                  setState(() {
                                    selectedTimeSlotIndex = index;
                                    selectedTimeSlot = time;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ]);
                    }) : ((selectedDateSlotIndex == 0 && widget.todayClosed) || (selectedDateSlotIndex == 1 && widget.tomorrowClosed)) ? Center(
                      child: Text('restaurant_is_closed'.tr ),
                    ) : checkoutController.timeSlots != null ? checkoutController.timeSlots!.isNotEmpty ? Container(
                      width: double.infinity,
                      padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSmall),
                      decoration: isDesktop ? null : BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 5 : 2,
                          mainAxisSpacing: Dimensions.paddingSmall,
                          crossAxisSpacing: Dimensions.paddingSmall,
                          childAspectRatio: isDesktop ? 3.5 : 3,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: checkoutController.timeSlots!.length,
                        itemBuilder: (context, index){
                          String time = _createTime(index);
                          final bool withinLimit = _isSlotWithinLimit(index);
                          return SlotWidget(
                            title: time,
                            isSelected: selectedTimeSlotIndex == index,
                            isEnabled: withinLimit,
                            onTap: () {
                              if(!withinLimit) {
                                _refuseSlotPastOfferEnd();
                                return;
                              }
                              setState(() {
                                selectedTimeSlotIndex = index;
                                selectedTimeSlot = time;
                              });
                            },
                          );
                        },
                      ),
                    ) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),
                  ]),
                ),
              ),
              SizedBox(height: isDesktop ? Dimensions.paddingDefault : 0),

              GetBuilder<CheckoutController>(builder: (checkoutController) {
               return GetBuilder<RestaurantController>(builder: (restaurantController) {
                 return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge, vertical: Dimensions.paddingSmall),
                    child: Row(children: [
                      Expanded(
                        child: CustomButtonWidget(
                          buttonText: 'cancel'.tr,
                          fontSize: Dimensions.fontSizeDefault,
                          color: context.surfaceContainerLowest,
                          textColor: Theme.of(context).textTheme.bodyLarge?.color,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Expanded(
                        child: CustomButtonWidget(
                          buttonText: 'confirm_schedule'.tr,
                          fontSize: Dimensions.fontSizeDefault,
                          onPressed: (selectedTimeSlotIndex == null || !_isSlotWithinLimit(selectedTimeSlotIndex!)) ? null : () {
                            checkoutController.updateDateSlotIndex(selectedDateSlotIndex);
                            checkoutController.updateTimeSlot(selectedTimeSlotIndex, selectedTimeSlot != 'Not Available');
                            checkoutController.setPreferenceTimeForView(selectedTimeSlot, selectedTimeSlot != 'Not Available');
                            checkoutController.showHideTimeSlot();
                            checkoutController.setCustomDate(selectCustomDate, _instanceOrder && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(selectCustomDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));

                            if(!isDesktop) Get.back();
                          },
                        ),
                      ),
                    ]),
                  );
               });
             }),
            ]);
          });
        }),
      ),
    );
  }

  Widget tabView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: context.heading.defaultSize.strong.overrideWith(color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : context.textBaseMedium),
          ),
          const SizedBox(height: Dimensions.paddingSmall),

          Divider(color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color
              : ResponsiveHelper.isDesktop(context) ? Colors.transparent : context.outlineVariant,
            thickness: isSelected ? 2 : 0, height: 0),
        ],
      ),
    );
  }

  String _createCustomTime(int index) {
    String time = (index == 0 && selectedDateSlotIndex == 2
      && Get.find<RestaurantController>().isRestaurantOpenNow(Get.find<CheckoutController>().restaurant!.active!, Get.find<CheckoutController>().restaurant!.schedules)
      && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(selectCustomDate?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
      ? _instanceOrder
      ? 'instant_delivery'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].startTime!)} '
      '- ${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].endTime!)}');
    return time;
  }

  String _createTime(int index) {
    String time = (index == 0 && selectedDateSlotIndex == 0
      && Get.find<RestaurantController>().isRestaurantOpenNow(Get.find<CheckoutController>().restaurant!.active!, Get.find<CheckoutController>().restaurant!.schedules)
      ? _instanceOrder
      ? 'instant_delivery'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].startTime!)} '
      '- ${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].endTime!)}');
    return time;
  }
}
