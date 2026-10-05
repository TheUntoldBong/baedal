import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CookiesViewWidget extends StatelessWidget {
  const CookiesViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: Get.isDarkMode ? 1 : 0.8)),
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.paddingDefault,
        horizontal: Dimensions.paddingDefault,
      ),
      child: Padding(padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

          const SizedBox(height: Dimensions.padding2xSmall),

          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
            child: Text(
              Get.find<SplashController>().configModel!.cookiesText ?? 'This is dummy cookies text',
              style: context.body.small.medium.overrideWith(color: context.onSurfaceVariant),
              maxLines: 10, textAlign: TextAlign.justify, overflow: TextOverflow.ellipsis,
            ),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.end, children: [

            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50,30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: (){
                Get.find<SplashController>().saveCookiesData(false);
                Get.find<SplashController>().cookiesStatusChange(Get.find<SplashController>().configModel!.cookiesText ?? 'This is dummy cookies text');
              }, child:  Text(
              'no_thanks'.tr,
              style: context.body.small.regular.overrideWith(color: context.onSurfaceVariant),
            )),


            SizedBox(width: ResponsiveHelper.isDesktop(context)?Dimensions.paddingExtraLarge:Dimensions.paddingLarge,),

            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
                minimumSize: const Size(80,35),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: (){
                Get.find<SplashController>().saveCookiesData(true);
                Get.find<SplashController>().cookiesStatusChange(Get.find<SplashController>().configModel!.cookiesText ?? "This is dummy cookies text");
              },
              child:  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault,vertical: 5),
                child: Center(
                  child: Text(
                  'yes_accept'.tr, style: context.body.small.regular.overrideWith(color: context.onSurfaceVariant),
                  ),
                ),
              )),

          ])

        ]),
      ),
    );
  }
}
