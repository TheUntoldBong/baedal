part of '../screens/search_screen.dart';

class _SearchSuggestionView extends StatelessWidget {
  const _SearchSuggestionView({required this.searchController, required this.foodsAndRestaurants, required this.searchTextEditingController, required this.isAddToCartCart, required this.onSearchTriggered});

  final search.SearchController searchController;
  final List<Map<String, dynamic>> foodsAndRestaurants;
  final TextEditingController searchTextEditingController;
  final bool isAddToCartCart;
  final VoidCallback onSearchTriggered;

  @override
  Widget build(BuildContext context) {
    String query = searchTextEditingController.text.trim();

    return Material(color: context.surfaceContainer,
      child: Column(children: [
        SizedBox(height: Dimensions.paddingDefault,),

        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: foodsAndRestaurants.isNotEmpty ? ListView.builder(
                  itemCount: foodsAndRestaurants.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    bool isRestaurant = foodsAndRestaurants[index]['isRestaurant'] ?? false;
                    String name = foodsAndRestaurants[index]['name'] ?? '';

                    return SearchSuggestionListTile(
                      titleWidget: Text.rich(
                        TextSpan(children: _highlightMatches(name, query),
                        style: context.heading.large.overrideWith(fontWeight: AppWeight.regular)),
                      ),
                      leading: CustomAssetImageWidget(
                        isRestaurant ? Images.restaurantIcon : Images.itemIcon,
                        height: 16, width: 16,
                      ),
                      onTap: () async {
                        searchTextEditingController.text = name;
                        searchController.setRestaurant(isRestaurant, willUpdate: false);
                        onSearchTriggered();
                        searchController.searchAllData(name, nearMe: false, historyType: isRestaurant ? 'restaurant' : 'food');
                      },
                    );
                  },
                ) : query.isEmpty ? Padding(
                  padding: EdgeInsets.only(top: context.height * 0.2),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const CustomAssetImageWidget(Images.emptyRestaurant),
                    const SizedBox(height: Dimensions.paddingLarge),

                    Text('no_suggestions_found'.tr, style: context.heading.extraLarge.overrideWith(color: context.textBaseMedium)),
                  ]),
                ) : const SizedBox(),
              ),
            ),
          ),
        ),

        if(query.isNotEmpty) ...[
          Divider(color: context.outlineVariant, height: 1, thickness: 1),
          SearchSuggestionListTile(
            titleWidget: Text.rich(TextSpan(children: [
              TextSpan(text: query, style: context.heading.large.strong),
              TextSpan(text: ' ${'near_me'.tr}'),
            ])),
            leading: CustomAssetImageWidget(Images.search, height: 16, width: 16, color: context.iconBaseMedium),
            onTap: () { onSearchTriggered(); searchController.searchAllData(query, nearMe: true); },
          ),
          SearchSuggestionListTile(
            titleWidget: Text.rich(TextSpan(children: [
              TextSpan(text: '${'search_for'.tr} "'),
              TextSpan(text: query, style: context.heading.large.strong),
              const TextSpan(text: '"'),
            ])),
            leading: CustomAssetImageWidget(Images.search, height: 16, width: 16, color: context.iconBaseMedium),
            onTap: () { onSearchTriggered(); searchController.searchAllData(query, nearMe: false); },
          ),
          isAddToCartCart ? SizedBox(height: 80) : SizedBox.shrink(),
        ],
      ]),
    );
  }

  List<TextSpan> _highlightMatches(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(text: text.substring(index, index + query.length), style: const TextStyle(fontWeight: FontWeight.bold)));
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}