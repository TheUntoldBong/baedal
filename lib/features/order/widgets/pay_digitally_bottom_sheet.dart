import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PayDigitallyBottomSheet extends StatefulWidget {
  final OrderModel order;
  final double totalPrice;
  final String? contactNumber;

  const PayDigitallyBottomSheet({super.key, required this.order, required this.totalPrice, this.contactNumber});

  static void open(BuildContext context, {required OrderModel order, required double totalPrice, String? contactNumber}) {
    final sheet = PayDigitallyBottomSheet(order: order, totalPrice: totalPrice, contactNumber: contactNumber);
    if(ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: sheet));
    } else {
      Get.bottomSheet(sheet, backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true);
    }
  }

  @override
  State<PayDigitallyBottomSheet> createState() => _PayDigitallyBottomSheetState();
}

class _PayDigitallyBottomSheetState extends State<PayDigitallyBottomSheet> {
  int _selectedIndex = -1;
  bool _isLoading = false;

  List<PaymentBody> get _gateways => Get.find<SplashController>().configModel?.activePaymentMethodList ?? [];

  String get _callback {
    if(GetPlatform.isWeb) {
      String? hostname = html.window.location.hostname;
      String protocol = html.window.location.protocol;
      return '$protocol//$hostname${RouteHelper.getOrderDetailsRoute(widget.order.id, contactNumber: widget.contactNumber, paymentStatus: '')}';
    }
    return '${AppConstants.codToDigitalCallbackUrl}?status=';
  }

  void _proceed() async {
    final PaymentBody gateway = _gateways[_selectedIndex];
    final int? orderId = widget.order.id;
    final String? paymentMethod = gateway.getWay;
    if(orderId == null || paymentMethod == null || paymentMethod.isEmpty) {
      showCustomSnackBar('payment_can_not_be_processed'.tr);
      return;
    }
    setState(() => _isLoading = true);

    final PayDigitallyResponseModel response = await Get.find<OrderController>().payDigitally(
      orderId: orderId, paymentMethod: paymentMethod, callback: _callback,
    );

    if(!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if(!response.isSuccess) {
      showCustomSnackBar(response.message ?? 'payment_can_not_be_processed'.tr);
      return;
    }

    final String paymentUrl = response.data!.paymentUrl!;
    Get.back();

    if(GetPlatform.isWeb) {
      html.window.open(paymentUrl, '_self');
    } else {
      Get.toNamed(RouteHelper.getPaymentRoute(
        widget.order, gateway.getWay, codToDigitalUrl: paymentUrl,
        guestId: Get.find<AuthController>().getGuestId(), contactNumber: widget.contactNumber,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: 550,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(Dimensions.radiusLarge),
            bottom: Radius.circular(isDesktop ? Dimensions.radiusLarge : 0),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingDefault, Dimensions.paddingSmall, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('complete_payment_by_digitally'.tr, style: context.heading.extraLarge.semiBold),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  Text(
                    'pay_online_using_your_preferred_payment_method'.tr,
                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ]),
              ),

              CustomInkWellWidget(
                onTap: () => Get.back(),
                radius: Dimensions.radiusLarge,
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingExtraSmall),
                  decoration: BoxDecoration(
                    color: context.surface,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.clear, size: 20, color: context.iconBaseMedium)),
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  const SizedBox(height: Dimensions.paddingLarge),
                  Text('choose_payment_method'.tr, style: context.heading.large),
                  const SizedBox(height: Dimensions.paddingMedium),

                  for(int index = 0; index < _gateways.length; index++) ...[
                    _GatewayTile(
                      title: _gateways[index].getWayTitle ?? '',
                      image: _gateways[index].getWayImageFullUrl,
                      isSelected: _selectedIndex == index,
                      onTap: _isLoading ? null : () => setState(() => _selectedIndex = index),
                    ),
                    if(index != _gateways.length - 1) const Divider(height: 1, thickness: 1,),
                  ],
                ]),
              ),
            ),
          ),

          SizedBox(height: Dimensions.paddingExtraLarge,),

          Divider(height: 1,),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingDefault, Dimensions.paddingLarge, Dimensions.paddingLarge),
              child: Column(children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text('total'.tr, style: context.heading.large),

                  Text(PriceConverter.convertPrice(widget.totalPrice), style: context.heading.large),
                ]),
                const SizedBox(height: Dimensions.paddingSmall),

                CustomButtonWidget(
                  buttonText: 'proceed'.tr,
                  isLoading: _isLoading,
                  disabledMessage: _isLoading ? null : 'select_payment_method'.tr,
                  onPressed: (_selectedIndex == -1 || _isLoading) ? null : _proceed,
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  final String title;
  final String? image;
  final bool isSelected;
  final VoidCallback? onTap;

  const _GatewayTile({required this.title, required this.image, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
        child: Row(children: [

          if(image != null && image!.isNotEmpty) ...[
            CustomImageWidget(image: image!, height: 20, width: 60, fit: BoxFit.contain),
            const SizedBox(width: Dimensions.paddingMedium),
          ],

          Expanded(child: Text(title, style: context.subHeading.defaultSize.medium)),

          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: isSelected ? context.primary : context.iconDisabledDefault,
          ),
        ]),
      ));
  }
}
