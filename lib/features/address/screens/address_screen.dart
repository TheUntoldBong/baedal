import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_card_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    bool isDeskTop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<AddressController>(builder: (addressController) {
      return Scaffold (

        appBar: CustomAppBarWidget(title: 'my_address'.tr),
        body: GetBuilder<AddressController>(builder: (addressController) {
          if(!isLoggedIn) {
            return NotLoggedInScreen(callBack: (value){
              _initCall();
              setState(() {});
            });
          }

          bool showStickyAddButton = !isDeskTop && (addressController.addressList?.isNotEmpty ?? false);

          return Stack(children: [

            RefreshIndicator(
              onRefresh: () async {
                await addressController.getAddressList();
              },
              child: Container(
                height: context.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: addressController.addressList != null ? AssetImage(addressController.addressList!.isNotEmpty ? Images.city : Images.cityWhite)
                        : const AssetImage(Images.city),
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [

                      Center(child: SizedBox(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(children: [

                            isDeskTop ? const SizedBox(height: Dimensions.paddingLarge) : const SizedBox(),

                            addressController.addressList != null ? addressController.addressList!.isNotEmpty ? Padding(
                              padding: ResponsiveHelper.isMobile(context) ? const EdgeInsets.all(Dimensions.paddingDefault) : EdgeInsets.zero,
                              child: ResponsiveHelper.isMobile(context) ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: addressController.addressList!.length,
                                itemBuilder: (context, index) {
                                  return AddressCardWidget(
                                    address: addressController.addressList![index], fromAddress: true,
                                    index: index,
                                    onTap: () {
                                      Get.toNamed(RouteHelper.getMapRoute(
                                        addressController.addressList![index], 'address',
                                      ));
                                    },
                                  );
                                },
                              ) : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: Dimensions.paddingLarge,
                                  mainAxisSpacing: isDeskTop ? Dimensions.paddingSmall : 0.01,
                                  childAspectRatio: isDeskTop ? 4 : 5,
                                  crossAxisCount: ResponsiveHelper.isTab(context) ? 2 : 3,
                                ),
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(ResponsiveHelper.isTab(context) ? Dimensions.paddingSmall : 0),
                                shrinkWrap: true,
                                itemCount: isDeskTop ? (addressController.addressList!.length + 1)  : addressController.addressList!.length,
                                itemBuilder: (context, index) {
                                  return (isDeskTop && (index == addressController.addressList!.length)) ? Padding(
                                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                                    child: InkWell(
                                      onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                                      child: Container(
                                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                        decoration:  BoxDecoration(
                                          color: context.surfaceContainer,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                        ),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                          Icon(Icons.add_circle_outline, color: context.primary),
                                          const SizedBox(height: Dimensions.paddingSmall),

                                          Text('add_new_address'.tr, style: context.subHeading.small.regular.overrideWith(color: context.primary)),

                                        ]),
                                      ),
                                    ),
                                  ) : AddressCardWidget(
                                    address: addressController.addressList![index], fromAddress: true,
                                    index: index,
                                    onTap: () {
                                      Get.toNamed(RouteHelper.getMapRoute(
                                        addressController.addressList![index], 'address',
                                      ));
                                    },
                                  );
                                },
                              ),
                            ) : NoDataScreen(title: 'no_address_found'.tr, isEmptyAddress: true, fromAddress: true) : Center(child: Padding(
                              padding: EdgeInsets.only(top: context.height * 0.4),
                              child: CircularProgressIndicator(),
                            )),

                            showStickyAddButton ? const SizedBox(height: 80) : const SizedBox(),

                          ]),
                        ),
                      )),

                    ]),
                  ),
                ),
              ),

            if(showStickyAddButton) Positioned(
              left: Dimensions.paddingDefault,
              right: Dimensions.paddingDefault,
              bottom: Dimensions.paddingDefault,
              child: SafeArea(
                top: false,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: context.shadow, blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add_circle_outline, size: 18, color: context.surfaceContainer),
                      const SizedBox(width: Dimensions.paddingSmall),
                      Text('add_new_address'.tr, style: context.heading.defaultSize.strong.overrideWith(color: Theme.of(context).colorScheme.onPrimary)),
                    ]),
                  ),
                ),
              ),
            ),

          ]);
        }),
      );
    });
  }
}