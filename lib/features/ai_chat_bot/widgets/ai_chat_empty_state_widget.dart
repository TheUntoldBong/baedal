import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_suggestion_chips_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatEmptyStateWidget extends StatelessWidget {
  const AiChatEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingLarge,
        vertical: Dimensions.paddingExtraLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            height: 110, width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.primary.withValues(alpha: 0.2),
                  context.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: context.primary,
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          Text(
            'no_conversation_yet'.tr,
            style: context.heading.large.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.padding2xSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Text(
              'start_a_new_conversation_with_ai'.tr,
              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),

          AiChatSuggestionChipsWidget(
            onSuggestionTap: (text) => Get.toNamed(
              RouteHelper.getAiChatDetailsScreen(initialMessage: text),
            ),
          ),

        ],
      ),
    );
  }
}
