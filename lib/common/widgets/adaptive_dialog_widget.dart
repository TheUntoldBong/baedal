import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

Future<T?> showCustomDialog<T>({
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  double? maxHeight,
  Color? barrierColor,
}) {

  return Get.bottomSheet<T>(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? MediaQuery.of(Get.context!).size.height * 0.9),
      child: child,
    ),
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Get.context!.surfaceContainer,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: barrierColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
  );
}

class DialogSheetBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showCloseIcon;
  final bool showDrager;
  const DialogSheetBody({super.key, required this.child, this.padding = EdgeInsets.zero, this.showCloseIcon = false, this.showDrager = true});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: Dimensions.paddingSmall),
              if(showDrager) Container(
                height: 4, width: 40,
                decoration: BoxDecoration(
                  color: context.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),

              Flexible(child: SingleChildScrollView(padding: padding, child: child)),
            ]),
            if(showCloseIcon) Positioned(
              top: Dimensions.paddingMedium,
              right: Dimensions.paddingMedium,
              child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.surfaceContainer.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: const Icon(Icons.clear),
                  ),
                ),
              ),)

          ],
        ),
      ),
    );
  }
}
