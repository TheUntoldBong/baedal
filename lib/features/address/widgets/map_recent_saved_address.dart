import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/prediction_model.dart';
import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MapRecentSavedAddress extends StatefulWidget {
  const MapRecentSavedAddress({super.key, this.onAddressSelected, this.onSetOnMap});

  final Function(AddressModel address)? onAddressSelected;
  final VoidCallback? onSetOnMap;

  @override
  State<MapRecentSavedAddress> createState() => _MapRecentSavedAddressState();
}

class _MapRecentSavedAddressState extends State<MapRecentSavedAddress> {
  int _selectedTab = 0;

  Future<void> _selectCurrentLocation() async {
    AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
    widget.onAddressSelected?.call(address);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<AddressController>(
        builder: (addressController) {
          if (addressController.locationSuggestions != null) {
            return Column(children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, 0, Dimensions.paddingDefault, Dimensions.paddingLarge),
                    child: _SuggestionsSection(
                      suggestions: addressController.locationSuggestions!,
                      query: addressController.locationSearchController.text,
                    ),
                  ),
                ),
              ),
              _QuickActionBar(
                onSetOnMap: () => widget.onSetOnMap?.call(),
                onCurrentLocation: _selectCurrentLocation,
              ),
            ]);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSmall, children: [

              Container(
                padding: EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge-3),
                ),
                child: Column(children: [

                  CustomInkWellWidget(
                    onTap: () => widget.onSetOnMap?.call(),
                    radius: Dimensions.radiusDefault,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      child: Row(children: [
                        CustomAssetImageWidget(Images.mapSet, width: 20),
                        const SizedBox(width: Dimensions.paddingSmall),
                        Text('set_on_map'.tr, style: context.heading.defaultSize.strong),
                        const Spacer(),
                        const Icon(Icons.arrow_forward, size: 22),
                      ]),
                    ),
                  ),

                  Divider(height: 1, indent: Dimensions.paddingDefault, endIndent: Dimensions.paddingDefault),

                  CustomInkWellWidget(
                    onTap: _selectCurrentLocation,
                    radius: Dimensions.radiusDefault,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      child: GetBuilder<LocationController>(
                        builder: (locationController) {
                          return Row(children: [
                            Icon(Icons.location_on_outlined, color: context.iconBaseMedium, size: 22),
                            const SizedBox(width: Dimensions.paddingSmall),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('current_location'.tr, style: context.heading.defaultSize.strong),
                                const SizedBox(height: 2),
                                Text(
                                  locationController.address ?? '',
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                                ),
                              ]),
                            ),
                            const SizedBox(width: Dimensions.paddingSmall),
                            Container(
                              height: 20, width: 20,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: context.primary, width: 1.5),
                              ),
                              child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: context.primary)),
                            ),
                          ]);
                        },
                      ),
                    ),
                  ),

                ]),
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingDefault),
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: Border.all(color: context.outline),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Builder(builder: (context) {
                      final bool hasRecent = addressController.recentSearchedAddressList != null &&
                          addressController.recentSearchedAddressList!.isNotEmpty;
                      final String tab0Content = hasRecent ? 'recent' : 'saved';
                      final String tab1Content = hasRecent ? 'saved' : 'recent';
                      return Row(children: [
                        _AddressTab(
                          label: tab0Content == 'recent' ? 'recent'.tr : 'saved'.tr,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: Dimensions.paddingSmall),
                        _AddressTab(
                          label: tab1Content == 'recent' ? 'recent'.tr : 'saved'.tr,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ]);
                    }),

                    const SizedBox(height: Dimensions.paddingSmall),
                    Expanded(
                      child: Builder(builder: (context) {
                        final bool hasRecent = addressController.recentSearchedAddressList != null &&
                            addressController.recentSearchedAddressList!.isNotEmpty;
                        final String selectedContent = _selectedTab == 0
                            ? (hasRecent ? 'recent' : 'saved')
                            : (hasRecent ? 'saved' : 'recent');

                        if (selectedContent == 'recent') {
                          if (addressController.recentSearchedAddressList == null ||
                              addressController.recentSearchedAddressList!.isEmpty) {
                            return _EmptyAddressState(message: 'no_recent_address_found'.tr);
                          }
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: addressController.recentSearchedAddressList!.length.clamp(0, 10),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final AddressModel address = addressController.recentSearchedAddressList![index];
                              return CustomInkWellWidget(
                                onTap: () async {
                                  Get.find<LocationController>().updateAddress(address);
                                  await addressController.addRecentSearchedAddress(address);
                                  widget.onAddressSelected?.call(address);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(children: [
                                    Container(
                                      height: 26, width: 26,
                                      decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                                      child: Icon(Icons.location_on_outlined, color: context.iconBaseMedium, size: 18),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSmall),
                                    Expanded(
                                      child: Text(
                                        address.address ?? '',
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: context.body.defaultSize.regular,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSmall),
                                    Icon(Icons.chevron_right, size: 20, color: context.iconBaseMedium),
                                  ]),
                                ),
                              );
                            },
                          );
                        }

                        if (addressController.addressList == null || addressController.addressList!.isEmpty) {
                          return _EmptyAddressState(message: 'no_saved_address_found'.tr);
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: addressController.addressList!.length.clamp(0, 10),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final AddressModel address = addressController.addressList![index];
                            return CustomInkWellWidget(
                              onTap: () async {
                                Get.find<LocationController>().updateAddress(address);
                                await addressController.addRecentSearchedAddress(address);
                                widget.onAddressSelected?.call(address);
                              },
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(children: [
                                Container(height: 36, width: 36,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer, shape: BoxShape.circle,
                                  ),
                                  child: Center(child: CustomAssetImageWidget(
                                    address.addressType == 'home' ? Images.navHome
                                        : address.addressType == 'office' ? Images.office : Images.others,
                                    color: context.iconBaseMedium,
                                    height: 18, width: 18,
                                  )),
                                ),
                                const SizedBox(width: Dimensions.paddingSmall),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(address.address ?? '',
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault),
                                    ),
                                  ]),
                                ),
                                const SizedBox(width: Dimensions.paddingSmall),
                                Icon(Icons.chevron_right, size: 20, color: context.iconBaseMedium),
                              ]),
                            );
                          },
                        );
                      }),
                    ),
                  ]),
                ),
              ),
            ]),
          );
        }
      ),
    );
  }
}

class _QuickActionBar extends StatelessWidget {
  final VoidCallback onSetOnMap;
  final VoidCallback onCurrentLocation;
  const _QuickActionBar({required this.onSetOnMap, required this.onCurrentLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: onSetOnMap,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CustomAssetImageWidget(Images.mapSet, color: context.primary, width: 16),
              const SizedBox(width: Dimensions.padding2xSmall),
              Text('set_on_map'.tr, style: context.heading.defaultSize.strong),
            ]),
          ),
        ),

        Container(height: 20, width: 1, color: context.bgNeutralMedium),

        Expanded(
          child: InkWell(
            onTap: onCurrentLocation,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.my_location, color: context.primary, size: 20),
              const SizedBox(width: Dimensions.padding2xSmall),
              Text('current_location'.tr, style: context.heading.defaultSize.strong),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  final List<PredictionModel> suggestions;
  final String query;
  const _SuggestionsSection({required this.suggestions, required this.query});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: context.surfaceContainer,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      border: Border.all(color: context.outline),
    );

    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        decoration: cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('suggestions'.tr, style: context.heading.extraLarge.strong),
          const SizedBox(height: Dimensions.paddingSmall),
          const SizedBox(
            height: 40,
            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      decoration: cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('suggestions'.tr, style: context.heading.extraLarge.strong),
        const SizedBox(height: Dimensions.paddingLarge),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => _SuggestionItem(
              suggestion: suggestions[index], query: query,
            ),
          ),
        ),
      ]),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final PredictionModel suggestion;
  final String query;
  const _SuggestionItem({required this.suggestion, required this.query});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    return CustomInkWellWidget(
      onTap: () async {
        AddressModel address = await addressController.setLocationFromPlace(suggestion.placeId, suggestion.description);
        addressController.updateLocationSuggestions(null);
        Get.find<LocationController>().updateAddress(address);

        Get.toNamed(
          RouteHelper.getPickMapRoute('add-address', false),
          arguments: PickMapScreen(
            fromAddAddress: true, fromSignUp: false, fromSplash: false,
            googleMapController: Get.find<LocationController>().mapController,
            route: null, canRoute: false, fromLocationSuggestion: true,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [
          Container(
            height: 36, width: 36,
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_outlined, color: context.iconBaseMedium, size: 18),
          ),
          const SizedBox(width: Dimensions.paddingSmall),
          Expanded(child: _buildHighlightedText(context, suggestion.description ?? '', query)),
        ]),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text, String query) {
    final baseStyle = context.subHeading.defaultSize.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge!.color);
    final boldStyle = context.heading.defaultSize.strong;

    if (query.isEmpty) return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        if (matchIndex > 0) TextSpan(text: text.substring(0, matchIndex), style: baseStyle),
        TextSpan(text: text.substring(matchIndex, matchIndex + query.length), style: boldStyle),
        if (matchIndex + query.length < text.length) TextSpan(text: text.substring(matchIndex + query.length), style: baseStyle),
      ]),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  final String message;
  const _EmptyAddressState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraOverLarge),
      child: Center(
        child: Text(message, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center),
      ),
    );
  }
}

class _AddressTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _AddressTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: context.subHeading.small.semiBold.overrideWith(
            color: isSelected ? context.onPrimary : context.onSurface,
          ),
        ),
      ),
    );
  }
}
