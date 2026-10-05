import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_payment_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class ProSubscriptionActionsWidget extends StatelessWidget {
  final List<PlanItem>? plans;
  final VoidCallback? onRenew;
  const ProSubscriptionActionsWidget({super.key, this.plans, this.onRenew});

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Color(0xffA16BFF);
    final bool hasPlans = plans != null && plans!.isNotEmpty;

    return GetBuilder<ProController>(builder: (proController) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: proController.isCancelLoading ? null : () => _onCancelPressed(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                backgroundColor: context.bgNeutralLight,
                elevation: 0,
              ),
              child: proController.isCancelLoading
                  ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.textBaseMedium))
                  : Text('cancel_subscription'.tr, style: context.heading.small.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),
          Expanded(
            child: ElevatedButton(
              onPressed: hasPlans ? () => _onRenewPressed(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                backgroundColor: hasPlans ? buttonColor : context.bgNeutralLight,
                elevation: 0,
              ),
              child: Text(
                'renew_subscription'.tr,
                style: context.heading.small.strong.overrideWith(
                  color: hasPlans ? context.surfaceContainer : context.textBaseMedium,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _onCancelPressed(BuildContext context) {
    showCustomDialog(
      child: ConfirmationDialogWidget(
      icon: Images.warning,
      title: 'cancel_subscription'.tr,
      description: 'are_you_sure_to_cancel_subscription'.tr,
      onYesPressed: () {
        Get.back();
        Get.find<ProController>().cancelSubscription();
      },
    ),
      isDismissible: false,
    );
  }

  void _onRenewPressed(BuildContext context) {
    if (onRenew != null) {

      onRenew!();
    } else {
      final int? planId = Get.find<ProController>().activeOfferModel?.benefit?.planId;
      final PlanItem? plan = Get.find<ProController>().planModel?.plans?.firstWhereOrNull((p) => p.id == planId && p.status == true);
      if (plan == null) {
        showCustomSnackBar('no_data_found'.tr);
        return;
      }
      _onSubscribePressed(context, plan, true);
    }
  }

  void _onSubscribePressed(BuildContext context, PlanItem plan, bool isRenew) {
    if ((plan.price ?? 0) <= 0) {
      Get.find<ProController>().subscribePlan(plan, 'free_trial', 'free_trial', isRenew);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew,),
    );
  }
}
