part of '../screens/search_screen.dart';

class _SearchInitialView extends StatelessWidget {
  const _SearchInitialView({
    required this.searchController, required this.searchTextEditingController,
    required this.scrollController, required this.isLoggedIn, required this.historyDisplayCount, required this.onHistoryDisplayCountChanged,
    required this.cuisineShimmerMinElapsed,
  });
  final search.SearchController searchController;
  final TextEditingController searchTextEditingController;
  final ScrollController scrollController;
  final bool isLoggedIn;
  final int historyDisplayCount;
  final ValueChanged<int> onHistoryDisplayCountChanged;
  final bool cuisineShimmerMinElapsed;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        child: Container(
          color: context.surfaceContainer,
          child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            const SizedBox(height: Dimensions.paddingSmall),
            searchController.curatedHistoryList.isNotEmpty ? Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                searchController.curatedHistoryList.isEmpty ? Shimmer(child: Container(width: 130, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                 : Expanded(child: Text('recent_search'.tr, style: context.heading.extraLarge)),

                InkWell(
                  onTap: () => searchController.clearSearchAddress(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: 4),
                    child: Text(
                      'clear_all'.tr,
                      style: context.heading.defaultSize.overrideWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ]),
            ) : const SizedBox.shrink(),

            SizedBox(height: searchController.curatedHistoryList.isNotEmpty ? Dimensions.padding2xSmall : 0),

            SizedBox(
              child: Column(children: [
                ListView.separated(
                  itemCount: historyDisplayCount > searchController.curatedHistoryList.length ? searchController.curatedHistoryList.length : historyDisplayCount,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => SizedBox(height: Dimensions.paddingExtraSmall),
                  itemBuilder: (context, index) {
                    Map<String, dynamic> historyItem = searchController.curatedHistoryList[index];
                    String historyType = historyItem['type'] ?? 'history';
                    String query = historyItem['query'] ?? '';

                    return InkWell(
                      onTap: () {
                        searchTextEditingController.text = query;
                        searchController.searchAllData(query, nearMe: false);
                      },
                      child: SearchSuggestionListTile(
                        leading: historyType == 'history'
                            ? Icon(Icons.history, color: context.iconBaseMedium, size: 18)
                            : CustomAssetImageWidget(
                                historyType == 'restaurant' ? Images.restaurantIcon : Images.itemIcon,
                                height: 18, width: 18,
                              ),
                        titleWidget: Text(query,
                          style: context.heading.large.overrideWith(fontWeight: AppWeight.regular)
                        ),
                        trailingWidget: InkWell(
                          onTap: () => searchController.removeHistory(historyItem),
                          child: Icon(Icons.close, color: context.iconBaseMedium, size: 16),
                        ),
                      ),
                    );
                  },
                ),
                if(searchController.curatedHistoryList.length > 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingMedium),
                    child: InkWell(
                      onTap: () {
                        onHistoryDisplayCountChanged(
                          historyDisplayCount >= searchController.curatedHistoryList.length ? 5 : historyDisplayCount + 10,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            historyDisplayCount >= searchController.curatedHistoryList.length ? 'see_less'.tr : 'see_more'.tr,
                            style: context.heading.defaultSize.overrideWith(color: Theme.of(context).colorScheme.tertiary),
                          ),
                          Icon(historyDisplayCount >= searchController.curatedHistoryList.length ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.tertiary, size: Dimensions.fontSizeDefault),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),

            SizedBox(height: searchController.curatedHistoryList.isNotEmpty && isLoggedIn ? Dimensions.paddingLarge : 0),

            const SizedBox(height: Dimensions.paddingSmall),

            (searchController.trendingSearchList != null && searchController.trendingSearchList!.isEmpty) ? const SizedBox.shrink() : Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.outline, thickness: 1, height: 20),
                  SizedBox(height: Dimensions.paddingSmall),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                    child: searchController.trendingSearchList == null
                        ? Shimmer(child: Container(width: 150, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                        : Text('trending_search'.tr, style: context.heading.extraLarge),
                  ),

                  searchController.trendingSearchList == null ? Wrap(
                    alignment: WrapAlignment.start,
                    spacing: Dimensions.paddingMedium,
                    runSpacing: Dimensions.paddingMedium,
                    children: [0, 1, 2, 3, 4, 5].map((n) {
                      return Shimmer(child: Container(height: 34, width: n % 3 == 0 ? 90 : 130, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMedium), color: Theme.of(context).shadowColor)));
                    }).toList(),
                  ) : Wrap(
                    alignment: WrapAlignment.start,
                    spacing: Dimensions.paddingMedium,
                    runSpacing: Dimensions.paddingMedium,
                    children: searchController.trendingSearchList!.map((searchKey) {
                      return InkWell(
                        onTap: () {
                          searchTextEditingController.text = searchKey;
                          searchController.searchAllData(searchKey, nearMe: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                          ),
                          child: Text(searchKey, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: context.heading.defaultSize.overrideWith(fontWeight: AppWeight.regular)
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            (searchController.trendingSearchList != null && searchController.trendingSearchList!.isEmpty) ? const SizedBox.shrink() : const SizedBox(height: Dimensions.paddingSmall),
            GetBuilder<search.SearchController>(builder: (searchController) {
              bool isLoading = searchController.topCategoryModel == null;
              List<TopCategory> topCategories = searchController.topCategoryModel?.categories ?? [];
              return (!isLoading && topCategories.isEmpty) ? const SizedBox.shrink() : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.outline, thickness: 1, height: 20),
                  SizedBox(height: Dimensions.paddingSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: isLoading
                        ? Shimmer(child: Container(width: 140, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                        : Text('top_categories'.tr, style: context.heading.extraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingDefault),

                  isLoading ? SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      itemCount: 6,
                      itemBuilder: (context, index) => SizedBox(width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            Shimmer(child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).shadowColor))),
                            const SizedBox(height: Dimensions.paddingExtraSmall),
                            Shimmer(child: Container(width: 50, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                          ],
                        ),
                      ),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingExtraSmall),
                    ),
                  ) : SizedBox(
                    height: 90,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if(notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
                          searchController.loadMoreTopCategories();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        itemCount: topCategories.length + (searchController.topCategoryPaginate ? 1 : 0),
                        itemBuilder: (context, index){
                          if(index >= topCategories.length) {
                            return const SizedBox(width: 80,
                              child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                            );
                          }
                          return InkWell(
                            onTap: (){
                              Get.toNamed(RouteHelper.getCategoryProductRoute(topCategories[index].id, topCategories[index].name ?? ''));
                            },
                            child: SizedBox(width: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 5,),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.surfaceContainer, shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)],
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        '${topCategories[index].imageFullUrl}',
                                        fit: BoxFit.cover, width: 52, height: 52,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 52, height: 52,
                                            color: context.bgNeutralLight,
                                            child: const Center(child: Icon(Icons.restaurant_menu)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingExtraSmall),
                                  Text(
                                    topCategories[index].name ?? '',
                                    textAlign: TextAlign.center,
                                    style: context.heading.small.overrideWith(fontWeight: AppWeight.medium),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingExtraSmall),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingDefault),
                ],
              );
            }),

            GetBuilder<CuisineController>(builder: (cuisineController) {
              bool isLoading = cuisineController.cuisineModel == null || !cuisineShimmerMinElapsed;
              bool isEmpty = !isLoading && (cuisineController.cuisineModel!.cuisines?.isEmpty ?? true);
              return isEmpty ? const SizedBox.shrink() : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.outline, thickness: 1, height: 20),
                  SizedBox(height: Dimensions.paddingSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: isLoading
                        ? Shimmer(child: Container(width: 120, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                        : Text('top_cuisine'.tr, style: context.heading.extraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingDefault),

                  isLoading ? SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      itemCount: 6,
                      itemBuilder: (context, index) => SizedBox(width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            Shimmer(child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).shadowColor))),
                            const SizedBox(height: Dimensions.paddingExtraSmall),
                            Shimmer(child: Container(width: 50, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                          ],
                        ),
                      ),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingExtraSmall),
                    ),
                  ) : SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      itemCount: cuisineController.cuisineModel!.cuisines!.length,
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                          },
                          child: SizedBox(width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 5,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer, shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                      fit: BoxFit.cover, width: 52, height: 52,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 52, height: 52,
                                          color: context.bgNeutralLight,
                                          child: const Center(child: Icon(Icons.restaurant_menu)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingExtraSmall),
                                Text(
                                  cuisineController.cuisineModel!.cuisines![index].name!,
                                  textAlign: TextAlign.center,
                                  style: context.heading.small.overrideWith(fontWeight: AppWeight.medium),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingExtraSmall),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingDefault),
                ],
              );
            }),

            GetBuilder<search.SearchController>(builder: (searchController) {
              bool isLoading = searchController.featuredRestaurantModel == null;
              List<Restaurant> featuredRestaurants = searchController.featuredRestaurantModel?.restaurants ?? [];
              return (!isLoading && featuredRestaurants.isEmpty) ? const SizedBox.shrink() : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.outline, thickness: 1, height: 20),
                  SizedBox(height: Dimensions.paddingSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: isLoading
                        ? Shimmer(child: Container(width: 170, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                        : Text('featured_restaurants'.tr, style: context.heading.extraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingDefault),

                  isLoading ? SizedBox(
                    height: 227,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                        child: SizedBox(width: 280,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Shimmer(child: Container(width: 280, height: 140, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).shadowColor))),
                            const SizedBox(height: Dimensions.paddingSmall),
                            Shimmer(child: Container(width: 180, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                            const SizedBox(height: Dimensions.paddingExtraSmall),
                            Shimmer(child: Container(width: 120, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                          ]),
                        ),
                      ),
                    ),
                  ) : SizedBox(
                    height: 227,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if(notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
                          searchController.loadMoreFeaturedRestaurants();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        itemCount: featuredRestaurants.length + (searchController.featuredRestaurantPaginate ? 1 : 0),
                        itemBuilder: (context, index) {
                          if(index >= featuredRestaurants.length) {
                            return const Padding(
                              padding: EdgeInsets.only(right: Dimensions.paddingDefault),
                              child: SizedBox(width: 40, child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                            child: RestaurantCardWidget.detailed(restaurant: featuredRestaurants[index], width: 280),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingDefault),
                ],
              );
            }),

            const SizedBox(height: 120),

          ])),
        ),
      ),
    );
  }
}
