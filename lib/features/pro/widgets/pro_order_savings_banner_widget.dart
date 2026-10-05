import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProOrderSavingsBannerWidget extends StatelessWidget {
  final OrderModel order;
  const ProOrderSavingsBannerWidget({super.key, required this.order});

  static bool showProBanner(OrderModel order){
    final double saved = ProHelper.getOrderSavedAmount(order);
    return saved > 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!showProBanner(order)) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: const Color(0xFF3979E0),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        const Text('\u{1F451}', style: TextStyle(fontSize: 14)),
        const SizedBox(width: Dimensions.paddingSmall),
        Expanded(
          child: Text(
            '${'you_saved'.tr} ${PriceConverter.convertPrice(ProHelper.getOrderSavedAmount(order))} ${'with_pro'.tr}',
            style: context.subHeading.small.medium.overrideWith(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
