import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ContactInfoBottomSheet extends StatefulWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final FocusNode guestNameNode;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const ContactInfoBottomSheet({
    super.key, required this.checkoutController, required this.guestNameController,
    required this.guestNumberController, required this.guestNameNode, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode,
  });

  @override
  State<ContactInfoBottomSheet> createState() => _ContactInfoBottomSheetState();
}

class _ContactInfoBottomSheetState extends State<ContactInfoBottomSheet> {
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _canSave = widget.guestNameController.text.trim().isNotEmpty && widget.guestNumberController.text.trim().isNotEmpty;
  }

  void _validate() {
    setState(() {
      _canSave = widget.guestNameController.text.trim().isNotEmpty && widget.guestNumberController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        child: Column(children: [
          Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
            decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(10)),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('contact_info'.tr, style: context.subHeading.defaultSize.strong),
            IconButton(
              onPressed: ()=> Get.back(),
              icon: Icon(Icons.clear, color: context.iconBaseMedium),
            )
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          CustomTextFieldWidget(
            controller: widget.guestNameController,
            focusNode: widget.guestNameNode,
            nextFocus: widget.guestNumberNode,
            labelText: 'contact_person_name'.tr,
            hintText: 'enter_your_name'.tr,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            required: true,
            onChanged: (String text) => _validate(),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          CustomTextFieldWidget(
            controller: widget.guestNumberController,
            focusNode: widget.guestNumberNode,
            nextFocus: widget.guestEmailNode,
            labelText: 'contact_person_number'.tr,
            hintText: 'xxx-xxx-xxxxx'.tr,
            inputType: TextInputType.phone,
            isPhone: true,
            required: true,
            onCountryChanged: (CountryCode countryCode) {
              widget.checkoutController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: widget.checkoutController.countryDialCode
                ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                ?? Get.find<LocalizationController>().locale.countryCode,
            onChanged: (String text) => _validate(),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          CustomTextFieldWidget(
            controller: widget.guestEmailController,
            focusNode: widget.guestEmailNode,
            labelText: 'email'.tr,
            hintText: 'enter_email'.tr,
            inputType: TextInputType.emailAddress,
            inputAction: TextInputAction.done,
            onChanged: (String text) => _validate(),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          CustomButtonWidget(
            buttonText: 'confirm_information'.tr,
            onPressed: _canSave ? () {
              widget.checkoutController.update();
              Get.back();
            } : null,
          ),

          const SizedBox(height: Dimensions.paddingLarge),
        ]),
      ),
    );
  }
}
