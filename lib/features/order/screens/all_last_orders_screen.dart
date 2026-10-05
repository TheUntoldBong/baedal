import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_last_order_card_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AllLastOrdersScreen extends StatefulWidget {
  const AllLastOrdersScreen({super.key});

  @override
  State<AllLastOrdersScreen> createState() => _AllLastOrdersScreenState();
}

class _AllLastOrdersScreenState extends State<AllLastOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() {
    final controller = Get.find<OrderController>();
    final total = controller.homeLastOrdersPageSize ?? 0;
    final loaded = controller.homeLastOrders?.length ?? 0;
    if (!controller.homeLastOrdersPaginating && loaded < total) {
      controller.showLastOrderLoader(isHome: true);
      controller.getHomeLastOrders(offset: controller.homeLastOrdersOffset);
    }
  }

  void _loadMoreIfNotScrollable(bool hasMore) {
    if (!hasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        _loadMoreIfNeeded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      appBar: CustomAppBarWidget(title: 'order_again'.tr),
      body: SafeArea(
        child: GetBuilder<OrderController>(builder: (orderController) {
          final orders = orderController.homeLastOrders;
          if (orders == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orders.isEmpty) {
            return Center(child: Text('no_order_found'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)));
          }
          final bool hasMore = (orderController.homeLastOrdersPageSize ?? 0) > orders.length;
          _loadMoreIfNotScrollable(hasMore);

          final int crossAxisCount = ResponsiveHelper.isDesktop(context) ? 3 : 2;
          final double cellHeight = HomeLastOrderCardWidget.preferredHeight();

          return RefreshIndicator(
            onRefresh: () => orderController.getHomeLastOrders(),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingDefault,
                        vertical: Dimensions.paddingSmall,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: Dimensions.paddingMedium,
                          mainAxisSpacing: Dimensions.paddingLarge,
                          mainAxisExtent: cellHeight,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => HomeLastOrderCardWidget(
                            order: orders[index], width: double.infinity,
                          ),
                          childCount: orders.length,
                        ),
                      ),
                    ),

                    if (hasMore) SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingDefault),
                        child: Center(
                          child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: context.primary),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
