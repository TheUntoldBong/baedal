import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class OrderProductWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final int? itemLength;
  final int? index;
  const OrderProductWidget({super.key, required this.order, required this.orderDetails, this.itemLength, this.index});

  @override
  Widget build(BuildContext context) {
    if(orderDetails.isBogoBundle) {
      return _BogoBundleOrderRow(orderDetails: orderDetails);
    }

    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if(orderDetails.variation!.isNotEmpty) {
      for(Variation variation in orderDetails.variation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for(VariationValue value in variation.variationValues!) {
          variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '${variationText!})';
      }
    }else if(orderDetails.oldVariation!.isNotEmpty) {
      List<String> variationTypes = orderDetails.oldVariation![0].type!.split('-');
      if(variationTypes.length == orderDetails.foodDetails!.choiceOptions!.length) {
        int index = 0;
        for (var choice in orderDetails.foodDetails!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = orderDetails.oldVariation![0].type;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          orderDetails.foodDetails!.imageFullUrl != null && orderDetails.foodDetails!.imageFullUrl!.isNotEmpty ? Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              child: CustomImageWidget(
                height: 70, width: 70, fit: BoxFit.cover,
                image: '${orderDetails.foodDetails!.imageFullUrl}',
                isFood: true,
              ),
            ),
          ) : const SizedBox.shrink(),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        orderDetails.foodDetails?.name ?? '',
                        style: context.subHeading.small.medium,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Dimensions.padding2xSmall),

                    Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomAssetImageWidget(
                      orderDetails.foodDetails!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 11, width: 11,
                    ) : SizedBox(),

                  ]),
                ),
                const SizedBox(width: Dimensions.paddingDefault),

                Text('${'quantity'.tr}: ', style: context.body.small.regular),
                Text(
                  orderDetails.quantity.toString(),
                  style: context.subHeading.small.medium.overrideWith(color: context.primary),
                ),
              ]),
              const SizedBox(height: Dimensions.padding2xSmall),
              Row(children: [

                Expanded(child: Text(
                  PriceConverter.convertPrice(orderDetails.price),
                  style: context.heading.defaultSize.medium, textDirection: TextDirection.ltr,
                )),

                SizedBox(width: orderDetails.foodDetails!.isRestaurantHalalActive! && orderDetails.foodDetails!.isHalalFood! ? Dimensions.padding2xSmall : 0),

                orderDetails.foodDetails!.isRestaurantHalalActive! && orderDetails.foodDetails!.isHalalFood! ? const CustomAssetImageWidget(
                 Images.halal, height: 13, width: 13) : const SizedBox(),

              ]),

              addOnText.isNotEmpty ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'addons'.tr}: ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                  Flexible(child: Text(
                      addOnText,
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      )),
                ]),
              ) : const SizedBox(),

              variationText != '' ? (orderDetails.foodDetails!.variations != null && orderDetails.foodDetails!.variations!.isNotEmpty) ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'variations'.tr}: ', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                  Flexible(child: Text(
                      variationText!,
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      )),
                ]),
              ) : const SizedBox() : const SizedBox(),

            ]),
          ),
        ]),

      ]),
    );
  }
}

class _BogoBundleOrderRow extends StatelessWidget {
  final OrderDetailsModel orderDetails;
  const _BogoBundleOrderRow({required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    final OrderBogoDetailsModel bogo = orderDetails.bogoDetails!;
    final String? thumbnail = bogo.buyItems?.firstWhereOrNull((item) => (item.imageFullUrl ?? '').isNotEmpty)?.imageFullUrl;

    return Container(
      decoration: BoxDecoration(color: context.surfaceContainer),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingLarge),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            child: (thumbnail != null && thumbnail.isNotEmpty)
              ? CustomImageWidget(height: 70, width: 70, fit: BoxFit.cover, image: thumbnail, isFood: true)
              : Container(
                  height: 70, width: 70, color: context.surfaceContainerLowest,
                  child: Center(child: CustomAssetImageWidget(Images.bogoOfferIcon, height: 28, width: 28)),
                ),
          ),
        ),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(child: Text(
                bogo.offerTitle ?? 'bogo_offer'.tr,
                style: context.subHeading.small.medium,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(width: Dimensions.paddingDefault),

              Text('${'quantity'.tr}: ', style: context.body.small.regular),
              Text(
                orderDetails.quantity.toString(),
                style: context.subHeading.small.medium.overrideWith(color: context.primary),
              ),
            ]),
            const SizedBox(height: Dimensions.padding2xSmall),

            Text(
              PriceConverter.convertPrice(orderDetails.price),
              style: context.heading.defaultSize.medium, textDirection: TextDirection.ltr,
            ),
          ]),
        ),
      ]),
    );
  }
}
