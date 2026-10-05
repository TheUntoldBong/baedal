import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AddressBottomSheet extends StatelessWidget {
  const AddressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius : const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingExtraLarge),
          topRight : Radius.circular(Dimensions.paddingExtraLarge),
        ),
      ),
      child: GetBuilder<AddressController>(
        builder: (addressController) {
          bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
          AddressModel? selectedAddress = AddressHelper.getAddressFromSharedPref();
          return Column(mainAxisSize: MainAxisSize.min, children: [

            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding2xSmall, right: Dimensions.padding2xSmall),
              child: Align(alignment: Alignment.topRight,
                child: InkWell(onTap: ()=> Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.surfaceContainer),
                    child: Icon(Icons.close, size: 18, color: context.iconBaseMedium))),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                  Text('select_your_address'.tr, style: context.heading.extraLarge.strong),
                  const SizedBox(height: Dimensions.paddingExtraSmall),
                  Text(
                    'select_a_saved_address_or_add_a_new_one_to_continue'.tr,
                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                  const SizedBox(height: Dimensions.paddingOverLarge),

                  if(isLoggedIn) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('my_address'.tr, style: context.heading.defaultSize.strong),

                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.add_circle_outline, size: 16, color: context.primary),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Text('add_new_address'.tr, style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.primary)),
                          ]),
                        ),
                      ],
                    ),

                    addressController.addressList != null && addressController.addressList!.isEmpty ? Column(children: [

                      const SizedBox(height: Dimensions.paddingOverLarge),
                      CustomAssetImageWidget(Images.emptyAddressIcon, width: 50, height: 50,),
                      const SizedBox(height: Dimensions.paddingDefault),

                      Text(
                        'oops'.tr, textAlign: TextAlign.center,
                        style: context.heading.defaultSize.strong,
                      ),
                      const SizedBox(height: Dimensions.paddingSmall),

                      Text(
                        'you_dont_have_any_saved_address_yet'.tr, textAlign: TextAlign.center,
                        style: context.body.defaultSize.regular,
                      ),
                      const SizedBox(height: Dimensions.paddingLarge),

                    ]) : const SizedBox(),

                    const SizedBox(height: Dimensions.paddingLarge),

                    addressController.addressList != null ? addressController.addressList!.isNotEmpty ? ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: addressController.addressList!.length > 5 ? 5 : addressController.addressList!.length,
                      separatorBuilder: (context, index) => Divider(height: Dimensions.paddingLarge,),
                      itemBuilder: (context, index) {
                        AddressModel address = addressController.addressList![index];
                        bool selected = selectedAddress!.id == address.id;

                        return InkWell(
                          onTap: () {
                            Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                            Get.find<LocationController>().saveAddressAndNavigate(
                              address, false, null, false, ResponsiveHelper.isDesktop(context),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              CustomAssetImageWidget(
                                address.addressType == 'home' ? Images.navHome : address.addressType == 'office' ? Images.office : Images.others,
                                height: 16, width: 16,
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    address.addressType?.tr ?? '',
                                    style: context.heading.defaultSize.strong,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    address.address ?? '',
                                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ]),
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),

                              Container(
                                height: 20, width: 20,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? context.primary : context.outlineVariant,
                                    width: 1.5,
                                  ),
                                ),
                                child: selected ? Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.primary),
                                ) : const SizedBox(),
                              ),
                            ]),
                          ),
                        );
                      },
                    ) : const SizedBox() : const Center(child: CircularProgressIndicator()),

                    addressController.addressList != null && addressController.addressList!.isNotEmpty ? const SizedBox(height: Dimensions.paddingLarge) : SizedBox.shrink(),
                  ],

                  InkWell(
                    onTap: () => _onCurrentLocationButtonPressed(),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.primary,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.my_location, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                        const SizedBox(width: Dimensions.paddingSmall),
                        Text('use_current_location'.tr, style: context.heading.defaultSize.strong.overrideWith(color: Theme.of(context).colorScheme.onPrimary)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingMedium),

                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                      alignment: Alignment.center,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.map_outlined, size: 18, color: context.primary),
                        const SizedBox(width: Dimensions.paddingSmall),
                        Text('set_from_map'.tr, style: context.heading.defaultSize.strong.overrideWith(color: context.primary)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                ]),
              ),
            ),
          ]);
        }
      ),
    );
  }

  void _onCurrentLocationButtonPressed() {
    Get.find<LocationController>().checkPermission(() async {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
      ZoneResponseModel response = await Get.find<LocationController>().getZone(address.latitude, address.longitude, false);
      if(response.isSuccess) {
        Get.find<LocationController>().saveAddressAndNavigate(
          address, false, '', false, ResponsiveHelper.isDesktop(Get.context),
        );
      }else {
        Get.back();
        Get.toNamed(RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false));
        showCustomSnackBar('service_not_available_in_current_location'.tr);
      }
    });
  }
}
