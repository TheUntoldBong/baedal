import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/domain/models/rate_review_model.dart';
import 'package:stackfood_multivendor/features/review/widgets/deliver_man_review_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/product_review_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final RateReviewModel rateReviewModel;
  const RateReviewScreen({super.key, required this.rateReviewModel});

  @override
  RateReviewScreenState createState() => RateReviewScreenState();
}

class RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final ValueNotifier<int> _currentTab = ValueNotifier<int>(0);

  bool get _hasDeliveryMan => widget.rateReviewModel.deliveryMan != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _hasDeliveryMan ? 2 : 1, initialIndex: 0, vsync: this);
    _tabController!.addListener(() => _currentTab.value = _tabController!.index);
    Get.find<ReviewController>().initRatingData(widget.rateReviewModel.orderDetailsList!);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _currentTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      widget.rateReviewModel.orderDetailsList!.length > 1 ? 'items'.tr : 'item'.tr,
      if(_hasDeliveryMan) 'delivery_man'.tr,
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.surface,
      appBar: CustomAppBarWidget(title: 'rate_review'.tr),
      body: SafeArea(child: Column(children: [

        ValueListenableBuilder<int>(
          valueListenable: _currentTab,
          builder: (context, selected, _) => _RateReviewTabBar(
            labels: labels,
            selected: selected,
            onSelected: (index) => _tabController?.animateTo(index),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: [
            ProductReviewWidget(orderDetailsList: widget.rateReviewModel.orderDetailsList!),
            if(_hasDeliveryMan) DeliveryManReviewWidget(
              deliveryMan: widget.rateReviewModel.deliveryMan,
              orderID: widget.rateReviewModel.orderDetailsList![0].orderId.toString(),
            ),
          ],
        )),

      ])),
    );
  }
}

class _RateReviewTabBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const _RateReviewTabBar({required this.labels, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Dimensions.webMaxWidth,
        color: context.surfaceContainer,
        child: Column(children: [

          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Row(children: List<Widget>.generate(labels.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSmall),
                  child: _RateReviewTabChip(
                    label: labels[index],
                    isSelected: index == selected,
                    onTap: () => onSelected(index),
                  ),
                );
              })),
            ),
          ),

          const Divider(height: 1),
        ]),
      ),
    );
  }
}

class _RateReviewTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 250);

  const _RateReviewTabChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingDefault,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedDefaultTextStyle(
          duration: _duration,
          curve: Curves.easeOut,
          style: context.subHeading.small.strong.overrideWith(color: isSelected ? context.onPrimary : context.onSurface),
          child: Text(label),
        ),
      ),
    );
  }
}
