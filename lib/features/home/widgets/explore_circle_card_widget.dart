import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';


class ExploreCircleCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback onTap;
  const ExploreCircleCardWidget({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: CustomInkWellWidget(
        onTap: onTap,
        radius: Dimensions.radiusSmall,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  image: image,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                  placeholderBgColor: context.bgNeutralLight,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name.trim(),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: context.textBaseDefault,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
