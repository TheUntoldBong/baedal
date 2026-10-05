import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Get.find<CategoryController>().clearSearch(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Get.find<CategoryController>().clearSearch();
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'categories'.tr,
          onBackPressed: (){
            Get.find<CategoryController>().clearSearch();
            Get.back();
          },
        ),
        body: GetBuilder<CategoryController>(builder: (catController) {
          return SafeArea(
            child: SingleChildScrollView(
              controller: scrollController, child: SizedBox(
                child: Column(children: [

                  ResponsiveHelper.isDesktop(context) ? Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge),
                    height: 64, width: Dimensions.webMaxWidth,
                    color: context.primary.withValues(alpha: 0.10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('categories'.tr, style: context.heading.defaultSize.semiBold),

                        SizedBox(
                          height: 35, width: 250,
                          child: SearchBar(
                            controller: _searchController,
                            backgroundColor: WidgetStatePropertyAll(context.surfaceContainer),
                            elevation: WidgetStatePropertyAll(0),
                            side: WidgetStatePropertyAll(BorderSide(color: context.outline)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            overlayColor: WidgetStateColor.transparent,
                            onChanged: (value) {
                              catController.getCategoryList(true, search: value);
                            },
                            onSubmitted: (value) {
                              catController.getCategoryList(true, search: value);
                            },
                            hintText: 'search_by_category'.tr,
                            hintStyle: WidgetStatePropertyAll(
                              context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                            ),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                            leading: Icon(CupertinoIcons.search, size: 16, color: context.iconBaseMedium),
                            trailing: _searchController.text.isEmpty ? [const SizedBox()] : _searchController.text.isNotEmpty ? [InkWell(
                              child: Icon(Icons.clear, size: 16, color: context.iconBaseMedium),
                              onTap: () {
                                _searchController.clear();
                                catController.clearSearch();
                                catController.update();
                              },
                            )] : [const SizedBox()],
                          ),
                        ),
                      ],
                    ),
                  ) : const SizedBox(),

                  ResponsiveHelper.isDesktop(context) ? SizedBox() : Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault, top: Dimensions.paddingDefault),
                    child: SizedBox(
                      height: 47,
                      child: SearchBar(
                        controller: _searchController,
                        backgroundColor: WidgetStatePropertyAll(context.surfaceContainer),
                        elevation: WidgetStatePropertyAll(0),
                        side: WidgetStatePropertyAll(BorderSide(color: context.outline)),
                        onChanged: (value) {
                          catController.getCategoryList(true, search: value);
                        },
                        onSubmitted: (value) {
                          catController.getCategoryList(true, search: value);
                        },
                        hintText: 'search_by_category'.tr,
                        hintStyle: WidgetStatePropertyAll(
                          context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                        ),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                        leading: Icon(CupertinoIcons.search, color: context.iconBaseMedium),
                        trailing: _searchController.text.isEmpty ? [const SizedBox()] : _searchController.text.isNotEmpty ? [InkWell(
                          child: Icon(Icons.clear, color: context.iconBaseMedium),
                          onTap: () {
                            _searchController.clear();
                            catController.clearSearch();
                            catController.update();
                          },
                        )] : [const SizedBox()],
                      ),
                    ),
                  ),

                  Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: catController.categoryList != null ? catController.categoryList!.isNotEmpty ? GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 7 : ResponsiveHelper.isTab(context) ? 4 : 3,
                        childAspectRatio: (1/1),
                        mainAxisSpacing: Dimensions.paddingSmall,
                        crossAxisSpacing: Dimensions.paddingSmall,
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingDefault),
                      itemCount: catController.categoryList!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                            border: BoxBorder.all(
                              width: 1,
                              color: context.outlineVariant
                            )
                          ),
                          child: CustomInkWellWidget(
                            onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                              catController.categoryList![index].id, catController.categoryList![index].name!,
                            )),
                            radius: Dimensions.radiusDefault,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                child: CustomImageWidget(
                                  height: 40, width: 40, fit: BoxFit.cover,
                                  image: '${catController.categoryList![index].imageFullUrl}',
                                ),
                              ),
                              const SizedBox(height: Dimensions.padding2xSmall),

                              Text(
                                catController.categoryList![index].name!, textAlign: TextAlign.center,
                                style: context.subHeading.defaultSize.regular,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),

                            ]),
                          ),
                        );
                      },
                    ) : NoDataScreen(title: 'no_category_found'.tr) : const Center(child: CircularProgressIndicator()),
                  )),
                ],
              )),
            ),
          );
        }),
      ),
    );
  }
}
