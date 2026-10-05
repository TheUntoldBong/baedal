
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/offer_badge_widget.dart';
import 'package:stackfood_multivendor/common/widgets/vertical_food_card_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/bogo_offer/widgets/bogo_offer_details_bottom_sheet.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_stepper_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart' hide Restaurant;
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/latest_order_model.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/pro/screens/subscription_plan_screen.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/restaurant_category_foods_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/coupon_clipper.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/previous_orders_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/pro_plan_banner_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  final bool viewCartAutoNavigate;
  const RestaurantScreen({super.key, required this.restaurant, this.slug = '', this.fromDineIn = false, this.viewCartAutoNavigate = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final Map<int, GlobalKey> _categoryKeys = {};
  final GlobalKey _mostPopularKey = GlobalKey();
  final GlobalKey _bogoKey = GlobalKey();
  final ValueNotifier<int> _activeTab = ValueNotifier(0);

  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;
  bool _userClickedTab = false;
  int? _pendingTabIndex;
  bool _autoCartNavigated = false;

  @override
  void initState() {
    super.initState();
    _initDataCall();
    scrollController.addListener(_onScroll);
    if (widget.viewCartAutoNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openCartNow());
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _activeTab.dispose();
    super.dispose();
  }

  void _openCartNow() {
    if (_autoCartNavigated || !mounted) return;
    final int? restaurantId = widget.restaurant?.id ?? Get.find<RestaurantController>().restaurant?.id;
    if (restaurantId == null) return;
    _autoCartNavigated = true;
    Get.toNamed(RouteHelper.getCartRoute(restaurantId: restaurantId));
  }

  Future<void> _initDataCall() async {
    final RestaurantController restController = Get.find<RestaurantController>();
    if (restController.isSearching) {
      restController.changeSearchStatus(isUpdate: false);
    }
    final int? restaurantId = widget.restaurant?.id;
    await restController.getRestaurantDetails(Restaurant(id: restaurantId), setNullBeforeLoad: true);
    final int id = restaurantId ?? restController.restaurant!.id!;
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true, search: '');
    }
    await Future.wait([
      Get.find<CouponController>().getRestaurantCouponList(restaurantId: id),
      restController.getRestaurantRecommendedItemList(id, false),
      restController.getRestaurantBogoOffers(id),
      restController.getRestaurantCategoryFoods(id, VegType.all),
      if (AuthHelper.isLoggedIn() && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false))
        Get.find<OrderController>().getRestaurantLastOrders(id),
      if (AuthHelper.isLoggedIn() && Get.find<SplashController>().proStaus)
        Get.find<ProController>().getProActiveOffer(),
    ]);
  }

  GlobalKey _sectionKey(int index) => _categoryKeys.putIfAbsent(index, () => GlobalKey());

  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (!ResponsiveHelper.isDesktop(context)) {
      final bool showBackToTop = scrollController.position.pixels > _backToTopThreshold;
      if (showBackToTop != _showBackToTop) {
        setState(() => _showBackToTop = showBackToTop);
      }
    }

    _updateActiveTab();
  }

  void _updateActiveTab() {
    if (_userClickedTab) return;

    final RestaurantController restController = Get.find<RestaurantController>();
    final List<RestaurantCategoryItem> cats = restController.restaurantCategoryFoodsModel?.categories ?? [];
    final bool hasMostPopular = restController.recommendedProductModel?.products?.isNotEmpty == true;
    final bool hasBogoOffers = restController.bogoOfferList?.isNotEmpty == true;
    final double threshold = ResponsiveHelper.isDesktop(context)
        ? _pinnedOffset() + 16
        : MediaQuery.of(context).padding.top + 160;

    int autoIndex = hasMostPopular ? 0 : hasBogoOffers ? 1 : (cats.isNotEmpty ? 2 : 0);

    if (hasBogoOffers) {
      final ctx = _bogoKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final double top = box.localToGlobal(Offset.zero).dy;
        if (top <= threshold) {
          autoIndex = 1;
        }
      }
    }

    for (int i = cats.length - 1; i >= 0; i--) {
      final ctx = _categoryKeys[i]?.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final double top = box.localToGlobal(Offset.zero).dy;
        if (top <= threshold) {
          autoIndex = i + 2;
          break;
        }
      }
    }

    if (_pendingTabIndex != null && scrollController.position.userScrollDirection != ScrollDirection.idle) {
      _pendingTabIndex = null;
    }

    if (_pendingTabIndex != null) {
      if (autoIndex < _pendingTabIndex!) {
        _activeTab.value = _pendingTabIndex!;
        return;
      }
      _pendingTabIndex = null;
    }

    _activeTab.value = autoIndex;
  }

  void _scrollToContext(BuildContext ctx) {
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject == null) return;
    final viewport = RenderAbstractViewport.of(renderObject);
    final double target = viewport.getOffsetToReveal(renderObject, 0.0).offset;
    scrollController.animateTo(
      (target - _pinnedOffset()).clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400), curve: Curves.easeOut,
    );
  }

  double _pinnedOffset() => ResponsiveHelper.isDesktop(context)
      ? 150 + 44
      : MediaQuery.of(context).padding.top + 70 + 44;

  void _handleTabTap(int index) {
    final int previousActive = _activeTab.value;
    _userClickedTab = true;
    _pendingTabIndex = index;
    _activeTab.value = index;
    if (index == 0) {
      final ctx = _mostPopularKey.currentContext;
      if (ctx != null) {
        _scrollToContext(ctx);
      } else {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else if (index == 1) {
      final ctx = _bogoKey.currentContext;
      if (ctx != null) {
        _scrollToContext(ctx);
      } else {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      _jumpToCategory(index - 2, forward: (index - 2) >= previousActive);
    }
    Future.delayed(const Duration(milliseconds: 450), () => _userClickedTab = false);
  }

  Future<void> _jumpToCategory(int categoryIndex, {required bool forward}) async {
    final GlobalKey key = _sectionKey(categoryIndex);
    final BuildContext? immediate = key.currentContext;
    if (immediate != null) {
      _scrollToContext(immediate);
      return;
    }
    if (!scrollController.hasClients) return;

    const double hopDistance = 4000;
    const int maxHops = 30;
    double lastPixels = scrollController.position.pixels;

    for (int hop = 0; hop < maxHops; hop++) {
      if (!mounted || !scrollController.hasClients) return;
      final double delta = forward ? hopDistance : -hopDistance;
      final double next = (scrollController.position.pixels + delta).clamp(0.0, double.infinity);
      scrollController.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !scrollController.hasClients) return;

      final BuildContext? ctx = key.currentContext;
      if (ctx != null && ctx.mounted) {
        _scrollToContext(ctx);
        return;
      }

      final double pixels = scrollController.position.pixels;
      if (pixels == lastPixels) break;
      lastPixels = pixels;
    }
  }

  void _scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void _showMenuBottomSheet({
    required BuildContext context,
    required List<RestaurantCategoryItem> categories,
    required Map<String, List<Product>> categoryWiseFoods,
    required bool hasMostPopular,
    required List<Product> mostPopularProducts,
    required bool hasBogoOffers,
    required List<RestaurantBogoOfferModel> bogoOffers,
  }) {
    final Color primary = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.bgNeutralMedium,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.restaurant_menu_rounded, size: 18, color: primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'menu'.tr,
                        style: context.heading.large.strong,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: context.textBaseLight,
                        onPressed: () => Navigator.of(ctx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 1, thickness: 0.8, color: context.outline.withValues(alpha: 0.5)),
                Flexible(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _activeTab,
                    builder: (context, activeIndex, _) {
                      return ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (hasMostPopular)
                            _buildMenuCategoryItem(
                              context: context,
                              title: 'recommended'.tr,
                              count: mostPopularProducts.length,
                              isSelected: activeIndex == 0,
                              icon: Icons.thumb_up_rounded,
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _handleTabTap(0);
                              },
                            ),
                          if (hasBogoOffers)
                            _buildMenuCategoryItem(
                              context: context,
                              title: 'bogo_offers'.tr,
                              count: bogoOffers.length,
                              isSelected: activeIndex == 1,
                              icon: Icons.local_offer_rounded,
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _handleTabTap(1);
                              },
                            ),
                          ...List.generate(categories.length, (index) {
                            final cat = categories[index];
                            final int tabIndex = index + 2;
                            final bool isSelected = activeIndex == tabIndex;
                            final int itemCount = categoryWiseFoods['${cat.id}']?.length ?? cat.foodsCount ?? 0;

                            return _buildMenuCategoryItem(
                              context: context,
                              title: cat.name ?? '',
                              count: itemCount,
                              isSelected: isSelected,
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _handleTabTap(tabIndex);
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCategoryItem({
    required BuildContext context,
    required String title,
    required int count,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final Color primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: isSelected ? primary : context.textBaseLight),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: isSelected
                      ? context.subHeading.defaultSize.strong.overrideWith(color: primary)
                      : context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : context.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? primary : context.textBaseMedium,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, size: 16, color: primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: Stack(children: [

        RefreshIndicator(
          onRefresh: _initDataCall,
          edgeOffset: MediaQuery.of(context).padding.top + 70,
          color: context.primary,
          child: GetBuilder<RestaurantController>(builder: (restController) {
            return GetBuilder<CouponController>(builder: (couponController) {
              final RestaurantCategoryFoodsModel? categoryFoodsModel = restController.restaurantCategoryFoodsModel;
              final bool loaded = restController.restaurant != null && restController.restaurant!.name != null && categoryFoodsModel != null;
              if (!loaded) return const RestaurantScreenShimmerWidget();
              final Restaurant restaurant = restController.restaurant!;
              final List<RestaurantCategoryItem> categories = categoryFoodsModel.categories ?? [];
              final bool hasMostPopular = restController.recommendedProductModel?.products?.isNotEmpty == true;
              final bool hasBogoOffers = restController.bogoOfferList?.isNotEmpty == true;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                slivers: _buildMobileSlivers(context, restController, couponController, categoryFoodsModel, restaurant, categories, hasMostPopular, hasBogoOffers),
              );
            });
          }),
        ),

        _BackToTopButton(visible: _showBackToTop, onTap: _scrollToTop),

        GetBuilder<RestaurantController>(
          builder: (restaurantController) {
            return Positioned(bottom: 0, left: 0, right: 0, child: GetBuilder<CartController>(builder: (cartController) {
              final Restaurant? happyHourRestaurant = restaurantController.restaurant;
              final int? restaurantId = happyHourRestaurant?.id;
              if (restaurantId == null) return const SizedBox();
              final double subtotal = cartController.subTotalOf(restaurantId);
              final bool cartEmpty = cartController.cartList(restaurantId).isEmpty;

              return GetBuilder<HappyHourController>(builder: (happyHourController) {
                final bool bannerVisible = happyHourController.showRestaurantBanner(happyHourRestaurant?.isHappyHourRunning ?? false);

                final double bottomInset = MediaQuery.paddingOf(context).bottom;

                return Column(mainAxisSize: MainAxisSize.min, children: [

                  if (bannerVisible) HappyHourMilestoneBannerWidget(
                    onTap: (){},
                    subtotal: subtotal, isHappyHourRunning: happyHourRestaurant?.isHappyHourRunning,
                    bottomInset: cartEmpty ? bottomInset : 0,
                  ),

                  if (!cartEmpty) Container(
                    color: !bannerVisible ? Colors.transparent : context.surfaceContainer,
                    child: _ViewCartButton(restaurantId: restaurantId, fromDineIn: widget.fromDineIn),
                  ),
                ]);
              });
            }));
          }
        ),

        if (!ResponsiveHelper.isDesktop(context))
          GetBuilder<RestaurantController>(
            builder: (restaurantController) {
              final RestaurantCategoryFoodsModel? categoryFoodsModel = restaurantController.restaurantCategoryFoodsModel;
              if (restaurantController.restaurant == null || categoryFoodsModel == null) return const SizedBox.shrink();

              final List<RestaurantCategoryItem> categories = categoryFoodsModel.categories ?? [];
              final bool hasMostPopular = restaurantController.recommendedProductModel?.products?.isNotEmpty == true;
              final bool hasBogoOffers = restaurantController.bogoOfferList?.isNotEmpty == true;
              final int totalCategories = (hasMostPopular ? 1 : 0) + (hasBogoOffers ? 1 : 0) + categories.length;

              if (totalCategories == 0) return const SizedBox.shrink();

              return GetBuilder<CartController>(builder: (cartController) {
                final int? restaurantId = restaurantController.restaurant?.id;
                final bool cartEmpty = restaurantId == null || cartController.cartList(restaurantId).isEmpty;

                return GetBuilder<HappyHourController>(builder: (happyHourController) {
                  final bool bannerVisible = happyHourController.showRestaurantBanner(restaurantController.restaurant?.isHappyHourRunning ?? false);
                  final double bottomInset = MediaQuery.paddingOf(context).bottom;

                  double bottomOffset = bottomInset + 16;
                  if (!cartEmpty) {
                    bottomOffset += (GetPlatform.isIOS ? 95 : 68) + 12;
                  }
                  if (bannerVisible) {
                    bottomOffset += 45;
                  }

                  return Positioned(
                    left: 16,
                    bottom: bottomOffset,
                    child: _BrowseMenuButton(
                      categoryCount: totalCategories,
                      onTap: () => _showMenuBottomSheet(
                        context: context,
                        categories: categories,
                        categoryWiseFoods: categoryFoodsModel.categoryWiseFoods ?? {},
                        hasMostPopular: hasMostPopular,
                        mostPopularProducts: restaurantController.recommendedProductModel?.products ?? [],
                        hasBogoOffers: hasBogoOffers,
                        bogoOffers: restaurantController.bogoOfferList ?? [],
                      ),
                    ),
                  );
                });
              });
            },
          ),

      ]),
    );
  }

  List<Widget> _buildMobileSlivers(
      BuildContext context, RestaurantController restController, CouponController couponController,
      RestaurantCategoryFoodsModel categoryFoodsModel, Restaurant restaurant,
      List<RestaurantCategoryItem> categories, bool hasMostPopular, bool hasBogoOffers,
      ) {
    return [

      _RestaurantSliverHeader(restaurant: restaurant, restController: restController, onBack: () => Get.back()),

      SliverToBoxAdapter(child: _RestaurantOverview(restaurant: restaurant, restController: restController, couponController: couponController)),

      SliverToBoxAdapter(child: Container(
        color: context.surfaceContainer,
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, Dimensions.paddingDefault, Dimensions.paddingDefault, 0),
        child: ProPlanBannerWidget(onSubscribe: () => _onSubscribe(context)),
      )),

      if(AuthHelper.isLoggedIn() && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false))
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
          child: _PreviousOrdersBanner(restaurantId: restaurant.id!),
        )),

      if (categories.isNotEmpty || hasMostPopular || hasBogoOffers) SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingDefault,)),
      if (categories.isNotEmpty || hasMostPopular || hasBogoOffers) SliverPersistentHeader(
        pinned: true,
        delegate: _TabBarDelegate(height: 44, child: _RestaurantCategoryTabs(
          categories: categories, hasMostPopular: hasMostPopular, hasBogoOffers: hasBogoOffers,
          activeNotifier: _activeTab, onTabTap: _handleTabTap,
        )),
      ),

      if (hasMostPopular) SliverToBoxAdapter(
        child: _MostPopularSection(key: _mostPopularKey, products: restController.recommendedProductModel!.products!),
      ),

      if (hasMostPopular) const SliverToBoxAdapter(child: _SectionSeparator()),

      if (hasBogoOffers) SliverToBoxAdapter(
        child: _BogoOfferSection(key: _bogoKey, offers: restController.bogoOfferList!, restaurantId: restaurant.id),
      ),

      if (hasBogoOffers) const SliverToBoxAdapter(child: _SectionSeparator()),

      ..._buildCategorySlivers(context, categoryFoodsModel, categories, restaurant),
      SliverToBoxAdapter(child:  GetBuilder<CartController>(
        builder: (cartController) {
          return GetBuilder<HappyHourController>(
            builder: (happyHourController) {
              double height = 0;
              if (happyHourController.showRestaurantBanner(restaurant.isHappyHourRunning ?? false)) {
                height += 60;
              }
              if(cartController.cartList(widget.restaurant!.id!).isNotEmpty){
                height += 70;
              }
              return SizedBox(height: height);
            }
          );
        }
      ),)
    ];
  }

  List<Widget> _buildCategorySlivers(
      BuildContext context, RestaurantCategoryFoodsModel model,
      List<RestaurantCategoryItem> categories, Restaurant restaurant,
      ) {
    final Map<String, List<Product>> foodsMap = model.categoryWiseFoods ?? {};
    final List<Widget> slivers = [];
    bool isFirst = true;

    for (int i = 0; i < categories.length; i++) {
      final RestaurantCategoryItem cat = categories[i];
      final List<Product> products = foodsMap[cat.id.toString()] ?? [];
      if (products.isEmpty) continue;

      if (!isFirst) {
        slivers.add(SliverToBoxAdapter(
          key: ValueKey('cat_divider_${cat.id}'),
          child: const _SectionSeparator(),
        ));
      }
      isFirst = false;

      slivers.add(SliverToBoxAdapter(
        key: ValueKey('cat_header_${cat.id}'),
        child: _CategoryHeader(key: _sectionKey(i), name: cat.name ?? ''),
      ));

      slivers.add(SliverList(
        key: ValueKey('cat_list_${cat.id}'),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index.isOdd) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Divider(height: 1,),
              );
            }
            final int productIndex = index ~/ 2;
            return HorizontalFoodCardWidget(product: products[productIndex], restaurant: restaurant, padding: const EdgeInsets.all(Dimensions.paddingDefault));
          },
          childCount: products.length * 2 - 1,
        ),
      ));
    }

    if (slivers.isEmpty) {
      slivers.add(SliverToBoxAdapter(child: Container(height: 300, alignment: Alignment.center, child: Text('no_food_found'.tr))));
    }

    return slivers;
  }

  void _onSubscribe(BuildContext context) {
    if (AuthHelper.isLoggedIn()) {
      Get.find<ProController>().saveCurrentPath();
      if (ResponsiveHelper.isDesktop(context)) {
        SubscriptionPlanScreen.open();
      } else {
        Get.toNamed(RouteHelper.getSubscriptionPlanRoute());
      }
    } else {
     Get.toNamed(RouteHelper.signIn);
    }
  }
}

class _RestaurantSliverHeader extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final VoidCallback onBack;

  const _RestaurantSliverHeader({required this.restaurant, required this.restController, required this.onBack});

  void _openSearch() => Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant.id));

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    const double maxH = 210;
    final double minH = 70 + topPadding;
    final bool hasAnnouncement = (restaurant.announcementActive ?? false) && (restaurant.announcementMessage ?? '').isNotEmpty;

    return SliverAppBar(
      pinned: true,
      expandedHeight: maxH,
      collapsedHeight: 70,
      toolbarHeight: 70,
      backgroundColor: context.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: const [SizedBox()],
      flexibleSpace: LayoutBuilder(builder: (context, constraints) {
        final double t = ((maxH - constraints.maxHeight) / (maxH - minH)).clamp(0.0, 1.0);
        final double coverOpacity = (1 - (t - 0.45) / 0.4).clamp(0.0, 1.0);
        final double barOpacity = ((t - 0.45) / 0.4).clamp(0.0, 1.0);
        final double titleT = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

        return Stack(fit: StackFit.expand, children: [
          Container(color: context.surfaceContainer),

          ClipRect(
            child: Opacity(
              opacity: coverOpacity,
              child: Stack(children: [
                Positioned.fill(child: CustomImageWidget(
                  image: restaurant.coverPhotoFullUrl ?? '', fit: BoxFit.cover,
                  placeholder: Images.restaurantCover, isRestaurant: true,
                )),

                Positioned(left: 0, right: 0, bottom: 0, child: Container(
                  height: 24,
                  decoration: BoxDecoration(color: context.surfaceContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))),
                )),

                IgnorePointer(
                  ignoring: t > 0.65,
                  child: Padding(
                    padding: EdgeInsets.only(top: topPadding + 12, left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _SquareIconButton(onTap: onBack, child: Icon(Icons.arrow_back, size: 24, color: context.iconBaseDefault)),
                      const Spacer(),
                      _SquareIconButton(onTap: _openSearch, child: Icon(CupertinoIcons.search, size: 22, color: context.iconBaseDefault)),
                      const SizedBox(width: Dimensions.paddingSmall),
                      GetBuilder<FavouriteController>(builder: (favouriteController) {
                        final bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                        return _SquareIconButton(
                          child: CustomFavouriteWidget(isWished: isWished, bgColor: Colors.transparent, isRestaurant: true, id: restaurant.id!, size: 22),
                        );
                      }),
                    ]),
                  ),
                ),

                if (hasAnnouncement) IgnorePointer(
                  ignoring: t > 0.65,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault, bottom: 38),
                    child: Align(alignment: Alignment.bottomRight, child: _AnnouncementBar(message: restaurant.announcementMessage!)),
                  ),
                ),
              ]),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: barOpacity,
              child: IgnorePointer(
                ignoring: t < 0.65,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
                  child: SizedBox(height: 70, child: Row(children: [
                    _SoftIconButton(icon: Icons.arrow_back, onTap: onBack, showBg: false),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Expanded(child: ClipRect(child: Transform.translate(
                        offset: Offset(0, (1 - titleT) * 14),
                        child: Opacity(opacity: titleT, child: Text(restaurant.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: context.heading.large),
                        )
                    ))),
                    const SizedBox(width: Dimensions.paddingSmall),
                    _SoftIconButton(icon: CupertinoIcons.search, onTap: _openSearch),
                  ])),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _RestaurantOverview extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final CouponController couponController;

  const _RestaurantOverview({required this.restaurant, required this.restController, required this.couponController});

  String get _cuisines => restaurant.cuisineNames == null ? ''
      : restaurant.cuisineNames!.map((c) => c.name).where((n) => (n ?? '').isNotEmpty).join(', ');

  void _share() {
    if (AppConstants.webHostedUrl.isEmpty) return;
    final String shareUrl = '${AppConstants.webHostedUrl}${restController.filteringUrl(restaurant.slug ?? '')}';
    SharePlus.instance.share(ShareParams(text: shareUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
      width: Dimensions.webMaxWidth, color: context.surfaceContainer,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), child: Stack(children: [
              CustomImageWidget(image: restaurant.logoFullUrl ?? '', height: 60, width: 60, fit: BoxFit.cover, isRestaurant: true),
              restController.isRestaurantOpenNow(restaurant.active!, restaurant.schedules) ? const SizedBox()
                : Positioned(left: 0, right: 0, bottom: 0, child: Container(
                    height: 60, width: 60, alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    child: Text('closed_now'.tr, textAlign: TextAlign.center, style: context.heading.extraSmall.strong.overrideWith(color: Colors.white)),
                  )),
            ])),
            const SizedBox(width: Dimensions.paddingDefault),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: Text(restaurant.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: context.heading.extraLarge
                      )),

                      if (restaurant.verifiedSeller ?? false) ...[
                        const SizedBox(width: Dimensions.padding2xSmall),
                        const Padding(padding: EdgeInsets.only(top: 4), child: RestaurantVerifiedIconWidget(size: 18)),
                      ],
                    ],
                  ),
                ),

                if (AppConstants.webHostedUrl.isNotEmpty) InkWell(
                  onTap: _share,
                  child: Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSmall, top: 2),
                      child: Icon(Icons.share_outlined, size: 25, color: context.iconInfoMedium)),
                ),
              ]),

              if (_cuisines.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(_cuisines, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: context.subHeading.defaultSize)
              ],
              const SizedBox(height: 3),

              Row(children: [
                if (restaurant.distanceLabel?.isNotEmpty ?? false) ...[
                  Text(
                    restaurant.distanceLabel!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
                  ),
                  Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: context.surface)),
                ],
                Expanded(child: _RestaurantAddressLink(restaurant: restaurant)),
              ]),

            ])),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: _StatsCard(restaurant: restaurant),
        ),

        _OfferScroller(restaurant: restaurant, couponController: couponController),
      ]),
    ));
  }
}

class _RestaurantAddressLink extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantAddressLink({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final String address = restaurant.address?.trim() ?? '';
    final bool hasLocation = (restaurant.latitude?.trim().isNotEmpty ?? false)
        && (restaurant.longitude?.trim().isNotEmpty ?? false);

    if (address.isEmpty) return const SizedBox();

    final Widget addressText = Text(
      address, maxLines: 1, overflow: TextOverflow.ellipsis,
      style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
    );

    if (!hasLocation) return addressText;

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getMapRoute(
        AddressModel(
          id: restaurant.id, address: address,
          latitude: restaurant.latitude, longitude: restaurant.longitude,
          contactPersonNumber: '', contactPersonName: '', addressType: '',
        ),
        'restaurant',
        restaurantName: restaurant.name,
      )),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_on_outlined, size: 14, color: context.primary),
        const SizedBox(width: 2),
        Flexible(child: addressText),
      ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Restaurant restaurant;
  const _StatsCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.outline),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),

      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
      child: Row(children: [
        Expanded(child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant.id, restaurant.name, restaurant)),
          child: _StatItem(icon: Images.starFill, iconColor: context.iconWarningLight,
            value: (restaurant.avgRating ?? 0).toStringAsFixed(1),
            label: '${restaurant.ratingCount ?? 0}${(restaurant.ratingCount != null && restaurant.ratingCount! > 5) ? '+ ${'reviews'.tr}' : ' ${'review'.tr}'}',
          ),
        )),
        const _StatDivider(),
        Expanded(child: _StatItem(value: restaurant.deliveryTime ?? '', label: 'delivery_time'.tr)),
        const _StatDivider(),
        Expanded(child: _StatItem(value: PriceConverter.convertPrice(restaurant.minimumOrder), label: 'min_order'.tr)),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String? icon;
  final Color? iconColor;
  final String value;
  final String label;
  const _StatItem({this.icon, this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[CustomAssetImageWidget(icon!, height: 16, color: iconColor), const SizedBox(width: 3)],
        Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr, style: context.heading.defaultSize))
      ]),
      const SizedBox(height: 2),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: context.subHeading.small.overrideWith(color: context.textBaseMedium))
    ]);
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 42, color: context.outline);
}

class _OfferScroller extends StatelessWidget {
  final Restaurant restaurant;
  final CouponController couponController;
  const _OfferScroller({required this.restaurant, required this.couponController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProController>(builder: (proController) {
      final Widget? proCard = _buildProCard(proController);
      final List<Widget> cards = [?proCard, ..._buildOfferCards(context)];

      if (cards.isEmpty) return const SizedBox(height: Dimensions.paddingSmall);

      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(cards.length, (i) => Padding(
              padding: EdgeInsets.only(right: i < cards.length - 1 ? Dimensions.paddingDefault : 0),
              child: cards[i],
            )),
          )),
        ),
      );
    });
  }

  Widget? _buildProCard(ProController proController) {
    if (!ProHelper.showActiveBenefitBanner) {
      return null;
    }
    final ProActiveBenefit? benefit = proController.activeOfferModel?.benefit;
    if (benefit == null || benefit.type == null) return null;

    final bool hasMin = benefit.minOrderStatus == true && (benefit.minOrderAmount ?? 0) > 0;
    final String savingSubtitle = hasMin
        ? '${'min_purchase'.tr} ${PriceConverter.convertPrice(benefit.minOrderAmount)} ${'and_special_saving_for_pro_members'.tr}'
        : 'special_saving_for_pro_members'.tr;

    String? headline;
    String subtitle = savingSubtitle;

    switch (benefit.type!) {
      case ProBenefitType.discount:
        final double pct = benefit.percentage ?? 0;
        if (pct > 0) headline = '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}% ${'off'.tr}';
        break;

      case ProBenefitType.deliveryFee:
        if (benefit.offerType == ProOfferType.fullFree) {
          headline = 'free_delivery'.tr;
        } else if ((benefit.chargeDiscountPercentage ?? 0) > 0) {
          headline = '${(benefit.chargeDiscountPercentage ?? 0).toStringAsFixed(0)}% ${'off'.tr}';
        }
        break;

      case ProBenefitType.coupon:
        headline = 'pro_coupon'.tr;
        subtitle = 'you_have_a_coupon_as_a_pro_member'.tr;
        break;
    }

    if (headline == null) return null;
    return _ProOfferCard(discountText: headline, subtitle: subtitle);
  }

  List<Widget> _buildOfferCards(BuildContext context) {
    final List<Widget> cards = [];

    if (restaurant.discount != null && (restaurant.discount!.discount ?? 0) > 0) {
      final Discount d = restaurant.discount!;
      final String title = d.discountType == 'percent'
          ? '${_trim(d.discount ?? 0)}% ${'off'.tr}'
          : '${PriceConverter.convertPrice(d.discount)} ${'off'.tr}';
      cards.add(_OfferCard(
        title: title, color: context.bgWarningLight,
        message: '${'min_purchase'.tr} ${PriceConverter.convertPrice(d.minPurchase)} ${'and_max_discount_is'.tr} ${PriceConverter.convertPrice(d.maxDiscount)}',
        icon: Images.discountPercentIcon,
      ));
    }

    if (couponController.couponList != null) {
      for (final coupon in couponController.couponList!) {
        double couponDiscount = coupon.discount ?? 0;
        if(couponDiscount <= 0) continue;
        String text = coupon.discountType == 'amount'
            ? PriceConverter.convertPrice(couponDiscount)
            : '${couponDiscount.toStringAsFixed(couponDiscount % 1 == 0 ? 0 : 1)}%';
        cards.add(_OfferCard(
          title: '$text ${'off'.tr}',
          subTitle: '(${coupon.title ?? ''})', color: context.bgErrorLight,
          message: '${'min_purchase'.tr} ${PriceConverter.convertPrice(coupon.minPurchase)}',
          icon: Images.couponBadge,
          coupon: coupon,
        ));
      }
    }

    return cards;
  }

  String _trim(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String message;
  final Color color;
  final String icon;
  final CouponModel? coupon;

  const _OfferCard({required this.title, required this.message, required this.color, required this.icon, this.subTitle, this.coupon});

  bool get _isCoupon => coupon != null;

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(color: color, borderRadius: _isCoupon ? null : BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CustomAssetImageWidget(icon, height: 16, width: 16, color: context.iconWarningLight),
          const SizedBox(width: 4),
          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: context.heading.large,)),
        ]),
        if (subTitle != null) ...[
          const SizedBox(height: 2),
          Text(subTitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: context.body.small
          )
        ],
        const SizedBox(height: 4),
        Flexible(
          child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: context.body.small.overrideWith(color: context.textBaseMedium)
          ),
        ),
      ]),
    );

    final Widget card = _isCoupon
        ? ClipPath(clipper: CouponClipper(borderRadius: 16, notchRadius: 12), child: cardContent)
        : cardContent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showOfferSheet(context, _OfferDetailSheet(
        title: title, subTitle: subTitle, message: message,
        accentColor: color, icon: Images.couponIcon, coupon: coupon,
      )),
      child: card,
    );
  }
}

class _ProOfferCard extends StatelessWidget {
  final String discountText;
  final String subtitle;

  const _ProOfferCard({required this.discountText, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    Color proBlue = context.textInfoOn;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showOfferSheet(context, _OfferDetailSheet(
        title: discountText, message: subtitle,
        accentColor: context.primary.withValues(alpha: 0.12), icon: Images.star, isPro: true,
      )),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
        decoration: BoxDecoration(color: context.bgInfoLight, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
              decoration: BoxDecoration(color: context.bgInfoDefault, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_rounded, size: 16, color: proBlue),
                const SizedBox(width: 3),
                Text('pro'.tr, style: context.heading.small.overrideWith(color: proBlue)),
              ]),
            ),
            const SizedBox(width: Dimensions.paddingSmall),
            Flexible(
              child: Text(discountText, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: context.heading.large
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),
          Flexible(
            child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: context.body.small
            ),
          ),
        ]),
      ),
    );
  }
}

void _showOfferSheet(BuildContext context, Widget sheet) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}

class _OfferDetailSheet extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String message;
  final Color accentColor;
  final String icon;
  final CouponModel? coupon;
  final bool isPro;

  const _OfferDetailSheet({
    required this.title, required this.message, required this.accentColor, required this.icon,
    this.subTitle, this.coupon, this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color hint = context.textBaseMedium;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingSmall, Dimensions.paddingLarge, Dimensions.paddingLarge),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                Center(child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                  decoration: BoxDecoration(color: context.bgNeutralMedium, borderRadius: BorderRadius.circular(10)),
                )),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    height: 48, width: 48, alignment: Alignment.center,
                    decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    child: isPro
                        ? Icon(Icons.star_rounded, color: context.primary, size: 26)
                        : CustomAssetImageWidget(icon, height: 24, width: 24, color: const Color(0xFF1F2A44)),
                  ),
                  const SizedBox(width: Dimensions.paddingDefault),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: context.heading.extraLarge),
                    if (subTitle != null && subTitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subTitle!, style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                      ),
                    ],
                  ])),
                  const SizedBox(width: 30),
                ]),

                const SizedBox(height: Dimensions.paddingDefault),
                Text(message, style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium)),

                if (coupon != null) ...[
                  const SizedBox(height: Dimensions.paddingLarge),
                  Text('coupon_code'.tr, style: context.subHeading.small.overrideWith(fontWeight: AppWeight.semiBold),
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),
                  _CouponCodeBox(code: coupon!.code ?? '', accent: context.primary),
                  const SizedBox(height: Dimensions.paddingDefault),
                  if ((coupon!.minPurchase ?? 0) > 0) _detailRow(context, 'min_order'.tr, PriceConverter.convertPrice(coupon!.minPurchase)),
                  if ((coupon!.maxDiscount ?? 0) > 0) _detailRow(context, 'max_discount'.tr, PriceConverter.convertPrice(coupon!.maxDiscount)),
                  if ((coupon!.expireDate ?? '').isNotEmpty) _detailRow(context, 'valid_till'.tr, coupon!.expireDate!.split(' ').first),
                ],
              ]),
            ),
          ),

          Positioned(
            top: Dimensions.paddingDefault,
            right: Dimensions.paddingDefault,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                decoration: BoxDecoration(color: context.bgNeutralLight, shape: BoxShape.circle),
                child: Icon(Icons.close, size: 18, color: hint),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(label, style: context.subHeading.small.overrideWith(color: context.textBaseMedium)),
        const Spacer(),
        Text(value, style: context.subHeading.small,
        ),
      ]),
    );
  }
}

class _CouponCodeBox extends StatelessWidget {
  final String code;
  final Color accent;

  const _CouponCodeBox({required this.code, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(code, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: context.heading.large,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),
        InkWell(
          onTap: () {
            if (code.isEmpty) return;
            Clipboard.setData(ClipboardData(text: code));
            showCustomSnackBar('coupon_code_copied'.tr, isError: false);
          },
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.copy_rounded, size: 16, color: accent),
              const SizedBox(width: 4),
              Text('copy'.tr.toUpperCase(), style: context.subHeading.defaultSize.overrideWith(color: context.primary)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _RestaurantCategoryTabs extends StatefulWidget {
  final List<RestaurantCategoryItem> categories;
  final bool hasMostPopular;
  final bool hasBogoOffers;
  final ValueNotifier<int> activeNotifier;
  final void Function(int index) onTabTap;

  const _RestaurantCategoryTabs({required this.categories, required this.hasMostPopular, required this.hasBogoOffers, required this.activeNotifier, required this.onTabTap});

  @override
  State<_RestaurantCategoryTabs> createState() => _RestaurantCategoryTabsState();
}

class _RestaurantCategoryTabsState extends State<_RestaurantCategoryTabs> {
  final ScrollController _tabScrollController = ScrollController();
  final Map<int, GlobalKey> _tabKeys = {};
  final GlobalKey _containerKey = GlobalKey();
  int _lastActive = -1;

  GlobalKey _tabKey(int index) => _tabKeys.putIfAbsent(index, () => GlobalKey());

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveTab(int index) {
    if (!_tabScrollController.hasClients) return;
    final RenderBox? tabBox = _tabKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (tabBox == null || containerBox == null || !tabBox.attached || !containerBox.attached) return;

    final double tabContentLeft = _tabScrollController.offset + (tabBox.localToGlobal(Offset.zero).dx - containerBox.localToGlobal(Offset.zero).dx);
    final double target = (tabContentLeft + tabBox.size.width / 2 - _tabScrollController.position.viewportDimension / 2)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);
    _tabScrollController.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> tabIndices = [
      if (widget.hasMostPopular) 0,
      if (widget.hasBogoOffers) 1,
      for (int i = 0; i < widget.categories.length; i++) 2 + i,
    ];

    return Center(child: Container(
      key: _containerKey,
      width: Dimensions.webMaxWidth, height: 44,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 1, offset: Offset(0, 1))],
      ),
      child: tabIndices.isEmpty ? const SizedBox() : ValueListenableBuilder<int>(
        valueListenable: widget.activeNotifier,
        builder: (context, activeIndex, _) {
          if (_lastActive != activeIndex) {
            _lastActive = activeIndex;
            WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _scrollToActiveTab(activeIndex); });
          }
          return ListView.builder(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tabIndices.length,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            itemBuilder: (context, i) {
              final int index = tabIndices[i];
              final bool selected = index == activeIndex;
              final String label = index == 0 ? 'recommended'.tr : index == 1 ? 'bogo'.tr : (widget.categories[index - 2].name ?? '');
              return InkWell(
                key: _tabKey(index),
                onTap: () => widget.onTabTap(index),
                child: Container(height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 3,
                      color: selected ? context.primary : Colors.transparent))),
                  child: Text('  $label  ', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: selected ? context.heading.large.overrideWith(color: context.primary) : context.heading.large.overrideWith(color: context.textBaseMedium, fontWeight: AppWeight.medium),
                  ),
                ),
              );
            },
          );
        },
      ),
    ));
  }
}

class _MostPopularSection extends StatelessWidget {
  final List<Product> products;
  const _MostPopularSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double cardWidth = isDesktop ? 190 : 147;
    final int count = products.length > 10 ? 10 : products.length;
    return Container(width: double.infinity, color: context.surfaceContainer,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingLarge),
        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Text('recommended'.tr, style: context.heading.extraLarge)),
        const SizedBox(height: Dimensions.paddingDefault),
        GetBuilder<FavouriteController>(builder: (favouriteController) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(count, (index) => Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingDefault, bottom: 5),
              child: VerticalFoodCardWidget(product: products[index], width: cardWidth,),
            ))),
          );
        }),
        const SizedBox(height: Dimensions.paddingSmall),
      ]),
    );
  }
}

class _SectionSeparator extends StatelessWidget {
  const _SectionSeparator();

  @override
  Widget build(BuildContext context) => Container(height: 3, color: context.outline);
}

class _BogoOfferSection extends StatelessWidget {
  final List<RestaurantBogoOfferModel> offers;
  final int? restaurantId;
  const _BogoOfferSection({super.key, required this.offers, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();
    return Container(width: double.infinity, color: context.surfaceContainer,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingLarge),
        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
            child: Text('bogo'.tr, style: context.heading.extraLarge)),
        const SizedBox(height: Dimensions.paddingDefault),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          itemCount: offers.length,
          separatorBuilder: (context, index) => Divider(height: Dimensions.paddingExtraLarge),
          itemBuilder: (context, index) => _BogoOfferRowCard(item: offers[index], restaurantId: restaurantId),
        ),
        const SizedBox(height: Dimensions.paddingSmall),
      ]),
    );
  }
}

class _BogoOfferRowCard extends StatelessWidget {
  final RestaurantBogoOfferModel item;
  final int? restaurantId;
  const _BogoOfferRowCard({required this.item, required this.restaurantId});

  void _openBottomSheet(BuildContext context) {
    if (item.bundle.bundleId == null) return;
    BogoOfferDetailsBottomSheet.show(
      context,
      bundle: item.bundle, offerLabel: item.offer.offerLabel, validUntil: item.offer.validUntil, remainingUses: item.offer.remainingUses,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double price = item.bundle.finalPrice ?? 0;
    final double? originalPrice = item.bundle.bundlePrice;
    final bool hasDiscount = originalPrice != null && originalPrice > price;
    final double discountPercentage = item.bundle.discountPercentage ?? 0;
    final List<String> thumbnails = (item.bundle.itemThumbnails ?? []).whereType<String>().toList();

    return InkWell(
      onTap: () => _openBottomSheet(context),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (item.offer.offerLabel != null && item.offer.offerLabel!.isNotEmpty)
              Text(item.offer.offerLabel!, style: context.heading.small.medium.overrideWith(color: context.textInfosMedium)),
            const SizedBox(height: Dimensions.padding2xSmall),

            Text(item.offer.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
            const SizedBox(height: Dimensions.paddingSmall),

            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Dimensions.paddingSmall,
              runSpacing: Dimensions.padding2xSmall,
              children: [
                Text(PriceConverter.convertPrice(price), style: context.heading.large.overrideWith(color: context.primary), textDirection: TextDirection.ltr),

                if (hasDiscount) Text(
                  PriceConverter.convertPrice(originalPrice),
                  textDirection: TextDirection.ltr,
                  style: context.body.defaultSize.regular.overrideWith(color: context.primary).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: context.primary,
                  ),
                ),
              ],
            ),

            if (discountPercentage > 0) Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
              child: OfferBadgeWidget(
                text: '${discountPercentage.toStringAsFixed(discountPercentage % 1 == 0 ? 0 : 1)}% ${'off'.tr}',
                icon: Images.percentTag,
              ),
            ),

            if (item.offer.validUntil != null) ...[
              const SizedBox(height: Dimensions.padding2xSmall),
              Text('${'valid_until'.tr} : ${item.offer.validUntil}', style: context.body.small.overrideWith(color: context.textBaseMedium)),
            ],
          ]),
        ),
        const SizedBox(width: Dimensions.paddingDefault),

        SizedBox(width: 100, height: 100, child: Stack(clipBehavior: Clip.none, children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: context.outline),
            ),
            child: _BogoThumbnailGrid(thumbnails: thumbnails),
          ),
          Positioned(right: 5, bottom: 5, child: _BogoQuantityButton(item: item, restaurantId: restaurantId)),
        ])),
      ]),
    );
  }
}

class _BogoThumbnailGrid extends StatelessWidget {
  final List<String> thumbnails;
  const _BogoThumbnailGrid({required this.thumbnails});

  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    if (thumbnails.isEmpty) {
      return Center(child: CustomAssetImageWidget(Images.bogoOfferIcon, height: 28, width: 28));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final double height = constraints.maxHeight;
      final double halfWidth = (width - _gap) / 2;
      final double halfHeight = (height - _gap) / 2;

      if (thumbnails.length == 1) {
        return _tile(thumbnails[0], width, height);
      }

      if (thumbnails.length == 2) {
        return Row(children: [
          _tile(thumbnails[0], halfWidth, height),
          const SizedBox(width: _gap),
          _tile(thumbnails[1], halfWidth, height),
        ]);
      }

      if (thumbnails.length == 3) {
        return Row(children: [
          _tile(thumbnails[0], halfWidth, height),
          const SizedBox(width: _gap),
          Column(children: [
            _tile(thumbnails[1], halfWidth, halfHeight),
            const SizedBox(height: _gap),
            _tile(thumbnails[2], halfWidth, halfHeight),
          ]),
        ]);
      }

      final int remaining = thumbnails.length - 4;
      return Column(children: [
        Row(children: [
          _tile(thumbnails[0], halfWidth, halfHeight),
          const SizedBox(width: _gap),
          _tile(thumbnails[1], halfWidth, halfHeight),
        ]),
        const SizedBox(height: _gap),
        Row(children: [
          _tile(thumbnails[2], halfWidth, halfHeight),
          const SizedBox(width: _gap),
          remaining > 0
              ? _remainingTile(context, thumbnails[3], halfWidth, halfHeight, remaining)
              : _tile(thumbnails[3], halfWidth, halfHeight),
        ]),
      ]);
    });
  }

  Widget _tile(String image, double width, double height) {
    return SizedBox( width: width, height: height, child: CustomImageWidget(image: image, fit: BoxFit.cover, isFood: true));
  }

  Widget _remainingTile(BuildContext context, String image, double width, double height, int remaining) {
    return SizedBox(width: width, height: height, child: Stack(fit: StackFit.expand, children: [
      _tile(image, width, height),
      ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
      Center(child: Text(
        '+$remaining',
        style: context.heading.small.strong.overrideWith(color: Colors.white),
        textDirection: TextDirection.ltr,
      )),
    ]));
  }
}

class _BogoQuantityButton extends StatelessWidget {
  final RestaurantBogoOfferModel item;
  final int? restaurantId;
  const _BogoQuantityButton({required this.item, required this.restaurantId});

  int? get _restaurantId => item.bundle.restaurant?.id ?? restaurantId;

  bool _reachedLimit(int quantity) {
    int? limit = item.offer.remainingUses;
    return limit != null && quantity >= limit;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int? restaurantId = _restaurantId;
      CartModel? cartItem = cartController.findBogoBundleInCart(item.bundle.bundleId, restaurantId: restaurantId);
      int quantity = cartItem?.quantity ?? 0;
      bool canStep = cartItem != null && restaurantId != null && !cartController.isLoading;

      return QuantityStepperWidget(
        quantity: quantity,
        buttonSize: 32,
        iconSize: 20,
        iconColor: context.iconBaseDefault,
        decrementIcon: quantity == 1 ? CupertinoIcons.trash : Icons.remove,
        onAdd: () {
          if(item.bundle.bundleId == null || cartController.isLoading) {
            return;
          }
          cartController.addBogoToCartOnline(item.bundle.bundleId!, 1);
        },
        onDecrement: !canStep ? null : () {
          if(quantity > 1) {
            cartController.updateBogoBundleQuantity(false, cartItem, restaurantId: restaurantId);
          } else {
            cartController.removeBogoBundle(cartItem, restaurantId: restaurantId);
          }
        },
        onIncrement: !canStep ? null : () {
          if(_reachedLimit(quantity)) {
            showCustomSnackBar('you_can_only_use_this_offer_more_times'.trParams({'limit': '${item.offer.remainingUses}'}));
            return;
          }
          cartController.updateBogoBundleQuantity(true, cartItem, restaurantId: restaurantId);
        },
      );
    });
  }
}

class _CategoryHeader extends StatelessWidget {
  final String name;
  const _CategoryHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, Dimensions.paddingLarge, Dimensions.paddingDefault, 0),
      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.extraLarge),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SquareIconButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceContainer,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      elevation: 1.5, shadowColor: context.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault), onTap: onTap,
        child: SizedBox(height: 36, width: 36, child: Center(child: child)),
      ),
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBg;
  const _SoftIconButton({required this.icon, required this.onTap, this.showBg = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: showBg ? context.surfaceContainerLowest : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: Padding(padding: EdgeInsets.all(Dimensions.padding2xSmall), child: InkWell(borderRadius: BorderRadius.circular(10), onTap: onTap, child: Icon(icon, size: 24))),
    );
  }
}


class _AnnouncementBar extends StatefulWidget {
  final String message;
  const _AnnouncementBar({required this.message});

  @override
  State<_AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<_AnnouncementBar> {
  bool _expanded = false;
  static const double _buttonSize = 40;
  static const double _pillHeight = 40;

  bool _overflows(double maxWidth) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: widget.message, style: context.body.defaultSize.overrideWith(color: context.textBaseMedium),),
      maxLines: 1, textDirection: Directionality.of(context),
    )..layout();
    return painter.width > maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double fullPillWidth = (constraints.maxWidth ).clamp(0.0, constraints.maxWidth);
      final double innerWidth = fullPillWidth  - Dimensions.paddingDefault - Dimensions.paddingSmall;
      final double pillWidth = _expanded ? fullPillWidth : _buttonSize;
      final bool useMarquee = innerWidth > 0 && _overflows(innerWidth);

      return SizedBox(
        height: _buttonSize,
        child: Stack(alignment: AlignmentDirectional.centerEnd, clipBehavior: Clip.none, children: [
          PositionedDirectional(
            end: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
              width: pillWidth, height: _pillHeight, clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(_pillHeight / 2),
                boxShadow: [BoxShadow(color: context.shadow, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: !_expanded ? const SizedBox() : Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: Dimensions.paddingDefault,
                  end: 50,
                ),
                child: useMarquee ? Marquee(
                  text: widget.message,
                  style: context.body.defaultSize.overrideWith(color: context.textBaseMedium),
                  blankSpace: 40, velocity: 40, pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 0, accelerationDuration: const Duration(milliseconds: 500),
                  decelerationDuration: const Duration(milliseconds: 500),
                ) : Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(widget.message, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: context.body.defaultSize.overrideWith(color: context.textBaseMedium),
                    )
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            customBorder: const CircleBorder(),
            child: Container(
              height: _buttonSize, width: _buttonSize, alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF9A826), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: context.shadow, blurRadius: 8, offset: const Offset(0, 2))]),
              child: Transform.flip(
                flipX: true,
                child: CustomAssetImageWidget(Images.announcement, height: 16, width: 16, color: context.iconWarningOn),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

class _PreviousOrdersBanner extends StatelessWidget {
  final int restaurantId;
  const _PreviousOrdersBanner({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    if (!AuthHelper.isLoggedIn() || !(Get.find<SplashController>().configModel?.repeatOrderOption ?? false)) {
      return const SizedBox.shrink();
    }
    return GetBuilder<OrderController>(builder: (orderController) {
      final List<LatestOrderModel> orders = orderController.restaurantLastOrders ?? [];
      if (orders.isEmpty) return const SizedBox.shrink();
      final int count = orderController.restaurantLastOrdersPageSize ?? orders.length;

      return Container(
        color: context.surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
        child: InkWell(
          onTap: () => _showPreviousOrdersSheet(context),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall + 2),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: context.primary.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(children: [
              Icon(Icons.receipt_long_outlined, size: 20, color: context.primary),
              const SizedBox(width: Dimensions.paddingSmall),
              Expanded(child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$count ', style: context.heading.large.overrideWith(color: context.primary)),
                  TextSpan(text: 'previous_orders_in_this_restaurant'.tr, style: context.heading.large.overrideWith(color: context.textBaseDefault, fontWeight: AppWeight.regular)),
                ]),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(width: Dimensions.paddingSmall),
              Icon(Icons.chevron_right, size: 22, color: context.primary),
            ]),
          ),
        ),
      );
    });
  }

  void _showPreviousOrdersSheet(BuildContext context) {
    PreviousOrdersBottomSheetWidget.show(context, restaurantId: restaurantId);
  }
}

class _ViewCartButton extends StatelessWidget {
  final int restaurantId;
  final bool fromDineIn;
  const _ViewCartButton({required this.restaurantId, required this.fromDineIn});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      final int itemCount = cartController.cartList(restaurantId).length;
      return Center(
        child: SizedBox(
          height: GetPlatform.isIOS ? 100 : 70, width: Get.width,
          child: CustomButtonWidget(
            buttonText: '${'view_cart'.tr} ${'items'.tr} ($itemCount)', takeMinimumWidth: true, height: 40, radius: Dimensions.radiusMedium,
            fontSize: Dimensions.fontSizeDefault,
            onPressed: () async {
              await Get.toNamed(RouteHelper.getCartRoute(fromDineIn: fromDineIn, restaurantId: restaurantId));
              // Get.find<RestaurantController>().makeEmptyRestaurant();
              Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
            },
          ),
        ),
      );
    });
  }
}

class _BackToTopButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _BackToTopButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top + 70 + 44 + 12;
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: GetBuilder<RestaurantController>(
        builder: (restaurantController) {
          return restaurantController.restaurant == null ? SizedBox() : IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, -0.6),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: CustomInkWellWidget(
                      radius: 99,
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: context.surfaceContainer, width: 1),
                            boxShadow: [BoxShadow(color: context.shadow, blurRadius: 12, offset: Offset(0, 4))],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('back_to_top'.tr,
                                style: context.heading.small.overrideWith(color: context.theme.cardColor)
                            ),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Icon(Icons.arrow_upward_outlined, size: 18, color: context.surfaceContainer),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _TabBarDelegate({required this.child, this.height = 44});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => oldDelegate.height != height || oldDelegate.child != child;
}

class _BrowseMenuButton extends StatefulWidget {
  final int categoryCount;
  final VoidCallback onTap;

  const _BrowseMenuButton({
    required this.categoryCount,
    required this.onTap,
  });

  @override
  State<_BrowseMenuButton> createState() => _BrowseMenuButtonState();
}

class _BrowseMenuButtonState extends State<_BrowseMenuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: primary.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: primary.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 17,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'menu'.tr.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.categoryCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}