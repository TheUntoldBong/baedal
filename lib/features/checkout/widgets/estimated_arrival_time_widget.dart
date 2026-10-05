import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/dine_in_date_select_bottom_sheet.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/dine_in_schedule_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class EstimatedArrivalTimeWidget extends StatefulWidget {
  final CheckoutController checkoutController;
  const EstimatedArrivalTimeWidget({super.key, required this.checkoutController});

  @override
  State<EstimatedArrivalTimeWidget> createState() => _EstimatedArrivalTimeWidgetState();
}

class _EstimatedArrivalTimeWidgetState extends State<EstimatedArrivalTimeWidget> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = widget.checkoutController;
      if (controller.orderType == 'dine_in' && controller.selectedDineInDate != null &&
          controller.estimateDineInTime == null && controller.restaurant != null) {
        _autoSetInitialTime(controller);
      }
    });
  }

  void _autoSetInitialTime(CheckoutController controller) {
    if (controller.timeSlots == null || controller.timeSlots!.isEmpty) return;

    final duration = controller.restaurant!.dineInBookingDuration ?? 0;
    final format = controller.restaurant!.dineInBookingDurationTimeFormat ?? 'min';

    final initialTime = DineInScheduleHelper.addHours(TimeOfDay.now(), duration, format);
    final datetime = DateConverter.formattingDineInDateTime(initialTime, controller.selectedDineInDate!);

    final (bool inTime, String? message) = DineInScheduleHelper.isInDineInSchedule(controller.timeSlots!, datetime, initialTime, format, duration);

    if (inTime) {
      controller.setEstimateDineInTime(initialTime.format(Get.context!));
      controller.setOrderPlaceDineInDateTime(datetime);
    } else {
      if (kDebugMode) {
        print('Auto-set initial time failed: $message');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutController = widget.checkoutController;

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isDineIn = (checkoutController.orderType == 'dine_in');
    String? dineInDate;

    if(isDineIn && checkoutController.selectedDineInDate != null) {
      String dayName = DateConverter.isToday(checkoutController.selectedDineInDate!) ? 'today'.tr
          : DateConverter.isTomorrow(checkoutController.selectedDineInDate!) ? 'tomorrow'.tr : 'custom'.tr;
      dineInDate = '$dayName (${DateConverter.containTAndZToUTCFormat(checkoutController.selectedDineInDate!.toString())})';
    }

    return isDineIn ? Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('estimated_arrival_time'.tr, style: context.subHeading.defaultSize.medium),
        const SizedBox(height: Dimensions.paddingLarge),

        InkWell(
          onTap: () {
            if(ResponsiveHelper.isDesktop(context)) {
              Get.dialog(Dialog(child: DineInDateSelectBottomSheet(restaurant: checkoutController.restaurant!)));
            } else {
              showCustomBottomSheet(child: DineInDateSelectBottomSheet(restaurant: checkoutController.restaurant!));
            }
          },
          child: Stack(clipBehavior: Clip.none, children: [

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.outline, width: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingLarge),

                Expanded(
                  child: Text(checkoutController.selectedDineInDate != null ? dineInDate! : 'select_date'.tr, style: context.body.defaultSize.regular),
                ),

                Icon(Icons.calendar_today, color: context.iconBaseMedium),
                const SizedBox(width: Dimensions.paddingSmall),
              ]),
            ),

            Positioned(
              top: -15, left: 10,
              child: checkoutController.selectedDineInDate != null ? Container(
                color: context.surfaceContainer,
                padding: EdgeInsets.all(5),
                child: Text('select_date'.tr, style: context.body.defaultSize.regular),
              ) : const SizedBox(),
            )

          ]),
        ),
        SizedBox(height: Dimensions.paddingLarge),

        InkWell(
          onTap: () async {

            if(checkoutController.selectedDineInDate == null) {
              showCustomSnackBar('please_select_dine_in_date_first'.tr);
            } else {

              TimeOfDay time = DineInScheduleHelper.addHours(TimeOfDay.now(), checkoutController.restaurant!.dineInBookingDuration!, checkoutController.restaurant!.dineInBookingDurationTimeFormat!);

              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: time,
              );

              if (pickedTime != null && pickedTime != TimeOfDay.now()) {

                DateTime datetime = DateConverter.formattingDineInDateTime(pickedTime, checkoutController.selectedDineInDate!);

                final (bool inTime, String? message) = DineInScheduleHelper.isInDineInSchedule(checkoutController.timeSlots!, datetime, pickedTime, checkoutController.restaurant!.dineInBookingDurationTimeFormat!, checkoutController.restaurant!.dineInBookingDuration!);

                if(inTime) {
                  checkoutController.setEstimateDineInTime(pickedTime.format(Get.context!));
                  checkoutController.setOrderPlaceDineInDateTime(datetime);
                } else {
                  showCustomSnackBar(message ?? 'restaurant_is_close_on_your_selected_time'.tr);
                }
              } else {
                if (kDebugMode) {
                  print("No time selected or picker canceled");
                }
              }
            }
          },
          child: Stack(clipBehavior: Clip.none, children: [

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.outline, width: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingLarge),

                Expanded(
                  child: Text(checkoutController.estimateDineInTime ?? 'select_time'.tr, style: context.body.defaultSize.regular),
                ),

                Icon(Icons.watch, color: context.iconBaseMedium),
                const SizedBox(width: Dimensions.paddingSmall),
              ]),
            ),

            Positioned(
              top: -15, left: 10,
              child: checkoutController.estimateDineInTime != null ? Container(
                color: context.surfaceContainer,
                padding: EdgeInsets.all(5),
                child: Text('select_time'.tr, style: context.body.defaultSize.regular),
              ) : const SizedBox(),
            ),

          ]),
        ),

      ]),
    ) : const SizedBox();
  }
}
