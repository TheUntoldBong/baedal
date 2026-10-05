import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/all_result_widget.dart';
import 'package:stackfood_multivendor/features/search/widgets/item_view_widget.dart';

class SearchResultView extends StatefulWidget {
  final String searchText;
  final TabController tabController;
  const SearchResultView({super.key, required this.searchText, required this.tabController});

  @override
  SearchResultViewState createState() => SearchResultViewState();
}

class SearchResultViewState extends State<SearchResultView> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    search.SearchController searchController = Get.find<search.SearchController>();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && searchController.totalSize != null && searchController.pageOffset != null) {
        int totalPage = (searchController.totalSize! / 10).ceil();
        if(searchController.pageOffset! < totalPage){
          searchController.searchData(searchController.searchText, searchController.pageOffset!+1);
          searchController.pageOffset = searchController.pageOffset!+1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      return Padding(
        padding: EdgeInsets.only(bottom: cartController.cartBundleList.isNotEmpty ? 70 : 0),
        child: TabBarView(
          controller: widget.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            AllResultWidget(scrollController: scrollController, tabController: widget.tabController, onSeeAllFood: () => widget.tabController.animateTo(1)),
            ItemViewWidget(isRestaurant: false, scrollController: scrollController, tabController: widget.tabController),
            ItemViewWidget(isRestaurant: true, scrollController: scrollController, tabController: widget.tabController),
          ],
        ),
      );
    });
  }
}
