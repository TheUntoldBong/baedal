import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_plan_model.dart';
import 'package:stackfood_multivendor/features/pro/widgets/pro_payment_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ProPlanSelectorWidget extends StatefulWidget {
  final List<PlanItem> plans;
  final int? currentPlanId;
  final bool isRenewal;
  final VoidCallback? onCancel;
  const ProPlanSelectorWidget({super.key, required this.plans, this.currentPlanId, this.isRenewal = false, this.onCancel});

  @override
  State<ProPlanSelectorWidget> createState() => _ProPlanSelectorWidgetState();
}

class _ProPlanSelectorWidgetState extends State<ProPlanSelectorWidget> {
  int _selectedPlanIndex = 0;
  late ScrollController _durationScrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _durationScrollController = ScrollController();
    _durationScrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _durationScrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    setState(() {
      _canScrollLeft = _durationScrollController.offset > 0;
      _canScrollRight = _durationScrollController.offset < _durationScrollController.position.maxScrollExtent;
    });
  }

  void _scrollDuration(bool isLeft) {
    final scrollAmount = 100.0;
    final newOffset = isLeft
        ? (_durationScrollController.offset - scrollAmount).clamp(0.0, _durationScrollController.position.maxScrollExtent)
        : (_durationScrollController.offset + scrollAmount).clamp(0.0, _durationScrollController.position.maxScrollExtent);
    _durationScrollController.animateTo(newOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Color(0xffA16BFF);
    final int selectedPlanIndex = _getSelectedPlanIndex(widget.plans);
    final PlanItem? selectedPlan = widget.plans.isNotEmpty ? widget.plans[selectedPlanIndex] : null;
    final List<MapEntry<int, PlanItem>> selectedDurationPlans = selectedPlan != null ? ProHelper.getSelectedDurationPlans(widget.plans, selectedPlan) : [];
    final List<MapEntry<int, PlanItem>> durationPlans = ProHelper.getUniqueDurationPlans(widget.plans);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (durationPlans.isNotEmpty) ...[
          _buildDurationSelector(context, durationPlans, widget.plans, buttonColor),
          const SizedBox(height: Dimensions.paddingLarge),
        ],

        if (selectedDurationPlans.length > 1) ...[
          _buildPlanList(context, selectedDurationPlans, ),
          const SizedBox(height: Dimensions.paddingLarge),
        ],

        _buildPriceRow(context, selectedPlan, buttonColor),
        const SizedBox(height: Dimensions.paddingExtraLarge),

        Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(widget.onCancel != null) Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
              child: CustomButtonWidget(
                height: 45, width: 100,
                color: context.bgNeutralMedium,
                onPressed: widget.onCancel,
                radius: Dimensions.radiusExtraSmall,
                buttonText: 'back'.tr,
                fontSize: Dimensions.fontSizeSmall,
                textColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            _buildSubscribeButton(context, selectedPlan, buttonColor, widget.onCancel),
          ],
        )),
      ],
    );
  }

  Widget _buildDurationSelector(BuildContext context, List<MapEntry<int, PlanItem>> durationPlans, List<PlanItem> plans , Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_duration'.tr, style: context.subHeading.defaultSize.medium),
        const SizedBox(height: Dimensions.paddingSmall),
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.padding2xSmall),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: context.surfaceContainer,
              ),
              child: SingleChildScrollView(
                controller: _durationScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(durationPlans.length, (index) {
                    final MapEntry<int, PlanItem> durationPlan = durationPlans[index];
                    final bool isSelected = ProHelper.getDurationKey(plans[_selectedPlanIndex]) == ProHelper.getDurationKey(durationPlan.value);
                    return Padding(
                      padding: EdgeInsets.only(right: index < durationPlans.length - 1 ? Dimensions.padding2xSmall : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlanIndex = durationPlan.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: isSelected ? context.surfaceContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              if(isSelected) BoxShadow(
                                color: context.shadow,
                                offset: Offset(0, 2)
                              )
                            ],
                          ),
                          child: Text(
                            ProHelper.getDurationKey(durationPlan.value),
                            textAlign: TextAlign.center,
                            style: context.subHeading.small.strong.overrideWith(
                              color: isSelected ? color : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            if(_canScrollLeft) Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _scrollDuration(true),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                    child: Icon(Icons.chevron_left, size: 18, color: color),
                  ),
                ),
              ),
            ),
            if(_canScrollRight) Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _scrollDuration(false),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                    child: Icon(Icons.chevron_right, size: 18, color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanList(BuildContext context, List<MapEntry<int, PlanItem>> plans,) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSmall),
      itemBuilder: (context, index) {
        final MapEntry<int, PlanItem> entryItem = plans[index];
        final bool isSelected = _selectedPlanIndex == entryItem.key;
        return InkWell(
          onTap: () => setState(() => _selectedPlanIndex = entryItem.key),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: isSelected ? context.primary.withAlpha(200) : context.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(child: Text(entryItem.value.planName ?? '', style: context.subHeading.defaultSize.medium)),
                const SizedBox(width: Dimensions.paddingSmall),
                Text(
                  PriceConverter.convertPrice(entryItem.value.price ?? 0),
                  style: context.heading.defaultSize.strong,
                ),
                Text(
                  ' / ${entryItem.value.durationLabel ?? ''}',
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(BuildContext context, PlanItem? plan, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(plan?.planName ?? '', style: context.subHeading.defaultSize.medium),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: PriceConverter.convertPrice(plan?.price),
                  style: context.heading.large.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                TextSpan(
                  text: ' / ${plan?.durationLabel ?? ''}',
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context, PlanItem? plan, Color? buttonColor, VoidCallback? onCancel) {
    bool isRenew = widget.isRenewal && plan?.id == widget.currentPlanId;
    String buttonText = 'subscribe_now'.tr;
    if (plan?.planType == ProPlanType.freeTrial) {
      buttonText = 'start_free_trial'.tr;
    } else if (isRenew) {
      buttonText = 'renew_subscription'.tr;
    } else if (widget.isRenewal) {
      buttonText = 'shift_plan'.tr;
    }

    return GetBuilder<ProController>(builder: (proController,) {
      return ElevatedButton(
        onPressed: proController.isSubscribeLoading || plan == null ? null : (){
          onCancel?.call();
          _onSubscribePressed(context, plan, isRenew);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
          elevation: 0,
        ),
        child: proController.isSubscribeLoading ? SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(color: context.surfaceContainer, strokeWidth: 2),
        ) : Text(buttonText, style: context.heading.defaultSize.strong.overrideWith(color: Colors.white)),
      );
    });
  }

  void _onSubscribePressed(BuildContext context, PlanItem plan, bool isRenew) {
    if ((plan.price ?? 0) <= 0) {
      Get.find<ProController>().subscribePlan(plan, 'free_trial', 'free_trial', isRenew);
      return;
    }
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew)));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProPaymentBottomSheetWidget(plan: plan, isRenew: isRenew),
      );
    }
  }

  int _getSelectedPlanIndex(List<PlanItem> plans) {
    if (_selectedPlanIndex < plans.length) return _selectedPlanIndex;
    _selectedPlanIndex = 0;
    return _selectedPlanIndex;
  }

}
