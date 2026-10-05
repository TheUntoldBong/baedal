import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/screens/pick_map_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DeliveryInfoFields extends StatefulWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final TextEditingController guestAddressController;
  final TextEditingController guestStreetNumberController;
  final TextEditingController guestHouseController;
  final TextEditingController guestFloorController;
  final FocusNode guestNameNode;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final FocusNode guestAddressNode;
  final FocusNode guestStreetNumberNode;
  final FocusNode guestHouseNode;
  final FocusNode guestFloorNode;

  const DeliveryInfoFields({super.key, required this.checkoutController,
    required this.guestNameController, required this.guestNumberController, required this.guestEmailController,
    required this.guestAddressController, required this.guestStreetNumberController, required this.guestHouseController, required this.guestFloorController,
    required this.guestNameNode, required this.guestNumberNode, required this.guestEmailNode, required this.guestAddressNode, required this.guestStreetNumberNode,
    required this.guestHouseNode, required this.guestFloorNode});

  @override
  State<DeliveryInfoFields> createState() => _DeliveryInfoFieldsState();
}

class _DeliveryInfoFieldsState extends State<DeliveryInfoFields> {

  @override
  void initState() {
    super.initState();
    AddressModel address = AddressHelper.getAddressFromSharedPref()!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LocationController>().updateAddress(address);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDineIn = (widget.checkoutController.orderType == 'dine_in');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<LocationController>(builder: (locationController) {
      widget.guestAddressController.text = locationController.address ?? '';

      return Container(
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(takeAway || isDineIn ? 'contact_information'.tr : 'deliver_to'.tr, style: context.subHeading.defaultSize.medium),
          const SizedBox(height: Dimensions.paddingDefault),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: takeAway || isDineIn ? Border.all(color: context.primary.withValues(alpha: 0.2)) : null,
            ),
            child: takeAway || isDineIn ? Column(children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingDefault),
                child: Column(children: [
                  const SizedBox(height: Dimensions.paddingSmall),

                  CustomTextFieldWidget(
                    showTitle: false,
                    hintText: 'enter_your_name'.tr,
                    inputType: TextInputType.name,
                    controller: widget.guestNameController,
                    focusNode: widget.guestNameNode,
                    nextFocus: widget.guestNumberNode,
                    capitalization: TextCapitalization.words,
                    labelText: 'contact_person_name'.tr,
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  CustomTextFieldWidget(
                    labelText: 'contact_person_number'.tr,
                    hintText: 'xxx-xxx-xxxxx'.tr,
                    controller: widget.guestNumberController,
                    focusNode: widget.guestNumberNode,
                    nextFocus: widget.guestEmailNode,
                    inputType: TextInputType.phone,
                    isPhone: true,
                    onCountryChanged: (CountryCode countryCode) {
                      widget.checkoutController.countryDialCode = countryCode.dialCode;
                    },
                    countryDialCode: widget.checkoutController.countryDialCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  CustomTextFieldWidget(
                    labelText: 'email'.tr,
                    hintText: 'enter_email'.tr,
                    controller: widget.guestEmailController,
                    focusNode: widget.guestEmailNode,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.emailAddress,
                  ),

                ]),
              ),
            ]) : Column(crossAxisAlignment: CrossAxisAlignment.start,  children: [

              CustomTextFieldWidget(
                showTitle: false,
                required: true,
                hintText: 'enter_your_name'.tr,
                inputType: TextInputType.name,
                controller: widget.guestNameController,
                focusNode: widget.guestNameNode,
                nextFocus: widget.guestNumberNode,
                capitalization: TextCapitalization.words,
                labelText: 'contact_person_name'.tr,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              CustomTextFieldWidget(
                labelText: 'contact_person_number'.tr,
                hintText: 'xxx-xxx-xxxxx'.tr,
                required: true,
                controller: widget.guestNumberController,
                focusNode: widget.guestNumberNode,
                nextFocus: widget.guestEmailNode,
                inputType: TextInputType.phone,
                isPhone: true,
                onCountryChanged: (CountryCode countryCode) {
                  widget.checkoutController.countryDialCode = countryCode.dialCode;
                },
                countryDialCode: widget.checkoutController.countryDialCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              CustomTextFieldWidget(
                labelText: 'email'.tr,
                hintText: 'enter_email'.tr,
                controller: widget.guestEmailController,
                focusNode: widget.guestEmailNode,
                nextFocus: widget.guestAddressNode,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(
                      RouteHelper.getPickMapRoute('add-address', false),
                      arguments: PickMapScreen(
                        fromAddAddress: true, fromSignUp: false, fromSplash: false,
                        googleMapController: locationController.mapController,
                        route: null, canRoute: false, fromGuestCheckout: true,
                      ),
                    );
                  },
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.location_on, size: 18, color: context.primary),
                    SizedBox(width: 3),

                    Text('select_from_map'.tr, style: context.subHeading.small.regular.overrideWith(color: context.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              CustomTextFieldWidget(
                hintText: 'delivery_address'.tr,
                labelText: 'address'.tr,
                required: true,
                inputType: TextInputType.streetAddress,
                controller: widget.guestAddressController,
                focusNode: widget.guestAddressNode,
                nextFocus: widget.guestStreetNumberNode,
                onChanged: (text) => locationController.setPlaceMark(text),
              ),

              Center(
                child: Visibility(
                  visible: !widget.checkoutController.showMoreDetails,
                  child: Padding(
                    padding: EdgeInsets.only(top: Dimensions.paddingLarge),
                    child: InkWell(
                      onTap: () {
                        widget.checkoutController.setShowMoreDetails(true);
                      },
                      child: Text('${'add_more_details'.tr} +', style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary)),
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: widget.checkoutController.showMoreDetails,
                child: Column(children: [
                  SizedBox(height: Dimensions.paddingLarge),

                  !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
                    hintText: 'write_street_number'.tr,
                    labelText: 'street_number'.tr,
                    inputType: TextInputType.streetAddress,
                    controller: widget.guestStreetNumberController,
                    focusNode: widget.guestStreetNumberNode,
                    nextFocus: widget.guestHouseNode,
                  ) : const SizedBox(),
                  SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : 0),

                  Row(
                    children: [
                      ResponsiveHelper.isDesktop(context) ? Expanded(
                        child: CustomTextFieldWidget(
                          hintText: 'write_street_number'.tr,
                          labelText: 'street_number'.tr,
                          inputType: TextInputType.streetAddress,
                          controller: widget.guestStreetNumberController,
                          focusNode: widget.guestStreetNumberNode,
                          nextFocus: widget.guestHouseNode,
                          showTitle: false,
                        ),
                      ) : const SizedBox(),
                      SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSmall : 0),

                      Expanded(
                        child: CustomTextFieldWidget(
                          hintText: 'write_house_number'.tr,
                          labelText: 'house'.tr,
                          inputType: TextInputType.text,
                          controller: widget.guestHouseController,
                          focusNode: widget.guestHouseNode,
                          nextFocus: widget.guestFloorNode,
                          showTitle: false,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Expanded(
                        child: CustomTextFieldWidget(
                          hintText: 'write_floor_number'.tr,
                          labelText: 'floor'.tr,
                          inputType: TextInputType.text,
                          controller: widget.guestFloorController,
                          focusNode: widget.guestFloorNode,
                          inputAction: TextInputAction.done,
                          showTitle: false,
                        ),
                      ),
                    ],
                  ),
                ]),
              ),

            ]),
          ),

        ]),
      );
    });
  }
}
