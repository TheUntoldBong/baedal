import 'package:full_screen_bottom_sheet/full_screen_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/widgets/happy_hour_promo_banner_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HappyHourScreen extends StatefulWidget {
  const HappyHourScreen({super.key});

  static Future<void> show(BuildContext context) {
    return FullScreenBottomSheet.show(context, builder: (_) => const HappyHourScreen());
  }

  @override
  State<HappyHourScreen> createState() => _HappyHourScreenState();
}

class _HappyHourScreenState extends State<HappyHourScreen> {
  static const double _dragHandleHeight = Dimensions.paddingLarge;

  VoidCallback? _happyHourDisposer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    final HappyHourController controller = Get.find<HappyHourController>();
    _happyHourDisposer = controller.addListener(_closeWhenExpired);
    WidgetsBinding.instance.addPostFrameCallback((_){
      controller.getStoreList(1, false);
    });
  }

  @override
  void dispose() {
    _happyHourDisposer?.call();
    super.dispose();
  }

  void _closeWhenExpired() {
    if(_closing || !mounted || Get.find<HappyHourController>().isActive) {
      return;
    }
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  void _openRestaurant(BuildContext context, Restaurant restaurant) {
    Navigator.of(context, rootNavigator: true).pop();
    Get.toNamed(
      RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug ?? ''),
      arguments: RestaurantScreen(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenBottomSheet(
      backgroundColor: context.surfaceContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      headerExtent: (metrics) => FullScreenBottomSheetBar.heightOf(metrics, dragHandleHeight: _dragHandleHeight),
      headerBuilder: (context, metrics) => FullScreenBottomSheetBar(
        metrics: metrics,
        dragHandleHeight: _dragHandleHeight,
        backgroundColor: context.surfaceContainer,
        border: Border(bottom: BorderSide(color: context.outline)),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
        title: Text('happy_hour'.tr, style: context.heading.extraLarge.overrideWith(color: context.onSurface)),
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
        pageBar: CustomAppBarWidget(title: 'happy_hour'.tr, onBackPressed: () => Get.back()),
      ),
      slivers: (context, scrollController) => [
        SliverToBoxAdapter(
          child: GetBuilder<HappyHourController>(builder: (happyHourController) {
            return PaginatedListViewWidget(
              scrollController: scrollController,
              totalSize: happyHourController.storeModel?.totalSize,
              offset: happyHourController.storeModel?.offset,
              onPaginate: (int? offset) async => await happyHourController.getStoreList(offset!, false),
              productView: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, Dimensions.paddingDefault, Dimensions.paddingDefault, 0),
                  child: const HappyHourPromoBannerCardWidget(),
                ),

                const Divider(height: 5, thickness: 5),
                const SizedBox(height: Dimensions.paddingLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                  child: happyHourController.storeModel == null
                    ? const RestaurantCardShimmerListWidget()
                    : (happyHourController.storeModel!.restaurants?.isEmpty ?? false)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingExtraLarge),
                          child: Text('there_is_no_restaurant'.tr, textAlign: TextAlign.center,
                            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                        )
                      : RestaurantsViewWidget(
                          restaurants: happyHourController.storeModel!.restaurants,
                          onRestaurantTap: (restaurant) => _openRestaurant(context, restaurant),
                        ),
                ),
                const SizedBox(height: Dimensions.paddingLarge),
              ]),
            );
          }),
        ),
      ],
    );
  }
}
