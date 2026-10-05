import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OptionSelectionBottomSheetWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final int initialIndex;
  final Function(int index) onApply;
  const OptionSelectionBottomSheetWidget({super.key,
    required this.title, required this.options, required this.onApply, this.initialIndex = -1,
  });

  @override
  State<OptionSelectionBottomSheetWidget> createState() => _OptionSelectionBottomSheetWidgetState();
}

class _OptionSelectionBottomSheetWidgetState extends State<OptionSelectionBottomSheetWidget> {
  late int _selectIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(
              widget.title,
              style: context.heading.extraLarge,
            )),
            const SizedBox(width: Dimensions.paddingSmall),

            InkWell(
              onTap: () => Get.back(),
              child: Container(
                height: 28, width: 28,
                decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.close, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final bool isSelected = _selectIndex == index;
              return InkWell(
                onTap: () => setState(() => _selectIndex = index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingMedium),
                  child: Row(children: [
                    Expanded(child: Text(
                      widget.options[index].tr,
                      style: context.subHeading.small,
                    )),
                    const SizedBox(width: Dimensions.paddingDefault),

                    _RadioCircle(isSelected: isSelected),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          SafeArea(
            child: CustomButtonWidget(
              buttonText: 'apply'.tr,
              onPressed: _selectIndex == -1 ? null : () {
                widget.onApply(_selectIndex);
                Get.back();
              },
            ),
          ),

        ]),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22, width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? context.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? context.primary : context.outlineVariant,
          width: 1.5,
        ),
      ),
      child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}
