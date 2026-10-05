import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/filter_icon_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class VegFilterWidget extends StatelessWidget {
  final VegType? type;
  final bool fromAppBar;
  final Function(VegType value)? onSelected;
  final Color? iconColor;
  const VegFilterWidget({super.key, required this.type, required this.onSelected, this.fromAppBar = false, this.iconColor});


  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    List<PopupMenuEntry> entryList = _generateVegTypeList(context);

    return Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Padding(
      padding: fromAppBar ? EdgeInsets.zero : EdgeInsets.only(left: ltr ? Dimensions.paddingSmall : 0, right: ltr ? 0 : Dimensions.paddingSmall),
      child: PopupMenuButton<dynamic>(
        offset: const Offset(-20, 20),
        itemBuilder: (BuildContext context) => entryList,
        onSelected: (dynamic value) => onSelected!(VegType.values[value]),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        ),
        child: FilterIconWidget(fromAppBar: fromAppBar, iconColor: iconColor,),
      ),
    ) : const SizedBox();
  }

  List<PopupMenuEntry> _generateVegTypeList(BuildContext context) {
    List<PopupMenuEntry> entryList = [];
    for(int i=0; i < VegType.values.length; i++){
      final VegType vegType = VegType.values[i];
      final bool selected = vegType == type;
      entryList.add(PopupMenuItem<int>(value: i, child: Row(children: [
        selected
            ? Icon(Icons.radio_button_checked_sharp, color: context.primary)
            : Icon(Icons.radio_button_off, color: context.iconBaseMedium),
        const SizedBox(width: Dimensions.padding2xSmall),

        Text(
          vegType.value.tr,
          style: context.subHeading.defaultSize.medium.overrideWith(
            color: selected ? context.textBaseDefault : context.textBaseMedium,
          ),
        ),
      ])));
    }
    return entryList;
  }
}
