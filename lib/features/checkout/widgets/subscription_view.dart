import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/schedule_info_card.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/subscription_schedule_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/subscription_type_button.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionView extends StatelessWidget {
  final CheckoutController checkoutController;
  const SubscriptionView({super.key, required this.checkoutController});

  static const List<String> typeList = ['daily', 'weekly', 'monthly'];

  @override
  Widget build(BuildContext context) {
    final String currentType = checkoutController.subscriptionType ?? typeList.first;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      const SizedBox(height: Dimensions.paddingLarge),

      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('subscription_type'.tr, style: context.subHeading.defaultSize.medium),
            const SizedBox(height: Dimensions.paddingSmall),

            Row(children: [
              for(int index = 0; index < typeList.length; index++) ...[
                Expanded(child: SubscriptionTypeButton(checkoutController: checkoutController, type: typeList[index], index: index)),
                if(index != typeList.length - 1) const SizedBox(width: Dimensions.paddingSmall),
              ],
            ]),
          ]),
        ),
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),

        ResponsiveHelper.isDesktop(context) ? Expanded(child: dateTimeCard(context, checkoutController, currentType)) : const SizedBox(),
      ]),
      SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingLarge),

      !ResponsiveHelper.isDesktop(context) ? dateTimeCard(context, checkoutController, currentType) : const SizedBox(),
      const SizedBox(height: Dimensions.paddingLarge),
    ]);
  }

  static Widget dateTimeCard(BuildContext context, CheckoutController checkoutController, String type) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool hasRange = checkoutController.subscriptionRange != null;
    final bool hasDailyTime = type == 'daily' && checkoutController.selectedDays.isNotEmpty && checkoutController.selectedDays[0] != null;
    final bool hasValue = hasRange && (type != 'daily' || hasDailyTime);

    return ScheduleInfoCard(
      isDesktop: isDesktop,
      margin: EdgeInsets.zero,
      title: 'select_date_and_time'.tr,
      subtitle: 'choose_the_date_range_and_preferred_time_for_your_repeat_orders'.tr,
      hasValue: hasValue,
      valueDisplay: hasRange ? RichText(text: TextSpan(children: [
        TextSpan(
          text: DateConverter.dateRangeToDate(checkoutController.subscriptionRange!),
          style: context.subHeading.defaultSize.strong.overrideWith(color: Colors.blueAccent),
        ),
        if(hasDailyTime) TextSpan(
          text: '  ${DateConverter.dateToTimeOnly(checkoutController.selectedDays[0]!)}',
          style: context.subHeading.defaultSize.regular.overrideWith(color: Colors.blueAccent),
        ),
      ])) : const SizedBox.shrink(),
      onEditTap: () {
        if(ResponsiveHelper.isDesktop(context)) {
          Get.dialog(Dialog(backgroundColor: Colors.transparent, child: SubscriptionScheduleBottomSheet(checkoutController: checkoutController)));
        } else {
          showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (con) => SubscriptionScheduleBottomSheet(checkoutController: checkoutController),
          );
        }
      },
    );
  }
}
