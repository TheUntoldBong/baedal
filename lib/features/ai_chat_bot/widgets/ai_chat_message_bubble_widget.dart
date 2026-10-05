import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_message_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_metadata_view_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatMessageBubbleWidget extends StatelessWidget {
  final AiChatMessage message;
  const AiChatMessageBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final Color userBubble = Get.isDarkMode
        ? context.primary.withValues(alpha: 0.25)
        : context.primary.withValues(alpha: 0.12);
    final Color assistantBubble = Get.isDarkMode
        ? context.surfaceContainer.withValues(alpha: 0.6)
        : context.surfaceContainer;

    String? timeText;
    if (message.createdAt != null && message.createdAt!.isNotEmpty) {
      try {
        timeText = DateConverter.localDateToIsoStringAMPM(
          DateTime.parse(message.createdAt!).toLocal(),
        );
      } catch (_) {
        timeText = null;
      }
    }

    final BorderRadius bubbleRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusExtraSmall),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusExtraSmall),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingDefault,
        vertical: Dimensions.padding2xSmall,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              if (!isUser) _AssistantAvatar(),
              if (!isUser) const SizedBox(width: Dimensions.paddingSmall),

              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingDefault,
                    vertical: Dimensions.paddingSmall + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? userBubble : assistantBubble,
                    borderRadius: bubbleRadius,
                  ),
                  child: _buildMessageContent(
                    message.content ?? '',
                    context.body.small.regular.overrideWith(color: context.textBaseDefault).copyWith(height: 1.4),
                  ),
                ),
              ),

              if (message.sending) ...[
                const SizedBox(width: Dimensions.padding2xSmall),
                SizedBox(
                  height: 12, width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: context.textBaseMedium,
                  ),
                ),
              ],

            ],
          ),

          if (!isUser && message.metadata != null && !message.metadata!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSmall,
                left: 44,
              ),
              child: AiChatMetadataViewWidget(metadata: message.metadata!),
            ),

          if (timeText != null)
            Padding(
              padding: EdgeInsets.only(
                top: Dimensions.padding2xSmall,
                left: isUser ? 0 : 44,
                right: isUser ? Dimensions.padding2xSmall : 0,
              ),
              child: Text(
                timeText,
                style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildMessageContent(String content, TextStyle baseStyle) {
    final List<String> lines = content.split('\n');
    final List<Widget> children = <Widget>[];
    final RegExp bulletPattern = RegExp(r'^[-*]\s+(.*)$');

    for (final String rawLine in lines) {
      final String line = rawLine.trimRight();
      final String trimmed = line.trimLeft();

      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: Dimensions.padding2xSmall));
        continue;
      }

      final Match? bullet = bulletPattern.firstMatch(trimmed);
      if (bullet != null) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 1, right: Dimensions.padding2xSmall),
              child: Text('•', style: baseStyle),
            ),
            Expanded(child: Text.rich(_buildInlineSpans(bullet.group(1)!, baseStyle))),
          ]),
        ));
        continue;
      }

      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text.rich(_buildInlineSpans(line, baseStyle)),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  TextSpan _buildInlineSpans(String content, TextStyle baseStyle) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp boldPattern = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
    int start = 0;

    for (final Match match in boldPattern.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(text: content.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }

    if (start < content.length) {
      spans.add(TextSpan(text: content.substring(start)));
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32, width: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
    );
  }
}

class AiChatTypingBubbleWidget extends StatefulWidget {
  const AiChatTypingBubbleWidget({super.key});

  @override
  State<AiChatTypingBubbleWidget> createState() => _AiChatTypingBubbleWidgetState();
}

class _AiChatTypingBubbleWidgetState extends State<AiChatTypingBubbleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color assistantBubble = Get.isDarkMode
        ? context.surfaceContainer.withValues(alpha: 0.6)
        : context.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingDefault,
        vertical: Dimensions.padding2xSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          _AssistantAvatar(),
          const SizedBox(width: Dimensions.paddingSmall),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingDefault,
              vertical: Dimensions.paddingSmall + 4,
            ),
            decoration: BoxDecoration(
              color: assistantBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusLarge),
                topRight: Radius.circular(Dimensions.radiusLarge),
                bottomRight: Radius.circular(Dimensions.radiusLarge),
                bottomLeft: Radius.circular(Dimensions.radiusExtraSmall),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final double t = ((_controller.value + i * 0.18) % 1.0);
                    final double scale = 0.6 + 0.4 * (t < 0.5 ? (t * 2) : (1 - (t - 0.5) * 2));
                    final double opacity = 0.4 + 0.6 * (t < 0.5 ? (t * 2) : (1 - (t - 0.5) * 2));
                    return Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            height: 8, width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.textBaseMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
