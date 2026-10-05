import 'package:stackfood_multivendor/features/interest/controllers/interest_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<InterestController>().getCategoryList(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: GetBuilder<InterestController>(builder: (interestController) {
          return interestController.categoryList != null ? interestController.categoryList!.isNotEmpty ? Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingLarge),

                Text('choose_your_interests'.tr, style: context.heading.overLarge.medium.copyWith(fontSize: 22)),
                const SizedBox(height: Dimensions.paddingSmall),

                Text('get_personalized_recommendations'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                const SizedBox(height: Dimensions.paddingLarge),

                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: interestController.categoryList!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      childAspectRatio: (1/0.35),
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => interestController.addInterestSelection(index),
                        child: Container(
                          margin: const EdgeInsets.all(Dimensions.padding2xSmall),
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.padding2xSmall, horizontal: Dimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: interestController.interestCategorySelectedList![index] ? context.primary
                                : context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                            boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)],
                          ),
                          alignment: Alignment.center,
                          child: Row(children: [
                            CustomImageWidget(
                              image: '${interestController.categoryList![index].imageFullUrl}',
                              height: 30, width: 30,
                            ),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Flexible(child: Text(
                              interestController.categoryList![index].name!,
                              style: context.body.small.medium.overrideWith(
                                color: interestController.interestCategorySelectedList![index] ? context.surfaceContainer
                                    : context.textBaseDefault,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                CustomButtonWidget(
                  buttonText: 'save_and_continue'.tr,
                  isLoading: interestController.isLoading,
                  onPressed: () {
                    List<int?> interests = [];
                    for(int index=0; index<interestController.categoryList!.length; index++) {
                      if(interestController.interestCategorySelectedList![index]) {
                        interests.add(interestController.categoryList![index].id);
                      }
                    }
                    interestController.saveInterest(interests).then((isSuccess) {
                      if(isSuccess) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    });
                  },
                ),

              ]),
            ),
          ) : NoDataScreen(title: 'no_category_found'.tr) : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
