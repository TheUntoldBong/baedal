import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';


class RestaurantFilterBottomSheetWidget extends StatefulWidget {
  const RestaurantFilterBottomSheetWidget({super.key});

  @override
  State<RestaurantFilterBottomSheetWidget> createState() => _RestaurantFilterBottomSheetWidgetState();
}

class _RestaurantFilterBottomSheetWidgetState extends State<RestaurantFilterBottomSheetWidget> {
  static const List<_Option> _orderTypes = [
    _Option(value: 'delivery', label: 'delivery'),
    _Option(value: 'take_away', label: 'take_away'),
    _Option(value: 'dine_in', label: 'dine_in'),
  ];

  static const List<_Option> _preferences = [
    _Option(value: 'discount', label: 'discounted'),
    _Option(value: 'veg', label: 'veg'),
    _Option(value: 'non_veg', label: 'non_veg'),
  ];

  late Set<String> _draftTypes;
  late int _draftDiscount;
  late int _draftVeg;
  late int _draftNonVeg;

  bool _orderTypeExpanded = true;
  bool _preferencesExpanded = true;

  @override
  void initState() {
    super.initState();
    final restaurantController = Get.find<RestaurantController>();
    _draftTypes = Set.from(restaurantController.restaurantTypes);
    _draftDiscount = restaurantController.discount;
    _draftVeg = restaurantController.veg;
    _draftNonVeg = restaurantController.nonVeg;
  }

  bool get _isDefaultType => _draftTypes.length == 1 && _draftTypes.single == 'all';

  bool get _hasActiveFilter => !_isDefaultType || _draftDiscount == 1 || _draftVeg == 1 || _draftNonVeg == 1;

  bool _isPreferenceSelected(String value) {
    switch(value) {
      case 'discount': return _draftDiscount == 1;
      case 'veg': return _draftVeg == 1;
      default: return _draftNonVeg == 1;
    }
  }

  void _togglePreference(String value) {
    setState(() {
      switch(value) {
        case 'discount': _draftDiscount = _draftDiscount == 1 ? 0 : 1; break;
        case 'veg':
          _draftVeg = _draftVeg == 1 ? 0 : 1;
          if(_draftVeg == 1) {
            _draftNonVeg = 0;
          }
          break;
        default:
          _draftNonVeg = _draftNonVeg == 1 ? 0 : 1;
          if(_draftNonVeg == 1) {
            _draftVeg = 0;
          }
      }
    });
  }

  void _toggleType(String value) {
    setState(() {
      if(value == 'all') {
        _draftTypes = {'all'};
        return;
      }
      _draftTypes.remove('all');
      _draftTypes.contains(value) ? _draftTypes.remove(value) : _draftTypes.add(value);
      if(_draftTypes.isEmpty) _draftTypes = {'all'};
    });
  }

  void _resetAndClose() {
    setState(() {
      _draftTypes = {'all'};
      _draftDiscount = 0;
      _draftVeg = 0;
      _draftNonVeg = 0;
    });

    Get.find<RestaurantController>().resetFilters();
    Get.back();
  }

  void _applyAndClose() {
    Get.find<RestaurantController>().applyFilters(
      types: _draftTypes, discount: _draftDiscount, veg: _draftVeg, nonVeg: _draftNonVeg,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Stack(
      children: [
        Container(
          width: isDesktop ? 480 : double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusExtraLarge)
                : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              const SizedBox(height: Dimensions.paddingSmall),

              Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingDefault, Dimensions.paddingDefault, Dimensions.paddingSmall),
                child: Row(children: [
                  Expanded(child: Text('filter_restaurants'.tr, style: context.heading.large.strong)),
                ]),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    _SectionHeader(
                      title: 'order_type'.tr,
                      expanded: _orderTypeExpanded,
                      onTap: () => setState(() => _orderTypeExpanded = !_orderTypeExpanded),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: !_orderTypeExpanded ? const SizedBox(width: double.infinity) : Column(children: [
                        for(final option in _orderTypes) _CheckboxRow(
                          label: option.label.tr,
                          isSelected: _draftTypes.contains(option.value),
                          onTap: () => _toggleType(option.value),
                        ),
                      ]),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                      child: Divider(height: 1),
                    ),

                    _SectionHeader(
                      title: 'preferences'.tr,
                      expanded: _preferencesExpanded,
                      onTap: () => setState(() => _preferencesExpanded = !_preferencesExpanded),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: !_preferencesExpanded ? const SizedBox(width: double.infinity) : Column(children: [
                        for(final option in _preferences) _CheckboxRow(
                          label: option.label.tr,
                          isSelected: _isPreferenceSelected(option.value),
                          onTap: () => _togglePreference(option.value),
                        ),
                      ]),
                    ),

                  ]),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingLarge, Dimensions.paddingDefault, Dimensions.paddingLarge, Dimensions.paddingDefault),
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  boxShadow: [BoxShadow(color: context.shadow, offset: const Offset(0, -3), blurRadius: 10)],
                ),
                child: Row(children: [
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'reset'.tr,
                    color: context.bgNeutralLight,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                    onPressed: _hasActiveFilter ? _resetAndClose : null,
                  )),
                  const SizedBox(width: Dimensions.paddingSmall),
                  Expanded(child: CustomButtonWidget(buttonText: 'apply'.tr, onPressed: _applyAndClose)),
                ]),
              ),
            ]),
          ),
        ),
        Positioned(
          top: Dimensions.paddingMedium,
          right: Dimensions.paddingMedium,
          child:
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: context.surface, shape: BoxShape.circle),
              child: Icon(Icons.close, size: 18, color: context.iconBaseDefault),
            ),
          ),
        )
      ],
    );
  }
}

class _Option {
  final String value;
  final String label;
  const _Option({required this.value, required this.label});
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
        child: Row(children: [
          Expanded(child: Text(title, style: context.subHeading.defaultSize.strong)),
          AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: expanded ? 0.5 : 0,
            child: Icon(Icons.keyboard_arrow_down, color: context.iconBaseMedium),
          ),
        ]),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CheckboxRow({required this.label, required this.isSelected, required this.onTap});

  static const Duration _duration = Duration(milliseconds: 120);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = context.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
        child: Row(children: [
          Expanded(child: AnimatedDefaultTextStyle(
            duration: _duration,
            style: (isSelected ? context.subHeading.defaultSize.medium : context.subHeading.defaultSize.regular).overrideWith(
              color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : context.textBaseMedium,
            ),
            child: Text(label),
          )),
          AnimatedContainer(
            duration: _duration,
            height: 24, width: 24,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isSelected ? activeColor : context.outlineVariant, width: 1.5),
            ),
            alignment: Alignment.center,
            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}
