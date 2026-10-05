import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class AiChatConversationShimmerWidget extends StatelessWidget {
  const AiChatConversationShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSmall,
        vertical: Dimensions.paddingSmall,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
            ),
            child: Row(children: [
              Container(
                height: 44, width: 44,
                decoration: BoxDecoration(
                  color: context.bgNeutralLight,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    height: 14, width: 160,
                    color: context.bgNeutralLight,
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Container(
                    height: 12, width: 100,
                    color: context.bgNeutralLight,
                  ),
                ]),
              ),

            ]),
          ),
        );
      },
    );
  }
}
