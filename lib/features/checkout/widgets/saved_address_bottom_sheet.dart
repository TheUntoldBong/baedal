import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class SavedAddressBottomSheet extends StatefulWidget {
  const SavedAddressBottomSheet({super.key});

  @override
  State<SavedAddressBottomSheet> createState() => _SavedAddressBottomSheetState();
}

class _SavedAddressBottomSheetState extends State<SavedAddressBottomSheet> {

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<AddressController>(builder: (addressController) {
      return GetBuilder<CheckoutController>(builder: (checkoutController) {
        return GetBuilder<LocationController>(builder: (locationController) {
          return Container(
            width: isDesktop ? 500 : context.width,
            padding: const EdgeInsets.all(Dimensions.paddingSmall),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Center(
                    child: Container(
                      height: 5, width: 40,
                      decoration: BoxDecoration(
                        color: context.bgNeutralMedium,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('select_your_address'.tr, style: context.subHeading.large.medium),

                      InkWell(
                        onTap: () async {
                          Get.back();

                          var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, checkoutController.restaurant!.zoneId));
                          if(address != null) {

                            checkoutController.insertAddresses(address, notify: true);

                            checkoutController.getDistanceInKM(
                              LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                              LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                            );
                          }
                        },
                        child: Text('${'add_new_address'.tr} +', style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  Text('saved_addresses'.tr, style: context.body.defaultSize.regular),

                  addressController.addressList != null ? addressController.addressList!.isNotEmpty ? Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                      shrinkWrap: true,
                      itemCount: addressController.addressList?.length,
                      itemBuilder: (context, index) {
                        final address = addressController.addressList?[index];
                        bool isSelectedAddress = checkoutController.address?.id == address!.id && checkoutController.address?.latitude == address.latitude && checkoutController.address?.longitude == address.longitude;

                        return Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                          padding: EdgeInsets.all(Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: isSelectedAddress ? context.primary.withValues(alpha: 0.1) : context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: isSelectedAddress ? context.primary.withValues(alpha: 0.1) : context.outline,
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              Get.back();

                              checkoutController.insertAddresses(address, notify: true);

                              checkoutController.getDistanceInKM(
                                LatLng(
                                  double.parse(address.latitude!),
                                  double.parse(address.longitude!),
                                ),
                                LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                              );
                            },
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                CustomAssetImageWidget(
                                  address.addressType == 'home' ? Images.homeIcon : address.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                                  color: isSelectedAddress ? context.primary : context.iconBaseMedium,
                                  height: ResponsiveHelper.isDesktop(context) ? 25 : 18, width: ResponsiveHelper.isDesktop(context) ? 25 : 18,
                                ),
                                const SizedBox(width: Dimensions.padding2xSmall),

                                Text(
                                  address.addressType!.tr,
                                  style: context.subHeading.defaultSize.medium,
                                ),

                                (address.isDefault ?? false) ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  ),
                                  child: Text('default'.tr, style: context.body.extraSmall.regular.overrideWith(color: Colors.blue)),
                                ) : const SizedBox(),
                              ]),
                              const SizedBox(height: Dimensions.padding2xSmall),

                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  address.address ?? '',
                                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ) : Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                      child: CustomAssetImageWidget(Images.emptyAddress, height: 100, width: 100),
                  )) : Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: CircularProgressIndicator(),
                  )),
                  const SizedBox(height: Dimensions.paddingSmall),

                  Center(
                    child: CustomInkWellWidget(
                      onTap: () {
                        _checkPermission(() async {
                          Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                          AddressModel addressModel = await locationController.getCurrentLocation(true, mapController: null, showSnackBar: true);

                          if(addressModel.zoneIds!.isNotEmpty) {
                            checkoutController.insertAddresses(addressModel, notify: true);

                            checkoutController.getDistanceInKM(
                              LatLng(
                                locationController.position.latitude, locationController.position.longitude,
                              ),
                              LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                            );

                            Get.back();
                            Get.back();
                          }
                        });
                      },
                      padding: const EdgeInsets.all(Dimensions.paddingSmall),
                      radius: Dimensions.radiusDefault,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                        Icon(Icons.my_location_sharp, size: 20, color: context.primary),
                        const SizedBox(width: Dimensions.paddingSmall),

                        Text(
                          'use_my_current_location'.tr,
                          style: context.body.defaultSize.regular,
                        ),

                      ]),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingDefault),

                ]),
              ),

              Positioned(
                top: 0, right: 0,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.clear, color: context.iconBaseMedium, size: 20),
                ),
              ),
            ]),
          );
        });
      });
    });
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog());
    }else {
      onTap();
    }
  }

}
