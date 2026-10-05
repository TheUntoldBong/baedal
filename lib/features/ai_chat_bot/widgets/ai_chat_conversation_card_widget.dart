import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_conversation_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatConversationCardWidget extends StatelessWidget {
  final AiChatConversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;
  const AiChatConversationCardWidget({
    super.key,
    required this.conversation,
    this.onTap,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    String? timeText;
    String? rawTime = conversation.updatedAt ?? conversation.createdAt;
    if (rawTime != null && rawTime.isNotEmpty) {
      try {
        timeText = DateConverter.localDateToIsoStringAMPM(
          DateTime.parse(rawTime).toLocal(),
        );
      } catch (_) {
        timeText = null;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CustomInkWellWidget(
        onTap: onTap ?? () {},
        radius: Dimensions.radiusDefault,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Container(
              height: 44, width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primary.withValues(alpha: 0.25),
                    context.primary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: context.primary,
              ),
            ),
            const SizedBox(width: Dimensions.paddingDefault),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  conversation.title ?? '',
                  style: context.subHeading.defaultSize.medium,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Row(children: [

                  if (conversation.messagesCount != null) ...[
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: context.textBaseMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${conversation.messagesCount} ${'messages'.tr}',
                      style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ],

                  if (conversation.messagesCount != null && timeText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding2xSmall),
                      child: Container(
                        height: 3, width: 3,
                        decoration: BoxDecoration(
                          color: context.textBaseMedium,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  if (timeText != null)
                    Expanded(
                      child: Text(
                        timeText,
                        style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ]),

              ]),
            ),

            if (isDeleting)
              SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.textBaseMedium,
                ),
              )
            else if (onDelete != null)
              PopupMenuButton<String>(
                tooltip: 'options'.tr,
                icon: Icon(Icons.more_vert_rounded, color: context.textBaseMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, color: context.iconDangerDefault, size: 20),
                      const SizedBox(width: Dimensions.paddingSmall),
                      Text(
                        'delete'.tr,
                        style: context.body.small.medium.overrideWith(color: context.textDangerDefault),
                      ),
                    ]),
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: context.textBaseMedium,
              ),

          ]),
        ),
      ),
    );
  }
}
