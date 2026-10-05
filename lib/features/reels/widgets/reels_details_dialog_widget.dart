import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/reels/controllers/reels_controller.dart';
import 'package:stackfood_multivendor/features/reels/domain/models/reel_model.dart';
import 'package:stackfood_multivendor/features/reels/widgets/reel_transient_toast_widget.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/food_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/reels/helpers/web_video_helper.dart' as web_video;
import 'package:video_player/video_player.dart';
import 'package:stackfood_multivendor/theme/system_ui_style.dart';

final CacheManager _reelVideoCache = CacheManager(
  Config(
    'reel_video_cache',
    stalePeriod: const Duration(days: 1),
    maxNrOfCacheObjects: 30,
  ),
);

final ValueNotifier<bool> _isReelMuted = ValueNotifier<bool>(true);

class ReelsDetailsDialogWidget extends StatefulWidget {
  final List<ReelModel> reels;
  final int initialIndex;
  final String title;
  const ReelsDetailsDialogWidget({
    super.key,
    required this.reels,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<ReelsDetailsDialogWidget> createState() => _ReelsDetailsDialogWidgetState();
}

class _ReelsDetailsDialogWidgetState extends State<ReelsDetailsDialogWidget> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(appSystemUiOverlayStyle);
    super.dispose();
  }

  void _goToPage(int index, int totalReels) {
    if(index < 0 || index >= totalReels) {
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReelsController>(
      builder: (ReelsController reelsController) {
        final List<ReelModel> liveReels = reelsController.reelsList ?? <ReelModel>[];
        final List<ReelModel> reels = liveReels.isNotEmpty ? liveReels : widget.reels;
        if(_currentIndex >= reels.length) {
          _currentIndex = reels.isEmpty ? 0 : reels.length - 1;
        }
        return _buildContent(context, reels, reelsController);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<ReelModel> reels, ReelsController reelsController) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final Widget pager = PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: reels.length,
      onPageChanged: (int index) {
        setState(() {
          _currentIndex = index;
        });
        if(index >= reels.length - 2 && !reelsController.reelListLoadingComplete() && !reelsController.isLoading) {
          reelsController.loadMoreReels();
        }
      },
      itemBuilder: (BuildContext context, int index) {
        return _ReelDetailsPage(
          reel: reels[index],
          isActive: index == _currentIndex,
          shouldPreload: (index - _currentIndex).abs() == 1,
          isDesktop: isDesktop,
        );
      },
    );

    if(isDesktop) {
      final double videoHeight = MediaQuery.of(context).size.height * 0.88;
      const double videoWidth = 390;
      final bool canGoUp = _currentIndex > 0;
      final bool canGoDown = _currentIndex < reels.length - 1;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 8,
              left: 16,
              child: Text(
                widget.title,
                style: context.heading.large.medium.overrideWith(color: Colors.white),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _ReelMuteButton(),
                  const SizedBox(width: Dimensions.paddingSmall),
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: videoWidth,
                    height: videoHeight,
                    child: Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: pager,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingDefault),
                  SizedBox(
                    height: videoHeight,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _NavArrowButton(
                                icon: Icons.keyboard_arrow_up_rounded,
                                enabled: canGoUp,
                                onTap: canGoUp ? () => _goToPage(_currentIndex - 1, reels.length) : null,
                              ),
                              const SizedBox(height: Dimensions.paddingSmall),
                              _NavArrowButton(
                                icon: Icons.keyboard_arrow_down_rounded,
                                enabled: canGoDown,
                                onTap: canGoDown ? () => _goToPage(_currentIndex + 1, reels.length) : null,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _ReelLikeViewStats(
                            reel: reels[_currentIndex],
                            iconColor: Colors.white,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const ReelTransientToastWidget(),
          ],
        ),
      );
    }

    final Widget content = Material(
      color: Colors.black,
      borderRadius: BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                color: const Color(0xFF383838),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingDefault,
                      vertical: Dimensions.paddingSmall,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.title,
                            style: context.heading.extraLarge.strong.overrideWith(color: Colors.white),
                          ),
                        ),
                        const _ReelMuteButton(),
                        const SizedBox(width: Dimensions.paddingSmall),
                        InkWell(
                          onTap: Get.back,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: pager,
                ),
              ),
            ],
          ),
          const ReelTransientToastWidget(),
        ],
      ),
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox.expand(child: content),
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  const _NavArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: enabled ? 0.14 : 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: enabled ? 1 : 0.4),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _ReelDetailsPage extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;
  final bool shouldPreload;
  final bool isDesktop;
  const _ReelDetailsPage({
    required this.reel,
    required this.isActive,
    this.shouldPreload = false,
    this.isDesktop = false,
  });

  @override
  State<_ReelDetailsPage> createState() => _ReelDetailsPageState();
}

class _ReelDetailsPageState extends State<_ReelDetailsPage> {
  VideoPlayerController? _videoController;
  bool _isPreparing = false;
  bool _hasVideoError = false;
  bool _isFetchingProduct = false;
  Duration _savedPosition = Duration.zero;
  bool _shouldPlayWhenReady = false;
  String? _webBlobUrl;

  @override
  void initState() {
    super.initState();
    _isReelMuted.addListener(_handleMuteChanged);
    if(widget.isActive) {
      _prepareMedia(autoPlay: true);
      _loadReelStats();
    } else if(widget.shouldPreload) {
      _prepareMedia(autoPlay: false);
    }
  }

  void _handleMuteChanged() {
    final VideoPlayerController? controller = _videoController;
    if(controller != null && controller.value.isInitialized) {
      controller.setVolume(_isReelMuted.value ? 0.0 : 1.0);
    }
  }

  Future<void> _onStoreTap() async {
    final int? reelId = widget.reel.reelId;
    final int? restaurantId = widget.reel.restaurantId;
    if(restaurantId == null) {
      return;
    }
    if(_videoController != null && _videoController!.value.isPlaying) {
      await _videoController!.pause();
      if(mounted) setState(() {});
    }
    if(reelId != null) {
      Get.find<ReelsController>().visitReel(reelId);
    }
    Get.toNamed(RouteHelper.getRestaurantRoute(restaurantId, slug: 'store_$restaurantId'));
  }

  Future<void> _onOrderNowTap(ReelModel reelModel) async {
    final int? foodId = reelModel.foodId;
    if (foodId == null || _isFetchingProduct) return;

    if (mounted) setState(() => _isFetchingProduct = true);

    Product? product = await Get.find<ProductController>().getProductDetails(foodId, null);

    if (mounted) setState(() => _isFetchingProduct = false);
    if (product == null || !mounted) return;

    Get.bottomSheet(
      FoodBottomSheetWidget(product: product, inRestaurantPage: false, reelId: reelModel.reelId),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _loadReelStats() {
    final int? reelId = widget.reel.reelId;
    if(reelId == null) {
      return;
    }
    Get.find<ReelsController>().getReelStats(reelId, reload: true);
  }

  @override
  void didUpdateWidget(covariant _ReelDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.isActive && !oldWidget.isActive) {
      _loadReelStats();
      if(_videoController != null && _videoController!.value.isInitialized) {
        _videoController!.play();
        if(mounted) setState(() {});
      } else if(_isPreparing) {
        _shouldPlayWhenReady = true;
      } else {
        _prepareMedia(autoPlay: true);
      }
    } else if(!widget.isActive && oldWidget.isActive) {
      _shouldPlayWhenReady = false;
      if(_videoController != null) {
        _savedPosition = _videoController!.value.position;
        _videoController!.pause();
        if(mounted) setState(() {});
      }
    }

    if(widget.shouldPreload && !oldWidget.shouldPreload && !widget.isActive) {
      if(_videoController == null && !_isPreparing) {
        _prepareMedia(autoPlay: false);
      }
    }
  }

  Future<void> _prepareMedia({bool autoPlay = true}) async {
    if(_isPreparing) {
      if(autoPlay) _shouldPlayWhenReady = true;
      return;
    }
    if(_videoController != null) {
      if(autoPlay && !_videoController!.value.isPlaying) {
        _videoController!.play();
        if(mounted) setState(() {});
      }
      return;
    }

    final bool isPreloadOnly = !autoPlay;
    _shouldPlayWhenReady = autoPlay;
    _isPreparing = true;
    if(mounted) setState(() {});

    final String streamUrl = _buildStreamUrl();
    if(streamUrl.isEmpty) {
      _isPreparing = false;
      if(mounted) setState(() {});
      return;
    }

    final Map<String, String> baseHeaders = Get.find<ApiClient>().getHeader();
    final Map<String, String> authHeaders = <String, String>{};
    for(final String key in <String>[AppConstants.zoneId, AppConstants.localizationKey, 'Authorization']) {
      final String? value = baseHeaders[key];
      if(value != null && value.isNotEmpty) {
        authHeaders[key] = value;
      }
    }
    final Map<String, String> streamHeaders = <String, String>{
      ...authHeaders,
      'Range': 'bytes=0-2097151',
    };

    VideoPlayerController? controller;
    try {
      if(kIsWeb) {
        if(isPreloadOnly) {
          _isPreparing = false;
          if(mounted) setState(() {});
          return;
        }
        final String? blobUrl = await web_video.fetchVideoAsBlobUrl(streamUrl, authHeaders);
        if(blobUrl == null || blobUrl.isEmpty) {
          _isPreparing = false;
          _hasVideoError = true;
          if(mounted) setState(() {});
          return;
        }
        _webBlobUrl = blobUrl;
        controller = VideoPlayerController.networkUrl(Uri.parse(blobUrl));
      } else {
      final FileInfo? cached = await _reelVideoCache.getFileFromCache(streamUrl);
      if(cached != null && cached.file.existsSync()) {
        controller = VideoPlayerController.file(cached.file);
      } else if(isPreloadOnly) {
        try {
          final File file = await _reelVideoCache.getSingleFile(
            streamUrl, headers: authHeaders,
          );
          controller = VideoPlayerController.file(file);
        } catch (_) {
          controller = VideoPlayerController.networkUrl(
            Uri.parse(streamUrl), httpHeaders: streamHeaders,
          );
        }
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(streamUrl), httpHeaders: streamHeaders,
        );
        _reelVideoCache
            .downloadFile(streamUrl, authHeaders: authHeaders)
            .ignore();
      }
      }

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_isReelMuted.value ? 0.0 : 1.0);
      if(_savedPosition > Duration.zero && _savedPosition < controller.value.duration) {
        await controller.seekTo(_savedPosition);
      }
      if(_shouldPlayWhenReady) {
        await controller.play();
      }
      _videoController = controller;
      _hasVideoError = false;
    } catch (e) {
      debugPrint('=======> ReelDetails: Video controller error: $e');
      await controller?.dispose();
      _hasVideoError = true;
    } finally {
      _isPreparing = false;
      if(mounted) setState(() {});
    }
  }

  Future<void> _togglePlayback() async {
    if(_videoController == null) {
      return;
    }
    if(_videoController!.value.isPlaying) {
      await _videoController!.pause();
    } else {
      await _videoController!.play();
    }
    if(mounted) {
      setState(() {});
    }
  }

  void _disposeController() {
    final VideoPlayerController? controller = _videoController;
    _videoController = null;
    if(controller != null) {
      if(controller.value.isInitialized) {
        _savedPosition = controller.value.position;
      }
      controller.pause();
      controller.dispose();
    }
    if(_webBlobUrl != null) {
      web_video.revokeBlobUrl(_webBlobUrl!);
      _webBlobUrl = null;
    }
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    final int hours = duration.inHours;

    if(hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _buildStreamUrl() {
    if(widget.reel.resolvedVideoUrl.isNotEmpty) {
      return widget.reel.resolvedVideoUrl;
    }

    if(widget.reel.reelId == null) {
      return '';
    }

    final String guestId = AuthHelper.getGuestId();
    final bool appendGuestId = !AuthHelper.isLoggedIn() && guestId.isNotEmpty;
    return '${AppConstants.baseUrl}${AppConstants.reelDetailsUri}?reel_id=${widget.reel.reelId}&stream=1${appendGuestId ? '&guest_id=$guestId' : ''}';
  }

  @override
  void dispose() {
    _isReelMuted.removeListener(_handleMuteChanged);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showVideo = widget.isActive && _videoController != null && _videoController!.value.isInitialized && !_hasVideoError;

    return SafeArea(
      child: GestureDetector(
        onTap: _togglePlayback,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: _ReelDetailsMedia(
                reel: widget.reel,
                controller: _videoController,
                showVideo: showVideo,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.30),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const <double>[0, 0.28, 0.72, 1],
                  ),
                ),
              ),
            ),
            if(!widget.isDesktop)
              Positioned(
                right: Dimensions.paddingDefault,
                bottom: 150,
                child: _ReelLikeViewStats(reel: widget.reel, iconColor: Colors.white, textColor: Colors.white),
              ),
            Positioned(
              left: Dimensions.paddingDefault,
              right: Dimensions.paddingDefault,
              bottom: Dimensions.paddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: widget.isDesktop ? 0 : 0),
                    child: InkWell(
                      onTap: _onStoreTap,
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Row(
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1),
                                ),
                                child: ClipOval(
                                  child: CustomImageWidget(image: widget.reel.resolvedLogoUrl, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),
                              Flexible(
                                child: Text(
                                  widget.reel.resolvedSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.subHeading.defaultSize.medium.overrideWith(color: Colors.white),
                                ),
                              ),
                              if(widget.reel.verifiedSeller == 1) ...<Widget>[
                                const SizedBox(width: Dimensions.padding2xSmall),
                                const RestaurantVerifiedIconWidget(),
                              ],

                            ],
                          )),

                         if(widget.reel.orderNowButton == true) CustomButtonWidget(
                            takeMinimumWidth: true,
                            height: 40,
                            buttonText: 'order_now'.tr,
                            isLoading: _isFetchingProduct,
                            onPressed: _isFetchingProduct ? null : () => _onOrderNowTap(widget.reel),
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSmall),
                  Padding(
                    padding: EdgeInsets.only(right: widget.isDesktop ? 0 : 53.0),
                    child: Text(
                      widget.reel.resolvedDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.body.extraSmall.regular.overrideWith(color: Colors.white.withValues(alpha: 0.92)).copyWith(height: 1.3),
                    ),
                  ),
                  if(_videoController != null && _videoController!.value.isInitialized) ...<Widget>[
                    const SizedBox(height: Dimensions.paddingDefault),
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _videoController!,
                      builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
                        final Duration currentPosition = value.position;
                        final Duration totalDuration = value.duration;
                        final bool hasDuration = totalDuration.inMilliseconds > 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                  padding: EdgeInsets.zero,
                                  colors: VideoProgressColors(
                                    playedColor: Colors.white,
                                    bufferedColor: Colors.white.withValues(alpha: 0.35),
                                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.padding2xSmall),
                            Row(
                              children: <Widget>[
                                Text(
                                  _formatDuration(currentPosition),
                                  style: context.body.extraSmall.regular.overrideWith(color: Colors.white.withValues(alpha: 0.92)),
                                ),
                                const Spacer(),
                                Text(
                                  hasDuration ? _formatDuration(totalDuration) : '--:--',
                                  style: context.body.extraSmall.regular.overrideWith(color: Colors.white.withValues(alpha: 0.92)),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
                ),
              ),
            if(_isPreparing)
              const Center(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                ),
              )
            else if(_videoController != null && _videoController!.value.isInitialized)
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _videoController!,
                builder: (BuildContext ctx, VideoPlayerValue val, Widget? _) {
                  if(val.isBuffering) {
                    return const Center(
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      ),
                    );
                  }
                  if(widget.isActive && !val.isPlaying) {
                    return Center(
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ReelDetailsMedia extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController? controller;
  final bool showVideo;
  const _ReelDetailsMedia({
    required this.reel,
    required this.controller,
    required this.showVideo,
  });

  @override
  Widget build(BuildContext context) {
    if(showVideo && controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller!.value.size.width,
          height: controller!.value.size.height,
          child: VideoPlayer(controller!),
        ),
      );
    }

    if(reel.resolvedThumbnailUrl.isNotEmpty) {
      return CustomImageWidget(image: reel.resolvedThumbnailUrl, fit: BoxFit.cover);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            context.primary.withValues(alpha: 0.18),
            context.primary.withValues(alpha: 0.75),
          ],
        ),
      ),
    );
  }
}

class _ReelLikeViewStats extends StatelessWidget {
  final ReelModel reel;
  final Color iconColor;
  final Color textColor;
  const _ReelLikeViewStats({
    required this.reel,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReelsController>(
      builder: (ReelsController reelsController) {
        final int? reelId = reel.reelId;
        final ReelStatsModel? fetchedStats = reelId != null ? reelsController.getReelStatsFromMap(reelId) : null;
        final bool isStatsLoading = reelId != null && reelsController.isReelStatsLoading(reelId) && fetchedStats == null;
        final int likes = fetchedStats?.totalLikes ?? reel.stats?.totalLikes ?? 0;
        final int views = fetchedStats?.totalViews ?? reel.stats?.totalViews ?? 0;

        final bool isLiked = reelId != null && reelsController.isReelLiked(reelId);
        final bool isLikeBusy = reelId != null && reelsController.isReelLikeBusy(reelId);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: (reelId == null || isLikeBusy)
                  ? null
                  : () => reelsController.toggleReelLike(reelId),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isStatsLoading ? '0' : ReelModel.compactCount(likes),
              style: context.body.extraSmall.regular.overrideWith(color: textColor),
            ),
            const SizedBox(height: 18),
            Icon(Icons.remove_red_eye_outlined, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              isStatsLoading ? '0' : ReelModel.compactCount(views),
              style: context.body.extraSmall.regular.overrideWith(color: textColor),
            ),
          ],
        );
      },
    );
  }
}

class _ReelMuteButton extends StatelessWidget {
  const _ReelMuteButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isReelMuted,
      builder: (BuildContext context, bool isMuted, Widget? child) {
        return InkWell(
          onTap: () => _isReelMuted.value = !isMuted,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
