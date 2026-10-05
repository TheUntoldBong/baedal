import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/contact_info_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ContactInfoWidget extends StatefulWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameController;
  final TextEditingController guestNumberController;
  final TextEditingController guestEmailController;
  final FocusNode guestNameNode;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const ContactInfoWidget({
    super.key, required this.checkoutController, required this.guestNameController,
    required this.guestNumberController, required this.guestNameNode, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode,
  });

  @override
  State<ContactInfoWidget> createState() => _ContactInfoWidgetState();
}

class _ContactInfoWidgetState extends State<ContactInfoWidget> {
  bool _isPhoneLoading = true;

  void _splitPhoneNumber(String number) async {
    _isPhoneLoading = true;
    try {
      PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
      widget.guestNumberController.text = phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
      widget.checkoutController.countryDialCode = '+${phoneNumber.countryCode}';
    } catch (_) {}
    if(mounted) {
      setState(() => _isPhoneLoading = false);
    }
  }

  void _openContactInfoSheet(BuildContext context) {
    Widget sheet = ContactInfoBottomSheet(
      checkoutController: widget.checkoutController, guestNameController: widget.guestNameController,
      guestNumberController: widget.guestNumberController, guestNameNode: widget.guestNameNode, guestNumberNode: widget.guestNumberNode,
      guestEmailController: widget.guestEmailController, guestEmailNode: widget.guestEmailNode,
    );

    if(ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: sheet));
    } else {
      Get.bottomSheet(sheet, backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

      if(isLoggedIn && _isPhoneLoading) {
        if(widget.guestNumberController.text.trim().isNotEmpty) {
          _isPhoneLoading = false;
        } else if(profileController.userInfoModel != null) {
          _splitPhoneNumber(profileController.userInfoModel!.phone ?? '');
          widget.guestNameController.text = '${profileController.userInfoModel!.fName ?? ''} ${profileController.userInfoModel!.lName ?? ''}'.trim();
          widget.guestEmailController.text = profileController.userInfoModel!.email ?? '';
        }
      }

      if(isLoggedIn && _isPhoneLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      bool hasContactInfo = widget.guestNameController.text.trim().isNotEmpty && widget.guestNumberController.text.trim().isNotEmpty;

      if(!isLoggedIn && !hasContactInfo) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: InkWell(
            onTap: () => _openContactInfoSheet(context),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingMedium),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_circle_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                const SizedBox(width: Dimensions.paddingSmall),
                Text('add_contact_info'.tr, style: context.subHeading.defaultSize.strong)
              ]),
            ),
          ),
        );
      }

      String? profileImage = isLoggedIn ? profileController.userInfoModel?.imageFullUrl : null;
      String name = widget.guestNameController.text.trim();
      String number = widget.guestNumberController.text.trim();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium, vertical: Dimensions.paddingMedium),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(children: [
            Container(
              height: 36, width: 36,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: context.surface, shape: BoxShape.circle),
              child: (profileImage != null && profileImage.isNotEmpty) ? CustomImageWidget(
                image: profileImage, height: 36, width: 36, fit: BoxFit.cover,
              ) : Icon(Icons.person, color: context.iconBaseMedium, size: 20),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: context.subHeading.defaultSize.strong, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: Dimensions.paddingOverSmall),
              Text(number, style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
            ])),
            const SizedBox(width: Dimensions.paddingSmall),

            InkWell(
              onTap: () => _openContactInfoSheet(context),
              child: CustomAssetImageWidget(Images.editBtn, width: 20),
            ),
          ]),
        ),
      );
    });
  }
}
