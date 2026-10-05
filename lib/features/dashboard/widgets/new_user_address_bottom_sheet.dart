import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NewUserAddressBottomSheet extends StatefulWidget {
  final bool fromCheckout;
  const NewUserAddressBottomSheet({super.key, this.fromCheckout = false});

  @override
  State<NewUserAddressBottomSheet> createState() => _NewUserAddressBottomSheetState();
}

class _NewUserAddressBottomSheetState extends State<NewUserAddressBottomSheet> {
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final FocusNode _houseFocus = FocusNode();
  final FocusNode _landmarkFocus = FocusNode();

  AddressModel? _selectedAddress;
  bool _isFetchingLocation = false;
  bool _isSaving = false;
  String _selectedAddressType = 'home'; // 'home', 'office', 'others'

  @override
  void initState() {
    super.initState();
    // Prefill if an address was already partially detected or available
    AddressModel? current = AddressHelper.getAddressFromSharedPref();
    if (current != null) {
      _selectedAddress = current;
      _houseController.text = current.house ?? '';
      _landmarkController.text = current.road ?? '';
      _selectedAddressType = current.addressType ?? 'home';
    }
  }

  @override
  void dispose() {
    _houseController.dispose();
    _landmarkController.dispose();
    _houseFocus.dispose();
    _landmarkFocus.dispose();
    super.dispose();
  }

  void _onUseCurrentLocation() {
    Get.find<LocationController>().checkPermission(() async {
      setState(() => _isFetchingLocation = true);
      try {
        AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
        if (address.latitude != null && address.longitude != null) {
          setState(() {
            _selectedAddress = address;
            _isFetchingLocation = false;
          });
        } else {
          setState(() => _isFetchingLocation = false);
        }
      } catch (e) {
        setState(() => _isFetchingLocation = false);
      }
    });
  }

  void _onChooseOnMap() async {
    var result = await Get.toNamed(
      RouteHelper.getPickMapRoute('add-address', false),
      arguments: PickMapScreen(
        fromAddAddress: true,
        fromSignUp: false,
        fromSplash: false,
        googleMapController: Get.find<LocationController>().mapController,
        route: null,
        canRoute: false,
        fromNewUserBottomSheet: true,
      ),
    );
    if (result is AddressModel) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  Future<void> _onSaveAddress() async {
    if (_selectedAddress == null || _selectedAddress!.latitude == null) {
      showCustomSnackBar('Please detect or choose your location first'.tr);
      return;
    }

    if (_houseController.text.trim().isEmpty) {
      showCustomSnackBar('Please enter house / flat / floor number'.tr);
      _houseFocus.requestFocus();
      return;
    }

    setState(() => _isSaving = true);

    try {
      ZoneResponseModel response = await Get.find<LocationController>().getZone(
        _selectedAddress!.latitude,
        _selectedAddress!.longitude,
        false,
      );

      if (!response.isSuccess) {
        setState(() => _isSaving = false);
        showCustomSnackBar('service_not_available_in_current_location'.tr);
        return;
      }

      _selectedAddress!.zoneId = response.zoneIds.isNotEmpty ? response.zoneIds[0] : 0;
      _selectedAddress!.zoneIds = response.zoneIds;
      _selectedAddress!.zoneData = response.zoneData;
      _selectedAddress!.house = _houseController.text.trim();
      _selectedAddress!.road = _landmarkController.text.trim();
      _selectedAddress!.addressType = _selectedAddressType;
      _selectedAddress!.isDefault = true;

      if (AuthHelper.isLoggedIn()) {
        UserInfoModel? userInfo = Get.find<ProfileController>().userInfoModel;
        if (userInfo != null) {
          _selectedAddress!.contactPersonName = '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim();
          _selectedAddress!.contactPersonNumber = userInfo.phone;
          _selectedAddress!.email = userInfo.email;
        }
      }

      await AddressHelper.saveAddressInSharedPref(_selectedAddress!);

      if (AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
        await Get.find<AddressController>().addAddress(_selectedAddress!, false, _selectedAddress!.zoneId);
      }

      HomeScreen.loadData(true);
      setState(() => _isSaving = false);
      Get.back();
      showCustomSnackBar('Address saved successfully!'.tr, isError: false);
    } catch (e) {
      setState(() => _isSaving = false);
      showCustomSnackBar('Failed to save address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: isDesktop ? 550 : double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusOverLarge)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: context.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
              ),

              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_rounded, color: context.primary, size: 24),
                  ),
                  const SizedBox(width: Dimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Delivery Address'.tr,
                          style: context.heading.large.strong,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Save once to see nearby restaurants and enjoy instant checkout.'.tr,
                          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: context.iconBaseMedium),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              // Location Detection Card
              Text(
                '1. Select Location'.tr.toUpperCase(),
                style: context.body.extraSmall.medium.overrideWith(
                  color: context.primary,
                ).copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              if (_selectedAddress == null) ...[
                // Action Buttons to acquire location
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: _isFetchingLocation ? null : _onUseCurrentLocation,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.primary,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: _isFetchingLocation
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: context.onPrimary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Detecting...'.tr,
                                      style: context.heading.small.medium.overrideWith(color: context.onPrimary),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.my_location_rounded, size: 18, color: context.onPrimary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Use Current Location'.tr,
                                        style: context.heading.small.medium.overrideWith(color: context.onPrimary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _onChooseOnMap,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: context.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 18, color: context.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Choose on Map'.tr,
                                  style: context.heading.small.medium.overrideWith(color: context.textBaseDefault),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Detected Address Preview Card
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingDefault),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: context.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: context.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, size: 12, color: context.onPrimary),
                      ),
                      const SizedBox(width: Dimensions.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Area'.tr,
                              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedAddress!.address ?? 'Location selected'.tr,
                              style: context.heading.small.medium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _onChooseOnMap,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            'Change'.tr,
                            style: context.heading.small.strong.overrideWith(color: context.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Dimensions.paddingLarge),

              // Address Details Input Fields
              Text(
                '2. Address Details'.tr.toUpperCase(),
                style: context.body.extraSmall.medium.overrideWith(
                  color: context.primary,
                ).copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              CustomTextFieldWidget(
                labelText: 'House / Flat / Floor No. *'.tr,
                hintText: 'e.g. Flat 402, Building A'.tr,
                controller: _houseController,
                focusNode: _houseFocus,
                nextFocus: _landmarkFocus,
                inputType: TextInputType.streetAddress,
                prefixIcon: Icons.home_work_outlined,
                showBorder: true,
                required: true,
              ),

              const SizedBox(height: Dimensions.paddingDefault),

              CustomTextFieldWidget(
                labelText: 'Landmark / Street (Optional)'.tr,
                hintText: 'e.g. Near City Park or Metro Station'.tr,
                controller: _landmarkController,
                focusNode: _landmarkFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.text,
                prefixIcon: Icons.place_outlined,
                showBorder: true,
              ),

              const SizedBox(height: Dimensions.paddingLarge),

              // Save As Chips
              Text(
                'Save As'.tr,
                style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              Row(
                children: [
                  _addressTypeChip(label: 'Home'.tr, icon: Icons.home_filled, type: 'home'),
                  const SizedBox(width: Dimensions.paddingSmall),
                  _addressTypeChip(label: 'Office'.tr, icon: Icons.work_rounded, type: 'office'),
                  const SizedBox(width: Dimensions.paddingSmall),
                  _addressTypeChip(label: 'Other'.tr, icon: Icons.location_on_rounded, type: 'others'),
                ],
              ),

              const SizedBox(height: Dimensions.paddingExtraLarge),

              // Save Button
              CustomButtonWidget(
                buttonText: 'Save Address & Continue'.tr,
                isLoading: _isSaving,
                radius: Dimensions.radiusDefault,
                onPressed: _isSaving ? null : _onSaveAddress,
              ),
              const SizedBox(height: Dimensions.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressTypeChip({required String label, required IconData icon, required String type}) {
    bool isSelected = _selectedAddressType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedAddressType = type),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? context.primary.withValues(alpha: 0.12) : context.surfaceContainerLow,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
              color: isSelected ? context.primary : context.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? context.primary : context.iconBaseMedium,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.body.small.medium.overrideWith(
                  color: isSelected ? context.primary : context.textBaseDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
