part of '../screens/order_details_screen.dart';

class _OrderDetailsInfo extends StatefulWidget {
  final OrderModel order;
  final double total;
  final List<OrderDetailsModel> orderDetails;
  final BillingValues billing;
  final bool? isDragable;
  final Key? deliveryManKey;

  const _OrderDetailsInfo({
    required this.order,
    required this.total,
    required this.orderDetails,
    required this.billing,
    this.isDragable = false,
    this.deliveryManKey,
  });

  @override
  State<_OrderDetailsInfo> createState() => _OrderDetailsInfoState();
}

class _OrderDetailsInfoState extends State<_OrderDetailsInfo> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final hasItems = widget.orderDetails.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(vertical: widget.isDragable! ? Dimensions.paddingSmall : Dimensions.paddingLarge),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        if (order.deliveryMan != null) ...[
          Padding(key: widget.deliveryManKey, padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
            child: Column(children: [
              DeliveryManSection(order: order),
              const SizedBox(height: Dimensions.paddingDefault),
            ]),
          ),
        ],

        ...[
          Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
            child: Column(children: [
              RestaurantUserAddressBlock(order: order),
              const SizedBox(height: Dimensions.radiusLarge),
            ]),
          ),
        ],


         ...[
          Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
            child: Column(children: [
              _MoreDetails(
                order: order,
                expanded: _showMore,
                onToggle: () => setState(() => _showMore = !_showMore),
              ),
            ]),
          ),
        ],

        if (hasItems) ...[
          Divider(height: 40, thickness: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              if (order.subscription != null) ...[
                RepeatOrderCard(
                  subscription: order.subscription!,
                  schedules: Get.find<OrderController>().schedules ?? const [],
                ),
                const SizedBox(height: Dimensions.paddingDefault),
              ],

              ItemInfoSection(order: order, orderDetails: widget.orderDetails),

            ]),
          ),
        ],

        if((order.payments != null && order.payments!.isNotEmpty) || (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)) ...[
          Divider(height: 40, thickness: 2),
          if(order.payments != null && order.payments!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
              child: PaymentMethodSection(payments: order.payments!, order: order, total: widget.total),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
              child: PaymentMethodSection(
                payments: [Payments(paymentMethod: order.paymentMethod, amount: order.orderAmount)],
                order: order, total: widget.total,
              ),
            ),
        ],

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,),
          child: Column(
            children: [
              Divider(height: 40, thickness: 1),
              BillingSummarySection(order: order, billing: widget.billing),
            ],
          ),
        )

      ]),
    );
  }
}

class _MoreDetails extends StatelessWidget {
  final OrderModel order;
  final bool expanded;
  final VoidCallback onToggle;

  const _MoreDetails({
    required this.order,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool showNotes = OrderNotesPanel.hasContent(order);

    if (!showNotes) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnimatedCrossFade(
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
          child: OrderNotesPanel(order: order),
        ),
        crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 250),
      ),

      Center(
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.padding2xSmall),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                expanded ? 'see_less'.tr : 'see_more'.tr,
                style: context.heading.defaultSize.strong.overrideWith(color: context.theme.colorScheme.tertiary),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(Icons.keyboard_arrow_down, size: 20, color: context.theme.colorScheme.tertiary),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _BottomView extends StatelessWidget {
  final OrderController orderController;
  final OrderModel order;
  final double total;
  final int? orderId;
  final String? contactNumber;
  final bool showTrackButton;

  const _BottomView({
    required this.orderController,
    required this.order,
    required this.total,
    required this.orderId,
    required this.contactNumber,
    this.showTrackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return BottomViewWidget(
      orderController: orderController,
      order: order,
      orderId: orderId,
      total: total,
      contactNumber: contactNumber,
      showTrackButton: showTrackButton,
    );
  }
}
