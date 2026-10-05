import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/section_divider_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_last_order_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

const int _homeLastOrderLimit = 10;

class HomeLastOrderSectionWidget extends StatelessWidget {
  const HomeLastOrderSectionWidget({super.key});

  double _cardWidth(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return 280;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double available = screenWidth - Dimensions.paddingDefault - (2 * Dimensions.paddingDefault);
    return available / 2.1;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final orders = orderController.homeLastOrders;
      if (orders == null || orders.isEmpty) {
        return const SizedBox.shrink();
      }
      final int shownCount = orders.length > _homeLastOrderLimit ? _homeLastOrderLimit : orders.length;
      final bool hasMore = (orderController.homeLastOrdersPageSize ?? 0) > shownCount;
      final double cardWidth = _cardWidth(context);
      final double rowHeight = HomeLastOrderCardWidget.preferredHeight();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const SectionDividerHeaderWidget(title: 'order_again'),
        const SizedBox(height: Dimensions.padding2xSmall),

        SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shownCount + (hasMore ? 1 : 0),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            itemBuilder: (context, index) {
              if (index == shownCount) {
                return Center(child: SectionViewAllTile(
                  onTap: () => Get.toNamed(RouteHelper.getAllLastOrdersRoute()),
                ));
              }
              return Center(
                child: HomeLastOrderCardWidget(order: orders[index], width: cardWidth),
              );
            },
          ),
        ),
      ]);
    });
  }
}

