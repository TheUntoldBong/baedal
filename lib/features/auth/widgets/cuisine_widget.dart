import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CuisineWidget extends StatelessWidget {
  final TextEditingController cuisineTextController;
  final FocusNode cuisineFocus;
  const CuisineWidget({super.key, required this.cuisineTextController, required this.cuisineFocus});

  @override
  Widget build(BuildContext context) {
    TextEditingController c = cuisineTextController;
    return GetBuilder<CuisineController>(
        builder: (cuisineController) {
          List<int> cuisines = [];
          if(cuisineController.cuisineModel != null) {
            for(int index=0; index<cuisineController.cuisineModel!.cuisines!.length; index++) {
              if(cuisineController.cuisineModel!.cuisines![index].status == 1 && !cuisineController.selectedCuisines!.contains(index)) {
                cuisines.add(index);
              }
            }
          }
          return Column(children: [

            Autocomplete<int>(
              optionsBuilder: (TextEditingValue value) {
                if(value.text.isEmpty) {
                  return const Iterable<int>.empty();
                }else {
                  return cuisines.where((cuisine) => cuisineController.cuisineModel!.cuisines![cuisine].name!.toLowerCase().contains(value.text.toLowerCase()));
                }
              },
              fieldViewBuilder: (context, controller, node, onComplete) {
                c = controller;
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: TextFormField(
                    controller: controller,
                    focusNode: node,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      onComplete();
                      controller.text = '';
                    },
                    decoration: InputDecoration(
                      hintText: 'search_cuisines'.tr,
                      hintStyle: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: context.textBaseMedium),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 1, color: context.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: context.primary),
                      ),
                      label: Text('cuisines'.tr, style: context.body.large.regular.overrideWith(color: context.textBaseMedium)),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, Function(int i) onSelected, data) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveHelper.isDesktop(context) ? context.width*0.3 : context.width *0.4),
                    child: ListView.builder(
                      itemCount: data.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => onSelected(data.elementAt(index)),
                        child: Container(
                          decoration: BoxDecoration(color: context.surfaceContainer),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.padding2xSmall),
                          child: Text(cuisineController.cuisineModel!.cuisines![data.elementAt(index)].name ?? ''),
                        ),
                      ),
                    ),
                  ),
                );
              },
              displayStringForOption: (value) => cuisineController.cuisineModel!.cuisines![value].name!,
              onSelected: (int value) {
                c.text = '';
                cuisineController.setSelectedCuisineIndex(value, true);
              },
            ),
            SizedBox(height: cuisineController.selectedCuisines!.isNotEmpty ? Dimensions.paddingSmall : 0),

            SizedBox(
              height: cuisineController.selectedCuisines!.isNotEmpty ? 40 : 0,
              child: ListView.builder(
                itemCount: cuisineController.selectedCuisines!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                    margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                    child: Row(children: [
                      Text(
                        cuisineController.cuisineModel!.cuisines![cuisineController.selectedCuisines![index]].name!,
                        style: context.body.defaultSize.regular.overrideWith(color: context.surfaceContainer),
                      ),
                      InkWell(
                        onTap: () => cuisineController.removeCuisine(index),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                          child: Icon(Icons.close, size: 15, color: context.surfaceContainer),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ]);
        }
    );
  }
}
