import 'dart:collection';
import 'dart:developer';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/google_map_widgets/restaurant_details_sheet_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/google_map_widgets/restaurant_search_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/map_custom_info_window_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class MapViewScreen extends StatefulWidget {
  final bool fromDineInScreen;
  const MapViewScreen({super.key, this.fromDineInScreen = false});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = HashSet<Marker>();
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  PageController? _pageController = PageController();
  bool _showLoading = true;
  List<Restaurant>? _markedRestaurants;

  @override
  void initState() {
    super.initState();
    if(ResponsiveHelper.isDesktop(Get.context)) {
      _pageController = PageController(viewportFraction: 0.37, initialPage: 0);
    }


    if(widget.fromDineInScreen){
      Get.find<DineInController>().getDineInRestaurantList(1, false);
    }else {
      Get.find<RestaurantController>().getNearbyRestaurantList();
    }
    Get.find<RestaurantController>().setNearestRestaurantIndex(-1, notify: false);
  }

  @override
  void dispose() {
    super.dispose();

    _controller?.dispose();
    _pageController?.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.fromDineInScreen ? 'restaurants_map'.tr : 'nearby_restaurants'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<DineInController>(builder: (dineInController) {
          _syncMarkers(widget.fromDineInScreen ? dineInController.dineInModel?.restaurants : restController.nearbyRestaurantModel?.restaurants);
          return ResponsiveHelper.isDesktop(context) ? (widget.fromDineInScreen ? dineInController.dineInModel != null : restController.nearbyRestaurantModel != null) ? Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Get.isDarkMode? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 5)],
              ),
              child: Row(children: [

                Expanded(
                  flex: 2,
                  child: PageView.builder(
                    itemCount: widget.fromDineInScreen ? dineInController.dineInModel?.restaurants?.length : restController.nearbyRestaurantModel!.restaurants!.length,
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    padEnds: false,
                    onPageChanged: (int index) {
                      _animateMarker(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index], index);
                    },
                    itemBuilder: (context, index) {
                      bool isSelected = restController.nearestRestaurantIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                        child: RestaurantView(
                          restaurant: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index],
                          isSelected: isSelected,
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getRestaurantRoute(
                                widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index].id : restController.nearbyRestaurantModel!.restaurants![index].id,
                                slug: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index].slug ?? '' : restController.nearbyRestaurantModel!.restaurants![index].slug ?? '',
                              ),
                              arguments: RestaurantScreen(restaurant: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingExtraLarge),

                Expanded(
                  flex: 6,
                  child: Stack(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(
                          double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
                          double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
                        ), zoom: 12),
                        minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                        zoomControlsEnabled: false,
                        markers: _markers,
                        onTap: (position) {
                          _customInfoWindowController.hideInfoWindow!();
                          restController.setNearestRestaurantIndex(-1);
                        },
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove!();
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          _customInfoWindowController.googleMapController = controller;
                        },
                        style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                      ),
                    ),

                    CustomInfoWindow(
                      controller: _customInfoWindowController,
                      height: 55, width: 120,
                      offset: 25,
                    ),

                    (widget.fromDineInScreen ? dineInController.dineInModel != null : restController.nearbyRestaurantModel != null) ? Positioned(
                      top: Dimensions.paddingSmall, left: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
                      child: RestaurantSearchWidget(
                        mapController: _controller, restaurantList: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants! : restController.nearbyRestaurantModel!.restaurants!,
                        customInfoWindowController: _customInfoWindowController,
                        callBack: (int index) {
                          _animateMarker(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index], index);
                        },
                      ),
                    ) : const SizedBox(),

                    _showLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

                    Positioned(
                      bottom: 30,
                      right: 10,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            mini: true,
                            child: const Icon(Icons.add),
                            onPressed: () async {
                              var currentZoomLevel = await _controller?.getZoomLevel();
                              currentZoomLevel = (currentZoomLevel! + 1);
                              _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                            },
                          ),
                          const SizedBox(height: 10),

                          FloatingActionButton(
                            mini: true,
                            child: const Icon(Icons.remove),
                            onPressed: () async {
                              var currentZoomLevel = await _controller?.getZoomLevel();
                              currentZoomLevel = (currentZoomLevel! - 1);
                              _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                            },
                          ),
                        ],
                      ),
                    ),

                  ]),
                ),

              ]),
            ),
          ) : const SizedBox() : (widget.fromDineInScreen ? dineInController.dineInModel != null : restController.nearbyRestaurantModel != null) ? Stack(children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(
                double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
                double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
              ), zoom: 12),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: _markers,
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
                restController.setNearestRestaurantIndex(-1);
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _customInfoWindowController.googleMapController = controller;
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 55, width: 120,
              offset: 25,
            ),

            (widget.fromDineInScreen ? dineInController.dineInModel != null : restController.nearbyRestaurantModel != null) ? Positioned(
              top: Dimensions.paddingSmall, left: Dimensions.paddingSmall, right: Dimensions.paddingSmall,
              child: RestaurantSearchWidget(
                mapController: _controller, restaurantList: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants! : restController.nearbyRestaurantModel!.restaurants!,
                customInfoWindowController: _customInfoWindowController,
                callBack: (int index) {
                  _animateMarker(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index], index);
                },
              ),
            ) : const SizedBox(),

            Positioned(
              bottom: restController.nearestRestaurantIndex != -1 ? 270 : 80,
              right: 15,
              child: Column(
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    mini: true,
                    child: Icon(Icons.add, color: Theme.of(context).hintColor, size: 25),
                    onPressed: () async {
                      var currentZoomLevel = await _controller?.getZoomLevel();
                      currentZoomLevel = (currentZoomLevel! + 1);
                      _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                    },
                  ),
                  const SizedBox(height: 10),

                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    mini: true,
                    child: Icon(Icons.remove, color: Theme.of(context).hintColor, size: 25),
                    onPressed: () async {
                      var currentZoomLevel = await _controller?.getZoomLevel();
                      currentZoomLevel = (currentZoomLevel! - 1);
                      _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              right: 15, bottom: restController.nearestRestaurantIndex != -1 ? 210 : 20,
              child: InkWell(
                onTap: () => _checkPermission(() async {
                  AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                  GetPlatform.isWeb ? _setMarkerForWeb(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants! : restController.nearbyRestaurantModel!.restaurants!)
                  : _setMarkers(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants! : restController.nearbyRestaurantModel!.restaurants!, false, address: address);
                }),
                child: Container(
                  padding: const EdgeInsets.all( Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Icon(Icons.my_location_outlined, color: Theme.of(context).hintColor, size: 25),
                ),
              ),
            ),

            restController.nearestRestaurantIndex != -1 ? Positioned(
              bottom: 0,
              child: SizedBox(
                height: 160, width: context.width,
                child: PageView.builder(
                  onPageChanged: (int index) {
                   _animateMarker(widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index], index);
                  },
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  itemCount: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants!.length : restController.nearbyRestaurantModel!.restaurants!.length,
                  itemBuilder: (context, index) {
                    bool active = restController.nearestRestaurantIndex == index;
                    return RestaurantDetailsSheetWidget(restaurant: widget.fromDineInScreen ? dineInController.dineInModel!.restaurants![index] : restController.nearbyRestaurantModel!.restaurants![index], isActive: active);
                  },
                ),
              ),
            ) : const SizedBox(),

            _showLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),
          ]) : const SizedBox();
        });
      }),
    );
  }

  void _syncMarkers(List<Restaurant>? restaurants) {
    if(identical(restaurants, _markedRestaurants)) {
      return;
    }
    _markedRestaurants = restaurants;

    if(restaurants == null || restaurants.isEmpty) {
      _showLoading = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) {
        return;
      }
      GetPlatform.isWeb ? _setMarkerForWeb(restaurants) : _setMarkers(restaurants, false);
    });
  }

  Future<void> _animateMarker(Restaurant restaurant, int index) async {
    Get.find<RestaurantController>().setNearestRestaurantIndex(index);

    LatLng latLng = LatLng(
      double.tryParse(restaurant.latitude ?? '') ?? 0,
      double.tryParse(restaurant.longitude ?? '') ?? 0,
    );
    if(_controller != null) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 12)));
    }
    ResponsiveHelper.isWeb() ? null : _customInfoWindowController.addInfoWindow!(MapCustomInfoWindowWidget(restaurant: restaurant), latLng);

    if(!_pageController!.hasClients) {
      _pageController = PageController(initialPage: index);
    } else {
      _pageController!.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  void _setMarkers(List<Restaurant> restaurants, bool selected, {AddressModel? address}) async {
    try{

      BitmapDescriptor restaurantMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(width: 50, imagePath: Images.nearbyRestaurantMarker);
      BitmapDescriptor myLocationMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(width: 50, imagePath: Images.myLocationMarker);

      _markers = {};
      List<LatLng> latLngs = [];

      _markers.add(Marker(
        markerId: const MarkerId('id--1'),
        visible: true,
        draggable: false,
        zIndexInt: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        position: LatLng(
          double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
          double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
        ),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(MapCustomInfoWindowWidget(
              userInfoModel: Get.find<ProfileController>().userInfoModel),
              LatLng(
                double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
                double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
              ),
          );
        },
        icon: myLocationMarkerIcon,
      ));


      if(address != null) {
        _markers.add(Marker(
          markerId: const MarkerId('id--2'),
          visible: true,
          draggable: false,
          zIndexInt: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.tryParse(address.latitude ?? '') ?? 0,
            double.tryParse(address.longitude ?? '') ?? 0,
          ),
          icon: myLocationMarkerIcon,
        ));
        setState(() {});
      }

      int index0 = 0;
      for(int index=0; index<restaurants.length; index++) {
        double? lat = double.tryParse(restaurants[index].latitude ?? '');
        double? lng = double.tryParse(restaurants[index].longitude ?? '');
        if(lat == null || lng == null) {
          continue;
        }
        index0++;
        LatLng latLng = LatLng(lat, lng);
        latLngs.add(latLng);
        _markers.add(Marker(
          markerId: MarkerId('id-$index0'),
          visible: true,
          draggable: false,
          zIndexInt: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: latLng,
          onTap: () {
            _animateMarker(restaurants[index], index);
          },
          icon: restaurantMarkerIcon,
        ));
      }

      if(mounted) {
        setState(() => _showLoading = false);
      }

    } catch (e, stackTrace) {
      log('$e', stackTrace: stackTrace);
      if(mounted) {
        setState(() => _showLoading = false);
      }
    }
  }

  void _setMarkerForWeb(List<Restaurant> restaurants) async {
    List<LatLng> latLngs = [];
    _markers = HashSet<Marker>();
    _markers.add(Marker(markerId: const MarkerId('id-0'), position: LatLng(
      double.parse(AddressHelper.getAddressFromSharedPref()?.latitude??'0'),
      double.parse(AddressHelper.getAddressFromSharedPref()?.longitude??'0'),
    ), icon: BitmapDescriptor.defaultMarker));
    int index0 = 0;
    for(int index=0; index<restaurants.length; index++) {
      double? lat = double.tryParse(restaurants[index].latitude ?? '');
      double? lng = double.tryParse(restaurants[index].longitude ?? '');
      if(lat == null || lng == null) {
        continue;
      }
      index0++;
      LatLng latLng = LatLng(lat, lng);
      latLngs.add(latLng);
      _markers.add(Marker(markerId: MarkerId('id-$index0'), position: latLng, onTap: () {
        _animateMarker(restaurants[index], index);
      },
       icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: '${restaurants[index].name}',
          onTap: () {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(restaurants[index].id, slug: restaurants[index].slug ?? ''),
              arguments: RestaurantScreen(restaurant: restaurants[index]),
            );
          },
        ),
      ));
    }
    if(mounted) {
      setState(() => _showLoading = false);
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