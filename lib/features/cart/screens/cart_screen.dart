import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_constrained_box.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_pro_banner_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_product_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_suggested_item_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/checkout_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/pricing_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/pro_benefit_banner_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/pro/controllers/pro_controller.dart';
import 'package:stackfood_multivendor/features/pro/screens/subscription_plan_screen.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/pro_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  final int restaurantId;
  const CartScreen({super.key, required this.fromNav, this.fromReorder = false, this.fromDineIn = false, required this.restaurantId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<RestaurantController>().makeEmptySuggestedItems(willUpdate: false);
    WidgetsBinding.instance.addPostFrameCallback((_){
      initCall();
    });

  }

  Future<void> initCall() async {
    Get.find<CartController>().setExpanded(false);
    Get.find<ProController>().getProActiveOffer();
    Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurantId, name: null), setNullBeforeLoad: true);
    Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<CartController>().getCartDataOnline(widget.restaurantId);
    if(Get.find<CartController>().cartList(widget.restaurantId).isNotEmpty){
      Get.find<CartController>().calculationCart(widget.restaurantId);
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      if(Get.find<CartController>().needExtraPackage){
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(widget.restaurantId);
      Get.find<RestaurantController>().getRestaurantProductList(widget.restaurantId, 1, VegType.all, false);
      showReferAndEarnSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: CartAppBarWidget(restaurantId: widget.restaurantId,  isBackButtonExist: (isDesktop || !widget.fromNav)),
      body: GetBuilder<RestaurantController>(builder: (restaurantController) {
        return GetBuilder<CartController>(builder: (cartController) {

          bool isRestaurantOpen = true;

          if(restaurantController.restaurant != null) {
            isRestaurantOpen = restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules);
          }

          bool suggestionEmpty = (restaurantController.suggestedItems != null && restaurantController.suggestedItems!.isEmpty);

          return (cartController.isLoading && widget.fromReorder) ? const Center(
            child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
          ) : cartController.cartList(widget.restaurantId).isNotEmpty ? Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: isDesktop ? const EdgeInsets.only(top: Dimensions.paddingSmall) : EdgeInsets.zero,
                          child: SizedBox(
                            child: Center(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(children: [

                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          WebConstrainedBox(
                                            dataLength: cartController.cartList(widget.restaurantId).length, minLength: 5, minHeight: suggestionEmpty ? 0.6 : 0.3,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [


                                              CustomCard(
                                                borderRadius: 0,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: Dimensions.paddingDefault,),
                                                      ListView.separated(
                                                        physics: isDesktop ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: cartController.cartList(widget.restaurantId).length,
                                                        itemBuilder: (context, index) {
                                                          final cartList = cartController.cartList(widget.restaurantId);
                                                          if (index >= cartController.addOnsList.length || index >= cartController.availableList.length) {
                                                            return const SizedBox();
                                                          }
                                                          return CartProductWidget(
                                                            cart: cartList[index], cartIndex: index, addOns: cartController.addOnsList[index],
                                                            isAvailable: cartController.availableList[index], isRestaurantOpen: isRestaurantOpen,
                                                          );
                                                        },
                                                        separatorBuilder: (BuildContext context, int index) {
                                                          return Divider(thickness: 1, height: Dimensions.paddingExtraLarge,);
                                                        },
                                                      ),

                                                      Divider(thickness: 1, height: Dimensions.paddingLarge,),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: Dimensions.paddingSmall, bottom: Dimensions.paddingDefault),
                                                        child: TextButton.icon(
                                                          style: TextButton.styleFrom(
                                                            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                                                            minimumSize: Size.zero,
                                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            visualDensity: VisualDensity.compact,
                                                          ),
                                                          onPressed: (){
                                                            if(isRestaurantOpen) {
                                                              final currentCartList = cartController.cartList(widget.restaurantId);
                                                              Get.toNamed(
                                                                RouteHelper.getRestaurantRoute(widget.restaurantId, slug: currentCartList.isEmpty ? '' : (currentCartList.first.product?.restaurantName ?? '')),
                                                                arguments: RestaurantScreen(restaurant: Restaurant(id: widget.restaurantId)),
                                                              );
                                                            } else {
                                                              Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
                                                            }
                                                          },
                                                          icon: Icon(Icons.add_circle_outline_sharp, color: context.iconInfoMedium),
                                                          label: Text(
                                                            isRestaurantOpen ? 'add_more_items'.tr : 'add_from_another_restaurants'.tr,
                                                            style: context.heading.defaultSize.overrideWith(color: context.textInfosMedium),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSmall,),

                                              CustomCard(
                                                borderRadius: 0,
                                                child: PricingViewWidget(cartController: cartController, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn, restaurantId: widget.restaurantId,),
                                              ),


                                              !isDesktop ? GetBuilder<ProController>(builder: (proController) {
                                                final Widget banner;
                                                if(ProHelper.showActiveBenefitBanner && ProHelper.activeOfferModel?.benefit?.type != null) {
                                                  banner = const ProBenefitBannerWidget();
                                                } else if(!ProHelper.showActiveBenefitBanner && ProHelper.showUnsubscribedBanner) {
                                                  banner = CartProBannerWidget(onExplore: () => _onSubscribe(context));
                                                } else {
                                                  return const SizedBox();
                                                }
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingMedium),
                                                  child: banner,
                                                );
                                              }) : const SizedBox(),

                                              !isDesktop ? CartSuggestedItemViewWidget(cartList: cartController.cartList(widget.restaurantId), restaurantId: widget.restaurantId) : const SizedBox(),
                                            ]),
                                          ),

                                        ]),
                                      ]),
                                    ),
                                  ]),

                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

              CheckoutButtonWidget(cartController: cartController, availableList: cartController.availableList, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn, restaurantId: widget.restaurantId,),

            ],
          ) : SingleChildScrollView(child: SizedBox(child: NoDataScreen(isEmptyCart: true, title: 'you_have_not_add_to_cart_yet'.tr)));
        },
        );
      }),
    );
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

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }

}