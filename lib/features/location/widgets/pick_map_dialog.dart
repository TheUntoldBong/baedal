import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_extended.dart';
import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_minimized.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/serach_location_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickMapDialog extends StatefulWidget {
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final Function(AddressModel address)? onPicked;
  final int? restaurantId;
  const PickMapDialog({super.key,
    required this.fromSignUp, required this.fromAddAddress, required this.canRoute,
    required this.route, this.googleMapController, this.onPicked, this.restaurantId,
  });

  @override
  State<PickMapDialog> createState() => _PickMapDialogState();
}

class _PickMapDialogState extends State<PickMapDialog> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  final TextEditingController controller = TextEditingController();
  double _currentZoom = 16.0;

  @override
  void initState() {
    super.initState();

    LocationController locationController = Get.find<LocationController>();
    if(widget.fromAddAddress) {
      locationController.setPickData();
    }
    locationController.makeLoadingOff();
    _initialPosition = (locationController.pickAddress != null && locationController.pickAddress!.isNotEmpty && (locationController.pickPosition.latitude != 0 || locationController.pickPosition.longitude != 0)) ? LatLng(
      locationController.pickPosition.latitude,
      locationController.pickPosition.longitude,
    ) : LatLng(
      double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
      double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        height: ResponsiveHelper.isDesktop(context) ? 500 : null,
        width: ResponsiveHelper.isDesktop(context) ? 700 : Dimensions.webMaxWidth,
        decoration: context.width > 700 ? BoxDecoration(
          color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        ) : null,

        child: GetBuilder<LocationController>(builder: (locationController) {

          return ResponsiveHelper.isDesktop(context) ?
          Column(
            children: [

              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.clear),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall, left: Dimensions.paddingExtraLarge, right: Dimensions.paddingExtraLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('pick_your_location'.tr, style: context.heading.defaultSize.medium),
                    Text('sharing_your_accurate_location'.tr, style: context.body.small.regular),

                    const SizedBox(height: Dimensions.paddingDefault),

                    SearchLocationWidget(mapController: _mapController, pickedAddress: locationController.pickAddress, isEnabled: true, fromDialog: true),
                    const SizedBox(height: Dimensions.paddingDefault),

                    SizedBox(
                      height: 270,
                      child:  Stack(children: [
                        ClipRRect(
                          borderRadius:BorderRadius.circular(Dimensions.radiusDefault),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: widget.fromAddAddress ? LatLng(locationController.position.latitude, locationController.position.longitude) : _initialPosition,
                              zoom: _currentZoom,
                            ),
                            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            onMapCreated: (GoogleMapController mapController) {
                              _mapController = mapController;
                              _mapController!.moveCamera(CameraUpdate.newLatLng(_initialPosition));
                            },
                            scrollGesturesEnabled: !Get.isDialogOpen!,
                            onCameraMove: (CameraPosition cameraPosition) {
                              _cameraPosition = cameraPosition;
                            },
                            onCameraMoveStarted: () {
                              locationController.updateCameraMovingStatus(true);
                              locationController.disableButton();
                            },
                            onCameraIdle: () {
                              locationController.updateCameraMovingStatus(false);
                              Get.find<LocationController>().updatePosition(_cameraPosition, false);
                            },
                          ),
                        ),

                        Center(child: Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.pickMapIconSize * 0.65),
                          child: locationController.isCameraMoving ? const AnimatedMapIconExtended() : const AnimatedMapIconMinimised(),
                        )),


                        Positioned(
                          bottom: 25, right: Dimensions.paddingSmall,
                          child: FloatingActionButton(
                            mini: true, backgroundColor: context.surfaceContainer,
                            onPressed: () => Get.find<LocationController>().checkPermission(() {
                              Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                            }),
                            child: Icon(Icons.my_location, color: context.primary),
                          ),
                        ),

                        Positioned(
                          bottom: 80, right: Dimensions.paddingSmall,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.surfaceContainer,
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)],
                            ),
                            child: Column(children: [
                              IconButton(
                                onPressed: (){
                                  _currentZoom++;
                                  _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
                                },
                                icon: Icon(Icons.add, ),
                              ),
                              const SizedBox(height: Dimensions.padding2xSmall),

                              IconButton(
                                onPressed: (){
                                  _currentZoom--;
                                  _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
                                },
                                icon: Icon(Icons.remove, ),
                              ),

                            ]),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingDefault),


                    CustomButtonWidget(
                      isBold: false, fontSize: Dimensions.fontSizeSmall,
                      width: 300, height: 40,
                      radius: Dimensions.radiusExtraSmall,
                      buttonText: locationController.inZone ? widget.fromAddAddress ? 'pick_address'.tr : 'pick_location'.tr
                          : 'service_not_available_in_this_area'.tr,
                      isLoading: locationController.isLoading,
                      onPressed: locationController.isLoading ? (){} : (locationController.buttonDisabled || locationController.loading) ? null : () {
                        _onPickAddressButtonPressed(locationController);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ) : Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.fromAddAddress ? LatLng(locationController.position.latitude, locationController.position.longitude)
                    : _initialPosition,
                zoom: 16,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController mapController) {
                _mapController = mapController;
                if(!widget.fromAddAddress && (locationController.pickAddress == null || locationController.pickAddress!.isEmpty)) {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: mapController);
                }
              },
              scrollGesturesEnabled: !Get.isDialogOpen!,
              zoomControlsEnabled: false,
              onCameraMove: (CameraPosition cameraPosition) {
                _cameraPosition = cameraPosition;
              },
              onCameraMoveStarted: () {
                locationController.disableButton();
              },
              onCameraIdle: () {
                Get.find<LocationController>().updatePosition(_cameraPosition, false);
              },
            ),

            Center(child: !locationController.loading ? CustomAssetImageWidget(Images.pickMarker, height: 50, width: 50)
                : const CircularProgressIndicator()),

            Positioned(
              top: Dimensions.paddingLarge, left: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
              child: SearchLocationWidget(mapController: _mapController, pickedAddress: locationController.pickAddress, isEnabled: null),
            ),

            Positioned(
              bottom: 80, right: Dimensions.paddingLarge,
              child: FloatingActionButton(
                mini: true, backgroundColor: context.surfaceContainer,
                onPressed: () => Get.find<LocationController>().checkPermission(() {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                }),
                child: Icon(Icons.my_location, color: context.primary),
              ),
            ),

            Positioned(
              bottom: Dimensions.paddingLarge, left: Dimensions.paddingLarge, right: Dimensions.paddingLarge,
              child: CustomButtonWidget(
                buttonText: locationController.inZone ? widget.fromAddAddress ? 'pick_address'.tr : 'pick_location'.tr
                    : 'service_not_available_in_this_area'.tr,
                isLoading: locationController.isLoading,
                onPressed: locationController.isLoading ? (){} : (locationController.buttonDisabled || locationController.loading) ? null : () {
                  _onPickAddressButtonPressed(locationController);
                },
              ),
            ),
          ]);

        }),
      ),
    );
  }

  void _onPickAddressButtonPressed(LocationController locationController) {
    if(locationController.pickPosition.latitude != 0 && locationController.pickAddress!.isNotEmpty) {
      if(widget.onPicked != null) {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others', address: locationController.pickAddress,
          contactPersonName: AddressHelper.getAddressFromSharedPref()!.contactPersonName,
          contactPersonNumber: AddressHelper.getAddressFromSharedPref()!.contactPersonNumber,
        );
        widget.onPicked!(address);
        Get.back();
      }else if(widget.fromAddAddress) {
        if(widget.googleMapController != null) {
          widget.googleMapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
            locationController.pickPosition.latitude, locationController.pickPosition.longitude,
          ), zoom: 16)));
          locationController.addAddressData();
        }
        Get.back();
      }else {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others', address: locationController.pickAddress,
        );
        if(!Get.find<AuthController>().isGuestLoggedIn() || !Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().guestLogin().then((response) {
            if(response.isSuccess) {
              Get.find<ProfileController>().setForceFullyUserEmpty();
              locationController.saveAddressAndNavigate(
                address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(Get.context), restaurantId: widget.restaurantId,
              );
            }
          });
        } else{
          locationController.saveAddressAndNavigate(
            address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(context), restaurantId: widget.restaurantId,
          );
        }
      }
    }else {
      showCustomSnackBar('pick_an_address'.tr);
    }
  }
}
