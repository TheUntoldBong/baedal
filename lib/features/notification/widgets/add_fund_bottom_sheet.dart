import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AddFundBottomSheet extends StatelessWidget {
  final NotificationModel notificationModel;
  const AddFundBottomSheet({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {

    double? walletAmount = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;
    double? previousAmount = walletAmount - double.parse(notificationModel.data?.amount ?? '0.0');

    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      padding: EdgeInsets.all(Dimensions.paddingLarge),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

       ResponsiveHelper.isDesktop(context) ? Align(
         alignment: Alignment.centerRight,
         child: IconButton(
             onPressed: (){
                Navigator.pop(context);
             },
             icon: Icon(Icons.clear),
         ),
       ) : Container(
          height: 5, width: 70,
          decoration: BoxDecoration(
            color: context.bgNeutralLight,
            borderRadius: BorderRadius.circular(50),
          ),
          margin: EdgeInsets.only(bottom: Dimensions.paddingDefault),
        ),

        Text(
          'credited_by_admin'.tr,
          style: context.heading.extraLarge.strong,
        ),
        const SizedBox(height: Dimensions.paddingExtraLarge),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Center(
            child: Text('add_fund'.tr, style: context.subHeading.defaultSize.strong),
          ),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(color: context.outline, width: 2),
          ),
          child: Column(
            children: [
              buildRow('wallet_previous_amount'.tr, PriceConverter.convertPrice(previousAmount)),
              buildRow('credit_amount'.tr, PriceConverter.convertPrice(double.parse(notificationModel.data?.amount ?? '0.0'))),
              buildRow('current_amount'.tr, PriceConverter.convertPrice(walletAmount)),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingLarge),

        CustomButtonWidget(
          buttonText: 'okay'.tr,
          width: 200,
          onPressed: () {
            Navigator.pop(context);
          },
        ),


      ]),
    );
  }

  Widget buildRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.context!.subHeading.defaultSize.medium),
          Text(amount, style: Get.context!.heading.defaultSize.strong),
        ],
      ),
    );
  }
}
