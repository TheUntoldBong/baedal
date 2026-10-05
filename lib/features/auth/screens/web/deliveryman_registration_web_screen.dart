import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_drop_down_button.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/gap_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/deliveryman_additional_data_section_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/pass_view_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DeliverymanRegistrationWebScreen extends StatefulWidget {
  final ScrollController scrollController;
  final TextEditingController fNameController;
  final TextEditingController lNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController identityNumberController;
  final FocusNode fNameNode;
  final FocusNode lNameNode;
  final FocusNode emailNode;
  final FocusNode phoneNode;
  final FocusNode passwordNode;
  final FocusNode confirmPasswordNode;
  final FocusNode identityNumberNode;
  final String? countryDialCode;
  final Widget buttonView;
  const DeliverymanRegistrationWebScreen({
    super.key, required this.scrollController, required this.fNameController, required this.lNameController, required this.emailController,
    required this.phoneController, required this.passwordController, required this.confirmPasswordController,
    required this.identityNumberController, required this.fNameNode, required this.lNameNode, required this.emailNode,
    required this.phoneNode, required this.passwordNode, required this.confirmPasswordNode, required this.identityNumberNode,
    this.countryDialCode, required this.buttonView,
  });

  @override
  State<DeliverymanRegistrationWebScreen> createState() => _DeliverymanRegistrationWebScreenState();
}

class _DeliverymanRegistrationWebScreenState extends State<DeliverymanRegistrationWebScreen> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliverymanRegistrationController>(builder: (deliverymanController) {
      return SingleChildScrollView(
        controller: widget.scrollController,
        child: SizedBox(
          child: Center(
            child: Column(children: [
              const Gap(Dimensions.paddingLarge),

              Text('delivery_man_registration'.tr, style: context.heading.large.medium),
              const SizedBox(height: Dimensions.paddingSmall),

              Text(
                'complete_registration_process_to_serve_as_delivery_man_in_this_platform'.tr,
                style: context.body.small.medium.overrideWith(color: context.textBaseMedium),
              ),
              const Gap(Dimensions.paddingLarge),

              SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('delivery_man_information'.tr, style: context.heading.defaultSize.medium),
                      const Gap(Dimensions.paddingSmall),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          flex: 2,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Row(children: [
                              Expanded(child: CustomTextFieldWidget(
                                hintText: 'write_first_name'.tr,
                                controller: widget.fNameController,
                                capitalization: TextCapitalization.words,
                                inputType: TextInputType.name,
                                focusNode: widget.fNameNode,
                                nextFocus: widget.lNameNode,
                                prefixIcon: CupertinoIcons.person_alt_circle_fill,
                                labelText: 'first_name'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                              )),
                              const Gap.horizontal(Dimensions.paddingLarge),

                              Expanded(child: CustomTextFieldWidget(
                                hintText: 'write_last_name'.tr,
                                controller: widget.lNameController,
                                capitalization: TextCapitalization.words,
                                inputType: TextInputType.name,
                                focusNode: widget.lNameNode,
                                nextFocus: widget.phoneNode,
                                prefixIcon: CupertinoIcons.person_alt_circle_fill,
                                labelText: 'last_name'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "last_name_field_is_required".tr),
                              )),
                            ]),
                            const Gap(Dimensions.paddingExtraLarge),

                            Row(children: [
                              Expanded(child:CustomTextFieldWidget(
                                hintText: 'write_email'.tr,
                                controller: widget.emailController,
                                focusNode: widget.emailNode,
                                nextFocus: widget.passwordNode,
                                inputType: TextInputType.emailAddress,
                                prefixIcon: CupertinoIcons.mail_solid,
                                labelText: 'email'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmail(value),
                              )),
                              const Gap.horizontal(Dimensions.paddingLarge),

                              Expanded(child: Stack(clipBehavior: Clip.none, children: [
                                CustomDropdownButton(
                                  hintText: 'select_delivery_type'.tr,
                                  prefixIcon: CustomAssetImageWidget(Images.dmType, height: 20, width: 20, fit: BoxFit.contain,),
                                  items: deliverymanController.dmTypeList,
                                  selectedValue: deliverymanController.selectedDmType,
                                  onChanged: (value) {
                                    deliverymanController.setSelectedDmType(value);
                                  },
                                ),

                                Positioned(
                                  left: 12, top: -13,
                                  child: Container(
                                    color: context.surfaceContainer,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Row(children: [
                                      Text('select_delivery_type'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                      Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                    ]),
                                  ),
                                ),
                              ])),
                            ]),
                            const Gap(Dimensions.paddingExtraLarge),

                            Row(children: [
                              Expanded(child: deliverymanController.zoneList != null ? deliverymanController.zoneList!.isNotEmpty ? Stack(clipBehavior: Clip.none, children: [
                                CustomDropdownButton(
                                  hintText: 'select_delivery_zone'.tr,
                                  prefixIcon: CustomAssetImageWidget(Images.dmZone, height: 20, width: 20, fit: BoxFit.contain,),
                                  dropdownMenuItems: deliverymanController.zoneList!.map((zone) => DropdownMenuItem<String>(
                                    value: zone.id.toString(),
                                    child: Text(zone.name ?? '', style: context.subHeading.defaultSize.regular),
                                  )).toList(),
                                  selectedValue: deliverymanController.selectedDeliveryZoneId,
                                  onChanged: (value) {
                                    deliverymanController.setSelectedDeliveryZone(zoneId: value);
                                  },
                                ),

                                Positioned(
                                  left: 12, top: -13,
                                  child: Container(
                                    color: context.surfaceContainer,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Row(children: [
                                      Text('select_delivery_zone'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                      Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                    ]),
                                  ),
                                ),
                              ]) : ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: Shimmer(
                                  child: Container(height: 50, color: Theme.of(context).shadowColor),
                                ),
                              ) : Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).shadowColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                height: 50,
                                child: Center(
                                  child: Text('no_zone_available'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                ),
                              )),
                              const Gap.horizontal(Dimensions.paddingLarge),

                              Expanded(
                                child: deliverymanController.vehicles != null ? deliverymanController.vehicles!.isNotEmpty ? Stack(clipBehavior: Clip.none, children: [
                                  CustomDropdownButton(
                                    hintText: 'select_vehicle_type'.tr,
                                    prefixIcon: CustomAssetImageWidget(Images.vehicleType, height: 20, width: 20, fit: BoxFit.contain,),
                                    dropdownMenuItems: deliverymanController.vehicles!.map((vehicle) => DropdownMenuItem<String>(
                                      value: vehicle.id.toString(),
                                      child: Text(vehicle.type ?? '', style: context.subHeading.defaultSize.regular),
                                    )).toList(),
                                    selectedValue: deliverymanController.selectedVehicleId,
                                    onChanged: (value) {
                                      deliverymanController.setSelectedVehicleType(vehicleId: value);
                                    },
                                  ),

                                  Positioned(
                                    left: 12, top: -13,
                                    child: Container(
                                      color: context.surfaceContainer,
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Row(children: [
                                        Text('select_vehicle_type'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                        Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                      ]),
                                    ),
                                  ),
                                ]) : ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  child: Shimmer(
                                    child: Container(height: 50, color: Theme.of(context).shadowColor),
                                  ),
                                ) : Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).shadowColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  height: 50,
                                  child: Center(
                                    child: Text('no_vehicle_available'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                  ),
                                ),
                              ),
                            ]),

                            (deliverymanController.selectedDmType == 'freelancer') ?
                            (deliverymanController.shifts != null && deliverymanController.shifts!.isNotEmpty) ?
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const SizedBox(height: Dimensions.paddingLarge),

                              Stack(clipBehavior: Clip.none, children: [
                                CustomDropdownButton(
                                  hintText: 'working_shift'.tr,
                                  prefixIcon: CustomAssetImageWidget(Images.workingShift, height: 20, width: 20, fit: BoxFit.contain,),
                                  dropdownMenuItems: deliverymanController.shifts!.map((shift) {
                                    bool isSelected = deliverymanController.selectedShifts.any((deliveryManShift) => deliveryManShift.id == shift.id);
                                    bool isFullDay = shift.isFullDay == 1;
                                    bool hasFullDay = deliverymanController.selectedShifts.any((deliveryManShift) => deliveryManShift.isFullDay == 1);
                                    bool hasOtherShifts = deliverymanController.selectedShifts.any((deliveryManShift) => deliveryManShift.isFullDay != 1);
                                    bool shouldDisable = isSelected || (isFullDay && hasOtherShifts) || (!isFullDay && hasFullDay);

                                    return DropdownMenuItem<ShiftModel>(
                                      value: shift,
                                      enabled: !shouldDisable,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected ? context.surfaceContainer : Colors.transparent,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                        ),
                                        child: Text(
                                          '${shift.name} (${DateConverter.timeStringToTime(shift.startTime!)} - ${DateConverter.timeStringToTime(shift.endTime!)})',
                                          style: context.body.defaultSize.regular.overrideWith(
                                            color: shouldDisable ? context.textBaseMedium : context.textBaseDefault,
                                          ), maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  selectedValue: null,
                                  selectedItemBuilder: (BuildContext context) {
                                    return (deliverymanController.shifts ?? []).map((shift) {
                                      return Text('working_shift'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium));
                                    }).toList();
                                  },
                                  onChanged: (value) {
                                    if (value != null && !deliverymanController.selectedShifts.any((s) => s.id == value.id)) {
                                      deliverymanController.toggleShift(value);
                                    }
                                  },
                                ),

                                Positioned(left: 12, top: -13,
                                  child: Container(
                                    color: context.surfaceContainer,
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Row(children: [
                                      Text('working_shift'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                      Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),

                              deliverymanController.selectedShifts.isNotEmpty ? Column(children: [
                                const SizedBox(height: Dimensions.paddingSmall),
                                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.start, children: List.generate(
                                    deliverymanController.selectedShifts.length,
                                    growable: true, (index) {
                                  final shift = deliverymanController.selectedShifts[index];
                                  return Chip(
                                    label: Text(shift.name ?? '', style: context.subHeading.small.medium.overrideWith(color: context.textBaseDefault)),
                                    deleteIcon: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                                    onDeleted: () {
                                      deliverymanController.removeShift(shift);
                                    },
                                    backgroundColor: context.surfaceContainer,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge), side: BorderSide(color: context.outlineVariant),),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 4),
                                  );
                                }),
                                )]
                              ) : SizedBox.shrink(),

                              const SizedBox(height: Dimensions.paddingOverLarge),
                            ]) : SizedBox.shrink() : SizedBox.shrink(),
                          ]),
                        ),
                        Gap.horizontal(Dimensions.paddingLarge),

                        Expanded(
                          flex: 1,
                          child: Container(
                            width: context.width,
                            decoration: BoxDecoration(
                              color: context.surfaceContainer,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(
                                children: [
                                  Text('delivery_man_image'.tr, style: context.heading.small.medium),
                                  Text(' *', style: context.heading.small.medium.overrideWith(color: context.error)),
                                ],
                              ),
                              const Gap(Dimensions.paddingSmall),

                              Align(
                                alignment: Alignment.center,
                                child: Stack(clipBehavior: Clip.none, children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    child: deliverymanController.pickedImage != null ? GetPlatform.isWeb ? Image.network(
                                      deliverymanController.pickedImage!.path, width: 100, height: 100, fit: BoxFit.cover,
                                    ) : Image.file(
                                      File(deliverymanController.pickedImage!.path), width: 100, height: 100, fit: BoxFit.cover,
                                    ) : Container(
                                      width: 100, height: 100,
                                      decoration: BoxDecoration(
                                        color: context.surfaceContainer,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      ),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                        CustomAssetImageWidget(Images.pictureIcon, width: 25, height: 25, fit: BoxFit.cover),
                                        const SizedBox(height: Dimensions.paddingSmall),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                          child: Text(
                                            'click_to_add'.tr,
                                            style: context.body.small.regular.overrideWith(color: Colors.blue), textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 0, right: 0, top: 0, left: 0,
                                    child: InkWell(
                                      onTap: () => deliverymanController.pickDmImage(true, false),
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          color: context.outlineVariant,
                                          strokeWidth: 1,
                                          strokeCap: StrokeCap.butt,
                                          dashPattern: const [5, 5],
                                          padding: const EdgeInsets.all(0),
                                          radius: const Radius.circular(Dimensions.radiusDefault),
                                        ),
                                        child: const SizedBox(),
                                      ),
                                    ),
                                  ),

                                  deliverymanController.pickedImage != null ? Positioned(
                                    bottom: -10, right: -10,
                                    child: InkWell(
                                      onTap: () => deliverymanController.removeDmImage(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: context.outline, width: 2),
                                          shape: BoxShape.circle, color: Theme.of(context).colorScheme.error,
                                        ),
                                        padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                                        child:  Icon(Icons.remove, size: 18, color: context.surfaceContainer,),
                                      ),
                                    ),

                                  ) : const SizedBox(),
                                ]),
                              ),
                              const Gap(Dimensions.paddingSmall),

                              Center(
                                child: Text(
                                  'jpg_png_jpeg_less_than_1_mb_ratio_1_1'.tr, textAlign: TextAlign.center,
                                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                                ),
                              ),
                              const Gap(Dimensions.paddingSmall),
                            ]),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  const Gap(Dimensions.paddingExtraLarge),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('identity_info'.tr, style: context.heading.defaultSize.medium),
                      const Gap(Dimensions.paddingLarge),

                      Row(children: [
                        Expanded(
                          child: Stack(clipBehavior: Clip.none, children: [
                            CustomDropdownButton(
                              hintText: 'select_identity_type'.tr,
                              prefixIcon: CustomAssetImageWidget(Images.identityType, height: 20, width: 20, fit: BoxFit.contain,),
                              items: deliverymanController.identityTypeList,
                              selectedValue: deliverymanController.selectedIdentityType,
                              onChanged: (value) {
                                deliverymanController.setSelectedIdentityType(value);
                              },
                            ),

                            Positioned(
                              left: 12, top: -13,
                              child: Container(
                                color: context.surfaceContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Row(children: [
                                  Text('select_identity_type'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                  Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                ]),
                              ),
                            ),
                          ]),
                        ),
                        const Gap.horizontal(Dimensions.paddingLarge),

                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'Ex: XXXXX-XXXXXXX-X',
                            controller: widget.identityNumberController,
                            focusNode: widget.identityNumberNode,
                            inputAction: TextInputAction.done,
                            labelText: 'identity_number'.tr,
                            required: true,
                            prefixIcon: Icons.twenty_mp_rounded,
                            fromDeliveryRegistration: true,
                            isEnabled: deliverymanController.selectedIdentityType != null,
                            validator: (value) => ValidateCheck.validateEmptyText(value, "identity_number_field_is_required".tr),
                          ),
                        ),
                      ]),
                      const Gap(Dimensions.paddingOverLarge),

                      Container(
                        width: context.width, height: 170,
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        child: Column(children: [
                          Row(
                            children: [
                              Text('identity_image'.tr, style: context.heading.small.medium),
                              Text(' *', style: context.heading.small.medium.overrideWith(color: context.error)),
                              const Gap.horizontal(Dimensions.padding2xSmall),

                              Text(
                                'upload_identity_image_ratio'.tr,
                                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                              ),
                            ],
                          ),
                          const Gap(Dimensions.paddingSmall),

                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: deliverymanController.pickedIdentities.length+1,
                              itemBuilder: (context, index) {
                                XFile? file = index == deliverymanController.pickedIdentities.length ? null : deliverymanController.pickedIdentities[index];
                                if(index == deliverymanController.pickedIdentities.length) {
                                  return InkWell(
                                    onTap: () => deliverymanController.pickDmImage(false, false),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        color: context.outlineVariant,
                                        strokeWidth: 1,
                                        strokeCap: StrokeCap.butt,
                                        dashPattern: const [5, 5],
                                        radius: const Radius.circular(Dimensions.radiusDefault),
                                      ),
                                      child: Container(
                                        height: 120, width: 250, alignment: Alignment.center,
                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          CustomAssetImageWidget(Images.pictureIcon, width: 25, height: 25, fit: BoxFit.cover),
                                          const SizedBox(height: Dimensions.paddingSmall),

                                          Text(
                                            'click_to_add'.tr,
                                            style: context.body.small.regular.overrideWith(color: Colors.blue), textAlign: TextAlign.center,
                                          ),
                                        ]),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                                  child: DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                      color: context.outlineVariant,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: Stack(children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        child: GetPlatform.isWeb ? Image.network(
                                          file!.path, width: 250, height: 120, fit: BoxFit.cover,
                                        ) : Image.file(
                                          File(file!.path), width: 250, height: 120, fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 10, top: 10,
                                        child: InkWell(
                                          onTap: () => deliverymanController.removeIdentityImage(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: context.surfaceContainer,
                                              border: Border.all(color: context.primary),
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            ),
                                            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                                            child: const Icon(Icons.delete_forever_sharp, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  const Gap(Dimensions.paddingExtraLarge),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('additional_info'.tr, style: context.heading.defaultSize.medium),
                      const SizedBox(height: Dimensions.paddingLarge),

                      DeliverymanAdditionalDataSectionWidget(deliverymanController: deliverymanController, scrollController: widget.scrollController),
                    ]),
                  ),
                  const Gap(Dimensions.paddingExtraLarge),

                  Container(
                    width: Dimensions.webMaxWidth,
                    padding: const EdgeInsets.all(Dimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                      boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('account_info'.tr, style: context.heading.defaultSize.medium),
                      const Gap(Dimensions.paddingLarge),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: 'phone'.tr,
                            controller: widget.phoneController,
                            focusNode: widget.phoneNode,
                            nextFocus: widget.emailNode,
                            inputType: TextInputType.phone,
                            isPhone: true,
                            onCountryChanged: (CountryCode countryCode) {
                              deliverymanController.setCountryDialCode(countryCode.dialCode);
                            },
                            countryDialCode: deliverymanController.countryDialCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode,
                            labelText: 'phone'.tr,
                            required: true,
                            validator: (value) => ValidateCheck.validatePhone(value, null),
                          ),
                        ),
                        const Gap.horizontal(Dimensions.paddingLarge),

                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          CustomTextFieldWidget(
                            hintText: '8+characters'.tr,
                            controller: widget.passwordController,
                            focusNode: widget.passwordNode,
                            nextFocus: widget.confirmPasswordNode,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            prefixIcon: Icons.lock,
                            onChanged: (value){
                              if(value != null && value.isNotEmpty){
                                if(!deliverymanController.showPassView){
                                  deliverymanController.showHidePassView();
                                }
                                deliverymanController.validPassCheck(value);
                              }else{
                                if(deliverymanController.showPassView){
                                  deliverymanController.showHidePassView();
                                }
                              }
                            },
                            labelText: 'password'.tr,
                            required: true,
                            validator: (value) => ValidateCheck.validateEmptyText(value, "enter_password_for_delivery_man".tr),
                          ),

                          deliverymanController.showPassView ? const PassViewWidget() : const SizedBox(),
                        ])),
                        const Gap.horizontal(Dimensions.paddingLarge),

                        Expanded(child: CustomTextFieldWidget(
                          hintText: '8+characters'.tr,
                          controller: widget.confirmPasswordController,
                          focusNode: widget.confirmPasswordNode,
                          inputAction: TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          labelText: 'confirm_password'.tr,
                          required: true,
                          validator: (value) => ValidateCheck.validateConfirmPassword(value, widget.passwordController.text),
                        ))
                      ]),
                      const Gap(Dimensions.paddingDefault),
                    ]),
                  ),
                  const Gap(Dimensions.paddingExtraLarge),

                  Row(children: [
                    Expanded(child: TramsConditionsCheckBoxWidget(deliverymanRegistrationController: deliverymanController, fromDmRegistration: true)),

                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      CustomButtonWidget(
                        width: 165,
                        textColor: context.textBaseMedium,
                        color: context.bgNeutralLight,
                        onPressed: () {
                          widget.phoneController.text = '';
                          widget.emailController.text = '';
                          widget.fNameController.text = '';
                          widget.lNameController.text = '';
                          widget.lNameController.text = '';
                          widget.passwordController.text = '';
                          widget.confirmPasswordController.text = '';
                          widget.identityNumberController.text = '';
                          deliverymanController.resetDmRegistrationData();
                          deliverymanController.setDeliverymanAdditionalJoinUsPageData(isUpdate: true);
                        },
                        buttonText: 'reset'.tr,
                        isBold: false,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                      const SizedBox(width: Dimensions.paddingLarge),

                      SizedBox(width: 165, child: widget.buttonView),
                    ]),
                  ]),

                  const Gap(40),
                ]),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
