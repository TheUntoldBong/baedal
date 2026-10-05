import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomDatePicker extends StatelessWidget {
  final String hint;
  final DateTimeRange? range;
  final Function(DateTimeRange range) onDatePicked;
  final bool isPause;
  const CustomDatePicker({super.key, required this.hint, required this.range, required this.onDatePicked, this.isPause = false});

  static Future<void> pickRange(BuildContext context, {
    required DateTimeRange? range, required bool isPause, required Function(DateTimeRange range) onDatePicked,
  }) async {
    DateTimeRange? pickedRange = await showModalBottomSheet<DateTimeRange?>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) {
        PickerDateRange? selectedRange;

        final firstDate = isPause ? DateTime.now().add(Duration(days: 1)) : DateTime.now();

        final lastDate = isPause
            ? DateTime.parse(Get.find<OrderController>().trackModel!.subscription!.endAt!)
            : DateTime.now().add(const Duration(days: 365));

        bool isDesktop = ResponsiveHelper.isDesktop(context);

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: context.height * 0.85),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusDefault)
                : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.padding2xSmall, right: Dimensions.padding2xSmall),
                  child: Align( alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: context.surfaceContainer,
                        child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                    child: Text('select_date_range'.tr, style: context.heading.extraLarge.strong.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                    child: Text(
                      'choose_your_preferable_date_range'.tr,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium).copyWith(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingDefault),
                  SfDateRangePicker(
                    minDate: firstDate,
                    maxDate: lastDate,
                    selectionMode: DateRangePickerSelectionMode.range,
                    cancelText: 'cancel'.tr,
                    confirmText: 'submit'.tr,
                    backgroundColor: context.surfaceContainer,
                    headerStyle: DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: context.heading.large.strong,
                      backgroundColor: context.surfaceContainer,
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      dayFormat: 'EEEEE',
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                      ),
                    ),
                    selectionColor: context.primary,
                    startRangeSelectionColor: context.primary,
                    endRangeSelectionColor: context.primary,
                    rangeSelectionColor: context.primary.withValues(alpha: 0.15),
                    selectionTextStyle: context.heading.defaultSize.strong.overrideWith(color: Colors.white),
                    selectionShape: DateRangePickerSelectionShape.rectangle,
                    selectionRadius: 10,
                    showActionButtons: true,
                    onSelectionChanged: (args) {
                      if (args.value is PickerDateRange) {
                        selectedRange = args.value;
                        debugPrint(selectedRange.toString());
                      }
                    },
                    onSubmit: (val) {
                      if (val is PickerDateRange) {
                        final start = val.startDate!;
                        final end = val.endDate ?? val.startDate!;
                        Navigator.pop(context, DateTimeRange(start: start, end: end));
                      } else {
                        Navigator.pop(context, null);
                      }
                    },
                    onCancel: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ]),
                SizedBox(height: Dimensions.paddingDefault),
              ],
            ),
          ),
        );
      },
    );

    if(pickedRange != null) {
      if(!isPause && pickedRange.start == pickedRange.end){
        showCustomSnackBar('start_date_and_end_date_can_not_be_same_for_subscription_order'.tr);
      }else{
        onDatePicked(pickedRange);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => pickRange(context, range: range, isPause: isPause, onDatePicked: onDatePicked),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          border: Border.all(color: context.primary, width: 0.3),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              range != null ? DateConverter.dateRangeToDate(range!) : hint,
              style: context.body.defaultSize.regular,
            ),
          ),

          Icon(Icons.date_range_rounded, size: 24, color: range != null ? context.primary : context.iconBaseMedium),
        ]),
      ),
    );
  }
}
