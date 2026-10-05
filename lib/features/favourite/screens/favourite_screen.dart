import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/favourite/widgets/clear_all_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  ValueNotifier<int> currentTab = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController?.addListener((){
      currentTab.value  = _tabController?.index??0;
    });
    _initCall();
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList(fromFavScreen: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'wishlist'.tr,
        isBackButtonExist: false,
        actions: [
          ValueListenableBuilder(valueListenable: currentTab, builder: (context,value,_){
            return GetBuilder<FavouriteController>(builder: (favouriteController){
              return (_tabController!.index == 0 ? Get.find<FavouriteController>().wishProductIdList.isNotEmpty : Get.find<FavouriteController>().wishRestIdList.isNotEmpty)? TextButton(
                onPressed: (){
                  showCustomBottomSheet(child: ClearAllBottomSheet(isFood: _tabController!.index == 0));
                },
                child: Text('clear_all'.tr, style: context.body.defaultSize.medium.overrideWith(color: Theme.of(context).colorScheme.error)),
              ) :
              SizedBox();
            });
          }),
        ],
      ),
      body: Get.find<AuthController>().isLoggedIn() ? SafeArea(child: Column(children: [

        ValueListenableBuilder<int>(
          valueListenable: currentTab,
          builder: (context, value, _) => _FavouriteTabBar(
            selected: value,
            onSelected: (index) => _tabController?.animateTo(index),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: const [
            FavItemViewWidget(isRestaurant: false),
            FavItemViewWidget(isRestaurant: true),
          ],
        )),

      ])) : NotLoggedInScreen(callBack: (value){
        _initCall();
        setState(() {});
      }),
    );
  }
}

class _FavouriteTabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _FavouriteTabBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>['food'.tr, 'restaurants'.tr];

    return Container(
      width: Dimensions.webMaxWidth,
      color: context.surfaceContainer,
      child: Column(children: [

        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: List<Widget>.generate(labels.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSmall),
                child: _FavouriteTabChip(
                  label: labels[index],
                  isSelected: index == selected,
                  onTap: () => onSelected(index),
                ),
              );
            })),
          ),
        ),

        Divider(height: 1),
      ]),
    );
  }
}

class _FavouriteTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 250);

  const _FavouriteTabChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingDefault,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedDefaultTextStyle(
          duration: _duration,
          curve: Curves.easeOut,
          style: context.subHeading.small.strong.overrideWith(color: isSelected ? context.onPrimary : context.onSurface),
          child: Text(label),
        ),
      ),
    );
  }
}
