import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_bundle_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartBundleListScreen extends StatefulWidget {
  final bool fromNav;
  const CartBundleListScreen({super.key, this.fromNav = false});

  @override
  State<CartBundleListScreen> createState() => _CartBundleListScreenState();
}

class _CartBundleListScreenState extends State<CartBundleListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<CartController>().getCartBundleList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'cart_list'.tr,
        isBackButtonExist: true,
        centerTitle: false,
        onBackPressed: widget.fromNav ? () => Get.find<DashboardController>().selectTab(0) : null,
        actions: [
          GetBuilder<CartController>(builder: (cartController) {
            if (cartController.cartBundleList.isEmpty) {
              return const SizedBox();
            }
            return Container(
              margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: cartController.isClearingAll ? null : () => _confirmClearAll(),
                icon: cartController.isClearingAll
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(CupertinoIcons.trash, size: 14, color: Theme.of(context).colorScheme.error),
                label: Text(
                  'clear_all'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: GetBuilder<CartController>(builder: (cartController) {
        if (cartController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = cartController.cartBundleList;
        if (list.isEmpty) {
          return const _EmptyCartBundleWidget();
        }

        final bool isDesktop = ResponsiveHelper.isDesktop(context);
        return RefreshIndicator(
          onRefresh: () => cartController.getCartBundleList(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multi-restaurant info banner if multiple carts exist
                    if (list.length > 1)
                      Container(
                        margin: const EdgeInsets.only(
                          left: Dimensions.paddingDefault,
                          right: Dimensions.paddingDefault,
                          top: Dimensions.paddingSmall,
                          bottom: 4,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.storefront_rounded, size: 20, color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSmall),
                            Expanded(
                              child: Text(
                                '${'items_from'.tr} ${list.length} ${'restaurants_ordered_separately'.tr}',
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Carts count summary header
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingDefault,
                        right: Dimensions.paddingDefault,
                        top: Dimensions.paddingSmall,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Active Cart',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${list.length}',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    isDesktop
                        ? GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 260,
                            ),
                            itemBuilder: (context, index) {
                              return CartBundleWidget(cartBundleWidget: list[index]);
                            },
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return CartBundleWidget(cartBundleWidget: list[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _confirmClearAll() {
    showCustomDialog(
      child: ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'are_you_sure_to_delete'.tr,
        description: 'all_items_will_be_removed_from_your_cart'.tr,
        isLogOut: true,
        isDelete: true,
        onYesPressed: () {
          Get.back();
          Get.find<CartController>().clearAllCartBundles();
        },
      ),
      isDismissible: false,
    );
  }
}

class _EmptyCartBundleWidget extends StatelessWidget {
  const _EmptyCartBundleWidget();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double imageSize = isDesktop ? 160 : 130;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Concentric glowing decorative background around cart graphic
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: imageSize * 1.5,
                  height: imageSize * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.12),
                        Theme.of(context).primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: imageSize * 1.15,
                  height: imageSize * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
                CustomAssetImageWidget(
                  Images.emptyCart,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'cart_is_empty'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge + 2,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
              child: Text(
                'you_have_not_add_to_cart_yet'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).disabledColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // Explore Restaurants Action Button
            SizedBox(
              width: 220,
              height: 48,
              child: CustomButtonWidget(
                buttonText: 'explore_food'.tr,
                icon: Icons.restaurant_menu_rounded,
                radius: 24,
                onPressed: () {
                  Get.find<DashboardController>().selectTab(0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


