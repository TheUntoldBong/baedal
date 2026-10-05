import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_icon_button.dart';
import 'package:stackfood_multivendor/common/widgets/filter/domain/models/filter_additional_data_model.dart';
import 'package:stackfood_multivendor/common/widgets/filter/public_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CategoryProductScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryProductScreen({super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryProductScreenState createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController restaurantScrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  TabController? _tabController;
  int currentPageIndex = 0;

  static const Duration _searchSwapDuration = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: currentPageIndex, vsync: this);
    _tabController?.addListener((){
      setState(() => currentPageIndex = _tabController?.index ?? 0);
    });
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryProductList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          debugPrint('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryProductList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, false,
          );
        }
      }
    });
    restaurantScrollController.addListener(() {
      if (restaurantScrollController.position.pixels == restaurantScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryRestaurantList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restaurantPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          debugPrint('end of the page');
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryRestaurantList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Product>? products;
      List<Restaurant>? restaurants;

      if (catController.isSearching && catController.searchProductList != null) {
        products = [];
        products.addAll(catController.searchProductList!);
      } else if(!catController.isSearching && catController.categoryProductList != null){
        products = [];
        products.addAll(catController.categoryProductList!);
      }
      if (catController.isSearching  && catController.searchRestaurantList != null) {
        restaurants = [];
        restaurants.addAll(catController.searchRestaurantList!);
      } else if(!catController.isSearching && catController.categoryRestaurantList != null){
        restaurants = [];
        restaurants.addAll(catController.categoryRestaurantList!);
      }

      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async{
          if(catController.isSearching) {
            toggleSearch();
          }else {}
        },
        child: Scaffold(
          appBar: AppBar(
            title: AnimatedSwitcher(
              duration: _searchSwapDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final bool isField = child.key == const ValueKey('category_search_field');
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(isField ? 0.18 : -0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: catController.isSearching
                  ? _buildSearchField(context, catController)
                  : Text(widget.categoryName, key: const ValueKey('category_title'), style: context.heading.large.medium),
            ),
            leadingWidth: 40,
            leading: Padding(
              padding: EdgeInsets.only(left: Dimensions.paddingSmall),
              child: IconButton(
                  onPressed: () {
                  if(catController.isSearching) {
                    toggleSearch();
                  }else {
                    Get.back();
                  }
                },
                icon: Icon(Icons.arrow_back, size: 22, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            backgroundColor: context.surfaceContainer,
            elevation: 0,
            surfaceTintColor: context.surfaceContainer,
            shadowColor: Theme.of(context).shadowColor,
            actions: [
              IconButton(
                onPressed: () => toggleSearch(),
                icon: AnimatedSwitcher(
                  duration: _searchSwapDuration,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: catController.isSearching
                      ? Icon(Icons.close_sharp, key: const ValueKey('search_close'), color: context.textBaseDefault)
                      : Icon(CupertinoIcons.search, key: const ValueKey('search_open'), color: context.primary),
                ),
              ),

              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartBundleListRoute()),
                icon: CartWidget(icon: Icons.shopping_cart_outlined, color: context.primary, size: 25),
              ),
              const SizedBox(width: Dimensions.paddingSmall,),
            ],
          ),
          body: Column(children: [
            ((catController.subCategoryList?.isNotEmpty ?? false) && !catController.isSearching) ? Container(
              height: 50, width: Dimensions.webMaxWidth, color: context.surfaceContainer,
              child: Center(
                child: SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: catController.subCategoryList!.length,
                    padding: const EdgeInsets.only(left: Dimensions.paddingLarge),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium, vertical: Dimensions.padding2xSmall),
                          margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusOverLarge),
                            color: index == catController.subCategoryIndex ? context.theme.primaryColor : context.theme.disabledColor,
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              catController.subCategoryList![index].name!,
                              style: index == catController.subCategoryIndex
                                  ? context.subHeading.small.medium.overrideWith(color: context.theme.cardColor)
                                  : context.subHeading.small.regular,
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ) : const SizedBox(),

            Container(
              width: Dimensions.webMaxWidth,
              color: context.surfaceContainer,
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingLarge,
                Dimensions.paddingDefault,
                Dimensions.paddingLarge,
                0,
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Expanded(child: (currentPageIndex == 1 ? restaurants == null : products == null) ? const SizedBox.shrink() : Text(
                  '${currentPageIndex == 1 ? (catController.restaurantPageSize ?? 0) : (catController.pageSize ?? 0)} ${(currentPageIndex == 1 ? 'restaurants' : 'items').tr}',
                  style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
                )),
                _buildTabToggleButton(context, label: 'items'.tr, index: 0),
                const SizedBox(width: Dimensions.paddingSmall),
                _buildTabToggleButton(context, label: 'restaurant'.tr, index: 1),
                const SizedBox(width: Dimensions.paddingSmall),

                CustomIconButton(onPressed: () => _openFilterSheet(catController), image: Images.sortIcon, size: 20),
              ]),
            ),
            Divider(thickness: 1, height: 1),

            Expanded(child: NotificationListener(
              onNotification: (dynamic scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  if((_tabController!.index == 1 && !catController.isRestaurant) || _tabController!.index == 0 && catController.isRestaurant) {
                    final String categoryId = catController.subCategoryIndex == 0
                        ? widget.categoryID ?? ''
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString();
                    if(catController.isSearching) {
                      catController.setRestaurant(_tabController!.index == 1);
                      catController.searchData(catController.searchText, categoryId, );
                    } else {
                      if(_tabController!.index == 1) {
                        catController.getCategoryRestaurantListSilently(categoryId, );
                      } else {
                        catController.getCategoryProductListSilently(categoryId,);
                      }
                    }
                  }
                }
                return false;
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: SizedBox(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ProductViewWidget(
                                isRestaurant: false, products: products, restaurants: null, noDataText: 'no_category_food_found'.tr,
                                padding: EdgeInsets.all(Dimensions.paddingDefault),
                              ),

                              catController.isLoading ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(context.primary)),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: restaurantScrollController,
                    child: SizedBox(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ProductViewWidget(
                                isRestaurant: true, products: null, restaurants: restaurants, noDataText: 'no_category_restaurant_found'.tr,
                                padding: EdgeInsets.all(Dimensions.paddingDefault),
                              ),

                              catController.isLoading ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSmall),
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(context.primary)),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ]),
        ),
      );
    });
  }

  Widget _buildSearchField(BuildContext context, CategoryController catController) {
    return Container(
      key: const ValueKey('category_search_field'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        border: Border.all(color: context.outlineVariant),
      ),
      child: Row(children: [
        Icon(Icons.search, size: 18, color: context.iconBaseMedium),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(
          child: TextField(
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: context.body.defaultSize.regular,
            cursorColor: context.primary,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'search_here'.tr,
              hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            ),
            onSubmitted: (String query) => catController.searchData(
              query, catController.subCategoryIndex == 0 ? widget.categoryID
                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
            ),
          ),
        ),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchTextController,
          builder: (context, value, _) => value.text.isEmpty ? const SizedBox() : InkWell(
            onTap: () {
              _searchTextController.clear();
              _searchFocusNode.requestFocus();
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 16, color: context.iconBaseMedium),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabToggleButton(BuildContext context, {required String label, required int index}) {
    final bool isSelected = currentPageIndex == index;
    return InkWell(
      onTap: () => _tabController?.animateTo(index),
      overlayColor: WidgetStateProperty.all(context.primary.withValues(alpha: 0.1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        child: Container(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
              color: isSelected ? context.textBaseDefault : Colors.transparent, width: 3,
            )),
          ),
          child: Text(label, style: isSelected
              ? context.heading.defaultSize
              : context.heading.defaultSize.copyWith(color: context.textBaseMedium)),
        ),
      ),
    );
  }

  void _openFilterSheet(CategoryController catController) {
    showFilterBottomSheetOrDialog(
      context, currentPageIndex == 1, filterAdditionalDataModel: FilterAdditionalDataModel(
        showPriceWidget: currentPageIndex == 0,
        callback: (data){
          data.mirrorSelections(fromRestaurant: currentPageIndex == 1);
          catController.setFilterDataModel(data);
          catController.setOffset(1);
          String? categoryid = catController.subCategoryIndex == 0 ? widget.categoryID
              : catController.subCategoryList![catController.subCategoryIndex].id.toString();
          if(catController.isSearching){
            catController.searchData(catController.searchText, categoryid);
          }else{
            catController.isRestaurant ?
                catController.getCategoryRestaurantList(categoryid, catController.offset, true)
                : catController.getCategoryProductList(categoryid, catController.offset, true);
          }
        },
      ),
      filterDataModel: catController.getFilterDataModel?..isRestaurant = currentPageIndex == 1,
    );
  }

  void toggleSearch(){
    final catController = Get.find<CategoryController>();
    _searchTextController.clear();

    if(catController.isSearching) {
      if(catController.categoryRestaurantList == null || catController.categoryRestaurantList!.isEmpty){
        catController.getCategoryRestaurantListSilently(catController.subCategoryIndex == 0
            ? widget.categoryID ?? ''
            : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
        );
      }
    }
    catController.toggleSearch();
  }
}
