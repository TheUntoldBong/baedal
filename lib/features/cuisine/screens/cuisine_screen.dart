import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_card_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({super.key});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().getCuisineList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    Get.find<CuisineController>().getCuisineList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'cuisine'.tr),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(children: [

          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0: Dimensions.paddingLarge),

          Center(child: SizedBox(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [
                RefreshIndicator(
                  onRefresh: () async {
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingDefault, right: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingDefault),
                    child: GetBuilder<CuisineController>(builder: (cuisineController) {
                      return Column(
                        children: [

                          ResponsiveHelper.isDesktop(context) ? SizedBox() : SizedBox(
                            height: 47,
                            child: SearchBar(
                              controller: _searchController,
                              backgroundColor: WidgetStatePropertyAll(context.surfaceContainer),
                              elevation: WidgetStatePropertyAll(0),
                              side: WidgetStatePropertyAll(BorderSide(color: context.outline)),
                              onChanged: (value) {
                                cuisineController.getCuisineList(search: value);
                              },
                              onSubmitted: (value) {
                                cuisineController.getCuisineList(search: value);
                              },
                              hintText: 'search_by_category'.tr,
                              hintStyle: WidgetStatePropertyAll(
                                context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                              ),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                              leading: Icon(CupertinoIcons.search, color: context.iconBaseMedium),
                              trailing: _searchController.text.isEmpty ? [const SizedBox()] : _searchController.text.isNotEmpty ? [InkWell(
                                child: Icon(Icons.clear, color: context.iconBaseLight),
                                onTap: () {
                                  _searchController.clear();
                                  cuisineController.getCuisineList(search: null);
                                  cuisineController.update();
                                },
                              )] : [const SizedBox()],
                            ),
                          ),
                          SizedBox(height: Dimensions.paddingDefault,),


                          cuisineController.cuisineModel != null ? GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : ResponsiveHelper.isDesktop(context) ? 8 : 6,
                              mainAxisSpacing: Dimensions.paddingDefault,
                              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingDefault,
                              childAspectRatio: 1,
                            ),
                            shrinkWrap: true,
                            itemCount: cuisineController.cuisineModel!.cuisines!.length,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return InkWell(
                                hoverColor: Colors.transparent,
                                onTap: (){
                                  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                                },
                                child: SizedBox(
                                  height: 130,
                                  child: CuisineCardWidget(
                                    image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                    name: cuisineController.cuisineModel!.cuisines![index].name!,
                                    fromCuisinesPage: true,
                                  ),
                                ),
                              );
                            }) : const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }),
                  ),
                ),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}
