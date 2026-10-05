import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class HowItWorkWidget extends StatelessWidget {
  const HowItWorkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingLarge, top: Dimensions.paddingDefault, right: Dimensions.paddingLarge, bottom: Dimensions.paddingDefault),
          child: Row(children: [
            Icon(Icons.info_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(width: Dimensions.padding2xSmall),

            Text('how_it_works'.tr , style: context.heading.defaultSize.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center),
          ]),
        ),

        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            physics: const BouncingScrollPhysics(),
            itemCount: AppConstants.dataList.length,
            separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
            itemBuilder: (context, index){
              return Container(
                width: 220,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Row(children: [
                  Container(
                    height: 40, width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                    child: Text('${index+1}', style: context.heading.defaultSize.strong),
                  ),
                  const SizedBox(width: Dimensions.paddingSmall),

                  Expanded(child: Text(AppConstants.dataList[index].tr, style: context.heading.small.regular.copyWith(color: context.textBaseMedium))),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingSmall),
      ]),
    );
  }
}
