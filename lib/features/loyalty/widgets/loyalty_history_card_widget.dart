import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/wallet/domain/models/wallet_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class LoyaltyHistoryCardWidget extends StatelessWidget {
  final int index;
  final List<Transaction>? data;
  const LoyaltyHistoryCardWidget({super.key, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isDebit = data![index].transactionType == 'point_to_wallet';
    double amount = isDebit ? (data![index].debit ?? 0) : (data![index].credit ?? 0);
    Color amountColor = isDebit ? Colors.red : Colors.green;

    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${isDebit ? '-' : '+'} ${amount.toStringAsFixed(2)} ${'point'.tr}',
                style: context.subHeading.large.strong.overrideWith(color: amountColor),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSmall),

              Text(
                data![index].transactionType == 'add_fund' ? '${'added_via'.tr} ${data![index].reference!.replaceAll('_', ' ')} ${data![index].adminBonus != 0 ? '(${'bonus'.tr} = ${data![index].adminBonus})' : '' }'
                    : data![index].transactionType == 'partial_payment' ? '${'spend_on_order'.tr} # ${data![index].reference}'
                    : data![index].transactionType == 'loyalty_point' ? 'converted_from_loyalty_point'.tr
                    : data![index].transactionType == 'referrer' ? 'earned_by_referral'.tr
                    : data![index].transactionType == 'order_place' ? 'earned_from_booking'.tr
                    : data![index].transactionType == 'point_to_wallet' ? 'convert_to_wallet_money'.tr
                    : data![index].transactionType!.tr,
                style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          Text(
            DateConverter.onlyDate(data![index].createdAt!),
            style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ]),

      index == data!.length-1 ? const SizedBox() : Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSmall, bottom: Dimensions.paddingMedium),
        child: Divider(),
      ),

    ]);
  }
}
