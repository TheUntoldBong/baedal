import 'package:full_screen_bottom_sheet/full_screen_bottom_sheet.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_last_order_card_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PreviousOrdersBottomSheetWidget extends StatefulWidget {
  final int restaurantId;
  const PreviousOrdersBottomSheetWidget({super.key, required this.restaurantId});

  static Future<void> show(BuildContext context, {required int restaurantId}) {
    return FullScreenBottomSheet.show(context, builder: (_) => PreviousOrdersBottomSheetWidget(restaurantId: restaurantId));
  }

  @override
  State<PreviousOrdersBottomSheetWidget> createState() => _PreviousOrdersBottomSheetWidgetState();
}

class _PreviousOrdersBottomSheetWidgetState extends State<PreviousOrdersBottomSheetWidget> {
  static const int _limit = 10;
  static const double _dragHandleHeight = Dimensions.paddingLarge;

  ScrollController? _scrollController;

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _attachScrollController(ScrollController controller) {
    if (identical(_scrollController, controller)) return;
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller..addListener(_onScroll);
  }

  void _onScroll() {
    final ScrollController? controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  void _loadMoreIfNotScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !(_scrollController?.hasClients ?? false)) return;
      if (_scrollController!.position.maxScrollExtent <= 0) _loadMore();
    });
  }

  void _loadMore() {
    final OrderController controller = Get.find<OrderController>();
    final int total = controller.restaurantLastOrdersPageSize ?? 0;
    final int loaded = controller.restaurantLastOrders?.length ?? 0;
    if (controller.restaurantLastOrdersPaginating || loaded >= total) return;

    if (controller.restaurantLastOrdersOffset >= (total / _limit).ceil()) return;

    controller.showLastOrderLoader(isHome: false);
    controller.getRestaurantLastOrders(widget.restaurantId, offset: controller.restaurantLastOrdersOffset, limit: _limit);
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenBottomSheet(
      snap: true,
      snapSizes: [0.5, 0.8],
      backgroundColor: context.surfaceContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      headerExtent: (metrics) => FullScreenBottomSheetBar.heightOf(metrics, dragHandleHeight: _dragHandleHeight),
      headerBuilder: (context, metrics) => FullScreenBottomSheetBar(
        metrics: metrics,
        dragHandleHeight: _dragHandleHeight,
        backgroundColor: context.surfaceContainer,
        border: Border(bottom: BorderSide(color: context.outline)),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        title: Text('previous_orders'.tr, style: context.heading.extraLarge.overrideWith(color: context.onSurface)),
        dragHandle: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: context.bgNeutralLight, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
        ),
        sheetTrailing: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 32, height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.surface),
            child: Icon(Icons.close, size: 18, color: context.iconBaseDefault),
          ),
        ),
        pageBar: CustomAppBarWidget(title: 'previous_orders'.tr, onBackPressed: () => Get.back()),
      ),
      slivers: (context, scrollController) {
        _attachScrollController(scrollController);
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingSmall),
              child: Text('quickly_reorder_from_your_previous_purchases'.tr, textAlign: TextAlign.center,
                style: context.body.small.overrideWith(color: context.textBaseMedium)),
            ),
          ),

          SliverToBoxAdapter(
            child: GetBuilder<OrderController>(builder: (orderController) {
              final List<LatestOrderModel> orders = orderController.restaurantLastOrders ?? [];
              final bool hasMore = (orderController.restaurantLastOrdersPageSize ?? 0) > orders.length;
              if (hasMore) _loadMoreIfNotScrollable();

              return Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, 0, Dimensions.paddingLarge, Dimensions.paddingLarge),
                child: Column(mainAxisSize: MainAxisSize.min, children: [

                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: Dimensions.paddingSmall,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => HomeLastOrderCardWidget(order: orders[index]),
                  ),

                  if (orderController.restaurantLastOrdersPaginating) Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: context.primary),
                    ),
                  ),

                ]),
              );
            }),
          ),
        ];
      },
    );
  }
}

