import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CashBackDialogWidget extends StatelessWidget {
  const CashBackDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {
      return homeController.cashBackOfferList != null ? Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: 50),
        alignment: Get.find<LocalizationController>().isLtr ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [


          homeController.cashBackOfferList!.isNotEmpty ? Container(
            constraints: BoxConstraints(maxHeight: context.height*0.5, minHeight: 30),
            width: context.width * 0.8,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                constraints: BoxConstraints(maxHeight: context.height*0.5, minHeight: 30),
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                child: ListView.builder(
                  itemCount: homeController.cashBackOfferList!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final CashBackModel cashBack = homeController.cashBackOfferList![index];

                    final bool isPercentage = cashBack.cashbackType != 'amount';
                    final String cashBackValue = isPercentage
                        ? '${(cashBack.cashbackAmount ?? 0).toStringAsFixed(0)}%'
                        : PriceConverter.convertPrice(cashBack.cashbackAmount);

                    final String maxDiscount = (isPercentage && (cashBack.maxDiscount ?? 0) > 0)
                        ? ' ${'and_max_discount_is'.tr} ${PriceConverter.convertPrice(cashBack.maxDiscount)}'
                        : '';

                    return Container(
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      ),
                      padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: context.bgNeutralLight,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSmall),
                          child: Text('$cashBackValue ${cashBack.title}', style: context.heading.defaultSize),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                          child: Text(
                            '${'min_spent'.tr} ${PriceConverter.convertPrice(cashBack.minPurchase)}$maxDiscount '
                                '| ${'valid_till'.tr} ${DateConverter.stringToReadableString(cashBack.endDate!)}',
                            style: context.body.small,
                          ),
                        ),

                      ]),
                    );
                  },
                ),
              ),
            ]),
          ) : Container(
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ),
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            child: Text('no_offer_available'.tr, style: context.body.defaultSize),
          ),

          Container(
            height: 70, width: 64,
            margin: EdgeInsets.only(bottom: 20, right: 0),
            child: InkWell(onTap: () => Get.back(), child: const CashBackLogoWidget()),
          ),

        ]),
      ) : const SizedBox();
    });
  }
}
