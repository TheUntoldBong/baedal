import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoItemGroupWidget extends StatelessWidget {
  final String label;
  final List<String> thumbnails;
  const BogoItemGroupWidget({super.key, required this.label, required this.thumbnails});

  static const double _size = 44;
  static const double _overlap = 34;

  @override
  Widget build(BuildContext context) {
    final List<String> visible = thumbnails.take(2).toList();
    final int overflow = thumbnails.length - visible.length;

    final int cardCount = visible.length + (overflow > 0 ? 1 : 0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: context.body.small.overrideWith(color: context.textBaseMedium)),
      const SizedBox(height: Dimensions.paddingSmall),

      visible.isEmpty ? const SizedBox() : SizedBox(
        height: _size,
        width: _size + (cardCount - 1) * _overlap,
        child: Stack(
          children: [
            ...List.generate(visible.length, (index) => Positioned(
              left: index * _overlap,
              child: Container(
                width: _size, height: _size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: context.surfaceContainer, width: 2),
                ),
                child: CustomImageWidget(image: visible[index], height: _size, width: _size, fit: BoxFit.cover, isFood: true),
              ),
            )),

            if(overflow > 0) Positioned(
              left: visible.length * _overlap,
              child: Container(
                height: _size, width: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: context.surfaceContainer, width: 2),
                ),
                child: Text('+$overflow', style: context.body.small.strong),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
