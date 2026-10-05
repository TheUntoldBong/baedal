import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/features/order/widgets/guest_track_order_input_view_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/color_coverter.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  static const int _pageLimit = 10;

  MyOrderTabType _selectedTab = MyOrderTabType.running;
  bool _isLoggedIn = AuthHelper.isLoggedIn();

  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;

  int _indexOf(MyOrderTabType tab) => MyOrderTabType.values.indexOf(tab);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: MyOrderTabType.values.length, initialIndex: _indexOf(_selectedTab), vsync: this);
    _tabController!.addListener(_onTabChanged);
    if (!_isLoggedIn) return;

    _scrollController.addListener(_onScroll);
    initCall();
  }

  void _onTabChanged() {
    if (_tabController == null) return;
    _selectTab(MyOrderTabType.values[_tabController!.index]);
  }

  void initCall() {
    final OrderController orderController = Get.find<OrderController>();
    for (final MyOrderTabType tab in MyOrderTabType.values) {
      orderController.getMyOrders(tab, 1, notify: false, limit: _pageLimit);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int page) =>
      Get.find<OrderController>().getMyOrders(_selectedTab, page, limit: _pageLimit);

  Future<void> _onRefresh() => _fetchPage(1);

  void _selectTab(MyOrderTabType tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    final int index = _indexOf(tab);
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent) return;

    final OrderController orderController = Get.find<OrderController>();
    final MyOrderTabData data = orderController.myOrderTab(_selectedTab);
    if (data.loading || data.paginating) return;

    final int totalPages = ((data.totalSize ?? 0) / _pageLimit).ceil();
    if (data.offset >= totalPages) return;

    orderController.setMyOrderOffset(_selectedTab, data.offset + 1);
    orderController.showMyOrderBottomLoader(_selectedTab);
    _fetchPage(data.offset);
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: context.surface,
      appBar: CustomAppBarWidget(
        title: 'my_orders'.tr,
        isBackButtonExist: true,
        centerTitle: false,
        onBackPressed: () {
          if(Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.find<DashboardController>().selectTab(0);
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoggedIn ? GetBuilder<OrderController>(builder: (orderController) {
          final MyOrderTabData data = orderController.myOrderTab(_selectedTab);
          final bool loading = data.loading;
          final List<MyOrderModel> orders = List<MyOrderModel>.from(data.orders ?? <MyOrderModel>[]);
          orders.sort((a, b) => _compareDescByCreatedAt(a.createdAt, b.createdAt));
          final List<_DateGroup> grouped = _groupByDate(orders);

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedHeaderDelegate(
                    height: 56,
                    child: _OrderTypeFilterBar(
                      selected: _selectedTab,
                      count: data.totalSize ?? 0,
                      onSelected: _selectTab,
                    ),
                  ),
                ),

                if (loading) const SliverToBoxAdapter(child: _OrderListShimmer())
                else if (grouped.isEmpty) SliverFillRemaining(hasScrollBody: false, child: _EmptyOrderView(text: 'no_order_found'.tr))
                else SliverList.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) => _OrderDateSection(
                      group: grouped[index],
                      isSubscription: _selectedTab == MyOrderTabType.repeat,
                    ),
                  ),

                if (!loading && data.paginating) const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                    child: Center(child: SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )),
                  ),
                ),
              ],
            ),
          );
        }) : const GuestTrackOrderInputViewWidget(),
      ),
    );
  }
  int _compareDescByCreatedAt(String? a, String? b) {
    final DateTime? da = _parseCreatedAt(a);
    final DateTime? db = _parseCreatedAt(b);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  List<_DateGroup> _groupByDate(List<MyOrderModel> items) {
    final Map<String, List<MyOrderModel>> map = <String, List<MyOrderModel>>{};
    final List<String> orderedKeys = <String>[];
    for (final MyOrderModel item in items) {
      final String key = _dateKey(item.createdAt);
      if (!map.containsKey(key)) {
        map[key] = <MyOrderModel>[];
        orderedKeys.add(key);
      }
      map[key]!.add(item);
    }
    return orderedKeys
        .map((key) => _DateGroup(dateLabel: _dateLabelOf(key), items: map[key]!))
        .toList();
  }

  String _dateKey(String? createdAt) {
    final DateTime? date = _parseCreatedAt(createdAt);
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _dateLabelOf(String key) {
    if (key.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(key);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime target = DateTime(date.year, date.month, date.day);
      if (target == today) return 'today'.tr;
      if (target == yesterday) return 'yesterday'.tr;
      return DateFormat('d MMM, yyyy').format(date);
    } catch (_) {
      return key;
    }
  }

  DateTime? _parseCreatedAt(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      try {
        return DateConverter.dateTimeStringToDate(value);
      } catch (_) {
        return null;
      }
    }
  }
}

class _DateGroup {
  final String dateLabel;
  final List<MyOrderModel> items;
  const _DateGroup({required this.dateLabel, required this.items});
}

class _SolidBar extends StatelessWidget {
  final Color color;
  final Widget child;
  const _SolidBar({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(color: color, elevation: 0, child: child);
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _PinnedHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _OrderTypeFilterBar extends StatelessWidget {
  final MyOrderTabType selected;
  final int count;
  final ValueChanged<MyOrderTabType> onSelected;

  const _OrderTypeFilterBar({required this.selected, required this.count, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<(MyOrderTabType, String)> tabs = <(MyOrderTabType, String)>[
      (MyOrderTabType.running, 'running'.tr),
      (MyOrderTabType.repeat, 'repeat'.tr),
      (MyOrderTabType.history, 'history'.tr),
    ];

    return _SolidBar(
      color: context.surfaceContainer,
      child: Column(
        children: [
          Container(height: 2, color: context.surface),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Row(
                children: [
                  _ResultCountBar(count: count),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(tabs.length, (index) {
                      final (MyOrderTabType filter, String label) = tabs[index];
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSmall),
                        child: _FilterChipItem(
                          label: label,
                          isSelected: filter == selected,
                          onTap: () => onSelected(filter),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingDefault,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: context.subHeading.small.strong.overrideWith(color: isSelected ? context.onPrimary : context.onSurface),
        ),
      ),
    );
  }
}

class _ResultCountBar extends StatelessWidget {
  final int count;
  const _ResultCountBar({required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${'orders'.tr}',
      style: context.heading.defaultSize.strong.overrideWith(color: context.textBaseMedium,),
    );
  }
}

class _OrderDateSection extends StatelessWidget {
  final _DateGroup group;
  final bool isSubscription;

  const _OrderDateSection({required this.group, required this.isSubscription});

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = <Widget>[];
    for (int i = 0; i < group.items.length; i++) {
      cards.add(Padding(
        padding: EdgeInsets.only(bottom: i < group.items.length - 1 ? Dimensions.paddingSmall : 0),
        child: _OrderItemCard(orderModel: group.items[i], isSubscription: isSubscription),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderDateBand(label: group.dateLabel),
        ...cards,
      ],
    );
  }
}

class _OrderDateBand extends StatelessWidget {
  final String label;
  const _OrderDateBand({required this.label});

  @override
  Widget build(BuildContext context) {
    final Color line = context.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(child: Container(height: 2, color: line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Text(label, style: context.subHeading.large),
          ),
          Expanded(child: Container(height: 2, color: line)),
        ],
      ),
    );
  }
}

ActionPane _deleteActionPane(BuildContext context, Future<void> Function() onDelete) {
  return ActionPane(
    motion: const ScrollMotion(),
    extentRatio: 0.2,
    children: [
      CustomSlidableAction(
        onPressed: (_) => onDelete(),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Icon(CupertinoIcons.delete, color: context.error, size: 22),
        ),
      ),
    ],
  );
}

Future<void> _confirmAndDeleteOrder(MyOrderModel order) async {
  final bool? confirmed = await Get.dialog<bool>(
    _DeleteOrderConfirmDialog(
      title: 'delete_order_question'.tr,
      subtitle: order.id != null ? '${'order'.tr} #${order.id}' : '',
    ),
    barrierDismissible: true,
  );
  if (confirmed != true) return;

  Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
  final bool ok = await Get.find<OrderController>().deleteOrder(order.id);
  if (Get.isDialogOpen ?? false) Get.back();

  if (!ok) {
    showCustomSnackBar('failed_to_delete_order'.tr);
    return;
  }
  Get.find<OrderController>().removeMyOrderFromList(order.id);
}

class _OrderItemCard extends StatefulWidget {
  final MyOrderModel orderModel;
  final bool isSubscription;

  const _OrderItemCard({required this.orderModel, required this.isSubscription});

  @override
  State<_OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<_OrderItemCard> {
  SlidableController? _slidableController;

  MyOrderModel get orderModel => widget.orderModel;

  void _openDetails() {
    Get.toNamed(
      RouteHelper.getOrderDetailsRoute(orderModel.id),
      arguments: OrderDetailsScreen(orderId: orderModel.id, orderModel: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canDelete = orderModel.isRemovable;
    final List<MyOrderItem> items = orderModel.items ?? <MyOrderItem>[];
    final int itemCount = orderModel.detailsCount ?? items.length;

    return Stack(children: [

      Positioned.fill(
        child: AnimatedBuilder(
          animation: _slidableController?.animation ?? const AlwaysStoppedAnimation<double>(0),
          builder: (context, _) {
            final bool sliding = (_slidableController?.animation.value ?? 0) > 0.01;
            if (!sliding) return const SizedBox();
            return Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FractionallySizedBox(
                widthFactor: 0.35, heightFactor: 1,
                child: Container(color: context.errorContainer),
              ),
            );
          },
        ),
      ),

      Slidable(
        key: ValueKey<int?>(orderModel.id),
        endActionPane: canDelete ? _deleteActionPane(context, () => _confirmAndDeleteOrder(orderModel)) : null,
        child: Builder(builder: (context) {
          final SlidableController? slidableController = Slidable.of(context);
          if (slidableController != null && slidableController != _slidableController) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _slidableController = slidableController);
            });
          }
          return AnimatedBuilder(
            animation: slidableController?.animation ?? const AlwaysStoppedAnimation<double>(0),
            builder: (context, child) {
              final bool sliding = (slidableController?.animation.value ?? 0) > 0.01;
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                child: Material(
                  color: sliding ? context.surfaceContainer : Colors.transparent,
                  child: child,
                ),
              );
            },
            child: InkWell(
              onTap: _openDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault, horizontal: Dimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderCardHeader(orderModel: orderModel, amount: orderModel.orderAmount, isSubscription: widget.isSubscription),
                    const SizedBox(height: Dimensions.paddingSmall),
                    Row(
                      children: [
                        ImagePreviewWidget(
                          image: items.isNotEmpty ? items.first.imageFullUrl : null,
                          extraCount: itemCount - 1,
                        ),
                        const SizedBox(width: Dimensions.paddingSmall),

                        Expanded(child: Text(
                          items.map((item) => item.name ?? '').where((name) => name.isNotEmpty).join(', '),
                          style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                        _OrderActionButton(orderModel: orderModel, isSubscription: widget.isSubscription, onDetails: _openDetails),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ]);
  }
}

class _DeleteOrderConfirmDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  const _DeleteOrderConfirmDialog({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.delete,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Dimensions.paddingDefault),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.heading.large,
            ),
            const SizedBox(height: Dimensions.paddingSmall),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
            ),
            const SizedBox(height: Dimensions.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(result: false),
                    style: TextButton.styleFrom(
                      backgroundColor: context.bgNeutralLight,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                      ),
                    ),
                    child: Text(
                      'no'.tr,
                      style: context.heading.defaultSize.strong,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingDefault),
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'yes'.tr,
                    onPressed: () => Get.back(result: true),
                    height: 44,
                    radius: Dimensions.radiusExtraSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCardHeader extends StatelessWidget {
  final double? amount;
  final MyOrderModel orderModel;
  final bool isSubscription;
  const _OrderCardHeader({required this.orderModel, this.amount, this.isSubscription = false});

  @override
  Widget build(BuildContext context) {
    String status = orderModel.orderStatus ?? '';
    if (orderModel.orderType == 'dine_in') {
      status = switch (status.toLowerCase()) {
        'processing' => 'cooking',
        'handover' => 'ready_to_serve',
        'pending' => 'pending',
        'canceled' => 'canceled',
        'confirmed' => 'confirmed',
        _ => 'served',
      };
    }

    final bool isRepeatOrder = isSubscription || orderModel.isRepeatOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (orderModel.restaurant != null)
          Row(children: [
            Flexible(child: Text(
              orderModel.restaurant?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.heading.large.strong,
            )),
            if (isRepeatOrder) ...[
              const SizedBox(width: Dimensions.padding2xSmall),
              Container(
                height: 18, width: 18, alignment: Alignment.center,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
                child: const Icon(Icons.autorenew, size: 12, color: Colors.white),
              ),
            ],
          ]),

        SizedBox(height: Dimensions.padding2xSmall,),
        Row(
          children: [
            Text(
              '${'order'.tr} #${orderModel.id ?? ''}',
              style: context.heading.defaultSize.regular.copyWith(color: context.textBaseMedium),
            ),
            const SizedBox(width: Dimensions.paddingDefault),
            StatusCard(orderStatus: status),
            const Spacer(),
            Text(
              PriceConverter.convertPrice(amount ?? 0),
              style: context.subHeading.large,
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  final MyOrderModel orderModel;
  final bool isSubscription;
  final VoidCallback onDetails;
  const _OrderActionButton({required this.orderModel, required this.isSubscription, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      final String status = (orderModel.orderStatus ?? '').toLowerCase();
      final bool reorderEnabled = (Get.find<SplashController>().configModel?.repeatOrderOption ?? false) && !isSubscription && (orderModel.canReorder ?? false);
      final bool trackable = orderModel.isTrackable;
      final (String label, VoidCallback onTap) = (status == 'delivered' && reorderEnabled)
          ? ('reorder'.tr, () => orderController.reorderFromLastOrder(orderModel.id))
          : trackable
          ? ('track'.tr, () => Get.toNamed(RouteHelper.getOrderTrackingRoute(orderModel.id, null)))
          : ('details'.tr, onDetails);

      final bool isReordering = orderController.isLoading && orderController.reorderingOrderId == orderModel.id;

      return CustomButtonWidget(
        height: 32,
        width: 90,
        color: context.primary,
        buttonText: label,
        isLoading: isReordering,
        onPressed: onTap,
        fontSize: Dimensions.fontSizeSmall,
      );
    });
  }
}

class StatusCard extends StatelessWidget {
  final String orderStatus;
  const StatusCard({super.key, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    final Color color = ColorConverter.getStatusColor(orderStatus);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSmall,
        vertical: Dimensions.paddingOverSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        orderStatus.tr,
        style: context.subHeading.small.regular,
      ),
    );
  }
}

class ImagePreviewWidget extends StatelessWidget {
  final String? image;
  final int extraCount;
  final double imageSize;

  const ImagePreviewWidget({super.key, required this.image, required this.extraCount, this.imageSize = 30});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: extraCount > 0 ? (imageSize * 2) - 5 : imageSize,
      height: imageSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: imageSize,
            width: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.surfaceContainer, width: 2),
            ),
            child: ClipOval(child: CustomImageWidget(image: image ?? '', fit: BoxFit.cover, isFood: true)),
          ),
          if (extraCount > 0) Positioned(
            left: imageSize - 5,
            child: Container(
              height: imageSize,
              width: imageSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Text(
                '+$extraCount', textAlign: TextAlign.center,
                style: context.heading.small.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListShimmer extends StatelessWidget {
  const _OrderListShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
          child: Center(child: _OrderShimmerBlock(width: 90, height: 12)),
        ),
        ...List<Widget>.generate(6, (_) => const _OrderShimmerCard()),
      ]),
    );
  }
}

class _OrderShimmerCard extends StatelessWidget {
  const _OrderShimmerCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSmall),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.paddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _OrderShimmerBlock(width: 140, height: 14),
          SizedBox(height: Dimensions.paddingSmall),
          Row(children: [
            _OrderShimmerBlock(width: 70, height: 10),
            SizedBox(width: Dimensions.paddingDefault),
            _OrderShimmerBlock(width: 60, height: 18),
            Spacer(),
            _OrderShimmerBlock(width: 50, height: 12),
          ]),
          SizedBox(height: Dimensions.paddingSmall),
          Row(children: [
            _OrderShimmerBlock(width: 30, height: 30, circle: true),
            SizedBox(width: Dimensions.paddingSmall),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _OrderShimmerBlock(width: 160, height: 10),
              SizedBox(height: 6),
              _OrderShimmerBlock(width: 100, height: 10),
            ])),
            SizedBox(width: Dimensions.paddingSmall),
            _OrderShimmerBlock(width: 120, height: 40),
          ]),
        ]),
      ),
    );
  }
}

class _OrderShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final bool circle;
  const _OrderShimmerBlock({required this.width, required this.height, this.circle = false});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFE9E9E9);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(8),
      ),
    );
  }
}

class _EmptyOrderView extends StatelessWidget {
  final String text;
  const _EmptyOrderView({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Text(
          text,
          style: context.heading.extraLarge.copyWith(color: context.textBaseMedium),
        ),
      ),
    );
  }
}
