import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_confirmation_dialogue_widget.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class AddressCardWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  final int? index;
  const AddressCardWidget({super.key, required this.address, required this.fromAddress, this.onTap, this.fromCheckout = false,
    this.isSelected = false, this.fromDashBoard = false, this.index});

  @override
  Widget build(BuildContext context) {
    if(fromAddress && ResponsiveHelper.isMobile(context)) {
      return _buildFromAddressCard(context);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: fromCheckout ? 0 : Dimensions.paddingSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingDefault : Dimensions.paddingSmall),
          decoration: fromDashBoard ? BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: isSelected ? context.primary : Colors.transparent, width: isSelected ? 1 : 0),
          ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            border: Border.all(color: isSelected ? context.primary : context.surfaceContainer, width: isSelected ? 0.5 : 0),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(mainAxisSize: MainAxisSize.min, children: [

                  CustomAssetImageWidget(
                    address?.addressType == 'home' ? Images.navHome : address?.addressType == 'office' ? Images.office : Images.others,
                    height: ResponsiveHelper.isDesktop(context) ? 25 : 20, width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Flexible(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(address?.addressType?.tr ?? '', style: context.subHeading.large.strong),

                        (address?.isDefault ?? false) ? Container(
                          margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                          ),
                          child: Text('default'.tr, style: context.body.defaultSize.medium.overrideWith(color: Colors.blue)),
                        ) : const SizedBox(),
                      ]),
                    
                      Text(
                        address?.address ?? '',
                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),

                ]),
              ]),
            ),

            fromAddress ? PopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'is_default',
                    child: Row(children: [
                      Expanded(child: Text('mark_as_default'.tr, style: context.body.defaultSize.regular)),
                      SizedBox(width: 20),

                      Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Colors.green, size: 20),
                    ]),
                  ),

                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Expanded(child: Text('edit'.tr, style: context.body.defaultSize.regular)),
                      SizedBox(width: 20),

                      Icon(CupertinoIcons.pencil_circle_fill, color: Colors.blue, size: 20),
                    ]),
                  ),

                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Expanded(child: Text('delete'.tr, style: context.body.defaultSize.regular)),
                      SizedBox(width: 20),

                      Icon(CupertinoIcons.delete, color: Colors.red, size: 20),
                    ]),
                  ),
                ];
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
              child: Icon(Icons.more_vert, size: 20, color: context.primary),
              onSelected: (dynamic value) {
                if (value == 'delete') {
                  if(Get.isSnackbarOpen) {
                    Get.back();
                  }
                  showCustomDialog(
                    child: AddressConfirmDialogueWidget(
                    icon: Images.locationConfirm,
                    title: 'are_you_sure'.tr,
                    description: 'you_want_to_delete_this_location'.tr,
                    onYesPressed: () {
                      Get.find<AddressController>().deleteAddress(address?.id, index!).then((response) {
                        Get.back();
                        showCustomSnackBar(response.message, isError: !response.isSuccess);
                      });
                    },
                  ),
                  );
                }else if (value == 'edit'){
                  Get.toNamed(RouteHelper.getEditAddressRoute(address));
                }else if (value == 'is_default'){
                  if(Get.isSnackbarOpen) {
                    Get.back();
                  }
                  showCustomDialog(
                    child: AddressConfirmDialogueWidget(
                    isDefault: true,
                    icon: Images.locationConfirm,
                    title: 'are_you_sure'.tr,
                    description: 'you_want_to_default_this_location'.tr,
                    onYesPressed: () {
                      Get.find<AddressController>().markDefault(address!.id!).then((response) {
                        Get.back();
                        showCustomSnackBar(response.message, isError: !response.isSuccess);
                      });
                    },
                  ),
                  );
                }
              },
            ) : const SizedBox(),

          ]),
        ),
      ),
    );
  }

  Widget _buildFromAddressCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: onTap as void Function()?,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge+1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              CustomAssetImageWidget(
                address?.addressType == 'home' ? Images.navHome : address?.addressType == 'office' ? Images.office : Images.others,
                height: 16, width: 16,
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(
                child: Text(
                  address?.addressType?.tr ?? '',
                  style: context.heading.large.strong,
                ),
              ),

              (address?.isDefault ?? false) ? Container(
                height: 24, alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                child: Text('default'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: Colors.green)),
              ) : const SizedBox(),

              PopupMenuButton(
                itemBuilder: (context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 'is_default',
                      child: Row(children: [
                        Expanded(child: Text('mark_as_default'.tr, style: context.body.defaultSize.regular)),
                        const SizedBox(width: 20),

                        const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Colors.green, size: 20),
                      ]),
                    ),

                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Expanded(child: Text('edit'.tr, style: context.body.defaultSize.regular)),
                        const SizedBox(width: 20),

                        const Icon(CupertinoIcons.pencil_circle_fill, color: Colors.blue, size: 20),
                      ]),
                    ),

                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Expanded(child: Text('delete'.tr, style: context.body.defaultSize.regular)),
                        const SizedBox(width: 20),

                        const Icon(CupertinoIcons.delete, color: Colors.red, size: 20),
                      ]),
                    ),
                  ];
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                padding: EdgeInsets.zero,
                child: Icon(Icons.more_vert, size: 20),
                onSelected: (dynamic value) {
                  if (value == 'delete') {
                    if(Get.isSnackbarOpen) {
                      Get.back();
                    }
                    showCustomDialog(
                      child: AddressConfirmDialogueWidget(
                      icon: Images.locationConfirm,
                      title: 'are_you_sure'.tr,
                      description: 'you_want_to_delete_this_location'.tr,
                      onYesPressed: () {
                        Get.find<AddressController>().deleteAddress(address?.id, index!).then((response) {
                          Get.back();
                          showCustomSnackBar(response.message, isError: !response.isSuccess);
                        });
                      },
                    ),
                    );
                  }else if (value == 'edit'){
                    Get.toNamed(RouteHelper.getEditAddressRoute(address));
                  }else if (value == 'is_default'){
                    if(Get.isSnackbarOpen) {
                      Get.back();
                    }
                    showCustomDialog(
                      child: AddressConfirmDialogueWidget(
                      isDefault: true,
                      icon: Images.locationConfirm,
                      title: 'are_you_sure'.tr,
                      description: 'you_want_to_default_this_location'.tr,
                      onYesPressed: () {
                        Get.find<AddressController>().markDefault(address!.id!).then((response) {
                          Get.back();
                          showCustomSnackBar(response.message, isError: !response.isSuccess);
                        });
                      },
                    ),
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSmall),

            Divider(height: Dimensions.paddingLarge),
            const SizedBox(height: Dimensions.paddingSmall),

            RichText(text: TextSpan(children: [
              TextSpan(text: address?.contactPersonName?.toCapitalized() ?? '', style: context.subHeading.large.medium),
              TextSpan(text: '  (${address?.contactPersonNumber ?? ''})', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
            ])),
            const SizedBox(height: Dimensions.paddingDefault),

            Text(
              address?.address ?? '',
              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: Dimensions.paddingSmall),
          ]),
        ),
      ),
    );
  }
}