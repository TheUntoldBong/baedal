import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_extended.dart';
import 'package:stackfood_multivendor/features/location/widgets/animated_map_icon_minimized.dart';
import 'package:stackfood_multivendor/features/location/widgets/custom_floating_action_button.dart';
import 'package:stackfood_multivendor/features/location/widgets/location_search_dialog.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class PickMapScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromSplash;
  final bool fromAddAddress;
  final bool canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final bool fromGuestCheckout;
  final bool fromLocationSuggestion;
  final bool fromNewUserBottomSheet;
  const PickMapScreen({
    super.key, required this.fromSignUp, required this.fromAddAddress, required this.canRoute,
    required this.route, this.googleMapController, required this.fromSplash, this.fromGuestCheckout = false,
    this.fromLocationSuggestion = false, this.fromNewUserBottomSheet = false,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  double _currentZoomLevel = 16.0;

  @override
  void initState() {
    super.initState();

    Get.find<LocationController>().makeLoadingOff();

    if(widget.fromAddAddress) {
      Get.find<LocationController>().setPickData();
    }
    _initialPosition = LatLng(
      double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
      double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromAddAddress && widget.fromGuestCheckout) ? CustomAppBarWidget(title: 'delivery_address'.tr)
          : (widget.fromLocationSuggestion || widget.fromNewUserBottomSheet) ? _LocationAddressAppBar(mapController: _mapController, onBack: () => Get.back())
          : null,
      body: SafeArea(child: Center(child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: GetBuilder<LocationController>(builder: (locationController) {
          return Stack(children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.fromAddAddress ? LatLng(locationController.position.latitude, locationController.position.longitude) : _initialPosition,
                zoom: _currentZoomLevel,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              onMapCreated: (GoogleMapController mapController) {
                _mapController = mapController;
                if(!widget.fromAddAddress && widget.route != 'splash') {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: mapController).then((value) {
                    if(widget.fromSplash) {
                      _onPickAddressButtonPressed(locationController);
                    }
                  });
                }
              },
              zoomControlsEnabled: false,
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
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),

            Center(child: Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.pickMapIconSize * 0.65),
              child: locationController.isCameraMoving ? const AnimatedMapIconExtended() : const AnimatedMapIconMinimised(),
            )),

            if(!widget.fromLocationSuggestion && !widget.fromNewUserBottomSheet)
              Positioned(
                top: Dimensions.paddingLarge, left: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
                child: LocationSearchDialog(mapController: _mapController, pickedLocation: locationController.pickAddress!),
              ),

            Positioned(
              bottom: 100, right: Dimensions.paddingLarge,
              child: Column(children: [

                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 4))],
                  ),
                  child: FloatingActionButton(
                    mini: true, backgroundColor: context.surfaceContainer,
                    onPressed: () => _checkPermission(() {
                      Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                    }),
                    child: Icon(Icons.my_location, color: context.primary),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingDefault),

                Container(
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 4))],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(children: [
                    CustomFloatingActionButton(
                      icon: Icons.add, heroTag: 'add_button',
                      onTap: () {
                        _currentZoomLevel++;
                        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
                      },
                    ),

                    Container(
                      width: 20, height: 1,
                      color: context.bgNeutralMedium,
                    ),

                    CustomFloatingActionButton(
                      icon: Icons.remove, heroTag: 'remove_button',
                      onTap: () {
                        _currentZoomLevel--;
                        _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
                      },
                    ),


                  ]),
                ),


              ]),
            ),


            Positioned(
              bottom: Dimensions.paddingLarge, left: Dimensions.paddingLarge, right: Dimensions.paddingLarge,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (locationController.buttonDisabled || locationController.loading) ? null : () => _onPickAddressButtonPressed(locationController),
                child: Container(
                  padding: EdgeInsets.all((locationController.buttonDisabled || locationController.loading) ? Dimensions.padding2xSmall : Dimensions.paddingDefault - 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (locationController.buttonDisabled || locationController.loading) ? context.primary.withValues(alpha: 0.8) : context.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: (locationController.buttonDisabled || locationController.loading) ? Center(
                    child: LoadingAnimationWidget.waveDots(color: Colors.white, size: 40),
                  ) : Text(
                    locationController.inZone ? widget.fromAddAddress ? 'confirm_address'.tr : 'set_location'.tr : 'service_not_available_in_this_area'.tr,
                    style: context.body.large.strong.overrideWith(color: context.onPrimary),
                  ),
                ),
              ),
            ),

          ]);
        }),
      ))),
    );
  }

  void _onPickAddressButtonPressed(LocationController locationController) {
    if(locationController.pickPosition.latitude != 0 && locationController.pickAddress!.isNotEmpty) {
      if(widget.fromAddAddress) {
        if(widget.googleMapController != null) {
          widget.googleMapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
            locationController.pickPosition.latitude, locationController.pickPosition.longitude,
          ), zoom: 17)));
        }

        if(widget.fromNewUserBottomSheet) {
          AddressModel address = AddressModel(
            latitude: locationController.pickPosition.latitude.toString(),
            longitude: locationController.pickPosition.longitude.toString(),
            addressType: 'others', address: locationController.pickAddress,
          );
          Get.back(result: address);
        } else if(widget.fromLocationSuggestion) {
          AddressModel address = AddressModel(
            latitude: locationController.pickPosition.latitude.toString(),
            longitude: locationController.pickPosition.longitude.toString(),
            addressType: 'others', address: locationController.pickAddress,
          );
          Get.back();
          Get.back(result: address);
        } else {
          locationController.addAddressData();
          Get.back();
        }
      }else {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others', address: locationController.pickAddress,
        );
        locationController.saveAddressAndNavigate(address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(Get.context));
      }
    }else {
      showCustomSnackBar('pick_an_address'.tr);
    }
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


class _LocationAddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GoogleMapController? mapController;
  final VoidCallback onBack;
  const _LocationAddressAppBar({required this.mapController, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color iconBg = context.surfaceContainer;

    return AppBar(
      backgroundColor: context.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: Dimensions.padding2xSmall),
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            final String text = locationController.pickAddress ?? '';
            final bool isEmpty = text.isEmpty;

            return LocationSearchDialog(
              mapController: mapController,
              fullWidthBar: true,
              fromAddress: true,
              pickedLocation: isEmpty ? '' : text,
              leading: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: 40, width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_back, color: textColor, size: 20),
                ),
              ),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
                  border: Border.all(color: context.outline, width: 1.5),
                ),
                child: Row(children: [

                  const Icon(Icons.location_on_outlined, size: 20),

                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(
                    child: Text(
                      isEmpty ? 'search_location'.tr : text,
                      style: context.body.defaultSize.regular.overrideWith(color: isEmpty ? context.textBaseMedium : textColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left,
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}