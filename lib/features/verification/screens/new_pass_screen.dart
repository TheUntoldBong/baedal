import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/pass_change_successfull_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:stackfood_multivendor/features/verification/controllers/verification_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final String? email;
  final bool fromPasswordChange;
  final bool fromDialog;
  const NewPassScreen({super.key, required this.resetToken, required this.number, required this.fromPasswordChange, this.fromDialog = false, this.email});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  GlobalKey<FormState>? _formKey;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body:  SafeArea(child: Align( alignment: Alignment.topCenter, child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.width > 700 ? 0 : Dimensions.paddingLarge, vertical: Dimensions.paddingLarge),
          child: Container(
            width: context.width > 700 ? 500 : context.width,
            padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingLarge) : null,
            decoration: context.width > 700 ? BoxDecoration(
              color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ) : null,
            child: Form(key: _formKey,
              child: Column( mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  InkWell(
                    onTap: () => Get.back(result: false),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                      child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Get.back(result: false),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                      child: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge!.color, size: 16),
                    ),
                  ),
                ]),
                SizedBox(height: Dimensions.paddingLarge),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
                  ),
                  child: Column( mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('set_your_new_password'.tr, style: context.heading.extraLarge.strong),
                    const SizedBox(height: Dimensions.padding2xSmall),
                    Text("${'enter_your_new_password_and_confirm_it_to_secure_your_account'.tr} ", style: context.body.small.overrideWith(color: context.textBaseMedium)),
                    const SizedBox(height: Dimensions.paddingOverLarge),

                    CustomTextFieldWidget(
                      hintText: 'ex_8_plus_character'.tr,
                      titleText: 'new_password'.tr,
                      showTitle: true,
                      showLabelText: false,
                      required: true,
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocus,
                      nextFocus: _confirmPasswordFocus,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      divider: false,
                      validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_new_password'.tr),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),

                    CustomTextFieldWidget(
                      hintText: 'ex_8_plus_character'.tr,
                      titleText: 'confirm_password'.tr,
                      showTitle: true,
                      showLabelText: false,
                      required: true,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      onSubmit: (text) => GetPlatform.isWeb ? _onPressedPasswordChange() : null,
                      validator: (value) => ValidateCheck.validateEmptyText(value, 'please_enter_confirm_password'.tr),
                    ),

                    const SizedBox(height: Dimensions.paddingOverLarge),

                    GetBuilder<ProfileController>(builder: (profileController) {
                      return GetBuilder<VerificationController>(builder: (verificationController) {
                        return CustomButtonWidget(
                          radius: Dimensions.radiusDefault,
                          buttonText: 'change_password'.tr,
                          isLoading: widget.fromPasswordChange ? profileController.isLoading : verificationController.isLoading,
                          onPressed: () => _onPressedPasswordChange(),
                        );
                      });
                    }),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingLarge),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                 Text('new_to_stackfood'.tr, style: context.body.small),

                  InkWell(
                    onTap:  () {
                      Get.toNamed(RouteHelper.getSignUpRoute());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                      child: Text('sign_up'.tr, style: context.subHeading.small.medium.overrideWith(color: Colors.blueAccent)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
          ),
        ),
      ),
    );
  }

  void _onPressedPasswordChange() {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (_formKey!.currentState!.validate()) {
      if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      }else if (password.length < 8) {
        showCustomSnackBar('password_should_be'.tr);
      }else if(password != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
      }else {
        if(widget.fromPasswordChange) {
          _changeUserPassword(password);
        }else {
          _resetUserPassword(password, confirmPassword);
        }
      }
    }

  }

  void _changeUserPassword(String password) {
    UserInfoModel user = Get.find<ProfileController>().userInfoModel!;
    user.password = password;
    Get.find<ProfileController>().changePassword(user).then((response) {
      if(response.isSuccess) {
        Get.back();
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          builder: (context) => const PasswordChangedBottomSheet(),
        );
      }else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _resetUserPassword(String password, String confirmPassword) {

    String? number = '';
    if(widget.number != null && widget.number != 'null' && widget.number!.isNotEmpty) {
      number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    }

    Get.find<VerificationController>().resetPassword(resetToken: widget.resetToken, phone: number, email: widget.email, password: password, confirmPassword: confirmPassword).then((value) {
      if (value.isSuccess) {
        if(!ResponsiveHelper.isDesktop(Get.context)) {
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.resetPassword));
        }else{
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false))?.then((value) {
            Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: false));
          });
        }
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          builder: (context) => const PasswordChangedBottomSheet(),
        );
      } else {
        showCustomSnackBar(value.message);
      }
    });
  }
}