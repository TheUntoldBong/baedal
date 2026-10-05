import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_drop_down_button.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/screens/set_location_screen.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/delivery_coverage_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

void showDeliveryAddressBottomSheet() {
  if(ResponsiveHelper.isDesktop(Get.context!)) {
    Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: DeliveryAddressBottomSheet()));
  } else {
    showCustomBottomSheet(child: const DeliveryAddressBottomSheet());
  }
}

class DeliveryAddressBottomSheet extends StatefulWidget {
  const DeliveryAddressBottomSheet({super.key});

  @override
  State<DeliveryAddressBottomSheet> createState() => _DeliveryAddressBottomSheetState();
}

class _DeliveryAddressBottomSheetState extends State<DeliveryAddressBottomSheet> {

  CoverageAreaModel? _selectedCoverageArea;

  @override
  void initState() {
    super.initState();
    _selectedCoverageArea = Get.find<CheckoutController>().selectedCoverageArea;
  }

  Future<void> _changeAddress(CheckoutController checkoutController) async {
    var address = await Get.toNamed(
      RouteHelper.getSetLocationRoute(),
      arguments: SetLocationScreen(initialAddress: checkoutController.addressController.text.trim()),
    );
    if(address != null && checkoutController.restaurant != null) {
      checkoutController.insertAddresses(address, notify: true);

      checkoutController.getDistanceInKM(
        LatLng(double.parse(address.latitude), double.parse(address.longitude)),
        LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
      );

      if(mounted) {
        setState(() => _selectedCoverageArea = checkoutController.selectedCoverageArea);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Container(
        width: isDesktop ? 500 : context.width,
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            !isDesktop ? Center(
              child: Container(
                height: 5, width: 40,
                decoration: BoxDecoration(
                  color: context.bgNeutralMedium,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: !isDesktop ? Dimensions.paddingLarge : 0),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_address'.tr, style: context.heading.large.strong),

              InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.clear, color: context.iconBaseMedium, size: 20),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingDefault),

            InkWell(
              onTap: () => _changeAddress(checkoutController),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: context.outline, width: 1),
                ),
                child: Row(children: [
                  Icon(Icons.location_on_outlined, size: 20, color: context.iconBaseMedium),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(
                    child: Text(
                      checkoutController.addressController.text.trim(),
                      style: context.subHeading.defaultSize.regular,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Icon(Icons.edit_outlined, size: 20, color: context.primary),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            RichText(
              text: TextSpan(
                text: checkoutController.isZipCodeWiseDelivery ? 'zip_code'.tr : 'area'.tr,
                style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                children: [
                  TextSpan(text: ' *', style: context.subHeading.defaultSize.regular.overrideWith(color: context.error)),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSmall),

            checkoutController.isCoverageLoading ? Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingDefault),
                child: CircularProgressIndicator(color: context.primary),
              ),
            ) : CustomDropdownButton<int>(
              hintText: checkoutController.isZipCodeWiseDelivery ? 'select_zip_code'.tr : 'select_area'.tr,
              selectedValue: _selectedCoverageArea?.id,
              backgroundColor: context.surfaceContainer,
              dropdownMenuItems: checkoutController.coverageAreaList?.map((area) => DropdownMenuItem<int>(
                value: area.id,
                child: Text(area.name ?? '', style: context.body.defaultSize.regular, maxLines: 1, overflow: TextOverflow.ellipsis),
              )).toList(),
              validator: (value) => null,
              onChanged: (value) {
                setState(() {
                  _selectedCoverageArea = checkoutController.coverageAreaList?.firstWhere((area) => area.id == value);
                });
              },
            ),
            const SizedBox(height: Dimensions.paddingExtraLarge),

            CustomButtonWidget(
              buttonText: 'confirm_information'.tr,
              onPressed: () {
                if(_selectedCoverageArea == null) {
                  showCustomSnackBar(checkoutController.isZipCodeWiseDelivery ? 'please_select_zip_code'.tr : 'please_select_area'.tr);
                  return;
                }
                checkoutController.setSelectedCoverageArea(_selectedCoverageArea);
                Get.back();
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingDefault),

          ]),
        ),
      );
    });
  }
}
