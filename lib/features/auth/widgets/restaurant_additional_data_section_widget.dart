import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class RestaurantAdditionalDataSectionWidget extends StatelessWidget {
  final RestaurantRegistrationController restaurantRegiController;
  final ScrollController scrollController;
  const RestaurantAdditionalDataSectionWidget({super.key, required this.restaurantRegiController, required this.scrollController});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: isDesktop ? null : BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      padding: EdgeInsets.only(
        left: isDesktop ? 0 : Dimensions.paddingSmall,
        right: isDesktop ? 0 : Dimensions.paddingSmall,
        top: Dimensions.paddingSmall,
        bottom: isDesktop ? 0 : Dimensions.paddingSmall,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: restaurantRegiController.dataList!.length,
        itemBuilder: (context, index) {
          bool showTextField = restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.text
            || restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.number || restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.email
            || restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.phone;
          bool showDate = restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.date;
          bool showCheckBox = restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.checkBox;
          bool showFile = restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.file;
          bool isRequired = restaurantRegiController.dataList![index].isRequired == 1;
          String fieldName = restaurantRegiController.camelCaseToSentence(restaurantRegiController.dataList![index].inputData ?? '');
          String labelText = (restaurantRegiController.dataList![index].placeholderData?.isNotEmpty ?? false)
              ? restaurantRegiController.dataList![index].placeholderData! : fieldName;
          return Padding(
            padding: EdgeInsets.only(bottom: index == restaurantRegiController.dataList!.length - 1 ? 0 : Dimensions.paddingLarge),
            child: showTextField ? CustomTextFieldWidget(
              hintText: restaurantRegiController.dataList![index].placeholderData ?? '',
              controller: restaurantRegiController.additionalList![index],
              inputType: restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.number ? TextInputType.number
                : restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.phone ? TextInputType.phone
                : restaurantRegiController.dataList![index].fieldType == CustomInputFieldType.email ? TextInputType.emailAddress
                : TextInputType.text,
              isRequired: isRequired,
              capitalization: TextCapitalization.words,
              required: isRequired,
              labelText: labelText,
              validator: isRequired ? (value) => ValidateCheck.validateCustomField(value, null, isRequired: true, fieldType: restaurantRegiController.dataList![index].fieldType!) : null,
            ) : showDate ? Column(children: [
              Row(children: [
                Text(fieldName, style: context.subHeading.defaultSize.medium),

                isRequired ? Text(
                  ' *',
                  style: context.body.defaultSize.regular.overrideWith(color: context.error),
                ) : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.padding2xSmall),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: context.surfaceContainer,
                  border: Border.all(color: context.outline),
                ),
                padding: const EdgeInsets.only(left: Dimensions.paddingSmall, right: Dimensions.paddingSmall),
                child: InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                      restaurantRegiController.setAdditionalDate(index, formattedDate);
                    }
                  },
                  child: Row(children: [
                    Expanded(child: Text(restaurantRegiController.additionalList![index] ?? 'not_set_yet'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium))),

                    Icon(Icons.calendar_month_rounded, color: context.iconBaseMedium),
                  ]),
                ),
              ),

            ]) : showCheckBox ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Text(fieldName, style: context.subHeading.defaultSize.medium),

                isRequired ? Text(
                  ' *',
                  style: context.body.defaultSize.regular.overrideWith(color: context.error),
                ) : const SizedBox(),
              ]),

              ListView.builder(
                itemCount: restaurantRegiController.dataList![index].checkData!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, i) {
                  return Row(children: [
                    Checkbox(
                      activeColor: context.primary,
                      value: restaurantRegiController.additionalList![index][i] == restaurantRegiController.dataList![index].checkData![i],
                      onChanged: (bool? isChecked) {
                        restaurantRegiController.setAdditionalCheckData(index, i, restaurantRegiController.dataList![index].checkData![i]);
                      },
                    ),
                    Text(
                      restaurantRegiController.dataList![index].checkData![i],
                      style: context.body.defaultSize.regular,
                    ),
                  ]);
                },
              ),

            ]) : showFile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Text(fieldName, style: context.subHeading.defaultSize.medium),

                isRequired ? Text(
                  ' *',
                  style: context.body.defaultSize.regular.overrideWith(color: context.error),
                ) : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.paddingSmall),

              Builder(
                builder: (context) {

                  FilePickerResult? file = 0 == restaurantRegiController.additionalList![index].length ? null : restaurantRegiController.additionalList![index][0];
                  bool isImage = false;
                  String fileName = '';
                  if(file != null) {
                    if(!GetPlatform.isWeb) {
                      fileName = file.files.single.path!.split('/').last;
                      isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') || file.files.single.path!.contains('png');
                    } else {
                      fileName = file.files.first.name;
                      isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') || file.files.first.name.contains('png');
                    }
                  }

                  return restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 0 && file != null ? Stack(children: [

                    Container(
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: isImage && !GetPlatform.isWeb ? ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: GetPlatform.isWeb ? Image.network(
                            file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                          ) : Image.file(
                            File(file.files.single.path!), width: 500, height: 70, fit: BoxFit.cover,
                          ),
                        ) : DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: context.outline,
                            strokeWidth: 1,
                            strokeCap: StrokeCap.butt,
                            dashPattern: const [5, 5],
                            padding: const EdgeInsets.all(0),
                            radius: const Radius.circular(Dimensions.radiusDefault),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
                            decoration: BoxDecoration(
                              color: context.surfaceContainer,
                            ),
                            child: Row(children: [
                              CustomAssetImageWidget(Images.documentIcon, height: 30, width: 30, fit: BoxFit.contain),
                              const SizedBox(width: Dimensions.paddingSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text(fileName, style: context.subHeading.small.medium),
                                SizedBox(height: isDesktop ? 2 : Dimensions.padding2xSmall),

                                Text(
                                  '${file.files.single.size / 1000} Kbps',
                                  style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                                ),

                              ])),

                            ]),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0, right: 0, bottom: 10,
                      child: IconButton(
                        onPressed: (){
                          restaurantRegiController.removeAdditionalFile(index, 0);
                        },
                        icon: Icon(CupertinoIcons.clear, color: context.iconBaseMedium, size: 20),
                      ),
                    ),

                  ]) : InkWell(
                    onTap: () async {
                      await restaurantRegiController.pickFile(index, restaurantRegiController.dataList![index].mediaData!);
                    },
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: context.outline,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [5, 5],
                        padding: const EdgeInsets.all(0),
                        radius: const Radius.circular(Dimensions.radiusDefault),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                          ),
                          child: Row(children: [
                            Icon(Icons.cloud_upload_outlined, size: 35, color: context.iconBaseMedium),
                            const SizedBox(width: Dimensions.paddingSmall),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              Text(
                                restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 1 ? 'select_multiple_files'.tr : 'select_a_file'.tr,
                                style: context.body.defaultSize.regular,
                              ),

                              Text(
                                'jpg_png_or_pdf_file_size_no_more_than_ten_mb'.tr,
                                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                              ),

                            ])),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: context.primary,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              alignment: Alignment.center,
                              child: Text('select'.tr, style: context.body.small.regular.overrideWith(color: context.surfaceContainer)),
                            ),

                          ]),
                        ),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 1 && restaurantRegiController.additionalList![index].length > 0 ? SizedBox(
                height: 80,
                child: ListView.builder(
                  physics:  const AlwaysScrollableScrollPhysics(),
                  itemCount: restaurantRegiController.additionalList![index].length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    FilePickerResult? file = i == restaurantRegiController.additionalList![index].length ? null : restaurantRegiController.additionalList![index][i];
                    bool isImage = false;
                    String fileName = '';
                    if(file != null) {
                      if(!GetPlatform.isWeb) {
                        fileName = file.files.single.path!.split('/').last;
                        isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') || file.files.single.path!.contains('png');
                      } else {
                        fileName = file.files.first.name;
                        isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') || file.files.first.name.contains('png');
                      }
                    }
                    return file != null ? Stack(children: [

                      Container(
                        width: isDesktop ? 500 :MediaQuery.of(context).size.width * 0.4,
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        child: Center(
                          child: isImage && !GetPlatform.isWeb ? ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.files.single.path!), width: 500, height: 70, fit: BoxFit.cover,
                            ),
                          ) : DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              color: context.outline,
                              strokeWidth: 1,
                              strokeCap: StrokeCap.butt,
                              dashPattern: const [5, 5],
                              padding: const EdgeInsets.all(0),
                              radius: const Radius.circular(Dimensions.radiusDefault),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingDefault),
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                              ),
                              child: Row(children: [
                                CustomAssetImageWidget(Images.documentIcon, height: 30, width: 30, fit: BoxFit.contain),
                                const SizedBox(width: Dimensions.paddingSmall),

                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Text(fileName, style: context.subHeading.small.medium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: isDesktop ? 3 : Dimensions.padding2xSmall),

                                  Text(
                                    '${file.files.single.size / 1000} Kbps',
                                    style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                                  ),

                                ])),

                              ]),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: -10, right: 0,
                        child: IconButton(
                          onPressed: (){
                            restaurantRegiController.removeAdditionalFile(index, i);
                          },
                          icon: Icon(CupertinoIcons.clear, color: context.iconBaseMedium, size: 20),
                        ),
                      ),

                    ]) : const SizedBox();
                  },
                ),
              ) :  const SizedBox(),
            ]) : const SizedBox(),
          );
        },
      ),
    );
  }
}
