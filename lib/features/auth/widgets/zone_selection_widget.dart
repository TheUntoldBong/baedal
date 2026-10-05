import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dropdown_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ZoneSelectionWidget extends StatelessWidget {
  final RestaurantRegistrationController restaurantRegController;
  final List<DropdownItem<int>> zoneList;
  final Function() callBack;
  const ZoneSelectionWidget({super.key, required this.restaurantRegController, required this.zoneList, required this.callBack});

  @override
  Widget build(BuildContext context) {
    return restaurantRegController.zoneIds != null ? Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: context.surfaceContainer,
            border: Border.all(color: context.outline, width: 0.3)
          ),
          child: CustomDropdown<int>(
            selectedIndex: restaurantRegController.selectedZoneIndex,
            onChange: (int? value, int index) {
              restaurantRegController.setZoneIndex(value);
              callBack();
            },
            dropdownButtonStyle: DropdownButtonStyle(
              height: 50,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.padding2xSmall,
                horizontal: Dimensions.padding2xSmall,
              ),
              primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            iconColor: context.textBaseDefault,
            dropdownStyle: DropdownStyle(
              elevation: 10,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            ),
            items: zoneList,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!].name!.tr),
            ),
          ),
        ),

        Positioned(
          left: 10, top: -15,
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceContainer,
            ),
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text('select_zone'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                Text(' *', style: context.body.defaultSize.regular.overrideWith(color: Colors.red)),
              ],
            ),
          ),
        ),
      ],
    ) : Center(child: Text('service_not_available_in_this_area'.tr));
  }
}