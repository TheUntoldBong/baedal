part of '../screens/order_details_screen.dart';

class _OrderDetailsStatus extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool floating;
  final double total;
  final bool arrivalState;

  const _OrderDetailsStatus({required this.order, required this.ongoing, this.floating = false, this.total = 0, this.arrivalState = false});

  @override
  Widget build(BuildContext context) => OrderStatusCard(
        order: order,
        ongoing: ongoing,
        floating: floating,
        total: total,
        arrivalState: arrivalState,
      );
}
