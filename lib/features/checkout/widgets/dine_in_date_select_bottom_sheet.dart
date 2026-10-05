import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/date_month_body_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DineInDateSelectBottomSheet extends StatefulWidget {
  final Restaurant restaurant;
  const DineInDateSelectBottomSheet({super.key, required this.restaurant});

  @override
  State<DineInDateSelectBottomSheet> createState() => _DineInDateSelectBottomSheetState();
}

class _DineInDateSelectBottomSheetState extends State<DineInDateSelectBottomSheet> {

  @override
  Widget build(BuildContext context) {

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Container(
        width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusExtraSmall) : const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          !ResponsiveHelper.isDesktop(context) ? Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: context.bgNeutralLight,
              borderRadius: BorderRadius.circular(5),
            ),
          ) : Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.clear))),
          SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : 0),

          Text('select_your_date'.tr, style: context.heading.large.medium, textAlign: TextAlign.center),
          SizedBox(height: Dimensions.paddingLarge),

          SfDateRangePicker(
            backgroundColor: context.surfaceContainer,
            headerStyle: DateRangePickerHeaderStyle(
              textAlign: TextAlign.start,
              textStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
              backgroundColor: context.surfaceContainer,
            ),

            initialSelectedDate: checkoutController.selectedDineInDate,
            selectionShape: DateRangePickerSelectionShape.circle,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              DateTime selectedDate = DateConverter.dateStringToDate(args.value.toString());

              bool isClose = checkRestaurantClose(selectedDate);
              if(isClose) {
                showCustomSnackBar('restaurant_is_close_on_your_selected_date'.tr);
              } else {
                checkoutController.setSelectedDineInDate(selectedDate);
              }
            },
              showNavigationArrow: true,
              selectableDayPredicate: (DateTime val) {
              return _canSelectDate(duration: widget.restaurant.dineInBookingDuration!, timeFormat: widget.restaurant.dineInBookingDurationTimeFormat, value: val);
            }
          ),

          SizedBox(height: Dimensions.paddingLarge),

          CustomButtonWidget(
            buttonText: 'done'.tr,
            onPressed: (){
              Get.back();
            },
          ),

        ]),
      );
    });
  }
}

bool checkRestaurantClose(DateTime selectCustomDate) {

  Get.find<CheckoutController>().updateDateSlot(selectCustomDate, true);

  bool isClose = Get.find<RestaurantController>().isRestaurantClosed(
    selectCustomDate, Get.find<CheckoutController>().restaurant!.active!,
    Get.find<CheckoutController>().restaurant!.schedules,
  );
  return isClose;
}

bool _canSelectDate({required int duration, required String? timeFormat, required DateTime value}) {
  List<DateMonthBodyModel> date = [];
  for(int i=0; i<100; i++){
    date.add(DateMonthBodyModel(date: DateTime.now().add(Duration(days: i)).day, month: DateTime.now().add(Duration(days: i)).month));
  }
  bool status = false;
  for(int i=0; i<date.length; i++){
    if(i > (duration-1) && timeFormat == 'day' && date[i].month == value.month && date[i].date == value.day){
      status = true;
      break;
    } else if(timeFormat != 'day' && date[i].month == value.month && date[i].date == value.day) {
      status = true;
      break;
    } else {
      status = false;
    }
  }
  return status;
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}