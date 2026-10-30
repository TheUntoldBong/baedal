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
import 'package:stackfood_multivendor/features/address/screens/set_location_screen.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
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

  Future<void> _selectLiveLocation(CheckoutController checkoutController, LocationController locationController) async {
    _checkPermission(() async {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      try {
        AddressModel addressModel = await locationController.getCurrentLocation(true, mapController: null, showSnackBar: true);

        if (Get.isDialogOpen ?? false) {
          Get.back(); // dismiss loader
        }

        if (addressModel.zoneIds != null && addressModel.zoneIds!.isNotEmpty) {
          checkoutController.insertAddresses(addressModel, notify: true, isLive: true);
          await AddressHelper.saveAddressInSharedPref(addressModel);

          if (checkoutController.restaurant != null && addressModel.latitude != null && addressModel.longitude != null) {
            double? lat = double.tryParse(addressModel.latitude!);
            double? lng = double.tryParse(addressModel.longitude!);
            double? rLat = double.tryParse(checkoutController.restaurant!.latitude ?? '');
            double? rLng = double.tryParse(checkoutController.restaurant!.longitude ?? '');
            if (lat != null && lng != null && rLat != null && rLng != null) {
              checkoutController.getDistanceInKM(LatLng(lat, lng), LatLng(rLat, rLng));
            }
          }

          Get.back(); // dismiss bottom sheet
        } else {
          showCustomSnackBar('service_not_available_in_current_location'.tr);
        }
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back(); // dismiss loader
        }
        showCustomSnackBar('Failed to get current location: $e');
      }
    });
  }

  Future<void> _searchOrSetFromMap(CheckoutController checkoutController) async {
    Get.back(); // close bottom sheet first
    var address = await Get.toNamed(
      RouteHelper.getSetLocationRoute(),
      arguments: SetLocationScreen(initialAddress: checkoutController.addressController.text.trim()),
    );
    if (address != null && address is AddressModel) {
      checkoutController.insertAddresses(address, notify: true, isLive: false);
      await AddressHelper.saveAddressInSharedPref(address);

      if (checkoutController.restaurant != null && address.latitude != null && address.longitude != null) {
        double? lat = double.tryParse(address.latitude!);
        double? lng = double.tryParse(address.longitude!);
        double? rLat = double.tryParse(checkoutController.restaurant!.latitude ?? '');
        double? rLng = double.tryParse(checkoutController.restaurant!.longitude ?? '');
        if (lat != null && lng != null && rLat != null && rLng != null) {
          checkoutController.getDistanceInKM(LatLng(lat, lng), LatLng(rLat, rLng));
        }
      }
    }
  }

  void _selectSavedAddress(AddressModel address, CheckoutController checkoutController) async {
    Get.back(); // close bottom sheet

    checkoutController.insertAddresses(address, notify: true, isLive: false);
    await AddressHelper.saveAddressInSharedPref(address);

    if (checkoutController.restaurant != null && address.latitude != null && address.longitude != null) {
      double? lat = double.tryParse(address.latitude!);
      double? lng = double.tryParse(address.longitude!);
      double? rLat = double.tryParse(checkoutController.restaurant!.latitude ?? '');
      double? rLng = double.tryParse(checkoutController.restaurant!.longitude ?? '');
      if (lat != null && lng != null && rLat != null && rLng != null) {
        checkoutController.getDistanceInKM(LatLng(lat, lng), LatLng(rLat, rLng));
      }
    }
  }

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
              borderRadius: BorderRadius.vertical(top: const Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
            ),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
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
                        onTap: () => Get.back(),
                        child: Icon(Icons.clear, color: context.iconBaseMedium, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingDefault),

                  // Option 1: Use Current Location (Live GPS)
                  Container(
                    decoration: BoxDecoration(
                      color: checkoutController.isLiveAddress
                          ? context.primary.withValues(alpha: 0.08)
                          : context.surface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: checkoutController.isLiveAddress
                            ? context.primary
                            : context.outline,
                        width: checkoutController.isLiveAddress ? 1.5 : 1,
                      ),
                    ),
                    child: CustomInkWellWidget(
                      onTap: () => _selectLiveLocation(checkoutController, locationController),
                      radius: Dimensions.radiusDefault,
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.my_location_sharp, size: 20, color: context.primary),
                        ),
                        const SizedBox(width: Dimensions.paddingDefault),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(
                                'use_my_current_location'.tr,
                                style: context.subHeading.defaultSize.semiBold,
                              ),
                              if (checkoutController.isLiveAddress) ...[
                                const SizedBox(width: Dimensions.paddingSmall),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 2),
                            Text(
                              'Deliver to current live GPS location',
                              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                            ),
                          ]),
                        ),

                        Icon(Icons.chevron_right, size: 20, color: context.iconBaseMedium),
                      ]),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  // Option 2: Search address or set on map
                  Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: context.outline, width: 1),
                    ),
                    child: CustomInkWellWidget(
                      onTap: () => _searchOrSetFromMap(checkoutController),
                      radius: Dimensions.radiusDefault,
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.map_outlined, size: 20, color: context.primary),
                        ),
                        const SizedBox(width: Dimensions.paddingDefault),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'set_from_map'.tr,
                              style: context.subHeading.defaultSize.semiBold,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Search any address or choose on map',
                              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                            ),
                          ]),
                        ),

                        Icon(Icons.chevron_right, size: 20, color: context.iconBaseMedium),
                      ]),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  // Section 3: Saved Addresses Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('saved_addresses'.tr, style: context.subHeading.defaultSize.semiBold),

                      InkWell(
                        onTap: () async {
                          Get.back();
                          var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, checkoutController.restaurant?.zoneId));
                          if (address != null && address is AddressModel) {
                            checkoutController.insertAddresses(address, notify: true, isLive: false);
                            await AddressHelper.saveAddressInSharedPref(address);
                            if (checkoutController.restaurant != null && address.latitude != null && address.longitude != null) {
                              double? lat = double.tryParse(address.latitude!);
                              double? lng = double.tryParse(address.longitude!);
                              double? rLat = double.tryParse(checkoutController.restaurant!.latitude ?? '');
                              double? rLng = double.tryParse(checkoutController.restaurant!.longitude ?? '');
                              if (lat != null && lng != null && rLat != null && rLng != null) {
                                checkoutController.getDistanceInKM(LatLng(lat, lng), LatLng(rLat, rLng));
                              }
                            }
                          }
                        },
                        child: Text('${'add_new_address'.tr} +', style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),

                  // Saved Addresses List
                  addressController.addressList != null ? addressController.addressList!.isNotEmpty ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                      shrinkWrap: true,
                      itemCount: addressController.addressList?.length,
                      itemBuilder: (context, index) {
                        final address = addressController.addressList![index];
                        bool isSelectedAddress = !checkoutController.isLiveAddress &&
                            checkoutController.address?.id == address.id &&
                            checkoutController.address?.latitude == address.latitude &&
                            checkoutController.address?.longitude == address.longitude;

                        return Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: isSelectedAddress ? context.primary.withValues(alpha: 0.08) : context.surface,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: isSelectedAddress ? context.primary : context.outline,
                              width: isSelectedAddress ? 1.5 : 1,
                            ),
                          ),
                          child: CustomInkWellWidget(
                            radius: Dimensions.radiusDefault,
                            onTap: () => _selectSavedAddress(address, checkoutController),
                            padding: const EdgeInsets.all(Dimensions.paddingDefault),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              CustomAssetImageWidget(
                                address.addressType == 'home' ? Images.homeIcon : address.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                                color: isSelectedAddress ? context.primary : context.iconBaseMedium,
                                height: 22, width: 22,
                              ),
                              const SizedBox(width: Dimensions.paddingDefault),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(
                                      (address.addressType ?? 'Other').tr,
                                      style: context.subHeading.defaultSize.medium,
                                    ),
                                    if (address.isDefault ?? false) ...[
                                      Container(
                                        margin: const EdgeInsets.only(left: Dimensions.paddingSmall),
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                        ),
                                        child: Text('default'.tr, style: context.body.extraSmall.regular.overrideWith(color: Colors.blue)),
                                      ),
                                    ],
                                  ]),
                                  const SizedBox(height: 2),

                                  Text(
                                    address.address ?? '',
                                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ]),
                              ),

                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelectedAddress ? context.primary : context.outline,
                                    width: isSelectedAddress ? 5 : 1.5,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ) : Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
                    child: Column(children: [
                      CustomAssetImageWidget(Images.emptyAddress, height: 60, width: 60),
                      const SizedBox(height: Dimensions.paddingSmall),
                      Text('no_saved_address_found'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                    ]),
                  )) : const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
                    child: CircularProgressIndicator(),
                  )),

                  const SizedBox(height: Dimensions.paddingSmall),
                ]),
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
