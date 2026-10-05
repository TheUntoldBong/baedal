import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/map_recent_saved_address.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key, this.onAddressSelected, this.onSetOnMap, this.initialAddress});

  final Function(AddressModel address)? onAddressSelected;
  final VoidCallback? onSetOnMap;
  final String? initialAddress;

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    final AddressController addressController = Get.find<AddressController>();
    addressController.locationSearchController.text = widget.initialAddress ?? '';
    addressController.updateLocationSuggestions(null, notify: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressController.getRecentSearchedAddresses();
      if (addressController.addressList == null && AuthHelper.isLoggedIn()) {
        addressController.getAddressList();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAddressSelected(AddressModel address) {
    if (widget.onAddressSelected != null) {
      widget.onAddressSelected!(address);
    } else {
      Get.back(result: address);
    }
  }

  void _onSetOnMap() {
    widget.onSetOnMap?.call();
    Get.toNamed(
      RouteHelper.getPickMapRoute('add-address', false),
      arguments: PickMapScreen(
        fromAddAddress: true, fromSignUp: false, fromSplash: false,
        googleMapController: Get.find<LocationController>().mapController,
        route: null, canRoute: false, fromLocationSuggestion: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Get.find<AddressController>().updateLocationSuggestions(null, notify: false);
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title: 'set_location'.tr),
        body: Stack(children: [
          Column(children: [
          const SizedBox(height: Dimensions.paddingDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: GetBuilder<AddressController>(
              builder: (addressController) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault+2),
                    border: Border.all(color: context.outlineVariant),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Icon(Icons.location_on_outlined, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
                    SizedBox(width: addressController.locationSearchController.text.isNotEmpty ? 0 : Dimensions.paddingSmall),
                    addressController.locationSearchController.text.isNotEmpty ? SizedBox.shrink()
                        : Container(height: 24, width: 1, color: Theme.of(context).textTheme.bodyLarge?.color),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('location_search_field'),
                        focusNode: _searchFocusNode,
                        controller: addressController.locationSearchController,
                        textInputAction: TextInputAction.search,
                        onTap: () => setState(() {}),
                        onChanged: (value) => addressController.searchLocationSuggestion(value),
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.streetAddress,
                        style:context.subHeading.defaultSize.regular,
                        decoration: InputDecoration(isDense: true, hintText: 'type_your_location'.tr, border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                          hintStyle: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: addressController.locationSearchController.text.isNotEmpty,
                      maintainState: true, maintainAnimation: true, maintainSize: false,
                      child: InkWell(
                        onTap: () {
                          addressController.locationSearchController.clear();
                          addressController.updateLocationSuggestions(null);
                          setState(() {});
                        },
                        child: const SizedBox(height: 30, width: 30, child: Icon(Icons.clear, size: 16)),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          Expanded(child: MapRecentSavedAddress(onAddressSelected: _onAddressSelected, onSetOnMap: _onSetOnMap)),
          ]),

          GetBuilder<LocationController>(builder: (locationController) {
            if(!locationController.loading) {
              return const SizedBox.shrink();
            }
            return SizedBox.expand(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const CustomLoaderWidget(),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
