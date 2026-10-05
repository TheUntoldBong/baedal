import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/filter_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_offer_section_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurant_filter_button_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class AllRestaurantFilterWidget extends StatefulWidget {
  const AllRestaurantFilterWidget({super.key, });

  static const List<(String, String)> _tabs = [
    ('all', 'all'),
    ('latest', 'newly_joined'),
    ('near_by_restaurants', 'nearby'),
    ('top_rated', 'top_rated'),
    ('popular', 'popular'),
  ];

  @override
  State<AllRestaurantFilterWidget> createState() => _AllRestaurantFilterWidgetState();
}

class _AllRestaurantFilterWidgetState extends State<AllRestaurantFilterWidget> {
  final ScrollController _tabScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = List.generate(AllRestaurantFilterWidget._tabs.length, (_) => GlobalKey());

  int _tabTapToken = 0;

  static const double _revealMargin = Dimensions.paddingLarge + Dimensions.paddingDefault;

  static const double _revealMsPerPixel = 1.9;
  static const int _minRevealMs = 260;
  static const int _maxRevealMs = 620;

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> _revealTab(int index) async {
    final BuildContext? tabContext = _tabKeys[index].currentContext;
    if(tabContext == null || !_tabScrollController.hasClients) {
      return;
    }
    final RenderObject? tabObject = tabContext.findRenderObject();
    if(tabObject == null || !tabObject.attached) {
      return;
    }
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(tabObject);
    if(viewport == null) {
      return;
    }

    final ScrollPosition position = _tabScrollController.position;
    final double atLeadingEdge = viewport.getOffsetToReveal(tabObject, 0).offset;
    final double atTrailingEdge = viewport.getOffsetToReveal(tabObject, 1).offset;

    double target;
    if(position.pixels > atLeadingEdge) {
      target = atLeadingEdge - _revealMargin;
    } else if(position.pixels < atTrailingEdge) {
      target = atTrailingEdge + _revealMargin;
    } else {
      return;
    }

    final double destination = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    final int travelMs = ((destination - position.pixels).abs() * _revealMsPerPixel).round();

    await _tabScrollController.animateTo(
      destination,
      duration: Duration(milliseconds: travelMs.clamp(_minRevealMs, _maxRevealMs)),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(
      builder: (restaurantController) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            constraints: BoxConstraints(maxWidth: Dimensions.webMaxWidth),
            child: Row(children: [
              Expanded(child: SizedBox(
                height: OfferSection.buttonHeight,
                child: ListView.separated(
                  controller: _tabScrollController,
                  scrollDirection: Axis.horizontal, shrinkWrap: true,
                  itemCount: AllRestaurantFilterWidget._tabs.length,
                  separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
                  itemBuilder: (context, index) {
                    final (value, labelKey) = AllRestaurantFilterWidget._tabs[index];
                    return RestaurantsFilterButtonWidget(
                      key: _tabKeys[index],
                      buttonText: labelKey.tr,
                      onTap: () async {
                        final int tapToken = ++_tabTapToken;
                        restaurantController.setExploreTab(value, loadRestaurants: false);
                        await _revealTab(index);
                        if(!mounted || tapToken != _tabTapToken) {
                          return;
                        }
                        restaurantController.getRestaurantList(1, true);
                      },
                      isSelected: restaurantController.activeExploreTab == value,
                    );
                  },
                ),
              )),
              SizedBox(width: Dimensions.paddingMedium,),
              const FilterViewWidget(),
            ]),
          ),
        );
      }
    );
  }
}
