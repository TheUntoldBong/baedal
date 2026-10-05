import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/min_max_time_picker_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';


class CustomTimePickerWidget extends StatelessWidget {
  const CustomTimePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> time = [];
    for(int i = 1; i <= 60 ; i++){
      time.add(i.toString());
    }
    List<String> unit = ['minute', 'hours', 'days'];

    return DialogSheetBody(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: GetBuilder<RestaurantRegistrationController>(
          builder: (restaurantRegiController) {
            return Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('estimated_delivery_time'.tr , style: context.heading.large.medium),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                      child: Text(
                        'this_item_will_be_shown_in_the_user_app_website'.tr,
                        style: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          'minimum'.tr,
                          style: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(),

                      SizedBox(
                        width: 70,
                        child: Text(
                          'maximum'.tr,
                          style: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          'unit'.tr,
                          style: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingDefault),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                      MinMaxTimePickerWidget(
                        times: time, onChanged: (int index)=> restaurantRegiController.minTimeChange(time[index]),
                        initialPosition: 10,
                      ),

                      Text(':', style: context.heading.defaultSize.strong),

                      MinMaxTimePickerWidget(
                        times: time, onChanged: (int index)=> restaurantRegiController.maxTimeChange(time[index]),
                        initialPosition: 10,
                      ),

                      MinMaxTimePickerWidget(
                        times: unit, onChanged: (int index) => restaurantRegiController.timeUnitChange(unit[index]),
                        initialPosition: 1,
                      ),

                    ]),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
                      child: Text(
                        '${restaurantRegiController.storeMinTime} - ${restaurantRegiController.storeMaxTime} ${restaurantRegiController.storeTimeUnit}',
                        style: context.heading.extraLarge.strong,
                      ),
                    ),

                    CustomButtonWidget(
                      width: 200,
                      buttonText: 'save'.tr,
                      onPressed: (){
                        int? min;
                        int? max;
                        bool isValid = false;
                        try{
                          min = int.parse(restaurantRegiController.storeMinTime);
                          max = int.parse(restaurantRegiController.storeMaxTime);
                          isValid = true;
                        } catch(e) {
                          log(3);
                        }
                        if(min != null && max != null && (min < max) && isValid){
                          Get.back();
                        }else{
                          showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                        }
                      },
                    ),

                  ],
                ),

                Positioned(
                  top: -10, right: -10,
                  child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(CupertinoIcons.clear)),
                ),
              ],
            );
          }
        ),
      ));
  }
}
