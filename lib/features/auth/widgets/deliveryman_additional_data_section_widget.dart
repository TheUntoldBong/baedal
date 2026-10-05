import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
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

class DeliverymanAdditionalDataSectionWidget extends StatelessWidget {
  final DeliverymanRegistrationController deliverymanController;
  final ScrollController scrollController;
  const DeliverymanAdditionalDataSectionWidget({super.key, required this.deliverymanController, required this.scrollController});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return deliverymanController.dataList!.isNotEmpty ? Container(
      decoration: isDesktop ? null : BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 12, spreadRadius: 0)],
      ),
      margin: const EdgeInsets.all(Dimensions.paddingDefault),
      padding: EdgeInsets.only(
        left: isDesktop ? 0 : Dimensions.paddingSmall,
        right: isDesktop ? 0 : Dimensions.paddingSmall,
        top: isDesktop ? 0 : Dimensions.paddingSmall,
        bottom: isDesktop ? 0 : Dimensions.paddingSmall,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        isDesktop ? SizedBox() : Text('additional_info'.tr, style: context.heading.large.semiBold),
        SizedBox(height: isDesktop ? 0 : Dimensions.padding2xSmall),

        isDesktop ? SizedBox() : Text('additional_info_subtitle'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
        SizedBox(height: isDesktop ? 0 :  Dimensions.paddingDefault),

        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: deliverymanController.dataList!.length,
          itemBuilder: (context, index) {
            bool showTextField = deliverymanController.dataList![index].fieldType == CustomInputFieldType.text || deliverymanController.dataList![index].fieldType == CustomInputFieldType.number || deliverymanController.dataList![index].fieldType == CustomInputFieldType.email || deliverymanController.dataList![index].fieldType == CustomInputFieldType.phone;
            bool showDate = deliverymanController.dataList![index].fieldType == CustomInputFieldType.date;
            bool showCheckBox = deliverymanController.dataList![index].fieldType == CustomInputFieldType.checkBox;
            bool showFile = deliverymanController.dataList![index].fieldType == CustomInputFieldType.file;
            return Padding(
              padding: EdgeInsets.only(bottom: index == deliverymanController.dataList!.length - 1 ? 0 : Dimensions.paddingOverLarge),
              child: showTextField ? CustomTextFieldWidget(
                hintText: deliverymanController.dataList![index].placeholderData ?? '',
                controller: deliverymanController.additionalList![index],
                inputType: deliverymanController.dataList![index].fieldType == CustomInputFieldType.number ? TextInputType.number
                  : deliverymanController.dataList![index].fieldType == CustomInputFieldType.phone ? TextInputType.phone
                  : deliverymanController.dataList![index].fieldType == CustomInputFieldType.email ? TextInputType.emailAddress
                  : TextInputType.text,
                isRequired: deliverymanController.dataList![index].isRequired == 1,
                capitalization: TextCapitalization.words,
                labelText: deliverymanController.dataList![index].placeholderData ?? '',
                required: deliverymanController.dataList![index].isRequired == 1,
                validator: deliverymanController.dataList![index].isRequired == 1 ? (value) => ValidateCheck.validateCustomField(value, null, isRequired: true, fieldType: deliverymanController.dataList![index].fieldType!) : null,
              ) : showDate ? Column(children: [

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
                        deliverymanController.setAdditionalDate(index, formattedDate);
                      }
                    },
                    child: Row(children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: deliverymanController.additionalList![index] ?? deliverymanController.camelCaseToSentence(deliverymanController.dataList![index].inputData!),
                            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                            children:[
                              TextSpan(
                                text: deliverymanController.dataList![index].isRequired == 1 ? ' * ' : ' ',
                                style: context.body.defaultSize.regular.overrideWith(color: context.error),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Icon(Icons.calendar_month_rounded, color: context.iconBaseMedium),
                    ]),
                  ),
                ),

              ]) : showCheckBox ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Text(deliverymanController.camelCaseToSentence(deliverymanController.dataList![index].inputData ?? ''), style: context.subHeading.defaultSize.medium),

                  Text(
                    deliverymanController.dataList![index].isRequired == 1 ? ' *' : '',
                    style: context.body.defaultSize.regular.overrideWith(color: context.error),
                  ),
                ]),

                ListView.builder(
                  itemCount: deliverymanController.dataList![index].checkData!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, i) {
                    return Row(children: [
                      Checkbox(
                        activeColor: context.primary,
                        value: deliverymanController.additionalList![index][i] == deliverymanController.dataList![index].checkData![i],
                        onChanged: (bool? isChecked) {
                          deliverymanController.setAdditionalCheckData(index, i, deliverymanController.dataList![index].checkData![i]);
                        }
                      ),
                      Text(
                        deliverymanController.dataList![index].checkData![i],
                        style: context.body.defaultSize.regular,
                      ),
                    ]);
                  },
                )

              ]) : showFile ? Container(
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(children: [
                    Text(deliverymanController.camelCaseToSentence(deliverymanController.dataList![index].inputData ?? ''), style: context.subHeading.defaultSize.medium),

                    Text(
                      deliverymanController.dataList![index].isRequired == 1 ? ' *' : '',
                      style: context.body.defaultSize.regular.overrideWith(color: context.error),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSmall),

                  Builder(builder: (context) {
                    FilePickerResult? file = 0 == deliverymanController.additionalList![index].length ? null : deliverymanController.additionalList![index][0];
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
                    return deliverymanController.dataList![index].mediaData!.uploadMultipleFiles == 1 ? SizedBox(
                      height: 120,
                      child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: deliverymanController.additionalList![index].length + 1,
                      itemBuilder: (context, i) {
                        FilePickerResult? file = i == deliverymanController.additionalList![index].length ? null : deliverymanController.additionalList![index][i];
                        bool isImage = false;
                        String fileName = '';
                        if (file != null) {
                          if (!GetPlatform.isWeb) {
                            fileName = file.files.single.path!.split('/').last;
                            isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') ||
                                file.files.single.path!.contains('png');
                          } else {
                            fileName = file.files.first.name;
                            isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') ||
                                file.files.first.name.contains('png');
                          }
                        }

                        return file == null ? Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                          child: InkWell(
                            onTap: () async {
                              await deliverymanController.pickFile(index, deliverymanController.dataList![index].mediaData!);
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
                              child: Container(
                                height: 120,
                                width: 160,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                decoration: BoxDecoration(
                                  color: context.surfaceContainer,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.cloud_upload_outlined, size: 30, color: context.iconBaseMedium),
                                  const SizedBox(height: Dimensions.paddingSmall),
                                  Text(
                                    'select_a_file'.tr,
                                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ) : Stack(children: [
                          Container(
                            width: 160, height: 120,
                            margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: context.surfaceContainer,
                            ),
                            child: isImage && !GetPlatform.isWeb ? ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: GetPlatform.isWeb ? Image.network(
                                file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                              ) : Image.file(
                                File(file.files.single.path!), width: 100, height: 100, fit: BoxFit.cover,
                              ),
                            ) : Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSmall),
                              alignment: Alignment.center,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                CustomAssetImageWidget(Images.documentIcon, height: 30, width: 30, fit: BoxFit.contain),
                                const SizedBox(height: Dimensions.paddingSmall),
                                Text(
                                  fileName,
                                  style: context.subHeading.extraSmall.medium,
                                  maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                ),
                              ]),
                            ),
                          ),

                          Positioned(
                            top: 0, right: 10,
                            child: InkWell(
                              onTap: (){
                                deliverymanController.removeAdditionalFile(index, i);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.surfaceContainer,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                  border: Border.all(color: context.outline),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Icon(CupertinoIcons.clear, color: Theme.of(context).colorScheme.error, size: 15),
                              ),
                            ),
                          ),
                        ]);
                      }),
                    ) : deliverymanController.dataList![index].mediaData!.uploadMultipleFiles == 0 && file != null ? Stack(children: [

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
                        top: 0, right: 0, bottom: 10,
                        child: IconButton(
                          onPressed: (){
                            deliverymanController.removeAdditionalFile(index, 0);
                          },
                          icon: Icon(CupertinoIcons.clear, color: context.iconBaseMedium, size: 20),
                        ),
                      ),

                    ]) : InkWell(
                      onTap: () async {
                        await deliverymanController.pickFile(index, deliverymanController.dataList![index].mediaData!);
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
                                  deliverymanController.dataList![index].mediaData!.uploadMultipleFiles == 1 ? 'select_multiple_files'.tr : 'select_a_file'.tr,
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
                                  color: Colors.blue,
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
                  }),

                ]),
              ) : SizedBox(),
            );

          },
        ),
      ]),
    ) : const SizedBox();
  }
}
