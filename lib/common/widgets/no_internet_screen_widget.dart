import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class NoInternetScreen extends StatelessWidget {
  final Widget? child;
  const NoInternetScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.025),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomAssetImageWidget(Images.noInternet, width: 150, height: 150),
            Text('oops'.tr, style: context.heading.extraOverLarge.strong.overrideWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ).copyWith(fontSize: 30)),
            const SizedBox(height: Dimensions.padding2xSmall),
            Text(
              'no_internet_connection'.tr,
              textAlign: TextAlign.center,
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            ),
            const SizedBox(height: 40),

            InkWell(
              onTap: () async {
                final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

                if(!connectivityResult.contains(ConnectivityResult.none)) {
                  try {
                    Get.off(child);
                  } catch (e) {
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary,
                ),
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  child: Center(child: Icon(Icons.refresh, size: 34, color: context.surfaceContainer)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
