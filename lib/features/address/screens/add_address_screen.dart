import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/screens/set_location_screen.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AddAddressScreen extends StatefulWidget {
  final bool fromCheckout;
  final int? zoneId;
  final AddressModel? address;
  final bool forGuest;

  const AddAddressScreen({super.key, required this.fromCheckout, this.zoneId, this.address, this.forGuest = false});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _levelNode = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  late LatLng _initialPosition;

  bool _otherSelect = false;
  String? _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
      ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    Get.find<LocationController>().setAddressTypeIndex(0, notify: false);
    if (Get.find<AuthController>().isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    if (widget.address == null) {
      _initialPosition = LatLng(
        double.parse(Get.find<SplashController>().configModel?.defaultLocation?.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel?.defaultLocation?.lng ?? '0'),
      );
    } else {
      Get.find<LocationController>().updateAddress(widget.address!);
      _initialPosition = LatLng(
        double.parse(widget.address?.latitude ?? '0'),
        double.parse(widget.address?.longitude ?? '0'),
      );

      if (widget.address?.addressType == 'home') {
        Get.find<LocationController>().setAddressTypeIndex(0, notify: false);
      } else if (widget.address?.addressType == 'office') {
        Get.find<LocationController>().setAddressTypeIndex(1, notify: false);
      } else {
        Get.find<LocationController>().setAddressTypeIndex(2, notify: false);
        _levelController.text = widget.address?.addressType ?? '';
        _otherSelect = true;
      }

      _splitPhoneNumber(widget.address!.contactPersonNumber!);
      _contactPersonNameController.text = widget.address!.contactPersonName ?? '';
      _emailController.text = widget.address!.email ?? '';
      _streetNumberController.text = widget.address!.road ?? '';
      _houseController.text = widget.address!.house ?? '';
      _floorController.text = widget.address!.floor ?? '';
    }
  }

  void _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    _countryDialCode = '+${phoneNumber.countryCode}';
    _contactPersonNumberController.text = phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: widget.forGuest ? 'delivery_address'.tr : widget.address == null ? 'add_new_address'.tr : 'update_address'.tr,
      ),
      body: SafeArea(
        child: GetBuilder<ProfileController>(builder: (profileController) {
          if (profileController.userInfoModel != null && _contactPersonNameController.text.isEmpty) {
            _contactPersonNameController.text = '${profileController.userInfoModel!.fName} ${profileController.userInfoModel!.lName}';
            _splitPhoneNumber(profileController.userInfoModel!.phone!);
          }

          return GetBuilder<LocationController>(builder: (locationController) {
            _addressController.text = locationController.address ?? '';

            return Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController, 
                  physics: const BouncingScrollPhysics(), 
                  padding: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingDefault),
                  child: Column(children: [
                    SizedBox(height: isDesktop ? Dimensions.paddingLarge : 0),
                    
                    SizedBox(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Expanded(flex: 6, child: addressSectionWidget(locationController, isDesktop)),
                            const SizedBox(width: Dimensions.paddingLarge),

                            Expanded(flex: 4, child: informationSectionWidget(locationController, isDesktop)),

                          ]) : mobileAddressFormWidget(locationController),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              !isDesktop ? GetBuilder<AddressController>(builder: (addressController) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingDefault),
                  child: SafeArea(
                    top: false,
                    child: Row(children: [
                      Expanded(
                        child: CustomButtonWidget(
                          radius: Dimensions.paddingSmall,
                          color: context.surfaceContainer,
                          textColor: Theme.of(context).textTheme.bodyLarge?.color,
                          buttonText: 'cancel'.tr,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingDefault),

                      Expanded(
                        child: CustomButtonWidget(
                          radius: Dimensions.paddingSmall,
                          buttonText: widget.forGuest ? 'continue'.tr : widget.address == null ? 'save_location'.tr : 'update_address'.tr,
                          isLoading: addressController.isLoading,
                          onPressed: locationController.loading ? null : () => _onSaveButtonPressed(locationController),
                        ),
                      ),
                    ]),
                  ),
                );
              }) : const SizedBox(),

            ]);
          });
        }),
      ),
    );
  }

  Widget mobileAddressFormWidget(LocationController locationController) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text('address_info'.tr, style: context.heading.large.strong),
      const SizedBox(height: Dimensions.paddingSmall),
      Text(
        'share_the_services_youd_like_to_see_and_help_us_improve_your_experience'.tr,
        style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
      ),
      const SizedBox(height: Dimensions.paddingExtraLarge),

      SizedBox(
        height: 38,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: locationController.addressTypeList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingLarge),
            child: InkWell(
              onTap: () {
                _otherSelect = index == 2;
                locationController.setAddressTypeIndex(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: Dimensions.padding2xSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: locationController.addressTypeIndex == index ? context.primary : null,
                ),
                child: Row(children: [
                  SizedBox(
                    height: 16, width: 16,
                    child: CustomAssetImageWidget(
                      index == 0 ? Images.navHome : index == 1 ? Images.office : Images.others,
                      color: locationController.addressTypeIndex == index ? context.surfaceContainer : context.iconBaseMedium,
                    ),
                  ),
                  SizedBox(width: Dimensions.padding2xSmall),

                  Text(
                    index == 0 ? 'home'.tr : index == 1 ? 'office'.tr : 'others'.tr,
                    style: context.subHeading.defaultSize.strong.overrideWith(color: locationController.addressTypeIndex == index ? context.surfaceContainer : context.textBaseMedium),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingDefault),

      CustomCard(
        isBorder: false,
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _otherSelect ? CustomTextFieldWidget(
            showTitle: true,
            titleText: 'level_name'.tr,
            hintText: 'ex_02'.tr,
            labelText: 'level_name'.tr,
            showLabelText: false,
            inputType: TextInputType.text,
            controller: _levelController,
            focusNode: _levelNode,
            nextFocus: _addressNode,
            capitalization: TextCapitalization.words,
            showBorder: true,
          ) : const SizedBox(),
          _otherSelect ? const SizedBox(height: Dimensions.paddingOverLarge) : const SizedBox(),

          InkWell(
            onTap: () async {
              var selectedAddress = await Get.toNamed(
                RouteHelper.getSetLocationRoute(),
                arguments: _addressController.text.isNotEmpty
                    ? SetLocationScreen(initialAddress: _addressController.text) : null,
              );
              if(selectedAddress != null && selectedAddress.latitude != null && selectedAddress.longitude != null) {
                locationController.updateAddress(selectedAddress, updateAddressType: false);
              }
            },
            child: IgnorePointer(
              child: CustomTextFieldWidget(
                showTitle: true,
                titleText: '${'location'.tr} *',
                hintText: 'add_location'.tr,
                labelText: 'location'.tr,
                showLabelText: false,
                required: true,
                prefixIcon: Icons.location_on_outlined,
                inputType: TextInputType.streetAddress,
                focusNode: _addressNode,
                nextFocus: _houseNode,
                controller: _addressController,
                showBorder: true,
                suffixImage: Images.editBtn,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingOverLarge),

          CustomTextFieldWidget(
            showTitle: true,
            titleText: '${'contact_person_name'.tr} *',
            hintText: 'ex_doe'.tr,
            labelText: 'contact_person_name'.tr,
            showLabelText: false,
            required: true,
            inputType: TextInputType.name,
            controller: _contactPersonNameController,
            focusNode: _nameNode,
            nextFocus: _numberNode,
            capitalization: TextCapitalization.words,
            showBorder: true,
          ),
          const SizedBox(height: Dimensions.paddingOverLarge),

          CustomTextFieldWidget(
            showTitle: true,
            titleText: '${'phone_number'.tr} *',
            hintText: 'xxx-xxx-xxxxx',
            labelText: 'phone_number'.tr,
            showLabelText: false,
            required: true,
            controller: _contactPersonNumberController,
            focusNode: _numberNode,
            nextFocus: widget.forGuest ? _emailFocus : null,
            inputAction: widget.forGuest ? TextInputAction.next : TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: (CountryCode countryCode) {
              _countryDialCode = countryCode.dialCode;
            },
            countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            showBorder: true,
          ),

          widget.forGuest ? const SizedBox(height: Dimensions.paddingOverLarge) : const SizedBox(),
          widget.forGuest ? CustomTextFieldWidget(
            showTitle: true,
            titleText: 'email'.tr,
            hintText: 'enter_email'.tr,
            labelText: 'email'.tr,
            showLabelText: false,
            controller: _emailController,
            focusNode: _emailFocus,
            inputType: TextInputType.emailAddress,
            showBorder: true,
          ) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingOverLarge),

          CustomTextFieldWidget(
            showTitle: true,
            titleText: 'street_number'.tr,
            hintText: 'street_number'.tr,
            labelText: 'street_number'.tr,
            showLabelText: false,
            inputType: TextInputType.streetAddress,
            focusNode: _streetNode,
            nextFocus: _nameNode,
            controller: _streetNumberController,
            showBorder: true,
          ),
          const SizedBox(height: Dimensions.paddingOverLarge),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: CustomTextFieldWidget(
                showTitle: true,
                titleText: 'house_no'.tr,
                hintText: 'house'.tr,
                labelText: 'house'.tr,
                showLabelText: false,
                inputType: TextInputType.text,
                focusNode: _houseNode,
                nextFocus: _floorNode,
                controller: _houseController,
                showBorder: true,
              ),
            ),
            const SizedBox(width: Dimensions.paddingLarge),

            Expanded(
              child: CustomTextFieldWidget(
                showTitle: true,
                titleText: 'floor'.tr,
                hintText: 'floor'.tr,
                labelText: 'floor'.tr,
                showLabelText: false,
                inputType: TextInputType.text,
                focusNode: _floorNode,
                nextFocus: _streetNode,
                controller: _floorController,
                showBorder: true,
              ),
            ),
          ]),
        ]),
      ),

    ]);
  }

  Widget addressSectionWidget(LocationController locationController, bool isDesktop) {
    return Container(
      decoration: isDesktop ? BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)],
      ) : const BoxDecoration(),
      padding: EdgeInsets.all(isDesktop ? Dimensions.paddingLarge : 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[


        Text('address_type'.tr, style: context.heading.defaultSize.semiBold),
        const SizedBox(height: Dimensions.paddingSmall),

        SizedBox(
          height: 45,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: locationController.addressTypeList.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingLarge),
              child: InkWell(
                onTap: () {
                  _otherSelect = index == 2;
                  locationController.setAddressTypeIndex(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: Dimensions.padding2xSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: locationController.addressTypeIndex == index ? context.primary : null,
                  ),
                  child: Row(children: [
                    SizedBox(
                      height: 20, width: 20,
                      child: CustomAssetImageWidget(
                        index == 0 ? Images.navHome : index == 1 ? Images.office : Images.others,
                        color: locationController.addressTypeIndex == index ? context.surfaceContainer : context.iconBaseMedium,
                      ),
                    ),
                    SizedBox(width: Dimensions.paddingSmall),

                    Text(
                      index == 0 ? 'home'.tr : index == 1 ? 'office'.tr : 'others'.tr,
                      style: context.subHeading.defaultSize.strong.overrideWith(color: locationController.addressTypeIndex == index ? context.surfaceContainer : context.textBaseMedium),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingDefault),
        CustomCard(
          isBorder: false,
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
            _otherSelect ? CustomTextFieldWidget(
              hintText: 'ex_02'.tr,
              labelText: 'level_name'.tr,
              inputType: TextInputType.text,
              controller: _levelController,
              focusNode: _levelNode,
              nextFocus: _addressNode,
              capitalization: TextCapitalization.words,
              showBorder: true,
            ) : const SizedBox(),
            _otherSelect ? const SizedBox(height: Dimensions.paddingOverLarge) : SizedBox(height: Dimensions.paddingSmall),

            CustomTextFieldWidget(
              hintText: 'delivery_address'.tr,
              labelText: 'delivery_address'.tr,
              required: true,
              inputType: TextInputType.streetAddress,
              focusNode: _addressNode,
              nextFocus: _nameNode,
              controller: _addressController,
              onChanged: (text) => locationController.setPlaceMark(text),
              showBorder: true,
            ),
            SizedBox(height: isDesktop ? 0 : Dimensions.paddingOverLarge),

            isDesktop ? SizedBox() : informationSectionWidget(locationController, isDesktop),
          ]),
        ),
        
      ]),
    );
  }

  Widget informationSectionWidget(LocationController locationController, bool isDesktop) {
    return Container(
      decoration: isDesktop ? BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)],
      ) : const BoxDecoration(),
      padding: EdgeInsets.all(isDesktop ? Dimensions.paddingOverLarge : 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        CustomTextFieldWidget(
          hintText: 'ex_doe'.tr,
          labelText: 'name'.tr,
          required: true,
          inputType: TextInputType.name,
          controller: _contactPersonNameController,
          focusNode: _nameNode,
          nextFocus: _numberNode,
          capitalization: TextCapitalization.words,
          showBorder: true,
        ),
        const SizedBox(height: Dimensions.paddingOverLarge),
        
        CustomTextFieldWidget(
          hintText: 'xxx-xxx-xxxxx',
          labelText: 'phone'.tr,
          required: true,
          controller: _contactPersonNumberController,
          focusNode: _numberNode,
          nextFocus: widget.forGuest ? _emailFocus : _streetNode,
          inputType: TextInputType.phone,
          isPhone: true,
          onCountryChanged: (CountryCode countryCode) {
            _countryDialCode = countryCode.dialCode;
          },
          countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
        ),
        const SizedBox(height: Dimensions.paddingOverLarge),
        
        widget.forGuest ? CustomTextFieldWidget(
          hintText: 'enter_email'.tr,
          labelText: 'email'.tr,
          controller: _emailController,
          focusNode: _emailFocus,
          nextFocus: _streetNode,
          inputType: TextInputType.emailAddress,
        ) : const SizedBox(),
        SizedBox(height: widget.forGuest ? Dimensions.paddingOverLarge : 0),
        
        CustomTextFieldWidget(
          hintText: "ex_02".tr,
          labelText: 'street_number'.tr,
          inputType: TextInputType.streetAddress,
          focusNode: _streetNode,
          nextFocus: _houseNode,
          controller: _streetNumberController,
        ),
        const SizedBox(height: Dimensions.paddingOverLarge),
        
        Row(children: [
          Expanded(
            child: CustomTextFieldWidget(
              hintText: 'ex_1005/2'.tr,
              labelText: 'house'.tr,
              inputType: TextInputType.text,
              focusNode: _houseNode,
              nextFocus: _floorNode,
              controller: _houseController,
            ),
          ),
          const SizedBox(width: Dimensions.paddingLarge),
          
          Expanded(
            child: CustomTextFieldWidget(
              hintText: 'ex_02'.tr,
              labelText: 'floor'.tr,
              inputType: TextInputType.text,
              focusNode: _floorNode,
              inputAction: TextInputAction.done,
              controller: _floorController,
            ),
          ),
        ]),
        SizedBox(height: isDesktop ? Dimensions.paddingOverLarge : 0),
        
        isDesktop ? GetBuilder<AddressController>(builder: (addressController) {
          return CustomButtonWidget(
            radius: Dimensions.paddingSmall,
            width: Dimensions.webMaxWidth,
            margin: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingSmall),
            buttonText: widget.forGuest ? 'continue'.tr : widget.address == null ? 'save_location'.tr : 'update_address'.tr,
            isLoading: addressController.isLoading,
            onPressed: locationController.loading ? null : () => _onSaveButtonPressed(locationController),
          );
        }) : const SizedBox(),
        
      ]),
    );
  }

  void _onSaveButtonPressed(LocationController locationController) async {
    String numberWithCountryCode = _countryDialCode! + _contactPersonNumberController.text;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    AddressModel? addressModel = _prepareAddressModel(locationController, phoneValid.isValid, numberWithCountryCode);
    if (addressModel == null) {
      return;
    }

    if (widget.forGuest) {
      addressModel.email = _emailController.text;
      Get.back(result: addressModel);
    } else {
      if (widget.address == null) {
        _addAddress(addressModel);
      } else {
        _updateAddress(addressModel);
      }
    }
  }

  AddressModel? _prepareAddressModel(LocationController locationController, bool isValid, String numberWithCountryCode) {
    if (_contactPersonNameController.text.isEmpty) {
      showCustomSnackBar('please_provide_contact_person_name'.tr);
    } else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else {
      AddressModel addressModel = AddressModel(
        id: widget.address?.id,
        addressType: _otherSelect ? _levelController.text : locationController.addressTypeList[locationController.addressTypeIndex],
        contactPersonName: _contactPersonNameController.text,
        contactPersonNumber: numberWithCountryCode,
        address: _addressController.text,
        latitude: locationController.position.latitude.toString(),
        longitude: locationController.position.longitude.toString(),
        zoneId: locationController.zoneID,
        road: _streetNumberController.text.trim(),
        house: _houseController.text.trim(),
        floor: _floorController.text.trim(),
      );

      return addressModel;
    }
    return null;
  }

  void _addAddress(AddressModel addressModel) {
    Get.find<AddressController>().addAddress(addressModel, widget.fromCheckout, widget.zoneId).then((response) {
      if (response.isSuccess) {
        Get.back(result: addressModel);
        showCustomSnackBar(response.message, isError: false);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _updateAddress(AddressModel addressModel) {
    Get.find<AddressController>().updateAddress(addressModel, widget.address!.id).then((response) {
      if (response.isSuccess) {
        Get.back();
        showCustomSnackBar(response.message, isError: false);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }
}
