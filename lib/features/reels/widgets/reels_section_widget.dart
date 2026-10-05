import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/reels/controllers/reels_controller.dart';
import 'package:stackfood_multivendor/features/reels/domain/models/reel_model.dart';
import 'package:stackfood_multivendor/features/reels/widgets/reels_details_dialog_widget.dart';
import 'package:stackfood_multivendor/features/reels/widgets/reels_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ReelsSectionWidget extends StatefulWidget {
  final String? title;
  final ValueChanged<ReelModel>? onReelTap;
  const ReelsSectionWidget({super.key, this.title, this.onReelTap});

  @override
  State<ReelsSectionWidget> createState() => _ReelsSectionWidgetState();
}

class _ReelsSectionWidgetState extends State<ReelsSectionWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackButton = false;
  bool _showForwardButton = false;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if(!_scrollController.hasClients) return;
    final bool back = _scrollController.position.pixels > 0;
    final bool forward = _scrollController.position.pixels < _scrollController.position.maxScrollExtent;
    if(back != _showBackButton || forward != _showForwardButton) {
      setState(() {
        _showBackButton = back;
        _showForwardButton = forward;
      });
    }
  }

  String _resolveTitle() {
    if(widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    return 'food_stories'.tr;
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ReelsController>(
      builder: (ReelsController reelsController) {
        if(reelsController.reelsList == null && reelsController.isLoading) {
          return const ReelsShimmerWidget();
        }

        final List<ReelModel> reels = reelsController.reelsList ?? <ReelModel>[];
        if(reels.isEmpty) {
          return const SizedBox.shrink();
        }

        final bool isDesktop = ResponsiveHelper.isDesktop(context);
        const double reelRatio = 266 / 150;
        final double cardWidth = isDesktop ? 160 : (MediaQuery.of(context).size.width / 2.4).clamp(140.0, 160.0);
        final double cardHeight = isDesktop ? 280 : cardWidth * reelRatio;
        final String resolvedTitle = _resolveTitle();

        const int maxVisibleReels = 9;
        final bool showViewAll = reels.length > maxVisibleReels;
        final int reelItemCount = showViewAll ? maxVisibleReels : reels.length;
        final int itemCount = showViewAll ? reelItemCount + 1 : reelItemCount;

        if(isDesktop && _isFirstTime && itemCount > 5) {
          _showForwardButton = true;
          _isFirstTime = false;
        }

        void openDialog(int initialIndex) {
          reelsController.setCurrentIndex(initialIndex);
          Get.dialog(
              ReelsDetailsDialogWidget(
              reels: reels,
              initialIndex: initialIndex,
              title: resolvedTitle,
              ),
            barrierDismissible: true,
            barrierColor: Colors.black.withValues(alpha: 0.82),
            useSafeArea: false,
          );
        }

        final Widget reelsList = ListView.separated(
          controller: isDesktop ? _scrollController : null,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          itemCount: itemCount,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingMedium),
          itemBuilder: (BuildContext context, int index) {
            if(showViewAll && index == reelItemCount) {
              return SizedBox(
                width: cardWidth,
                child: _ViewAllCardWidget(
                  onTap: () => openDialog(0),
                ),
              );
            }

            return SizedBox(
              width: cardWidth,
              child: _ReelCardWidget(
                reel: reels[index],
                isActive: index == reelsController.currentIndex,
                isDesktop: isDesktop,
                onTap: () {
                  reelsController.setCurrentIndex(index);
                  if(widget.onReelTap != null) {
                    widget.onReelTap!(reels[index]);
                    return;
                  }
                  openDialog(index);
                },
              ),
            );
          },
        );

        return Container(
          decoration: BoxDecoration(
            color: context.surfaceContainer,
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Row(
                  children: <Widget>[
                    CustomAssetImageWidget(Images.reels, width: 30, height: 30),
                    const SizedBox(width: Dimensions.paddingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(resolvedTitle, style: context.heading.extraLarge),
                          Text(
                            'food_stories_subtitle'.tr,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: context.body.small,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingMedium),
              SizedBox(
                height: cardHeight,
                child: isDesktop
                    ? Stack(
                        children: <Widget>[
                          reelsList,
                          if(_showBackButton)
                            Positioned(
                              left: Dimensions.paddingSmall,
                              top: (cardHeight - 40) / 2,
                              child: _ArrowIconButton(
                                isRight: false,
                                onTap: () => _scrollController.animateTo(
                                  _scrollController.offset - (cardWidth * 3),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            ),
                          if(_showForwardButton)
                            Positioned(
                              right: Dimensions.paddingSmall,
                              top: (cardHeight - 40) / 2,
                              child: _ArrowIconButton(
                                onTap: () => _scrollController.animateTo(
                                  _scrollController.offset + (cardWidth * 3),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            ),
                        ],
                      )
                    : reelsList,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewAllCardWidget extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewAllCardWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: context.surfaceContainer,
            border: Border.all(
              color: context.outlineVariant,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                offset: const Offset(0, 10),
                blurRadius: 20,
                color: context.shadow,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSmall),
                Text(
                  'view_all'.tr,
                  style: context.subHeading.small.overrideWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReelCardWidget extends StatelessWidget {
  final ReelModel reel;
  final bool isActive;
  final bool isDesktop;
  final VoidCallback onTap;
  const _ReelCardWidget({required this.reel, required this.isActive, required this.onTap, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: context.surfaceContainer,
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 4,
              color: context.shadow,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: reel.resolvedThumbnailUrl.isNotEmpty
                    ? CustomImageWidget(image: reel.resolvedThumbnailUrl, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              context.primary.withValues(alpha: 0.22),
                              context.primary.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.70),
                      ],
                    ),
                  ),
                ),
              ),
              if(!isDesktop && (reel.stats?.totalViews ?? 0) > 0) Positioned(
                top: Dimensions.paddingSmall,
                right: Dimensions.paddingSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.bgUtilBlanket,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(Icons.remove_red_eye_outlined, size: 12, color: context.iconNeutralOn),
                    const SizedBox(width: 4),
                    Text(
                      reel.resolvedViewCountText,
                      style: context.subHeading.small.overrideWith(color: context.onSurfaceVariant),
                    ),
                  ]),
                ),
              ),
              Positioned(
                left: Dimensions.paddingSmall,
                right: Dimensions.paddingSmall,
                bottom: Dimensions.paddingSmall,
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Container(
                              height: 30, width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.outline, width: 1),
                              ),
                              child: ClipOval(
                                child: CustomImageWidget(image: reel.resolvedLogoUrl, height: 200, width: 200, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: Dimensions.padding2xSmall),
                            Expanded(
                              child: Text(
                                reel.resolvedSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.heading.small.overrideWith(color: Colors.white),
                              ),
                            ),
                            if(reel.verifiedSeller == 1) ...<Widget>[
                              const SizedBox(width: 4),
                              const RestaurantVerifiedIconWidget(size: 12),
                            ],
                          ]),
                          if(reel.resolvedDescription.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              reel.resolvedDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.body.extraSmall.overrideWith(color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowIconButton extends StatelessWidget {
  final bool isRight;
  final VoidCallback onTap;
  const _ArrowIconButton({required this.onTap, this.isRight = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(
            isRight ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: context.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
