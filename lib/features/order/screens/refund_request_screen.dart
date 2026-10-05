import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class RefundRequestScreen extends StatefulWidget {
  final String? orderId;
  const RefundRequestScreen({super.key, required this.orderId});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const double _maxFormWidth = 700;
  static const double _imageBoxHeight = 150;

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().selectReason(0, isUpdate: false);
    Get.find<OrderController>().pickRefundImage(true);
    Get.find<OrderController>().getRefundReasons();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: CustomAppBarWidget(title: 'refund_request'.tr),
      body: SafeArea(child: GetBuilder<OrderController>(builder: (orderController) {

        final List<String?>? reasons = orderController.refundReasons;
        if(reasons == null || reasons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final bool hasReason = orderController.selectedReasonIndex != 0;

        return Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxFormWidth),
          child: Column(children: [

            Expanded(child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                _SectionCard(
                  title: 'what_is_wrong_with_this_order'.tr,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: context.outline),
                    ),
                    child: DropdownButton<String>(
                      value: reasons[orderController.selectedReasonIndex],
                      isExpanded: true,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      dropdownColor: context.surfaceContainer,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.iconBaseMedium),
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault),
                      items: reasons.map((String? item) {
                        return DropdownMenuItem(value: item, child: Text(item!.tr, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (value) {
                        orderController.selectReason(reasons.indexOf(value));
                        if(_noteController.text.isNotEmpty) {
                          _noteController.text = '';
                        }
                        if(orderController.refundImage != null) {
                          orderController.pickRefundImage(true);
                        }
                      },
                    ),
                  ),
                ),

                if(hasReason) ...[
                  const SizedBox(height: Dimensions.paddingDefault),

                  _SectionCard(
                    title: 'additional_note'.tr,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      CustomTextFieldWidget(
                        controller: _noteController,
                        hintText: 'ex_please_provide_any_note'.tr,
                        maxLines: 3,
                        showLabelText: false,
                        inputType: TextInputType.multiline,
                        inputAction: TextInputAction.newline,
                        capitalization: TextCapitalization.sentences,
                        fillColor: context.surface,
                      ),
                      const SizedBox(height: Dimensions.paddingLarge),

                      _RefundImagePicker(
                        image: orderController.refundImage?.path,
                        height: _imageBoxHeight,
                        onTap: () => orderController.pickRefundImage(false),
                      ),

                    ]),
                  ),
                ],

              ]),
            )),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingLarge),
              color: context.surfaceContainer,
              child: CustomButtonWidget(
                buttonText: 'submit_refund_request'.tr,
                radius: Dimensions.radiusDefault,
                isLoading: orderController.isLoading,
                onPressed: () => orderController.submitRefundRequest(_noteController.text.trim(), widget.orderId),
              ),
            ),

          ]),
        ));
      })),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(title, style: context.heading.defaultSize.strong),
        const SizedBox(height: Dimensions.paddingMedium),

        child,

      ]),
    );
  }
}

class _RefundImagePicker extends StatelessWidget {
  final String? image;
  final double height;
  final VoidCallback onTap;

  const _RefundImagePicker({required this.image, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: context.outline,
        strokeWidth: 2,
        strokeCap: StrokeCap.butt,
        dashPattern: const [8, 5],
        padding: EdgeInsets.zero,
        radius: const Radius.circular(Dimensions.radiusDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height, width: double.infinity,
            child: image == null ? Container(
              color: context.surface,
              alignment: Alignment.center,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                Icon(Icons.cloud_upload_rounded, size: 34, color: context.iconBaseMedium),
                const SizedBox(height: Dimensions.paddingSmall),

                Text('upload_image'.tr, style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium)),

              ]),
            ) : Stack(fit: StackFit.expand, children: [

              GetPlatform.isWeb ? Image.network(image!, fit: BoxFit.cover) : Image.file(File(image!), fit: BoxFit.cover),

              Center(child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: context.surfaceContainer.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt_rounded, color: context.iconBaseDefault),
              )),

            ]),
          ),
        ),
      ),
    );
  }
}
