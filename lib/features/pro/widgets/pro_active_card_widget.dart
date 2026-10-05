import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_subscription_actions_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProActiveCardWidget extends StatelessWidget {
  final ProActiveOfferModel? activeOfferModel;
  final VoidCallback? onRenew;
  const ProActiveCardWidget({super.key, required this.activeOfferModel, this.onRenew});

  @override
  Widget build(BuildContext context, ) {
    final ProActivePlanDetails? details = activeOfferModel?.planDetails;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('my_subscription'.tr, style: context.heading.large.medium),
        const SizedBox(height: Dimensions.paddingDefault),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: context.outline),
          ),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingLarge),
              decoration: BoxDecoration(
                color: const Color(0xFFE1D3FF),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                gradient: LinearGradient(colors: [
                  Color(0xFFEEDAFF),
                  Color(0xFFD9D4FF),
                ]),
                boxShadow: [BoxShadow(color: const Color(0xFFB794F6).withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      details?.planName ?? 'monthly_package'.tr,
                      style: context.heading.large.medium.overrideWith(color: Colors.black),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: 6),
                    decoration: BoxDecoration(color: context.surfaceContainer, borderRadius: BorderRadius.circular(20)),
                    child: Text('active'.tr, style: context.subHeading.small.strong.overrideWith(color: Colors.green)),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingLarge),
                Row(children: [
                  Expanded(child: _buildStatCard(context, 'total_saved'.tr, PriceConverter.convertPrice(details?.totalSaved ?? 0))),
                  const SizedBox(width: Dimensions.paddingDefault),
                  Expanded(child: _buildStatCard(context, 'orders_placed'.tr, '${details?.totalOrders ?? 0}')),
                ]),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingDefault),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingDefault),
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: context.outline),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('plan_details'.tr, style: context.subHeading.defaultSize.strong),
                const SizedBox(height: Dimensions.paddingDefault),
                _buildDetailRow(context, Icons.calendar_today_outlined, 'active_since'.tr, _formatDate(details?.startAt)),
                _buildDetailRow(context, Icons.calendar_today_outlined, 'expires_on'.tr, _formatDate(details?.endAt)),
                _buildDetailRow(context, Icons.credit_card_outlined, 'days_remaining'.tr, '${details?.daysRemaining ?? 0} ${'days'.tr.toLowerCase()}'),
                _buildDetailRow(context, Icons.account_balance_wallet_outlined, 'paid_by'.tr, _formatPaidBy(details?.paidBy), showDivider: false),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingLarge),
            _buildBenefitsSection(context),

            const SizedBox(height: Dimensions.paddingExtraLarge),
            GetBuilder<ProController>(builder: (proController) {
              final List<PlanItem>? plans = proController.planModel?.plans;
              return ProSubscriptionActionsWidget(plans: plans, onRenew: onRenew);
            }),
          ]),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150))),
        const SizedBox(height: Dimensions.padding2xSmall),
        Text(value, style: context.heading.large.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ]),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value, {bool showDivider = true}) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: context.textBaseMedium, size: 22),
        const SizedBox(width: Dimensions.paddingDefault),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
          const SizedBox(height: Dimensions.padding2xSmall),
          Text(value, style: context.subHeading.defaultSize.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
        ])),
      ]),
      if (showDivider) Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
        child: Divider(color: context.outlineVariant, height: 1),
      ),
    ]);
  }

  Widget _buildBenefitsSection(BuildContext context,) {
    final List<Map<String, String>> items = ProHelper.getActiveBenefitItems();
    if (items.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: context.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('package_benefits'.tr, style: context.subHeading.defaultSize.strong),
          const SizedBox(height: Dimensions.paddingDefault),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                ),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: context.subHeading.defaultSize.medium),
                      if (item['subtitle']!.isNotEmpty)
                        Text(item['subtitle']!, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    return DateConverter.stringToReadableString(date);
  }

  String _formatPaidBy(String? paidBy) {
    if (paidBy == null || paidBy.isEmpty) return '';
    return paidBy.replaceAll('_', ' ').capitalizeFirst ?? paidBy;
  }
}
