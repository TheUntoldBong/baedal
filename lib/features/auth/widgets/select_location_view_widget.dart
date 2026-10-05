import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/zone_selection_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/location/widgets/location_search_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dropdown_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class SelectLocationViewWidget extends StatefulWidget {
  final bool fromView;
  final GoogleMapController? mapController;
  final bool zoneCuisinesView;
  final TextEditingController? addressController;
  final FocusNode? addressFocus;
  final bool inDialog;
  const SelectLocationViewWidget({super.key, required this.fromView, this.mapController, this.zoneCuisinesView = false, this.addressController, this.addressFocus, this.inDialog = false});

  @override
  State<SelectLocationViewWidget> createState() => _SelectLocationViewWidgetState();
}

class _SelectLocationViewWidgetState extends State<SelectLocationViewWidget> {
  late CameraPosition _cameraPosition;
  Set<Polygon> _polygone = {};
  GoogleMapController? _mapController;
  int? _drawnZoneId;

  List<DropdownItem<int>> _generateDropDownZoneList(List<ZoneModel>? zoneList, List<int>? zoneIds) {
    List<DropdownItem<int>> dropDownZoneList = [];
    if(zoneList != null && zoneIds != null) {
      for(int index=0; index<zoneList.length; index++) {
        dropDownZoneList.add(DropdownItem<int>(value: index, child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${zoneList[index].name}'.tr),
          ),
        )));
      }
    }
    return dropDownZoneList;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<RestaurantRegistrationController>(builder: (restaurantRegController) {
      List<DropdownItem<int>> zoneList = _generateDropDownZoneList(restaurantRegController.zoneList, restaurantRegController.zoneIds);

      return Container(
        decoration: widget.fromView && !isDesktop ? BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ) : null,
        height: widget.fromView ? null : context.height,
        padding: widget.fromView && !isDesktop ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault) : EdgeInsets.zero,
        child: Center(
          child: SizedBox(width: Dimensions.webMaxWidth, child: SingleChildScrollView (
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              widget.fromView ? ZoneSelectionWidget(restaurantRegController: restaurantRegController, zoneList: zoneList, callBack: (){
                _setPolygon(restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!]);
              }) : const SizedBox(),
              widget.fromView ? const SizedBox(height: Dimensions.paddingDefault) : const SizedBox(),

              widget.fromView ? Text('set_precious_location_on_map_for_your_exact_pickup_location'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)) : const SizedBox(),
              widget.fromView ? const SizedBox(height: Dimensions.paddingDefault) : const SizedBox(),

              mapView(restaurantRegController),

              !restaurantRegController.inZone && !restaurantRegController.zoneLoading && widget.fromView ? Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(children: [
                  Text('* ', style: context.body.defaultSize.strong.overrideWith(color: Colors.red)),
                  Text('please_place_the_marker_inside_the_zone'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                ]),
              ) : const SizedBox(),

              !isDesktop ? SizedBox(height: !widget.fromView ? Dimensions.paddingSmall : 0) : const SizedBox(),

            ]),
          )),
        ),
      );
    });
  }

  Widget mapView(RestaurantRegistrationController restaurantRegController) {
    return restaurantRegController.zoneList!.isNotEmpty ? Container(
      height: ResponsiveHelper.isDesktop(context) ? widget.fromView ? 220 : MediaQuery.of(context).size.height * 0.8
          : widget.fromView ? 340 : (context.height * 0.87),
      width: MediaQuery.of(context).size.width,
      decoration: widget.fromView ? BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: context.outline),
      ) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Stack(clipBehavior: Clip.none, children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
                double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
              ), zoom: 16,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: true,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            zoomGesturesEnabled: true,
            webCameraControlEnabled: false,
            polygons: _polygone,
            onCameraIdle: () async {
              if(!widget.fromView) {
                widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
              }
              await restaurantRegController.setLocation(
                _cameraPosition.target, forRestaurantRegistration: true,
                zoneId: restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!].id,
              );
              ZoneModel selectedZone = restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!];
              if(mounted && _drawnZoneId != selectedZone.id) {
                _setPolygon(selectedZone, moveCameraToZone: false);
              }
            },
            onCameraMoveStarted: () => restaurantRegController.startZoneLoading(),
            onCameraMove: ((position) => _cameraPosition = position),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _setPolygon(restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!]);
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
              Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
            },
            style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
          ),
          const Center(
            child: FractionalTranslation(
              translation: Offset(0, -0.5),
              child: CustomAssetImageWidget(Images.picRestaurantMarker, height: 50, width: 50, fit: BoxFit.contain),
            ),
          ),

          Positioned(
            top: widget.fromView ? 10 : 20,
            left: ResponsiveHelper.isDesktop(context) && widget.fromView ? null : widget.fromView ? 10 : 20,
            right: widget.fromView ? 10 : 30,
            child: LocationSearchDialog(
              mapController: _mapController,
              pickedLocation: restaurantRegController.restaurantAddress.toString(),
              callBack: (Position? position) {
                if(position != null) {
                  _cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
                  if(!widget.fromView) {
                    widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                    restaurantRegController.setLocation(
                      _cameraPosition.target, forRestaurantRegistration: true,
                      zoneId: restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!].id,
                    );
                  }
                }
              },
              child: Container(
                height: widget.fromView ? 30 : 40, width: widget.fromView ? 200 : context.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.fromView ? Dimensions.radiusExtraSmall : 50),
                  color: context.surfaceContainer,
                  boxShadow: [BoxShadow(color: context.shadow, blurRadius: 2)],
                ),
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: restaurantRegController.zoneLoading ? Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    height: 14, width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: context.primary),
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),
                  Text('loading'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                ]) : Text(
                  restaurantRegController.restaurantAddress ?? '',
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
            ),
          ),

          widget.inDialog ? Positioned(
            top: 0, right: 0,
            child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.clear)),
          ) : const SizedBox(),

          widget.fromView ? Positioned(
            bottom: 130, right: 0,
            child: InkWell(
              onTap: () {
                if(ResponsiveHelper.isDesktop(context)) {
                  showGeneralDialog(context: context, pageBuilder: (_,_,_) {
                    return SelectLocationViewWidget(fromView: false, mapController: _mapController, inDialog: true);
                  });
                } else {
                  Get.to(Scaffold(
                    appBar: CustomAppBarWidget(title: 'set_your_store_location'.tr),
                    body: SelectLocationViewWidget(fromView: false, mapController: _mapController),
                  ));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingDefault),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(Icons.fullscreen, color: context.primary, size: 20),
              ),
            ),
          ) : const SizedBox(),

          Positioned(
            bottom: widget.fromView ? 90 : 200, right: 0,
            child: InkWell(
              onTap: () => _checkPermission(() {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                }),
              child: Container(
                padding: EdgeInsets.all(widget.fromView ? Dimensions.padding2xSmall : Dimensions.paddingSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingDefault),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(Icons.my_location_outlined, color: context.primary, size: 20),
              ),
            ),
          ),

          Positioned(
            bottom: widget.fromView ? 10 : 110, right: widget.fromView ? -5 : 0,
            child: Container(
              margin: const EdgeInsets.only(right: Dimensions.paddingDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: context.surfaceContainer,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  onTap: () async {
                    var currentZoomLevel = await _mapController?.getZoomLevel();
                    currentZoomLevel = (currentZoomLevel! + 1);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _cameraPosition.target,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.add, size: ResponsiveHelper.isDesktop(context) ? 15 : 20),
                ),
                const Divider(),

                InkWell(
                  onTap: () async {
                    var currentZoomLevel = await _mapController?.getZoomLevel();
                    currentZoomLevel = (currentZoomLevel! - 1);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _cameraPosition.target,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.remove, size: ResponsiveHelper.isDesktop(context) ? 15 : 20),
                ),
              ]),
            ),
          ),

          !widget.fromView ? Positioned(
            left: 20, right: 20, bottom: ResponsiveHelper.isDesktop(context) ? 40 : 20,
            child: CustomButtonWidget(
              buttonText: restaurantRegController.inZone ? 'set_location'.tr : 'not_in_zone'.tr,
              isLoading: restaurantRegController.zoneLoading,
              onPressed: restaurantRegController.inZone ? () {
                try{
                  widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                  Get.back();
                }catch(e){
                  showCustomSnackBar('please_setup_the_marker_in_your_required_location'.tr);
                }
              } : null,
            ),
          ) : const SizedBox()

        ]),
      ),
    ) : const SizedBox();
  }

  void _setPolygon(ZoneModel zoneModel, {bool moveCameraToZone = true}) {
    List<Polygon> polygonList = [];
    List<LatLng> zoneLatLongList = [];
    _drawnZoneId = zoneModel.id;

    zoneModel.formatedCoordinates?.forEach((coordinate) {
      zoneLatLongList.add(LatLng(coordinate.lat!, coordinate.lng!));
    });

    polygonList.add(
      Polygon(
        polygonId: PolygonId('${zoneModel.id!}'),
        points: zoneLatLongList,
        strokeWidth: 2,
        strokeColor: Get.theme.colorScheme.primary,
        fillColor: Get.theme.colorScheme.primary.withValues(alpha: .2),
      ),
    );

    _polygone = HashSet<Polygon>.of(polygonList);

    if(moveCameraToZone) {
      Future.delayed( const Duration(milliseconds: 500),(){
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          boundsFromLatLngList(zoneLatLongList),
          ResponsiveHelper.isDesktop(Get.context) ? 30 : 100.5,
        ));
      });
    }

    setState(() {});
  }

  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1 ?? 0, y1 ?? 0), southwest: LatLng(x0 ?? 0, y0 ?? 0));
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

