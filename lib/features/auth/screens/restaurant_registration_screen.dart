import 'dart:convert';
import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/enums/custom_input_field_type.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/gap_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/restaurant_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/translation_body_model.dart';
import 'package:stackfood_multivendor/features/auth/widgets/cuisine_widget.dart';
import 'package:stackfood_multivendor/features/business/widgets/base_card_widget.dart';
import 'package:stackfood_multivendor/features/business/widgets/package_card_widget.dart';
import 'package:stackfood_multivendor/features/business/widgets/web_business_plan_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/custom_time_picker_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/pass_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/registration_stepper_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/restaurant_additional_data_section_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/select_location_view_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class RestaurantRegistrationScreen extends StatefulWidget {
  const RestaurantRegistrationScreen({super.key});

  @override
  State<RestaurantRegistrationScreen> createState() => _RestaurantRegistrationScreenState();
}

class _RestaurantRegistrationScreenState extends State<RestaurantRegistrationScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];
  final TextEditingController _tinNumberController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();
  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _cuisineFocus = FocusNode();
  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;
  TabController? _tabController;
  final List<Tab> _tabs =[];
  bool firstTime = true;
  String? _countryDialCode;
  final ScrollController _scrollController = ScrollController();
  GlobalKey<FormState>? _formKeyLogin;
  GlobalKey<FormState>? _formKeySecond;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _languageList!.length, initialIndex: 0, vsync: this);
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    for (var language in _languageList) {
      if (kDebugMode) {
        print(language);
      }
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }
    Get.find<RestaurantRegistrationController>().resetData();
    Get.find<RestaurantRegistrationController>().setRestaurantAdditionalJoinUsPageData(isUpdate: false);
    Get.find<RestaurantRegistrationController>().storeStatusChange(0.1, isUpdate: false);
    Get.find<RestaurantRegistrationController>().getZoneList();
    Get.find<CuisineController>().getCuisineList();
    if(Get.find<DeliverymanRegistrationController>().showPassView){
      Get.find<DeliverymanRegistrationController>().showHidePassView();
    }

    Get.find<RestaurantRegistrationController>().resetBusiness();
    Get.find<RestaurantRegistrationController>().getPackageList(isUpdate: false);

    for (var language in _languageList) {
      _tabs.add(Tab(text: language.value));
    }
    _formKeyLogin = GlobalKey<FormState>();
    _formKeySecond = GlobalKey<FormState>();
  }

  Future<void> _showBackPressedDialogue(String title)async {
    showCustomDialog(
      child: ConfirmationDialogWidget(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () {
        if(Get.isDialogOpen??false){
          Get.back();
        }
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.off(() => const DashboardScreen(pageIndex: 0));
        }else {
          Get.off(() => const DashboardScreen(pageIndex: 4));
        }
      },
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    
    return GetBuilder<RestaurantRegistrationController>(builder: (restaurantRegController) {

      if(restaurantRegController.restaurantAddress != null){
        _addressController[0].text = restaurantRegController.restaurantAddress.toString();
      }
      
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async{
          if(restaurantRegController.storeStatus == 0.6 && firstTime){
            restaurantRegController.storeStatusChange(0.1);
            firstTime = false;
          }else if(restaurantRegController.storeStatus == 0.9){
            restaurantRegController.storeStatusChange(0.6);
          }else{
            await _showBackPressedDialogue('your_registration_not_setup_yet'.tr);
          }
        },
        child: Scaffold(
          appBar: CustomAppBarWidget(title: 'restaurant_registration'.tr, onBackPressed: () async {
            if(restaurantRegController.storeStatus == 0.6 && firstTime){
              restaurantRegController.storeStatusChange(0.1);
              firstTime = false;
            }else if(restaurantRegController.storeStatus == 0.9){
              restaurantRegController.storeStatusChange(0.6);
            }else{
              await _showBackPressedDialogue('your_registration_not_setup_yet'.tr);
            }
          }),
          body: SafeArea(
            child: Center(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                isDesktop ? Center(child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 35),
                    child: RegistrationStepperWidget(status: restaurantRegController.storeStatus == 0.9 ? 'business' : ''),
                  ),
                )) : SizedBox(),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingDefault),
                    child: SizedBox(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: isDesktop ? webView(restaurantRegController, isDesktop) : Column(children: [
                          
                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.1,
                            child: Form(
                              key: _formKeyLogin,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text('restaurant_info'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 0)],
                                  ),
                                  padding: EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(children: [

                                    SizedBox(
                                      height: 40,
                                      child: TabBar(
                                        tabAlignment: TabAlignment.start,
                                        controller: _tabController,
                                        indicatorColor: Theme.of(context).textTheme.bodyLarge?.color,
                                        indicatorWeight: 3,
                                        labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                                        unselectedLabelColor: context.textBaseMedium,
                                        unselectedLabelStyle: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                                        labelStyle: context.heading.defaultSize.strong,
                                        labelPadding: const EdgeInsets.only(right: Dimensions.paddingLarge),
                                        indicatorPadding: const EdgeInsets.only(right: Dimensions.paddingLarge),
                                        isScrollable: true,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        tabs: _tabs,
                                        onTap: (int ? value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: Dimensions.paddingLarge),
                                      child: Divider(height: 0),
                                    ),

                                    CustomTextFieldWidget(
                                      titleText: 'write_restaurant_name'.tr,
                                      controller: _nameController[_tabController!.index],
                                      focusNode: _nameFocus[_tabController!.index],
                                      nextFocus: _tabController!.index != _languageList!.length-1 ? _addressFocus[_tabController!.index] : _addressFocus[0],
                                      inputType: TextInputType.name,
                                      prefixImage: Images.shopIcon,
                                      capitalization: TextCapitalization.words,
                                      labelText: '${'store_name'.tr} (${_languageList[_tabController!.index].value!})',
                                      required: true,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_name_field_is_required".tr),
                                    ),
                                    const Gap(Dimensions.paddingExtraLarge),

                                    CustomTextFieldWidget(
                                      titleText: 'write_restaurant_address'.tr,
                                      controller: _addressController[_tabController!.index],
                                      focusNode: _addressFocus[_tabController!.index],
                                      nextFocus: _tabController!.index != _languageList.length-1 ? _addressFocus[_tabController!.index] : _addressFocus[0],
                                      inputType: TextInputType.streetAddress,
                                      capitalization: TextCapitalization.words,
                                      labelText: '${'restaurant_address'.tr} (${_languageList[_tabController!.index].value!})',
                                      required: true,
                                      maxLines: 3,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_address_field_is_required".tr),
                                    ),
                                  ]),
                                ),
                                const Gap(Dimensions.paddingDefault),

                                Text('restaurant_logo_and_cover_photo'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 0)],
                                  ),
                                  padding: EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('restaurant_logo'.tr, style: context.body.defaultSize.regular),

                                                Text('*'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                              ],
                                            ),
                                            const Gap(Dimensions.paddingDefault),

                                            Align(alignment: Alignment.center, child: Stack(children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                                  child: restaurantRegController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                                                    restaurantRegController.pickedLogo!.path, width: 150, height: 135, fit: BoxFit.cover,
                                                  ) : Image.file(
                                                    File(restaurantRegController.pickedLogo!.path), width: 150, height: 135, fit: BoxFit.cover,
                                                  ) : SizedBox(
                                                    width: 150, height: 135,
                                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                                      Icon(CupertinoIcons.photo_camera_solid, size: 38, color: context.iconDisabledDefault),
                                                      const Gap(Dimensions.paddingSmall),

                                                      Text(
                                                        'upload_logo'.tr,
                                                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
                                                      ),
                                                      const Gap(Dimensions.padding2xSmall),

                                                      Text(
                                                        'upload_jpg_png_gif_maximum_2_mb'.tr,
                                                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const Gap(Dimensions.padding2xSmall),

                                                      Text(
                                                        '(${'1_1_ratio'.tr})',
                                                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
                                                      ),

                                                    ]),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0, right: 0, top: 0, left: 0,
                                                child: InkWell(
                                                  onTap: () => restaurantRegController.pickImage(true, false),
                                                  child: DottedBorder(
                                                    options: RoundedRectDottedBorderOptions(
                                                      color: restaurantRegController.showLogoValidation 
                                                        ? Colors.red 
                                                        : context.outlineVariant,
                                                      strokeWidth: restaurantRegController.showLogoValidation ? 2 : 1,
                                                      strokeCap: StrokeCap.butt,
                                                      dashPattern: const [5, 5],
                                                      padding: const EdgeInsets.all(0),
                                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                                    ),
                                                    child: Center(
                                                      child: Visibility(
                                                        visible: restaurantRegController.pickedLogo != null,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(25),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(width: 2, color: Colors.white),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(CupertinoIcons.photo_camera_solid, color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])),
                                            if (restaurantRegController.showLogoValidation)
                                              Padding(
                                                padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
                                                child: Text(
                                                  'select_restaurant_logo'.tr,
                                                  style: context.body.small.regular.overrideWith(color: context.error),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Gap.horizontal(Dimensions.paddingDefault),

                                      Expanded(flex: 6,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('restaurant_cover'.tr, style: context.body.defaultSize.regular),

                                                Text('*'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                              ],
                                            ),
                                            const Gap(Dimensions.paddingDefault),

                                            Stack(children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                                  child: restaurantRegController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                                                    restaurantRegController.pickedCover!.path, width: context.width, height: 135, fit: BoxFit.cover,
                                                  ) : Image.file(
                                                    File(restaurantRegController.pickedCover!.path), width: context.width, height: 135, fit: BoxFit.cover,
                                                  ) : SizedBox(
                                                    width: context.width, height: 135,
                                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                                      Icon(CupertinoIcons.photo_camera_solid, size: 38, color: context.iconDisabledDefault),

                                                      Text(
                                                        'upload_cover'.tr,
                                                        style: context.body.small.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
                                                      ),

                                                      Text(
                                                        'upload_jpg_png_gif_maximum_2_mb'.tr,
                                                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const Gap(Dimensions.padding2xSmall),

                                                      Text(
                                                        '(${'1_2_ratio'.tr})',
                                                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
                                                      ),

                                                    ]),
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                bottom: 0, right: 0, top: 0, left: 0,
                                                child: InkWell(
                                                  onTap: () => restaurantRegController.pickImage(false, false),
                                                  child: DottedBorder(
                                                    options: RoundedRectDottedBorderOptions(
                                                      color: restaurantRegController.showCoverValidation 
                                                        ? Colors.red 
                                                        : context.outlineVariant,
                                                      strokeWidth: restaurantRegController.showCoverValidation ? 2 : 1,
                                                      strokeCap: StrokeCap.butt,
                                                      dashPattern: const [5, 5],
                                                      padding: const EdgeInsets.all(0),
                                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                                    ),
                                                    child: Center(
                                                      child: Visibility(
                                                        visible: restaurantRegController.pickedCover != null,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(25),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(width: 3, color: Colors.white),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(CupertinoIcons.photo_camera_solid, color: Colors.white, size: 50),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                            if (restaurantRegController.showCoverValidation)
                                              Padding(
                                                padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
                                                child: Text(
                                                  'select_restaurant_cover_photo'.tr,
                                                  style: context.body.small.regular.overrideWith(color: context.error),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ]),
                                ),
                                const Gap(Dimensions.paddingDefault),

                                Text('location_info'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingSmall),

                                restaurantRegController.zoneList != null ? SelectLocationViewWidget(
                                  fromView: true, addressController: _addressController[0], addressFocus: _addressFocus[0],
                                ) : const Center(child: CircularProgressIndicator()),

                                const Gap(Dimensions.paddingDefault),

                                Text('restaurant_preference'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingDefault),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(children: [

                                    CuisineWidget(cuisineTextController: _cuisineController, cuisineFocus: _cuisineFocus),
                                    const Gap(Dimensions.paddingOverLarge),

                                    InkWell(
                                      onTap: () {
                                        showCustomDialog(child: const CustomTimePickerWidget());
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: context.surfaceContainer,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                              border: Border.all(color: context.outline, width: 0.5),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                            child: Row(children: [
                                              Expanded(child: Text(
                                                '${restaurantRegController.storeMinTime} : ${restaurantRegController.storeMaxTime} ${restaurantRegController.storeTimeUnit}',
                                                style: context.heading.defaultSize.medium,
                                              )),
                                              Icon(Icons.access_time_filled, color: context.primary,)
                                            ]),
                                          ),

                                          Positioned(
                                            left: 10, top: -15,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: context.surfaceContainer,
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child: Row(
                                                children: [
                                                  Text('select_time'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                                  Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ]),
                            ),
                          ),

                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.6,
                            child: Form(
                              key: _formKeySecond,
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text('owner_info'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    CustomTextFieldWidget(
                                      titleText: 'write_first_name'.tr,
                                      controller: _fNameController,
                                      focusNode: _fNameFocus,
                                      nextFocus: _lNameFocus,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      prefixIcon: CupertinoIcons.person_crop_circle_fill,
                                      iconSize: 25,
                                      required: true,
                                      labelText: 'first_name'.tr,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                                    ),
                                    const Gap(Dimensions.paddingOverLarge),

                                    CustomTextFieldWidget(
                                      titleText: 'write_last_name'.tr,
                                      controller: _lNameController,
                                      focusNode: _lNameFocus,
                                      nextFocus: _phoneFocus,
                                      prefixIcon: CupertinoIcons.person_crop_circle_fill,
                                      iconSize: 25,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      required: true,
                                      labelText: 'last_name'.tr,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, "last_name_field_is_required".tr),
                                    ),
                                    const Gap(Dimensions.paddingOverLarge),

                                    CustomTextFieldWidget(
                                      titleText: isDesktop ? 'phone'.tr : 'enter_phone_number'.tr,
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      nextFocus: _emailFocus,
                                      inputType: TextInputType.phone,
                                      isPhone: true,
                                      showTitle: isDesktop,
                                      onCountryChanged: (CountryCode countryCode) {
                                        _countryDialCode = countryCode.dialCode;
                                      },
                                      countryDialCode: _countryDialCode == null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                                          : _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                                      required: true,
                                      labelText: 'phone'.tr,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, null),
                                    ),
                                  ]),
                                ),
                                const Gap(Dimensions.paddingDefault),

                                Text('account_info'.tr, style: context.heading.large.strong),
                                const Gap(Dimensions.paddingSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    CustomTextFieldWidget(
                                      titleText: 'write_email'.tr,
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      nextFocus: _passwordFocus,
                                      inputType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      iconSize: 25,
                                      required: true,
                                      labelText: 'email'.tr,
                                      validator: (value) => ValidateCheck.validateEmail(value),
                                    ),
                                    const Gap(Dimensions.paddingOverLarge),

                                    GetBuilder<DeliverymanRegistrationController>(builder: (deliverymanRegiController) {
                                      return Column(children: [
                                        CustomTextFieldWidget(
                                          titleText: '8+characters'.tr,
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          nextFocus: _confirmPasswordFocus,
                                          inputType: TextInputType.visiblePassword,
                                          prefixIcon: Icons.lock,
                                          iconSize: 25,
                                          isPassword: true,
                                          onChanged: (value){
                                            if(value != null && value.isNotEmpty){
                                              if(!deliverymanRegiController.showPassView){
                                                deliverymanRegiController.showHidePassView();
                                              }
                                              deliverymanRegiController.validPassCheck(value);
                                            }else{
                                              if(deliverymanRegiController.showPassView){
                                                deliverymanRegiController.showHidePassView();
                                              }
                                            }
                                          },
                                          required: true,
                                          labelText: 'password'.tr,
                                          validator: (value) => ValidateCheck.validateEmptyText(value, "password_field_is_required".tr),
                                        ),
                                        deliverymanRegiController.showPassView ? const PassViewWidget() : const SizedBox(),

                                      ]);
                                    }),
                                    const Gap(Dimensions.paddingOverLarge),

                                    CustomTextFieldWidget(
                                      titleText: '8+characters'.tr,
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocus,
                                      inputType: TextInputType.visiblePassword,
                                      inputAction: TextInputAction.done,
                                      prefixIcon: Icons.lock,
                                      iconSize: 25,
                                      isPassword: true,
                                      required: true,
                                      labelText: 'confirm_password'.tr,
                                      validator: (value) => ValidateCheck.validateEmptyText(value, "password_field_is_required".tr),
                                    ),
                                  ]),
                                ),
                                const Gap(Dimensions.paddingDefault),

                                Text('business_tin'.tr, style: context.heading.defaultSize.strong),
                                const Gap(Dimensions.paddingDefault),

                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                    CustomTextFieldWidget(
                                      hintText: 'taxpayer_identification_number_tin'.tr,
                                      labelText: 'tin'.tr,
                                      controller: _tinNumberController,
                                      inputAction: TextInputAction.done,
                                      inputType: TextInputType.text,
                                    ),
                                    const Gap(Dimensions.paddingExtraLarge),

                                    InkWell(
                                      onTap: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          initialDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );

                                        if (pickedDate != null) {
                                          restaurantRegController.setTinExpireDate(pickedDate);
                                        }
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: context.surfaceContainer,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                              border: Border.all(color: context.outline, width: 0.5),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                            child: Row(children: [
                                              Expanded(child: Text(
                                                restaurantRegController.tinExpireDate ?? 'select_date'.tr,
                                                style: context.heading.defaultSize.medium,
                                              )),
                                              Icon(Icons.calendar_month, color: context.primary),
                                            ]),
                                          ),

                                          Positioned(
                                            left: 10, top: -15,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: context.surfaceContainer,
                                              ),
                                              padding: const EdgeInsets.all(5),
                                              child: Text('expire_date'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(Dimensions.paddingLarge),

                                    Text('tin_certificate'.tr, style: context.subHeading.large.regular),

                                    Text('doc_format'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                                    const Gap(Dimensions.paddingLarge),

                                    restaurantRegController.tinFiles!.isEmpty ? InkWell(
                                      onTap: () {
                                        restaurantRegController.pickFiles();
                                      },
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          radius: const Radius.circular(Dimensions.radiusDefault),
                                          dashPattern: const [8, 4],
                                          strokeWidth: 1,
                                          color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE5E5E5),
                                        ),
                                        child: Container(
                                          height: 120,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Gap.horizontal(Dimensions.paddingSmall),
                                              CustomAssetImageWidget(Images.uploadIcon, height: 40, width: 40, color: Get.isDarkMode ? Colors.grey : null),
                                              const Gap.horizontal(Dimensions.paddingSmall),
                                              RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'click_to_upload'.tr,
                                                      style: context.body.small.strong.overrideWith(color: Colors.blue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ) : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge),
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(
                                          radius: const Radius.circular(Dimensions.radiusDefault),
                                          dashPattern: const [8, 4],
                                          strokeWidth: 1,
                                          color: const Color(0xFFE5E5E5),
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Stack(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                                                height: 120,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFAFAFA),
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Builder(
                                                            builder: (context) {
                                                              final filePath;
                                                              final fileName;
                                                              if(GetPlatform.isWeb) {
                                                                filePath = restaurantRegController.tinFiles![0].files[0];
                                                                fileName = filePath.name.toLowerCase();
                                                              } else {
                                                                filePath = restaurantRegController.tinFiles![0].paths[0];
                                                                fileName = filePath!.split('/').last.toLowerCase();
                                                              }

                                                              if (fileName.endsWith('.pdf')) {
                                                                return Row(
                                                                  children: [
                                                                    const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                                                    const Gap.horizontal(10),
                                                                    Expanded(
                                                                      child: Text(
                                                                        fileName,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    const Gap.horizontal(35),
                                                                  ],
                                                                );
                                                              } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
                                                                return Row(
                                                                  children: [
                                                                    const Icon(Icons.description, size: 40, color: Colors.blue),
                                                                    const Gap.horizontal(10),
                                                                    Expanded(
                                                                      child: Text(
                                                                        fileName,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    const Gap.horizontal(35),
                                                                  ],
                                                                );
                                                              } else {
                                                                return Row(
                                                                  children: [
                                                                    const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
                                                                    const Gap.horizontal(10),
                                                                    Expanded(
                                                                      child: Text(
                                                                        fileName,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    const Gap.horizontal(35),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: InkWell(
                                                  onTap: () {
                                                    restaurantRegController.removeFile(0);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  ]),
                                ),
                                const Gap(Dimensions.paddingDefault),

                                restaurantRegController.dataList!.isNotEmpty ? Text('additional_info'.tr, style: context.heading.large.strong) : const SizedBox(),
                                Gap(restaurantRegController.dataList!.isNotEmpty ? Dimensions.paddingSmall : 0),

                                restaurantRegController.dataList!.isNotEmpty ? RestaurantAdditionalDataSectionWidget(restaurantRegiController: restaurantRegController, scrollController: _scrollController) : const SizedBox(),

                              ]),
                            ),
                          ),

                          Visibility(
                            visible: restaurantRegController.storeStatus == 0.9,
                            child: Column(children: [

                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.paddingLarge, bottom: Dimensions.paddingOverLarge),
                                child: Center(child: Text('choose_your_business_plan'.tr, style: context.heading.defaultSize.strong)),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                child: Row(children: [

                                  Get.find<SplashController>().configModel!.commissionBusinessModel != 0 ? Expanded(
                                    child: BaseCardWidget(restaurantRegistrationController: restaurantRegController, title: 'commission_base'.tr,
                                      index: 0, onTap: ()=> restaurantRegController.setBusiness(0),
                                    ),
                                  ) : const SizedBox(),
                                  Gap.horizontal(Get.find<SplashController>().configModel!.commissionBusinessModel != 0 ? Dimensions.paddingDefault : 0),

                                  Get.find<SplashController>().configModel!.subscriptionBusinessModel != 0 ? Expanded(
                                    child: BaseCardWidget(restaurantRegistrationController: restaurantRegController, title: 'subscription_base'.tr,
                                      index: 1, onTap: ()=> restaurantRegController.setBusiness(1),
                                    ),
                                  ) : const SizedBox(),

                                ]),
                              ),
                              const Gap(Dimensions.paddingExtraLarge),

                              restaurantRegController.businessIndex == 0 ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                child: Text(
                                  "${'restaurant_will_pay'.tr} ${Get.find<SplashController>().configModel!.adminCommission}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel!.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                                  style: context.body.small.regular.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                                ),
                              ) : Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                                  child: Text(
                                    'run_restaurant_by_purchasing_subscription_packages'.tr,
                                    style: context.body.small.regular.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                                  ),
                                ),
                                const Gap(Dimensions.paddingLarge),

                                restaurantRegController.packageModel != null ? SizedBox(
                                  height: 440,
                                  child: restaurantRegController.packageModel!.packages!.isNotEmpty ? Swiper(
                                    itemCount: restaurantRegController.packageModel!.packages!.length,
                                    viewportFraction: restaurantRegController.packageModel!.packages!.length > 1 ? 0.7 : 1,
                                    physics: restaurantRegController.packageModel!.packages!.length > 1 ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return PackageCardWidget(
                                        canSelect: restaurantRegController.activeSubscriptionIndex == index,
                                        packages: restaurantRegController.packageModel!.packages![index],
                                      );
                                    },
                                    onIndexChanged: (index) {
                                      restaurantRegController.selectSubscriptionCard(index);
                                    },

                                  ) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomAssetImageWidget(Images.emptyFoodIcon, height: 150),
                                      const Gap(Dimensions.paddingLarge),
                                      Text('no_package_available'.tr, style: context.heading.defaultSize.medium),
                                    ]),
                                  ),
                                ) : const CircularProgressIndicator(),

                              ]),

                            ]),
                          ),

                          const Gap(Dimensions.paddingLarge),
                          
                        ]),
                      ),
                    ),
                  ),
                ),

                isDesktop ? const SizedBox() : buttonView(isDesktop: isDesktop),

              ]),
            ),
          ),
        ),
      );
    });
  }

  Widget webView(RestaurantRegistrationController restaurantRegistrationController, bool isDesktop){
    return Form(
      key: _formKeySecond,
      child: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

          restaurantRegistrationController.storeStatus != 0.9 ? Column(children: [
            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('restaurant_info'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingSmall),

                Row(children: [
                  Expanded(
                    child: Column(children: [
                      Container(
                        padding: EdgeInsets.all(Dimensions.paddingSmall),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            height: 40, width: 500,
                            color: Colors.transparent,
                            child: TabBar(
                              tabAlignment: TabAlignment.start,
                              controller: _tabController,
                              indicatorColor: Theme.of(context).textTheme.bodyLarge?.color,
                              indicatorWeight: 3,
                              labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                              unselectedLabelColor: context.textBaseMedium,
                              unselectedLabelStyle: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                              labelStyle: context.heading.small.strong.overrideWith(color: context.primary),
                              labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.radiusDefault, vertical: 0 ),
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: _tabs,
                              onTap: (int ? value) {
                                setState(() {});
                              },
                            ),
                          ),
                          const Gap(Dimensions.paddingLarge),

                          CustomTextFieldWidget(
                            hintText: 'write_restaurant_name'.tr,
                            controller: _nameController[_tabController!.index],
                            focusNode: _nameFocus[_tabController!.index],
                            nextFocus: _tabController!.index != _languageList!.length-1 ? _addressFocus[_tabController!.index] : _addressFocus[0],
                            inputType: TextInputType.name,
                            capitalization: TextCapitalization.words,
                            prefixImage: Images.shopIcon,
                            labelText: '${'store_name'.tr} (${_languageList[_tabController!.index].value!})',
                            required: true,
                            validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_name_field_is_required".tr),
                          ),
                          const Gap(Dimensions.paddingOverLarge),

                          CustomTextFieldWidget(
                            hintText: 'write_restaurant_address'.tr,
                            controller: _addressController[0],
                            focusNode: _addressFocus[0],
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            required: true,
                            labelText: 'restaurant_address'.tr,
                            validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_address_field_is_required".tr),
                          ),
                        ]),
                      ),
                      const Gap(Dimensions.paddingExtraLarge),

                      CuisineWidget(cuisineTextController: _cuisineController, cuisineFocus: _cuisineFocus),
                    ]),
                  ),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(
                    child: restaurantRegistrationController.zoneList != null ? SelectLocationViewWidget(fromView: true, addressController: _addressController[0], addressFocus: _addressFocus[0]) : const Center(child: CircularProgressIndicator()),
                  ),
                ]),
              ]),
            ),
            const Gap(Dimensions.paddingExtraLarge),

            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('general_info'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingLarge),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: InkWell(
                    onTap: () {
                      showCustomDialog(child: const CustomTimePickerWidget());
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: context.outline, width: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                          child: Row(children: [
                            Expanded(child: Text(
                              '${restaurantRegistrationController.storeMinTime} : ${restaurantRegistrationController.storeMaxTime} ${restaurantRegistrationController.storeTimeUnit}',
                              style: context.heading.defaultSize.medium,
                            )),
                            Icon(Icons.access_time_filled, color: context.primary,)
                          ]),
                        ),

                        Positioned(
                          left: 10, top: -15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.surfaceContainer,
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text('select_time'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                Text(' *', style: context.body.defaultSize.regular.overrideWith(color: context.error)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('restaurant_logo'.tr, style: context.subHeading.defaultSize.medium),
                          Text(' *', style: context.subHeading.defaultSize.medium.overrideWith(color: context.error)),
                        ]),
                        const Gap(Dimensions.paddingSmall),

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(children: [
                            Align(alignment: Alignment.center, child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: restaurantRegistrationController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                                  restaurantRegistrationController.pickedLogo!.path, width: 100, height: 100, fit: BoxFit.cover,
                                ) : Image.file(
                                  File(restaurantRegistrationController.pickedLogo!.path), width: 100, height: 100, fit: BoxFit.cover,
                                ) : Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(CupertinoIcons.camera_fill, color: context.iconDisabledDefault, size: 25),
                                    const Gap(Dimensions.padding2xSmall),

                                    Text('upload_logo'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                  ]),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0, top: 0, left: 0,
                                child: InkWell(
                                  onTap: () => restaurantRegistrationController.pickImage(true, false),
                                  child: DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                      color: restaurantRegistrationController.showLogoValidation 
                                        ? Colors.red 
                                        : context.outline,
                                      strokeWidth: restaurantRegistrationController.showLogoValidation ? 2 : 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: Center(
                                      child: Visibility(
                                        visible: restaurantRegistrationController.pickedLogo != null,
                                        child: Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 2, color: Colors.white),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.camera_alt, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                            const Gap(Dimensions.paddingSmall),

                            Text(
                              'identity_image_ratio'.tr,
                              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                              textAlign: TextAlign.center,
                            ),
                            if (restaurantRegistrationController.showLogoValidation)
                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                                child: Text(
                                  'select_restaurant_logo'.tr,
                                  style: context.body.small.regular.overrideWith(color: context.error),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ]),
                        ),
                      ],
                    )),
                    const Gap.horizontal(Dimensions.paddingDefault),

                    Expanded(child: Column(
                      children: [
                        Row(children: [
                          Text('restaurant_cover'.tr, style: context.subHeading.defaultSize.medium),
                          Text(' *', style: context.subHeading.defaultSize.medium.overrideWith(color: context.error)),
                        ]),
                        const Gap(Dimensions.paddingSmall),

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(children: [
                            Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: restaurantRegistrationController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                                  restaurantRegistrationController.pickedCover!.path, width: context.width, height: 100, fit: BoxFit.cover,
                                ) : Image.file(
                                  File(restaurantRegistrationController.pickedCover!.path), width: context.width, height: 100, fit: BoxFit.cover,
                                ) : Container(
                                  width: context.width, height: 100,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(CupertinoIcons.camera_fill, color: context.iconDisabledDefault, size: 25),
                                    const Gap(Dimensions.padding2xSmall),

                                    Text('upload_cover'.tr, style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                                  ]),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0, top: 0, left: 0,
                                child: InkWell(
                                  onTap: () => restaurantRegistrationController.pickImage(false, false),
                                  child: DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                      color: restaurantRegistrationController.showCoverValidation 
                                        ? Colors.red 
                                        : context.outline,
                                      strokeWidth: restaurantRegistrationController.showCoverValidation ? 2 : 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      radius: const Radius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: Center(
                                      child: Visibility(
                                        visible: restaurantRegistrationController.pickedCover != null,
                                        child: Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 3, color: Colors.white),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            const Gap(Dimensions.paddingSmall),

                            Text(
                              'upload_identity_image_ratio'.tr,
                              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                              textAlign: TextAlign.center,
                            ),
                            if (restaurantRegistrationController.showCoverValidation)
                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                                child: Text(
                                  'select_restaurant_cover_photo'.tr,
                                  style: context.body.small.regular.overrideWith(color: context.error),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ]),
                        ),
                      ],
                    )),
                  ])),
                ]),
              ]),
            ),
            const Gap(Dimensions.paddingExtraLarge),

            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('owner_info'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingLarge),

                Row(children: [
                  Expanded(child: CustomTextFieldWidget(
                    hintText: 'write_first_name'.tr,
                    controller: _fNameController,
                    focusNode: _fNameFocus,
                    nextFocus: _lNameFocus,
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                    prefixIcon: CupertinoIcons.person_crop_circle_fill,
                    iconSize: 25,
                    required: true,
                    labelText: 'first_name'.tr,
                    validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                  )),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(child: CustomTextFieldWidget(
                    hintText: 'write_last_name'.tr,
                    controller: _lNameController,
                    focusNode: _lNameFocus,
                    nextFocus: _phoneFocus,
                    inputType: TextInputType.name,
                    prefixIcon: CupertinoIcons.person_crop_circle_fill,
                    iconSize: 25,
                    capitalization: TextCapitalization.words,
                    required: true,
                    labelText: 'last_name'.tr,
                    validator: (value) => ValidateCheck.validateEmptyText(value, "last_name_field_is_required".tr),
                  )),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(
                    child: CustomTextFieldWidget(
                      hintText: isDesktop ? 'phone'.tr : 'enter_phone_number'.tr,
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      nextFocus: _emailFocus,
                      inputType: TextInputType.phone,
                      isPhone: true,
                      onCountryChanged: (CountryCode countryCode) {
                        _countryDialCode = countryCode.dialCode;
                      },
                      countryDialCode: _countryDialCode == null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                          : _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                      required: true,
                      labelText: 'phone'.tr,
                      validator: (value) => ValidateCheck.validateEmptyText(value, null),
                    ),
                  ),
                ]),
                const Gap(Dimensions.paddingSmall),
              ]),
            ),
            const Gap(Dimensions.paddingExtraLarge),

            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('account_info'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingLarge),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: CustomTextFieldWidget(
                      hintText: 'write_email'.tr,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      nextFocus: _passwordFocus,
                      inputType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      iconSize: 25,
                      required: true,
                      labelText: 'email'.tr,
                      validator: (value) => ValidateCheck.validateEmail(value),
                    ),
                  ),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(
                    child: GetBuilder<DeliverymanRegistrationController>(builder: (deliverymanRegiController) {
                      return Column(children: [
                        CustomTextFieldWidget(
                          hintText: '8+characters'.tr,
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          nextFocus: _confirmPasswordFocus,
                          inputType: TextInputType.visiblePassword,
                          prefixIcon: Icons.lock,
                          iconSize: 25,
                          isPassword: true,
                          onChanged: (value){
                            if(value != null && value.isNotEmpty){
                              if(!deliverymanRegiController.showPassView){
                                deliverymanRegiController.showHidePassView();
                              }
                              deliverymanRegiController.validPassCheck(value);
                            }else{
                              if(deliverymanRegiController.showPassView){
                                deliverymanRegiController.showHidePassView();
                              }
                            }
                          },
                          required: true,
                          labelText: 'password'.tr,
                          validator: (value) => ValidateCheck.validateEmptyText(value, "password_field_is_required".tr),
                        ),
                        deliverymanRegiController.showPassView ? const PassViewWidget() : const SizedBox(),

                      ]);
                    }),
                  ),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(child: CustomTextFieldWidget(
                    titleText: '8+characters'.tr,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    inputType: TextInputType.visiblePassword,
                    inputAction: TextInputAction.done,
                    prefixIcon: Icons.lock,
                    iconSize: 25,
                    isPassword: true,
                    required: true,
                    labelText: 'confirm_password'.tr,
                    validator: (value) => ValidateCheck.validateEmptyText(value, "password_field_is_required".tr),
                  )),
                ]),
                const Gap(Dimensions.paddingSmall),
              ]),
            ),
            const Gap(Dimensions.paddingExtraLarge),

            Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('business_tin'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingSmall),

                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                      CustomTextFieldWidget(
                        hintText: 'taxpayer_identification_number_tin'.tr,
                        labelText: 'tin'.tr,
                        controller: _tinNumberController,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.text,
                        validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_tin_field_is_required".tr),
                      ),
                      const Gap(Dimensions.paddingSizeExtraOverLarge),

                      InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            restaurantRegistrationController.setTinExpireDate(pickedDate);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: context.outline, width: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                              child: Row(children: [
                                Expanded(child: Text(
                                  restaurantRegistrationController.tinExpireDate ?? 'select_date'.tr,
                                  style: context.heading.defaultSize.medium,
                                )),
                                Icon(Icons.calendar_month, color: context.primary),
                              ]),
                            ),

                            Positioned(
                              left: 10, top: -15,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.surfaceContainer,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Text('expire_date'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ]),
                  ),
                  const Gap.horizontal(Dimensions.paddingLarge),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(children: [
                        Text('tin_certificate'.tr, style: context.subHeading.defaultSize.semiBold),
                        const Gap.horizontal(Dimensions.padding2xSmall),

                        Text('(${'doc_format'.tr})', style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium)),
                      ]),
                      const Gap(Dimensions.paddingSmall),

                      restaurantRegistrationController.tinFiles!.isEmpty ? InkWell(
                        onTap: () {
                          restaurantRegistrationController.pickFiles();
                        },
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: const Radius.circular(Dimensions.radiusDefault),
                            dashPattern: const [8, 4],
                            strokeWidth: 1,
                            color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE5E5E5),
                          ),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Gap.horizontal(Dimensions.paddingSmall),
                                CustomAssetImageWidget(Images.uploadIcon, height: 40, width: 40, color: Get.isDarkMode ? Colors.grey : null),
                                const Gap.horizontal(Dimensions.paddingSmall),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'click_to_upload'.tr,
                                        style: context.body.small.strong.overrideWith(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) : DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(Dimensions.radiusDefault),
                          dashPattern: const [8, 4],
                          strokeWidth: 1,
                          color: const Color(0xFFE5E5E5),
                        ),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: Dimensions.paddingDefault),
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        height: 100,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                final file = restaurantRegistrationController.tinFiles![0].files[0];
                                                final fileName = file.name.toLowerCase();

                                                if (fileName.endsWith('.pdf')) {
                                                  return Row(
                                                    children: [
                                                      const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                                      const Gap.horizontal(10),
                                                      Expanded(
                                                        child: Text(
                                                          fileName,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const Gap.horizontal(35),
                                                    ],
                                                  );
                                                } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
                                                  return Row(
                                                    children: [
                                                      const Icon(Icons.description, size: 40, color: Colors.blue),
                                                      const Gap.horizontal(10),
                                                      Expanded(
                                                        child: Text(
                                                          fileName,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const Gap.horizontal(35),
                                                    ],
                                                  );
                                                } else {
                                                  return Row(
                                                    children: [
                                                      const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
                                                      const Gap.horizontal(10),
                                                      Expanded(
                                                        child: Text(
                                                          fileName,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const Gap.horizontal(35),
                                                    ],
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: InkWell(
                                  onTap: () {
                                    restaurantRegistrationController.removeFile(0);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ]),
                  ),
                ]),
              ]),
            ),
            const Gap(Dimensions.paddingExtraLarge),

            restaurantRegistrationController.dataList!.isNotEmpty ? Container(
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('additional_info'.tr, style: context.heading.defaultSize.medium),
                const Gap(Dimensions.paddingDefault),

                RestaurantAdditionalDataSectionWidget(restaurantRegiController: restaurantRegistrationController, scrollController: _scrollController),
              ]),
            ) : const SizedBox(),
          ]) : const SizedBox(),

          restaurantRegistrationController.storeStatus == 0.9 ? const WebBusinessPlanWidget() : const SizedBox(),
          Gap(30),

          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            CustomButtonWidget(
              width: 165,
              textColor: context.textBaseMedium,
              color: context.bgNeutralLight,
              onPressed: () {

                if(restaurantRegistrationController.storeStatus == 0.9){
                  restaurantRegistrationController.storeStatusChange(0.6);
                }else {
                  _phoneController.text = '';
                  _emailController.text = '';
                  _fNameController.text = '';
                  _lNameController.text = '';
                  _lNameController.text = '';
                  _tinNumberController.text = '';
                  _passwordController.text = '';
                  _confirmPasswordController.text = '';
                  for (int i = 0; i < _nameController.length; i++) {
                    _nameController[i].text = '';
                  }
                  for (int i = 0; i < _addressController.length; i++) {
                    _addressController[i].text = '';
                  }
                  restaurantRegistrationController.resetRestaurantRegistration();

                  restaurantRegistrationController.setRestaurantAdditionalJoinUsPageData(isUpdate: true);
                }
              },
              buttonText: restaurantRegistrationController.storeStatus == 0.9 ? 'back'.tr : 'reset'.tr,
              isBold: false,
              fontSize: Dimensions.fontSizeSmall,
            ),

            Gap.horizontal((restaurantRegistrationController.storeStatus == 0.9) && (Get.find<SplashController>().configModel!.commissionBusinessModel == 0) &&
                restaurantRegistrationController.packageModel!.packages!.isEmpty ? 0 : Dimensions.paddingLarge),

            (restaurantRegistrationController.storeStatus == 0.9) && (Get.find<SplashController>().configModel!.commissionBusinessModel == 0) &&
             restaurantRegistrationController.packageModel!.packages!.isEmpty ? const SizedBox() : SizedBox(width: 165, child: buttonView(isDesktop: isDesktop)),
          ]),
        ]),
      ),
    );
  }

  Widget buttonView({bool isDesktop = false}){
    return GetBuilder<RestaurantRegistrationController>(builder: (restaurantRegiController){
      return Column(children: [
        isDesktop ? SizedBox() : LinearProgressIndicator(
          backgroundColor: context.bgNeutralMedium, minHeight: 3,
          value: restaurantRegiController.storeStatus == 0.1 ? 0.3 : restaurantRegiController.storeStatus == 0.6 ? 0.6 : 1,
        ),

        Container(
          padding: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingDefault),
          decoration: isDesktop ? null : BoxDecoration(
            color: context.surfaceContainer,
            boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
          ),
          child: CustomButtonWidget(
            isBold: isDesktop ? false : true,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
            isLoading: restaurantRegiController.isLoading,
            buttonText: restaurantRegiController.storeStatus == 0.1 && !isDesktop ? 'next'.tr : 'submit'.tr,
            onPressed: (restaurantRegiController.storeStatus == 0.1 && !isDesktop && !restaurantRegiController.inZone)
                || (isDesktop && !restaurantRegiController.inZone) ? null : () async {
              bool defaultNameNull = false;
              bool defaultAddressNull = false;
              bool customFieldEmpty = false;
              for(int index=0; index<_languageList!.length; index++) {
                if(_languageList[index].key == 'en') {
                  if (_nameController[index].text.trim().isEmpty) {
                    defaultNameNull = true;
                  }
                  if(_addressController[index].text.trim().isEmpty){
                    defaultAddressNull = true;
                  }
                  break;
                }
              }

              Map<String, dynamic> additionalData = {};
              List<FilePickerResult> additionalDocuments = [];
              List<String> additionalDocumentsInputType = [];

              if(restaurantRegiController.storeStatus != 0.1 || isDesktop){
                for (DataModel data in restaurantRegiController.dataList!) {
                  bool isTextField = data.fieldType == CustomInputFieldType.text || data.fieldType == CustomInputFieldType.number || data.fieldType == CustomInputFieldType.email || data.fieldType == CustomInputFieldType.phone;
                  bool isDate = data.fieldType == CustomInputFieldType.date;
                  bool isCheckBox = data.fieldType == CustomInputFieldType.checkBox;
                  bool isFile = data.fieldType == CustomInputFieldType.file;
                  int index = restaurantRegiController.dataList!.indexOf(data);
                  bool isRequired = data.isRequired == 1;

                  if(isTextField) {
                    if (kDebugMode) {
                      print('=====check text field : ${restaurantRegiController.additionalList![index].text == ''}');
                    }
                    if(restaurantRegiController.additionalList![index].text != '') {
                      additionalData.addAll({data.inputData! : restaurantRegiController.additionalList![index].text});
                    } else {
                      if(isRequired) {
                        customFieldEmpty = true;
                        showCustomSnackBar('${data.placeholderData} ${'can_not_be_empty'.tr}');
                        break;
                      }
                    }
                  } else if(isDate) {
                    if (kDebugMode) {
                      print('---check date : ${restaurantRegiController.additionalList![index]}');
                    }
                    if(restaurantRegiController.additionalList![index] != null) {
                      additionalData.addAll({data.inputData! : restaurantRegiController.additionalList![index]});
                    } else {
                      if(isRequired) {
                        customFieldEmpty = true;
                        showCustomSnackBar('${data.placeholderData} ${'can_not_be_empty'.tr}');
                        break;
                      }
                    }
                  } else if(isCheckBox) {
                    List<String> checkData = [];
                    bool noNeedToGoElse = false;
                    for(var e in restaurantRegiController.additionalList![index]) {
                      if(e != 0) {
                        checkData.add(e);
                        customFieldEmpty = false;
                        noNeedToGoElse = true;
                      } else if(!noNeedToGoElse && isRequired) {
                        customFieldEmpty = true;
                      }
                    }
                    if(customFieldEmpty && isRequired) {
                      showCustomSnackBar( '${'please_set_data_in'.tr} ${restaurantRegiController.dataList![index].inputData!.replaceAll('_', ' ')} ${'field'.tr}');
                      break;
                    } else {
                      additionalData.addAll({data.inputData! : checkData});
                    }

                  } else if(isFile) {
                    if (kDebugMode) {
                    }
                    if(restaurantRegiController.additionalList![index].length == 0 && isRequired) {
                      customFieldEmpty = true;
                      showCustomSnackBar('${'please_add'.tr} ${restaurantRegiController.dataList![index].inputData!.replaceAll('_', ' ')}');
                      break;
                    } else {
                      restaurantRegiController.additionalList![index].forEach((file) {
                        additionalDocuments.add(file);
                        additionalDocumentsInputType.add(restaurantRegiController.dataList![index].inputData!);
                      });

                    }
                  }

                }
              }

              String tin = _tinNumberController.text.trim();
              String minTime = restaurantRegiController.storeMinTime;
              String maxTime = restaurantRegiController.storeMaxTime;
              String fName = _fNameController.text.trim();
              String lName = _lNameController.text.trim();
              String phone = _phoneController.text.trim();
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();
              String confirmPassword = _confirmPasswordController.text.trim();
              String phoneWithCountryCode = _countryDialCode != null ? _countryDialCode! + phone : phone;
              bool valid = false;
              PhoneValid phoneValid = await CustomValidator.isPhoneValid(phoneWithCountryCode);
              phoneWithCountryCode = phoneValid.phone;

              try {
                double.parse(maxTime);
                double.parse(minTime);
                valid = true;
              } on FormatException {
                valid = false;
              }

              if(restaurantRegiController.storeStatus == 0.1 || restaurantRegiController.storeStatus == 0.6) {
                if(restaurantRegiController.storeStatus == 0.1 && !isDesktop){
                  if(_formKeyLogin!.currentState!.validate()){
                    if(defaultNameNull) {
                      showCustomSnackBar('enter_restaurant_name'.tr);
                    }else if(restaurantRegiController.pickedLogo == null){
                      restaurantRegiController.setImageValidation(logo: true);
                      showCustomSnackBar('select_restaurant_logo'.tr);
                    }else if(restaurantRegiController.pickedCover == null) {
                      restaurantRegiController.setImageValidation(cover: true);
                      showCustomSnackBar('select_restaurant_cover_photo'.tr);
                    }else if(defaultAddressNull) {
                      showCustomSnackBar('enter_restaurant_address'.tr);
                    }else if(restaurantRegiController.selectedZoneIndex == -1) {
                      showCustomSnackBar('please_select_zone_for_the_restaurant'.tr);
                    }else if(minTime.isEmpty) {
                      showCustomSnackBar('enter_minimum_delivery_time'.tr);
                    }else if(maxTime.isEmpty) {
                      showCustomSnackBar('enter_maximum_delivery_time'.tr);
                    }else if(!valid) {
                      showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
                    }else if(valid && double.parse(minTime) > double.parse(maxTime)) {
                      showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                    }else if(restaurantRegiController.restaurantLocation == null) {
                      showCustomSnackBar('set_store_location'.tr);
                    }else{
                      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                      restaurantRegiController.storeStatusChange(0.6);
                      firstTime = true;
                    }
                  }
                }else{
                  if(isDesktop){
                    if(defaultNameNull) {
                      showCustomSnackBar('enter_restaurant_name'.tr);
                    }else if(restaurantRegiController.pickedLogo == null){
                      restaurantRegiController.setImageValidation(logo: true);
                      showCustomSnackBar('select_restaurant_logo'.tr);
                    }else if(restaurantRegiController.pickedCover == null) {
                      restaurantRegiController.setImageValidation(cover: true);
                      showCustomSnackBar('select_restaurant_cover_photo'.tr);
                    }else if(defaultAddressNull) {
                      showCustomSnackBar('enter_restaurant_address'.tr);
                    }else if(restaurantRegiController.selectedZoneIndex == -1) {
                      showCustomSnackBar('please_select_zone_for_the_restaurant'.tr);
                    }else if(minTime.isEmpty) {
                      showCustomSnackBar('enter_minimum_delivery_time'.tr);
                    }else if(maxTime.isEmpty) {
                      showCustomSnackBar('enter_maximum_delivery_time'.tr);
                    }else if(!valid) {
                      showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
                    }else if(valid && double.parse(minTime) > double.parse(maxTime)) {
                      showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                    }else if(restaurantRegiController.restaurantLocation == null) {
                      showCustomSnackBar('set_store_location'.tr);
                    }else if(fName.isEmpty) {
                      showCustomSnackBar('enter_your_first_name'.tr);
                    }else if(lName.isEmpty) {
                      showCustomSnackBar('enter_your_last_name'.tr);
                    }else if(phone.isEmpty) {
                      showCustomSnackBar('enter_phone_number'.tr);
                    } else if (!phoneValid.isValid) {
                      showCustomSnackBar('invalid_phone_number'.tr);
                    } else if(email.isEmpty) {
                      showCustomSnackBar('enter_email_address'.tr);
                    }else if(!GetUtils.isEmail(email)) {
                      showCustomSnackBar('enter_a_valid_email_address'.tr);
                    }else if(password.isEmpty) {
                      showCustomSnackBar('enter_password'.tr);
                    }else if(password.length < 8) {
                      showCustomSnackBar('password_should_be'.tr);
                    }else if(password != confirmPassword) {
                      showCustomSnackBar('confirm_password_does_not_matched'.tr);
                    }else if(customFieldEmpty) {
                      if (kDebugMode) {
                        print('not provide addition data');
                      }
                    }else{
                      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                      restaurantRegiController.storeStatusChange(0.9);
                    }
                  }
                  if((restaurantRegiController.storeStatus == 0.6 && !isDesktop)){
                    if(fName.isEmpty) {
                      showCustomSnackBar('enter_your_first_name'.tr);
                    }else if(lName.isEmpty) {
                      showCustomSnackBar('enter_your_last_name'.tr);
                    }else if(phone.isEmpty) {
                      showCustomSnackBar('enter_phone_number'.tr);
                    }else if (!phoneValid.isValid) {
                      showCustomSnackBar('invalid_phone_number'.tr);
                    }else if(email.isEmpty) {
                      showCustomSnackBar('enter_email_address'.tr);
                    }else if(!GetUtils.isEmail(email)) {
                      showCustomSnackBar('enter_a_valid_email_address'.tr);
                    }else if(password.isEmpty) {
                      showCustomSnackBar('enter_password'.tr);
                    }else if(password.length < 8) {
                      showCustomSnackBar('password_should_be'.tr);
                    }else if(password != confirmPassword) {
                      showCustomSnackBar('confirm_password_does_not_matched'.tr);
                    }else if(customFieldEmpty) {
                      if (kDebugMode) {
                        print('not provide addition data');
                      }
                    }else {
                      restaurantRegiController.storeStatusChange(0.9);
                    }
                  }
                }
              }else {
                List<TranslationBodyModel> translation = [];
                for(int index=0; index<_languageList.length; index++) {
                  translation.add(TranslationBodyModel(
                    locale: _languageList[index].key, key: 'name',
                    value: _nameController[index].text.trim().isNotEmpty ? _nameController[index].text.trim()
                        : _nameController[0].text.trim(),
                  ));
                  translation.add(TranslationBodyModel(
                    locale: _languageList[index].key, key: 'address',
                    value: _addressController[index].text.trim().isNotEmpty ? _addressController[index].text.trim()
                        : _addressController[0].text.trim(),
                  ));
                }

                List<String> cuisines = [];
                for (var index in Get.find<CuisineController>().selectedCuisines!) {
                  cuisines.add(Get.find<CuisineController>().cuisineModel!.cuisines![index].id.toString());
                }

                Map<String, String> data = {};

                data.addAll(RestaurantBodyModel(
                  deliveryTimeType: restaurantRegiController.storeTimeUnit,
                  translation: jsonEncode(translation), minDeliveryTime: minTime,
                  maxDeliveryTime: maxTime, lat: restaurantRegiController.restaurantLocation!.latitude.toString(), email: email,
                  lng: restaurantRegiController.restaurantLocation!.longitude.toString(), fName: fName, lName: lName, phone: phoneWithCountryCode,
                  password: password, zoneId: restaurantRegiController.zoneList![restaurantRegiController.selectedZoneIndex!].id.toString(),
                  cuisineId: cuisines,
                  businessPlan: restaurantRegiController.businessIndex == 0 ? 'commission' : 'subscription',
                  packageId: restaurantRegiController.businessIndex == 0 ? '' : restaurantRegiController.packageModel!.packages![restaurantRegiController.activeSubscriptionIndex].id!.toString(),
                  tin: tin, tinExpireDate: restaurantRegiController.tinExpireDate,
                ).toJson());

                data.addAll({
                  'additional_data': jsonEncode(additionalData),
                });

                restaurantRegiController.registerRestaurant(data, additionalDocuments, additionalDocumentsInputType);
              }

            },
          ),
        ),
      ]);
    });
  }
}
