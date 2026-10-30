import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/saved_address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliverySection extends StatefulWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
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

  const DeliverySection({super.key, required this.checkoutController,
    required this.locationController, required this.guestNameController, required this.guestNumberController, required this.guestEmailController,
    required this.guestAddressController, required this.guestStreetNumberController, required this.guestHouseController, required this.guestFloorController,
    required this.guestNameNode, required this.guestNumberNode, required this.guestEmailNode, required this.guestAddressNode, required this.guestStreetNumberNode,
    required this.guestHouseNode, required this.guestFloorNode});

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {

  @override
  void initState() {
    super.initState();
    widget.checkoutController.setShowMoreDetails(false, willUpdate: false);
    if (widget.checkoutController.address == null) {
      widget.checkoutController.initLiveAddress();
    }
  }

  void _onEditAddressTap(CheckoutController checkoutController) {
    if(ResponsiveHelper.isDesktop(context)) {
      Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: SavedAddressBottomSheet()));
    } else {
      showCustomBottomSheet(child: const SavedAddressBottomSheet());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool takeAway = (widget.checkoutController.orderType == 'take_away');
    bool isDineIn = (widget.checkoutController.orderType == 'dine_in');
    bool homeDelivery = !takeAway && !isDineIn;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Column(children: [
        !homeDelivery ? _RestaurantLocationCard(checkoutController: checkoutController, isDesktop: isDesktop)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => _onEditAddressTap(checkoutController),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault),
              padding: const EdgeInsets.all(Dimensions.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: context.surface,
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Align( alignment: Alignment.topCenter,
                  child: Container(
                    width: 28, height: 28, padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: CustomAssetImageWidget(
                      checkoutController.addressType == 'home' ? Images.homeIcon : checkoutController.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                      height: ResponsiveHelper.isDesktop(context) ? 25 : 18, width: ResponsiveHelper.isDesktop(context) ? 25 : 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingMedium),
          
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: Dimensions.paddingSmall,
                            runSpacing: 4,
                            children: [
                              Text(
                                "delivery_address".tr,
                                style: context.heading.large.strong,
                              ),
                              if (checkoutController.isLiveAddress)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text('live'.tr.isEmpty ? 'Live' : 'live'.tr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ]),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSmall),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(color: context.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.edit_location_alt_outlined, size: 14, color: context.primary),
                            const SizedBox(width: 4),
                            Text(
                              'change'.tr.isEmpty ? 'Change' : 'change'.tr,
                              style: context.subHeading.small.semiBold.overrideWith(color: context.primary),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.padding2xSmall),
          
                    Text(
                      checkoutController.isLiveLocationLoading && checkoutController.addressController.text.trim().isEmpty
                          ? 'fetching_location'.tr
                          : checkoutController.addressController.text.trim(),
                      style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),

                    checkoutController.needCoverageAreaSelection ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
                      child: checkoutController.selectedCoverageArea != null ? RichText(
                        text: TextSpan(
                          text: '${checkoutController.isZipCodeWiseDelivery ? 'zip_code'.tr : 'area'.tr} : ',
                          style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium),
                          children: [
                            TextSpan(
                              text: checkoutController.selectedCoverageArea!.name ?? '',
                              style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium),
                            ),
                          ],
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : InkWell(
                        onTap: showDeliveryAddressBottomSheet,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          RichText(
                            text: TextSpan(
                              text: checkoutController.isZipCodeWiseDelivery ? 'select_zip_code'.tr : 'select_area'.tr,
                              style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.textBaseMedium),
                              children: [
                                TextSpan(text: ' *', style: context.subHeading.defaultSize.semiBold.overrideWith(color: context.error)),
                              ],
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: Dimensions.padding2xSmall),

                          Icon(Icons.keyboard_arrow_down, size: 18, color: context.primary),
                        ]),
                      ),
                    ) : const SizedBox(),
                  ]),
                ),
              ]),
            ),
          ),
          SizedBox(height: checkoutController.streetNumberController.text.isNotEmpty || checkoutController.houseController.text.isNotEmpty || checkoutController.floorController.text.isNotEmpty ? Dimensions.paddingDefault : 0),
        
          checkoutController.streetNumberController.text.isNotEmpty || checkoutController.houseController.text.isNotEmpty || checkoutController.floorController.text.isNotEmpty ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Wrap(children: [
              
              checkoutController.streetNumberController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: '${'street'.tr} : ',
                  style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  children: [
                    TextSpan(
                      text: checkoutController.streetNumberController.text,
                      style: context.subHeading.defaultSize.medium,
                    ),
                    TextSpan(
                      text: " ",
                      style: context.subHeading.defaultSize.medium,
                    ),
                  ],
                ),
              ) : SizedBox(),
                    
              checkoutController.streetNumberController.text.isNotEmpty ? Container(
                height: 15, width: 1,
                color: context.bgNeutralMedium,
              ) : const SizedBox(),
                    
              checkoutController.houseController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: ' ${'house'.tr} : ',
                  style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  children: [
                    TextSpan(
                      text: checkoutController.houseController.text,
                      style: context.subHeading.defaultSize.medium,
                    ),
                    TextSpan(text: " "),
                  ],
                ),
              ) : SizedBox(),
                    
              checkoutController.houseController.text.isNotEmpty ? Container(
                height: 15, width: 1, color: context.outline) : SizedBox(),
                    
              checkoutController.floorController.text.isNotEmpty ? RichText(
                text: TextSpan(
                  text: ' ${'floor'.tr} : ',
                  style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  children: [
                    TextSpan(
                      text: checkoutController.floorController.text,
                      style: context.subHeading.defaultSize.medium,
                    ),
                  ],
                ),
              ) : SizedBox(),
            ]),
          ) : Center(
            child: Column(children: [
        
              Visibility(
                visible: !checkoutController.showMoreDetails,
                child: Padding(
                  padding: EdgeInsets.only(top: Dimensions.paddingSmall),
                  child: InkWell(
                    onTap: () {
                      checkoutController.setShowMoreDetails(true);
                    },
                    child: Text('${'add_more_details'.tr} +', style: context.subHeading.defaultSize.strong.overrideWith(color: context.primary)),
                  ),
                ),
              ),
        
              Visibility(
                visible: checkoutController.showMoreDetails,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault+1),
                  child: Column(children: [
                    SizedBox(height: Dimensions.paddingLarge),
                          
                    !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
                      hintText: 'write_street_number'.tr,
                      labelText: 'street_number'.tr,
                      inputType: TextInputType.streetAddress,
                      focusNode: widget.checkoutController.streetNode,
                      nextFocus: widget.checkoutController.houseNode,
                      controller: widget.checkoutController.streetNumberController,
                    ) : const SizedBox(),
                    SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : 0),
                          
                    Row(
                      children: [
                        ResponsiveHelper.isDesktop(context) ? Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_street_number'.tr,
                            labelText: 'street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: widget.checkoutController.streetNode,
                            nextFocus: widget.checkoutController.houseNode,
                            controller: widget.checkoutController.streetNumberController,
                            showTitle: false,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSmall : 0),
                          
                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_house_number'.tr,
                            labelText: 'house'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.houseNode,
                            nextFocus: widget.checkoutController.floorNode,
                            controller: widget.checkoutController.houseController,
                            showTitle: false,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSmall),
                          
                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'write_floor_number'.tr,
                            labelText: 'floor'.tr,
                            inputType: TextInputType.text,
                            focusNode: widget.checkoutController.floorNode,
                            inputAction: TextInputAction.done,
                            controller: widget.checkoutController.floorController,
                            showTitle: false,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
        
            ]),
          ),

        ]),
      ]);
    });
  }
}

class _RestaurantLocationCard extends StatelessWidget {
  final CheckoutController checkoutController;
  final bool isDesktop;
  const _RestaurantLocationCard({required this.checkoutController, required this.isDesktop});
  

  void _openMap() {
    final restaurant = checkoutController.restaurant;
    if(restaurant == null) {
      return;
    }
    Get.toNamed(RouteHelper.getMapRoute(
      AddressModel(
        id: restaurant.id, address: restaurant.address, latitude: restaurant.latitude,
        longitude: restaurant.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
      ), 'restaurant',
      restaurantName: restaurant.name,
    ));
  }

  @override
  Widget build(BuildContext context) {
    print("adressssssss====> ${checkoutController.restaurant?.address}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingDefault),
      padding: const EdgeInsets.all(Dimensions.paddingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2),
        color: context.surface,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 28, height: 28, padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
            child: Icon(Icons.location_on_outlined, color: context.iconBaseMedium, size: 24),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('restaurant_location'.tr, style: context.heading.large.strong),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text(
              checkoutController.restaurant?.address?.trim() ?? '',
              style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Column(
          children: [
            SizedBox(height: Dimensions.paddingLarge),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: _openMap,
                child: Icon(Icons.map_outlined, size: 24, color: context.textInfosMedium),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
