import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PasswordChangedBottomSheet extends StatelessWidget {
  const PasswordChangedBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.bgNeutralLight),
                  child: Icon(Icons.close, size: 18, color: theme.iconTheme.color),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: Dimensions.paddingLarge, left: Dimensions.paddingLarge,
              right: Dimensions.paddingLarge, bottom: Dimensions.paddingLarge + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(children: [
              
              Container(padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.bgNeutralMedium),
                child: Icon(Icons.check_rounded, size: 38, color: theme.cardColor, fontWeight: FontWeight.w500),
              ),
            
              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge-3),
            
              Text(
                'password_changed_successfully'.tr,
                textAlign: TextAlign.center,
                style: context.heading.extraLarge.strong,
              ),

              const SizedBox(height: Dimensions.paddingSmall),

              Text(
                'password_changed_subtitle'.tr,
                textAlign: TextAlign.center,
                style: context.body.small.copyWith(height: 1.5),
              ),
            
               const SizedBox(height: Dimensions.paddingSizeExtraOverLarge-3),
            
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMedium)),
                    elevation: 0,
                  ),
                  child: Text(
                    'okay_got_it'.tr,
                    style: context.heading.defaultSize.strong.overrideWith(color: colorScheme.onPrimary),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSmall),
            
            ]),
          ),

        ],
      ),
    );
  }
}