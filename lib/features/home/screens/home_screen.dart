import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/controllers/ai_chat_bot_controller.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_bot_floating_button_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/promotional_banner_overlay.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor/features/happy_hour/widgets/happy_hour_banner_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurant_filter_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurants_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_dialog_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/enjoy_off_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/featured_store_list_section.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_last_order_section_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_offer_section_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_search_bar_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_you_will_love_section.dart';
import 'package:stackfood_multivendor/features/home/widgets/quick_delivery_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/recently_ordered_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/recently_viewed_restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/recommended_for_you_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/today_trends_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/top_pick_near_you_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/what_on_your_mind_view_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/my_order_model.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/reels/controllers/reels_controller.dart';
import 'package:stackfood_multivendor/features/reels/widgets/reels_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/theme/system_ui_style.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

part '../widgets/bad_weather_widget.dart';
part '../widgets/bogo_offer_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload) async {
    Get.find<ReelsController>().getReelsList();
    Get.find<HomeController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(reload, search: '');
    Get.find<HomeController>().getCategoryCuisineList(reload);
    Get.find<AdvertisementController>().getAdvertisementList();
    Get.find<DineInController>().getDineInRestaurantList(1, reload);
    Get.find<RestaurantController>().getRecommendedRestaurantList(reload, false);
    Get.find<RestaurantController>().getTopPickRestaurantList(reload, false);
    Get.find<RestaurantController>().getQuickDeliveryRestaurantList(reload, false);
    Get.find<CampaignController>().getItemCampaignList(reload);
    Get.find<RestaurantController>().getLatestRestaurantList(reload, VegType.all, false);
    Get.find<ReviewController>().getReviewedProductList(reload, VegType.all, false);
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    Get.find<CartController>().getCartBundleList();
    Get.find<HappyHourController>().getRunningHappyHour();
    Get.find<BogoOfferController>().getBogoHomeData();
    if(AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList(fromFavScreen: true);
      await Get.find<ProfileController>().getUserInfo();
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(reload, VegType.all, false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getMyOrders(MyOrderTabType.running, 1, notify: false);
      Get.find<AddressController>().getAddressList();
      Get.find<HomeController>().getCashBackOfferList();
      if((Get.find<SplashController>().configModel?.repeatOrderOption ?? false)){
        Get.find<OrderController>().getHomeLastOrders();
      }
      Get.find<ProController>().getProActiveOffer();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {

  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

  bool _detentArmed = true;
  double _detentOffset = 0;

  final ValueNotifier<bool> _searchHeaderMerged = ValueNotifier(false);

  final ValueNotifier<double> _searchHeaderProgress = ValueNotifier(0);

  final ValueNotifier<bool> _offerBarPinned = ValueNotifier(false);

  final GlobalKey _offerGridKey = GlobalKey();

  final GlobalKey _filterKey = GlobalKey();

  final GlobalKey _whatsOnYourMindKey = GlobalKey();

  static const double _searchBarHeight = 70;

  static const double _searchHeaderRamp = 90;

  static const Duration _floatingButtonTransition = Duration(milliseconds: 220);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();
    Get.find<HomeController>().startSearchHintTimer();
    WidgetsBinding.instance.addPostFrameCallback((_){
      HomeScreen.loadData(false).then((value) {
        Get.find<SplashController>().getReferBottomSheetStatus();
        final bool showRefer = (Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false) && Get.find<SplashController>().showReferBottomSheet;

        if (showRefer) {
          Future.delayed(const Duration(milliseconds: 500), () => _showReferBottomSheet());
        }
      });
    });

    _scrollController.addListener(() {
      final double mergeAt = _detentOffset > 0 ? _detentOffset : 54;
      final bool merged = _scrollController.offset >= mergeAt - 1;
      if (_searchHeaderMerged.value != merged) {
        _searchHeaderMerged.value = merged;
      }

      _updateSearchHeaderProgress();

      _updateOfferBarVisibility();

      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchHeaderMerged.dispose();
    _searchHeaderProgress.dispose();
    _offerBarPinned.dispose();
    Get.find<HomeController>().stopSearchHintTimer();
    super.dispose();
  }

  void _updateSearchHeaderProgress() {
    final double? top = _globalTop(_whatsOnYourMindKey, withHeight: false);
    if (top == null) return;

    final double searchBottom = MediaQuery.of(context).padding.top + _searchBarHeight;
    final double remaining = top - searchBottom;
    final double progress = (1 - (remaining / _searchHeaderRamp)).clamp(0.0, 1.0);
    if (_searchHeaderProgress.value != progress) {
      _searchHeaderProgress.value = progress;
    }
  }

  void _updateOfferBarVisibility() {
    final double searchBottom = MediaQuery.of(context).padding.top + _searchBarHeight;
    final bool pinned = _offerBarPinned.value;

    final double? filterTop = _globalTop(_filterKey, withHeight: false);
    if (filterTop != null && filterTop <= searchBottom + OfferSection.collapsedHeight) {
      if (pinned) _offerBarPinned.value = false;
      return;
    }

    final double? gridBottom = _globalTop(_offerGridKey, withHeight: true);
    if (gridBottom == null) return;

    final bool shouldPin = pinned ? gridBottom < searchBottom + 16 : gridBottom <= searchBottom;
    if (pinned != shouldPin) _offerBarPinned.value = shouldPin;
  }

  double? _globalTop(GlobalKey key, {required bool withHeight}) {
    final RenderObject? object = key.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.attached) return null;
    return object.localToGlobal(Offset.zero).dy + (withHeight ? object.size.height : 0);
  }

  void _showReferBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  void _measureDetentOffset() {
    if (!_scrollController.hasClients) return;
    final double? top = _globalTop(_whatsOnYourMindKey, withHeight: false);
    if (top == null) return;
    final double searchBarBottom = MediaQuery.of(context).padding.top + _searchBarHeight;
    final double measured = _scrollController.offset + (top - searchBarBottom);
    if (measured > 0) {
      _detentOffset = measured;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_scrollController.hasClients) return false;
    final double offset = _scrollController.offset;

    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null &&
          _detentArmed && _detentOffset > 0 && offset >= _detentOffset - 1.0) {
        _detentArmed = false;
      }
    } else if (offset <= 1.0) {
      _detentArmed = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<HomeController>(builder: (homeController) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureDetentOffset());
      return GetBuilder<LocalizationController>(builder: (localizationController) {
        return Scaffold(
        backgroundColor: context.surface,
        body: Stack(children: [

          Column(children: [

          ValueListenableBuilder<double>(
            valueListenable: _searchHeaderProgress,
            builder: (context, progress, _) => Container(
              height: MediaQuery.of(context).padding.top,
              color: Color.lerp(context.surface, context.surfaceContainer, progress),
            ),
          ),

          Expanded(child: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await Get.find<ReelsController>().getReelsList();
              await Get.find<HomeController>().getBannerList(true);
              await Get.find<CategoryController>().getCategoryList(true, search: '');
              await Get.find<HomeController>().getCategoryCuisineList(true);
              Get.find<AdvertisementController>().getAdvertisementList();
              await Get.find<CampaignController>().getItemCampaignList(true);
              if(Get.find<SplashController>().configModel!.newRestaurant == 1) {
                await Get.find<RestaurantController>().getLatestRestaurantList(true, VegType.all, false);
              }
              if(Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
                await Get.find<ReviewController>().getReviewedProductList(true, VegType.all, false);
              }
              await Get.find<RestaurantController>().getRestaurantList(1, true);
              if(Get.find<AuthController>().isLoggedIn()) {
                await Get.find<ProfileController>().getUserInfo();
                await Get.find<NotificationController>().getNotificationList(true);
                await Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, VegType.all, false);
                await Get.find<RestaurantController>().getOrderAgainRestaurantList(true);
                await Get.find<OrderController>().getHomeLastOrders();
                await Get.find<ProController>().getProActiveOffer();
              }
              await Get.find<CartController>().getCartBundleList();
            },
            child: Stack(children: [

              ValueListenableBuilder<bool>(
              valueListenable: _searchHeaderMerged,
              builder: (context, merged, _) => NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: CustomScrollView(
              controller: _scrollController,
              physics: BannerDetentScrollPhysics(
                getDetent: () => _detentOffset,
                isArmed: () => _detentArmed,
              ).applyTo(const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())),
              slivers: [

                SliverAppBar(
                  pinned: true, primary: false, toolbarHeight: 0, expandedHeight: 53,
                  floating: false, elevation: 0, automaticallyImplyLeading: false,
                  backgroundColor: context.surface,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: systemUiOverlayStyleOf(context, statusBarColor: Colors.transparent),
                  flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero,
                      centerTitle: true,
                      expandedTitleScale: 1,
                      title: CustomizableSpaceBarWidget(
                        builder: (context, scrollingRate) {
                          final double t = scrollingRate.clamp(0.0, 1.0);
                          return ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 1 - t,
                              child: Opacity(
                                opacity: (1 - (t * 1.4)).clamp(0.0, 1.0),
                                child: const HomeHeaderWidget(),
                              ),
                            ),
                          );
                        },
                      )
                  ),
                  actions: const [SizedBox()],
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                    height: _searchBarHeight,
                    showDivider: true,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _searchHeaderProgress,
                      builder: (context, progress, _) => Center(
                        child: RepaintBoundary(child: HomeSearchBarWidget(progress: progress)),
                      ),
                    ),
                  ),
                ),

                _HomeScreenGap(color: context.surface, height: Dimensions.paddingMedium),
                SliverToBoxAdapter(
                  child: Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      const BannerViewWidget(),
                      SizedBox(height: Dimensions.paddingMedium,),

                      const _BadWeatherCard(),

                      KeyedSubtree(
                        key: _whatsOnYourMindKey,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _searchHeaderMerged,
                          builder: (context, merged, child) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color:  context.surfaceContainer,
                              borderRadius: merged ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                            ),
                            child: WhatOnYourMindViewWidget(merged: merged),
                          ),
                        ),
                      ),

                    ]),
                  )),
                ),

                SliverToBoxAdapter(
                  child: Center(child: Container(constraints: BoxConstraints(maxWidth: Dimensions.webMaxWidth), child: KeyedSubtree(key: _offerGridKey, child: const OfferGrid()))),
                ),

                _HomeScreenGap(height: Dimensions.paddingMedium),

                SliverToBoxAdapter(
                  child: Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      if(_isLogin && (Get.find<SplashController>().configModel?.repeatOrderOption ?? false))
                        _CardWidget(child: const HomeLastOrderSectionWidget()),

                      const QuickDeliveryWidget(),

                      _CardWidget(
                        child: _BogoOfferCard(),
                      ),

                      const FeaturedStoreListSection(),

                      const ReelsSectionWidget(),

                      const TodayTrendsViewWidget(),

                      if(_isLogin)
                        const RecentlyOrderedWidget(),

                      if(_isLogin)
                        _CardWidget(child: const RecentlyViewedRestaurantsViewWidget()),

                      if(_configModel?.mostReviewedFoods == 1)
                        const ItemYouWillLoveSection(),

                      if(_isLogin)
                        const TopPickNearYouWidget(),

                      const RecommendedForYouWidget(),

                      if(Get.find<SplashController>().configModel!.bannerData != null && Get.find<SplashController>().configModel!.bannerData!.promotionalBannerImageFullUrl != null && Get.find<SplashController>().configModel!.bannerData!.promotionalBannerImageFullUrl!.isNotEmpty) ...[
                        _CardWidget(child: const PromotionalBannerViewWidget()),
                        const SizedBox(height: Dimensions.paddingLarge),
                      ],

                      _CardWidget(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(width: double.infinity),
                          HomeSectionHeaderWidget(name: 'explore_restaurants'),
                          const SizedBox(height: Dimensions.paddingDefault, width: double.infinity),
                        ]),
                      )
                    ]),
                  )),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterHeaderDelegate(
                    color: context.surfaceContainer,
                    child: KeyedSubtree(
                      key: _filterKey,
                      child: const AllRestaurantFilterWidget(),
                    ),
                  ),
                ),


                SliverToBoxAdapter(child: Center(child: FooterViewWidget(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: Dimensions.webMaxWidth),
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingMedium,
                      bottom: Dimensions.paddingOverLarge,
                      left: Dimensions.paddingLarge,
                      right: Dimensions.paddingLarge,
                    ),
                    decoration: BoxDecoration(color: context.surfaceContainer),
                    child: AllRestaurantsWidget(scrollController: _scrollController),
                  ),
                ))),

              ],
            ))),
              Positioned(
                top: _searchBarHeight-.5, left: 0, right: 0, height: OfferSection.collapsedHeight,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _offerBarPinned,
                  builder: (context, pinned, _) => ClipRect(
                    clipper: const _BottomShadowClipRect(bottomExtra: 16),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      offset: pinned ? Offset.zero : const Offset(0, -1),
                      child: PinnedOfferBar(showShadow: pinned),
                    ),
                  ),
                ),
              ),

            ]),
          ),
        )),
        ]),

          const PromotionalBannerOverlay(child: HappyHourBannerWidget()),

        ]),

        floatingActionButton: GetBuilder<OrderController>(
          builder: (orderController) => GetBuilder<HappyHourController>(
            builder: (happyHourController) => _buildFloatingButtons(context, homeController, happyHourController) ?? const SizedBox.shrink(),
          ),
        ),

        );
      });
    });
  }

  Widget? _buildFloatingButtons(BuildContext context, HomeController homeController, HappyHourController happyHourController) {
    final orderController = Get.find<OrderController>();
    bool visibleOrderBT = orderController.runningSheetVisible;
    final bool happyHourBannerVisible = happyHourController.showHomeBanner;
    final bottomPadding = (visibleOrderBT ? OrderController.runningSheetPeek : 0.0)
        + (happyHourBannerVisible ? happyHourController.bannerHeight : 0.0);
    final bool aiEnabled = (_configModel?.aiChatStatus ?? false)
        && !(Get.isRegistered<AiChatBotController>() && Get.find<AiChatBotController>().isAiDisabled);
    final bool cashBackEnabled = AuthHelper.isLoggedIn() && homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty;

    final List<Widget> buttons = [];

    if (aiEnabled) {
      buttons.add(const AiChatBotFloatingButtonWidget());
    }
    if (cashBackEnabled) {
      buttons.add(Padding(
        padding: EdgeInsets.only(bottom: (( 0)), right: (5)),
        child: InkWell(
          onTap: () => Get.dialog(const CashBackDialogWidget()),
          child: const CashBackLogoWidget(),
        ),
      ));
    }

    if (buttons.isEmpty) {
      return null;
    }

    final bool visible = homeController.showFavButton;
    final double hiddenX = Directionality.of(context) == TextDirection.rtl ? -1.4 : 1.4;

    return AnimatedSlide(
      duration: _floatingButtonTransition,
      curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
      offset: visible ? Offset.zero : Offset(hiddenX, 0),
      child: AnimatedOpacity(
        duration: _floatingButtonTransition,
        curve: Curves.easeOut,
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const SizedBox(height: Dimensions.paddingSmall),
                  buttons[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _HomeScreenGap extends StatelessWidget {
  final Color? color;
  final double? height;
  const _HomeScreenGap({this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: Dimensions.webMaxWidth),
          color: color ?? context.surfaceContainer,
          child: SizedBox(height: height ?? Dimensions.paddingOverLarge, width: double.infinity),
        ),
      ),
    );
  }
}


class BannerDetentScrollPhysics extends ScrollPhysics {
  final double Function() getDetent;
  final bool Function() isArmed;

  const BannerDetentScrollPhysics({
    super.parent,
    required this.getDetent,
    required this.isArmed,
  });

  bool get _active => isArmed() && getDetent() > 0;

  @override
  BannerDetentScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BannerDetentScrollPhysics(
      parent: buildParent(ancestor),
      getDetent: getDetent,
      isArmed: isArmed,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (_active) {
      final double detent = getDetent();
      if (position.pixels < detent && detent < value) {
        return value - detent;
      }
      if (detent <= position.pixels && position.pixels < value) {
        return value - position.pixels;
      }
    }
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (_active) {
      final double detent = getDetent();
      final Tolerance tol = toleranceFor(position);
      if (position.pixels > 0 && position.pixels < detent) {
        final bool goDown =
            velocity > 0 || (velocity == 0 && position.pixels >= detent / 2);
        final double target = goDown ? detent : 0.0;
        if ((position.pixels - target).abs() < tol.distance &&
            velocity.abs() < tol.velocity) {
          return null;
        }
        return ScrollSpringSimulation(spring, position.pixels, target, velocity,
            tolerance: tol);
      }
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

class _BottomShadowClipRect extends CustomClipper<Rect> {
  final double bottomExtra;
  const _BottomShadowClipRect({required this.bottomExtra});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height + bottomExtra);

  @override
  bool shouldReclip(_BottomShadowClipRect oldClipper) => oldClipper.bottomExtra != bottomExtra;
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  final bool showDivider;

  SliverDelegate({required this.child, this.height = 50, this.showDivider = false});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (!showDivider) return child;
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Dimensions.webMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            boxShadow: overlapsContent ? [BoxShadow(
              color: context.shadow,
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 5),
            )] : null,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child || oldDelegate.showDivider != showDivider;
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color color;

  _FilterHeaderDelegate({
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Dimensions.webMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: overlapsContent ? Border(bottom: BorderSide(
              color: context.outline,
              width: 1,
            )) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingMedium),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => OfferSection.collapsedHeight;

  @override
  double get minExtent => OfferSection.collapsedHeight;

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.child != child;
  }
}

class _CardWidget extends StatelessWidget {
  final Widget child;
  const _CardWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceContainer,
      child: child,
    );
  }
}

