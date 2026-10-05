import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/offer/controllers/offer_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OfferFilterWidget extends StatefulWidget {
  final bool isRestaurantTab;
  const OfferFilterWidget({super.key, this.isRestaurantTab = false});

  @override
  State<OfferFilterWidget> createState() => _OfferFilterWidgetState();
}

class _OfferFilterWidgetState extends State<OfferFilterWidget> {
  static const double _minLimit = 0;
  static const double _maxLimit = 1000;

  double _minPrice = _minLimit;
  double _maxPrice = _maxLimit;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  bool _halal = false;
  bool _veg = false;
  bool _nonVeg = false;

  int? _selectedRating;

  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedCuisineIds = {};
  bool _showAllCategories = false;
  bool _showAllCuisines = false;

  @override
  void initState() {
    super.initState();
    final OfferController offerController = Get.find<OfferController>();
    _minPrice = offerController.minPrice;
    _maxPrice = offerController.maxPrice;
    _halal = offerController.halal;
    _veg = offerController.veg;
    _nonVeg = offerController.nonVeg;
    _selectedRating = offerController.rating;
    _selectedCategoryIds.addAll(offerController.categoryIds);
    _selectedCuisineIds.addAll(offerController.cuisineIds);

    _minController = TextEditingController(text: _minPrice.toInt().toString());
    _maxController = TextEditingController(text: _maxPrice.toInt().toString());

    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(false);
    }
    if(Get.find<CuisineController>().cuisineModel?.cuisines?.isEmpty ?? true) {
      Get.find<CuisineController>().getCuisineList();
    }
  }

  void _reset() {
    setState(() {
      _minPrice = _minLimit;
      _maxPrice = _maxLimit;
      _minController.text = _minPrice.toInt().toString();
      _maxController.text = _maxPrice.toInt().toString();
      _halal = false;
      _veg = false;
      _nonVeg = false;
      _selectedRating = null;
      _selectedCategoryIds.clear();
      _selectedCuisineIds.clear();
      _showAllCategories = false;
      _showAllCuisines = false;
    });
    Get.find<OfferController>().resetFilters();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: Dimensions.paddingExtraLarge),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingMedium, vertical: Dimensions.paddingDefault),
          child: Row(children: [
            InkWell(
              onTap: () => Get.back(),
              child: const Padding(padding: EdgeInsets.all(Dimensions.padding2xSmall), child: Icon(Icons.close)),
            ),
            const SizedBox(width: Dimensions.paddingSmall),
            Text('filter'.tr, style: context.heading.extraLarge.strong),
          ]),
        ),
        Divider(thickness: 2, height: 1),

        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingExtraLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(!widget.isRestaurantTab) ...[
                _sectionTitle('price_range'.tr),
                const SizedBox(height: Dimensions.paddingLarge),
                _priceRangeSection(),
                const SizedBox(height: Dimensions.paddingLarge),
                Divider(thickness: 1, height: 1),
                const SizedBox(height: Dimensions.paddingLarge),
              ],

              _sectionTitle('type'.tr),
              const SizedBox(height: Dimensions.paddingLarge),
              _checkboxRow('halal'.tr, _halal, () => setState(() => _halal = !_halal)),
              _checkboxRow('veg'.tr, _veg, () => setState(() {
                _veg = !_veg;
                if(_veg) _nonVeg = false;
              })),
              _checkboxRow('non_veg'.tr, _nonVeg, () => setState(() {
                _nonVeg = !_nonVeg;
                if(_nonVeg) _veg = false;
              })),
              const SizedBox(height: Dimensions.paddingLarge),

              const SizedBox(height: Dimensions.paddingLarge),
              Divider( thickness: 1, height: 1),
              const SizedBox(height: Dimensions.paddingExtraLarge),

              _sectionTitle('ratings'.tr),
             const SizedBox(height: Dimensions.paddingLarge),
              _radioRow('5_rating'.tr, _selectedRating == 5, () => setState(() => _selectedRating = 5)),
              _radioRow('4_rating'.tr, _selectedRating == 4, () => setState(() => _selectedRating = 4)),
              _radioRow('3_rating'.tr, _selectedRating == 3, () => setState(() => _selectedRating = 3)),
              _radioRow('2_rating'.tr, _selectedRating == 2, () => setState(() => _selectedRating = 2)),
              const SizedBox(height: Dimensions.paddingExtraLarge),
              Divider( thickness: 1, height: 1),
              const SizedBox(height: Dimensions.paddingLarge),

              GetBuilder<CategoryController>(builder: (categoryController) {
                List<CategoryModel> categories = categoryController.categoryList ?? [];
                if(categories.isEmpty) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('categories'.tr),
                  const SizedBox(height: Dimensions.paddingSmall),
                  ..._expandableItems(
                    total: categories.length,
                    expanded: _showAllCategories,
                    onToggle: () => setState(() => _showAllCategories = !_showAllCategories),
                    itemBuilder: (index) => _checkboxRow(
                      categories[index].name ?? '',
                      _selectedCategoryIds.contains(categories[index].id),
                      () => setState(() {
                        if(_selectedCategoryIds.contains(categories[index].id)) {
                          _selectedCategoryIds.remove(categories[index].id);
                        } else {
                          _selectedCategoryIds.add(categories[index].id!);
                        }
                      }),
                    ),
                  )
                ]);
              }),
              const SizedBox(height: Dimensions.paddingExtraLarge),
              Divider( thickness: 1, height: 1),
              const SizedBox(height: Dimensions.paddingLarge),

              GetBuilder<CuisineController>(builder: (cuisineController) {
                List cuisines = cuisineController.cuisineModel?.cuisines ?? [];
                if(cuisines.isEmpty) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle('cuisine'.tr),
                  const SizedBox(height: Dimensions.paddingSmall),
                  ..._expandableItems(
                    total: cuisines.length,
                    expanded: _showAllCuisines,
                    onToggle: () => setState(() => _showAllCuisines = !_showAllCuisines),
                    itemBuilder: (index) => _checkboxRow(
                      cuisines[index].name ?? '',
                      _selectedCuisineIds.contains(cuisines[index].id),
                      () => setState(() {
                        if(_selectedCuisineIds.contains(cuisines[index].id)) {
                          _selectedCuisineIds.remove(cuisines[index].id);
                        } else {
                          _selectedCuisineIds.add(cuisines[index].id!);
                        }
                      }),
                    ),
                  ),
                ]);
              }),

            ]),
          ),
        ),

        Container(
          decoration: BoxDecoration(color: context.surfaceContainer),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: CustomButtonWidget(
                  color: context.bgNeutralMedium,
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  buttonText: 'reset'.tr,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),
              Expanded(
                child: CustomButtonWidget(
                  buttonText: 'apply'.tr,
                  onPressed: () {
                    Get.find<OfferController>().applyFilters(
                      minPrice: _minPrice, maxPrice: _maxPrice, halal: _halal, veg: _veg, nonVeg: _nonVeg,
                      rating: _selectedRating, categoryIds: _selectedCategoryIds, cuisineIds: _selectedCuisineIds,
                    );
                    Get.back();
                  },
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(children: [
      Expanded(child: Text(title, style: context.heading.large.strong)),
      Builder(builder: (context) => Icon(Icons.keyboard_arrow_up, color: context.iconBaseMedium, size: Dimensions.paddingExtraLarge)),
    ]);
  }

  Widget _priceRangeSection() {
    return Builder(builder: (context) => Column(children: [
      Row(children: [
        Expanded(child: _priceField(_minController, (value) {
          double? parsed = double.tryParse(value);
          if(parsed != null) setState(() => _minPrice = parsed.clamp(_minLimit, _maxPrice));},
          'minimum'.tr,
         )),
        const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault), child: Text('-')),
        Expanded(child: _priceField(_maxController, (value) {
          double? parsed = double.tryParse(value);
          if(parsed != null) setState(() => _maxPrice = parsed.clamp(_minPrice, _maxLimit));},
          'maximum'.tr,
          )),
      ]),
      const SizedBox(height: Dimensions.paddingMedium),
      RangeSlider(
        values: RangeValues(_minPrice.clamp(_minLimit, _maxLimit), _maxPrice.clamp(_minLimit, _maxLimit)),
        min: _minLimit, max: _maxLimit,
        divisions: _maxLimit.toInt(),
        activeColor: context.primary,
        inactiveColor: context.bgNeutralMedium,
        onChanged: (values) => setState(() {
          _minPrice = values.start;
          _maxPrice = values.end;
          _minController.text = _minPrice.toInt().toString();
          _maxController.text = _maxPrice.toInt().toString();
        }),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('\$${_minLimit.toInt()}', style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
        Text('\$${_maxLimit.toInt()}', style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
      ]),
    ]));
  }

  Widget _priceField(TextEditingController controller, ValueChanged<String> onChanged, String text) {
    return Builder(builder: (context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        border: Border.all(color: context.outline),
      ),
      child: Row(
        children: [
          Text(text, style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
          SizedBox(width: Dimensions.paddingExtraSmall),
          Container(height: Dimensions.paddingOverLarge, width: 1.5, color: context.bgNeutralMedium),
          SizedBox(width: Dimensions.paddingExtraSmall),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: context.body.defaultSize.regular,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: Dimensions.paddingSmall)),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _checkboxRow(String label, bool value, VoidCallback onTap) {
    return Builder(builder: (context) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingExtraSmall),
        child: Row(children: [
          Expanded(child: Text(label, style: context.subHeading.defaultSize.medium.overrideWith(color: value ? Theme.of(context).textTheme.bodyLarge?.color : context.textBaseMedium))),
          SizedBox(
            height: 18, width: 18,
            child: Checkbox(
              value: value,
              onChanged: (_) => onTap(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: context.outline),
              activeColor: context.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ]),
      ),
    ));
  }

  Widget _radioRow(String label, bool value, VoidCallback onTap) {
    return Builder(builder: (context) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall + 2),
        child: Row(children: [
          CustomAssetImageWidget(Images.starFill, width: Dimensions.fontSizeLarge, color: context.primary),
          const SizedBox(width: Dimensions.paddingSmall),
          Expanded(child: Text(label, style: context.subHeading.defaultSize.medium.overrideWith(color: value ? Theme.of(context).textTheme.bodyLarge?.color : context.textBaseMedium))),
          Container(
            height: 20, width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: value ? context.primary : context.outline, width: 2),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: value ? context.primary : Colors.transparent)),
          ),
        ]),
      ),
    ));
  }

  List<Widget> _expandableItems({required int total, required bool expanded, required VoidCallback onToggle, required Widget Function(int index) itemBuilder}) {
    bool needsToggle = total > 5;
    int visibleCount = expanded || !needsToggle ? total : 5;
    return [
      for(int i = 0; i < visibleCount; i++) itemBuilder(i),
      if(needsToggle)
        Builder(builder: (context) => InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(expanded ? 'see_less'.tr : 'see_more'.tr, style: context.subHeading.small.semiBold.overrideWith(color: Colors.blueAccent)),
              Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.blueAccent),
            ]),
          ),
        )),
    ];
  }
}
